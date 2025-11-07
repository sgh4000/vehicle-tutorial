#!/usr/bin/env python3
# Breast Cancer — robust NN: normalize inputs (StandardScaler), class weights, early stop, threshold tune (safe), ONNX + CM
# Also saves scaler params (mu, sigma) for Vehicle.

import os, json
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
os.environ.setdefault("CUDA_VISIBLE_DEVICES", "")

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.preprocessing import StandardScaler
from sklearn.utils.class_weight import compute_class_weight

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, Sequential
from tensorflow.keras.layers import Dense
import tf2onnx  # pip install tf2onnx

# ---- Hardcoded paths (EDIT if needed) ----
CSV_PATH   = "/home/mohammad/D2AIR/vehicle-tutorial/exercises/breast_cancer/BreastCancer.csv"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ONNX_PATH  = os.path.join(SCRIPT_DIR, "breast_cancer_model.onnx")
SCALER_JSON_PATH = os.path.join(SCRIPT_DIR, "breast_cancer_scaler.json")

np.random.seed(42)
tf.random.set_seed(42)

LABEL_CANDIDATES = [
    "diagnosis", "Diagnosis",
    "Class", "class",
    "target", "Target",
    "label", "Label",
    "Outcome", "outcome"
]

def pick_label_column(df: pd.DataFrame) -> str:
    for c in LABEL_CANDIDATES:
        if c in df.columns:
            return c
    return df.columns[-1]

def to_binary_labels(y_raw: pd.Series) -> np.ndarray:
    # String/categorical: e.g., 'B'/'M' -> B=0, M=1
    if y_raw.dtype == object or y_raw.dtype.name == "category":
        uniq_lower = {str(v).lower() for v in pd.unique(y_raw)}
        if uniq_lower <= {"b", "m"}:
            return (y_raw.astype(str).str.upper() == "M").astype(np.int64).to_numpy()

    # Numeric: sometimes {2,4} with 4=malignant
    y_num = pd.to_numeric(y_raw, errors="coerce")
    if not np.any(np.isnan(y_num)):
        uniq = set(np.unique(y_num))
        if uniq == {2, 4}:
            return (y_num == 4).astype(np.int64).to_numpy()
        return (y_num > 0.5).astype(np.int64).to_numpy()

    # Fallback: factorize to 0/1 (try to map malignant-like terms to 1)
    codes, uniques = pd.factorize(y_raw)
    pos_idx = None
    for i, u in enumerate(uniques):
        s = str(u).lower()
        if s in ("m", "malignant", "recurrence", "present", "yes", "1", "true"):
            pos_idx = i
            break
    if pos_idx is not None:
        return (codes == pos_idx).astype(np.int64)
    return (codes == 1).astype(np.int64)

def main():
    # Load
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"CSV not found: {CSV_PATH}")
    df = pd.read_csv(CSV_PATH)

    label_col = pick_label_column(df)
    if label_col not in df.columns:
        raise ValueError("Could not determine label column.")

    y = to_binary_labels(df[label_col])
    Xdf = df.drop(columns=[label_col]).copy()

    # Drop typical non-feature identifiers if present
    for col in ["id", "ID", "Unnamed: 32"]:
        if col in Xdf.columns:
            Xdf.drop(columns=[col], inplace=True)

    # One-hot encode any remaining categoricals (rare)
    non_num = Xdf.select_dtypes(include=["object", "category"]).columns.tolist()
    if non_num:
        Xdf = pd.get_dummies(Xdf, columns=non_num, drop_first=True)

    # Ensure numeric dtype
    Xdf = Xdf.apply(pd.to_numeric, errors="coerce")

    # Split: test once, then carve validation from train
    Xdf_train, Xdf_test, y_train_full, y_test = train_test_split(
        Xdf, y, test_size=0.3, random_state=42, stratify=y
    )
    Xdf_tr, Xdf_val, y_tr, y_val = train_test_split(
        Xdf_train, y_train_full, test_size=0.3, random_state=42, stratify=y_train_full
    )

    # Median imputation from train medians if NaNs exist
    if Xdf_tr.isna().any().any():
        med = Xdf_tr.median(numeric_only=True)
        Xdf_tr  = Xdf_tr.fillna(med)
        Xdf_val = Xdf_val.fillna(med)
        Xdf_test= Xdf_test.fillna(med)

    # --------- NORMALIZE (fit on TRAIN only) ----------
    scaler = StandardScaler()
    X_tr  = scaler.fit_transform(Xdf_tr.values).astype(np.float32)
    X_val = scaler.transform(Xdf_val.values).astype(np.float32)
    X_te  = scaler.transform(Xdf_test.values).astype(np.float32)

    # Save scaler stats for Vehicle (so you can apply same affine map)
    mu = scaler.mean_.astype(np.float32).tolist()
    sigma = scaler.scale_.astype(np.float32).tolist()
    with open(SCALER_JSON_PATH, "w") as f:
        json.dump({
            "feature_names": Xdf_tr.columns.tolist(),
            "mean": mu,
            "scale": sigma
        }, f, indent=2)

    # Class weights from y_tr
    classes = np.unique(y_tr)
    class_weights = compute_class_weight(class_weight="balanced", classes=classes, y=y_tr)
    class_weight_dict = dict(zip(classes.tolist(), class_weights.tolist()))

    # Model (compact) — logits output (no activation)
    n_features = X_tr.shape[1]
    model = Sequential([
        Dense(16, activation='relu', input_shape=(n_features,)),
        Dense(16, activation='relu'),
        Dense(2)
    ])
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=5e-4),
        loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"]
    )
    callbacks = [
        keras.callbacks.EarlyStopping(monitor="val_loss", patience=15, restore_best_weights=True, min_delta=1e-4),
        keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=5, min_lr=1e-5, verbose=0),
    ]

    # Train with explicit validation set
    model.fit(
        X_tr, y_tr,
        validation_data=(X_val, y_val),
        epochs=50,
        batch_size=10,
        class_weight=class_weight_dict,
        callbacks=callbacks,
        verbose=1
    )

    # ---- Probabilities for class 1 (safe softmax)
    def probs_class1(X: np.ndarray) -> np.ndarray:
        logits = model.predict(X, verbose=0)             # (N, 2)
        probs = tf.nn.softmax(logits, axis=1).numpy()    # (N, 2)
        return probs[:, 1].astype(np.float32)            # (N,)

    # ---- Tune threshold on validation for best accuracy (scalar thresholds only)
    y_val_1d = np.asarray(y_val, dtype=np.int64).ravel()
    p_val    = np.asarray(probs_class1(X_val), dtype=np.float32).ravel()
    assert p_val.shape[0] == y_val_1d.shape[0], (p_val.shape, y_val_1d.shape)

    thresholds = np.linspace(0.2, 0.8, 121).astype(np.float32)
    best_thr, best_val_acc = 0.5, -1.0
    for t in thresholds:
        pred_val = (p_val >= t).astype(np.int64)   # (N,)
        acc = accuracy_score(y_val_1d, pred_val)
        if acc > best_val_acc:
            best_val_acc, best_thr = acc, float(t)

    # ---- Final evaluation on train/test with tuned threshold
    y_tr_1d = np.asarray(y_tr,  dtype=np.int64).ravel()
    y_te_1d = np.asarray(y_test, dtype=np.int64).ravel()

    p_tr = probs_class1(X_tr)
    p_te = probs_class1(X_te)

    pred_tr = (p_tr >= best_thr).astype(np.int64)
    pred_te = (p_te >= best_thr).astype(np.int64)

    train_acc = accuracy_score(y_tr_1d, pred_tr)
    test_acc  = accuracy_score(y_te_1d, pred_te)

    # ---- ONNX export (Keras 3–safe)
    spec = [tf.TensorSpec([None, n_features], tf.float32, name="input")]
    @tf.function(input_signature=spec)
    def serving_fn(x):
        return model(x, training=False)
    onnx_model, _ = tf2onnx.convert.from_function(serving_fn, input_signature=spec, opset=13)
    with open(ONNX_PATH, "wb") as f:
        f.write(onnx_model.SerializeToString())

    # Minimal prints (plus where scaler is saved)
    print(f"label={label_col}")
    print(f"class_weights={class_weight_dict}")
    print(f"val_best_threshold={best_thr:.3f}  val_accuracy={best_val_acc:.4f}")
    print(f"train_accuracy={train_acc:.4f}")
    print(f"test_accuracy={test_acc:.4f}")
    print(f"onnx={ONNX_PATH}")
    print(f"scaler_json={SCALER_JSON_PATH}")

    # ---- Confusion matrix (test)
    cm = confusion_matrix(y_te_1d, pred_te, labels=[0, 1])
    plt.figure()
    im = plt.imshow(cm, interpolation="nearest")
    plt.title("Confusion Matrix — Test")
    plt.colorbar(im, fraction=0.046, pad=0.04)
    ticks = np.arange(2)
    plt.xticks(ticks, ["class 0", "class 1"], rotation=45)
    plt.yticks(ticks, ["class 0", "class 1"])
    thr = cm.max() / 2.0
    for i in range(2):
        for j in range(2):
            plt.text(j, i, int(cm[i, j]),
                     ha="center", va="center",
                     color="white" if cm[i, j] > thr else "black")
    plt.ylabel("True label")
    plt.xlabel("Predicted label")
    plt.tight_layout()
    plt.show()
        
    # ---- ONE BIG FIGURE: Raw feature vs TRUE label (0/1), one subplot per feature
    feature_names = Xdf_test.columns.tolist()

    # ensure arrays are 1-D
    y_te_1d = np.asarray(y_te_1d, dtype=np.int64).ravel()

    n_feats = len(feature_names)
    if n_feats == 0:
        print("No features to plot.")
    else:
        # grid layout
        n_cols = 4  # tweak columns if you like
        n_rows = int(np.ceil(n_feats / n_cols))

        fig, axes = plt.subplots(n_rows, n_cols, figsize=(4.5 * n_cols, 3.0 * n_rows), squeeze=False)
        fig.suptitle("Raw Feature Value vs True Label (0/1)", y=0.995, fontsize=14)

        # shared settings
        y_min, y_max = -0.3, 1.3
        jitter = 0.06  # vertical jitter so overlapping 0/1 points are visible
        point_size = 14
        alpha = 0.6

        # simple color mapping by true label
        colors = np.array(["tab:blue", "tab:red"])  # 0 -> blue, 1 -> red

        for idx, fname in enumerate(feature_names):
            r = idx // n_cols
            c = idx % n_cols
            ax = axes[r, c]

            x_raw = Xdf_test[fname].to_numpy()
            # keep rows where both x and y are finite
            mask = np.isfinite(x_raw) & np.isfinite(y_te_1d)
            x = x_raw[mask]
            y = y_te_1d[mask]

            if x.size < 5 or np.nanmin(x) == np.nanmax(x):
                ax.set_title(f"{fname} (insufficient spread)")
                ax.axis("off")
                continue

            # add a tiny vertical jitter around 0 or 1 so points don't sit on a line
            rng = np.random.default_rng(42 + idx)
            y_j = y + rng.uniform(-jitter, jitter, size=y.shape)

            # scatter each point; color by its true label
            ax.scatter(x, y_j, s=point_size, alpha=alpha, c=colors[y], edgecolors="none")

            ax.set_ylim(y_min, y_max)
            ax.set_yticks([0, 1])
            ax.set_xlabel(f"{fname} (raw)")
            ax.set_ylabel("True label (0/1)")
            ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.5)

            if idx == 0:
                # tiny legend once
                from matplotlib.lines import Line2D
                legend_elems = [
                    Line2D([0], [0], marker='o', color='w', label='Label 0',
                        markerfacecolor='tab:blue', markersize=6),
                    Line2D([0], [0], marker='o', color='w', label='Label 1',
                        markerfacecolor='tab:red', markersize=6)
                ]
                ax.legend(handles=legend_elems, loc="upper right", frameon=True)

        # turn off any empty axes
        for j in range(n_feats, n_rows * n_cols):
            r = j // n_cols
            c = j % n_cols
            axes[r, c].axis("off")

        plt.tight_layout(rect=[0, 0, 1, 0.98])
        plt.show()


if __name__ == "__main__":
    main()

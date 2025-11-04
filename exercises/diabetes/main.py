#!/usr/bin/env python3
# Pima Indians Diabetes — minimal NN: train + ONNX + show confusion matrix (+ class weights)

import os
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

# ---- Hardcoded paths (edit if needed) ----
CSV_PATH   = "/home/mohammad/D2AIR/vehicle-tutorial/exercises/diabetes/pima-indians-diabetes.csv"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ONNX_PATH  = os.path.join(SCRIPT_DIR, "pima_model.onnx")

np.random.seed(42)
tf.random.set_seed(42)

def pick_label_column(df: pd.DataFrame) -> str:
    # Prefer common names; else last column
    candidates = ["Outcome", "outcome", "Class", "class", "diabetes", "Diabetes", "target", "DEATH_EVENT"]
    for c in candidates:
        if c in df.columns:
            return c
    return df.columns[-1]

def main():
    # Load
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"CSV not found: {CSV_PATH}")
    df = pd.read_csv(CSV_PATH)

    label_col = pick_label_column(df)
    if label_col not in df.columns:
        raise ValueError("Could not determine label column.")

    # X/y
    X = df.drop(columns=[label_col]).to_numpy(dtype=np.float32)
    y = df[label_col].to_numpy()
    # ensure integer binary labels
    if y.dtype.kind in "fc":
        y = (y > 0.5).astype(np.int64)
    else:
        y = y.astype(np.int64)

    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # Scale (fit on train)
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train).astype(np.float32)
    X_test  = scaler.transform(X_test).astype(np.float32)

    # ---- Class weights (computed from y_train)
    classes = np.unique(y_train)
    class_weights = compute_class_weight(class_weight="balanced", classes=classes, y=y_train)
    class_weight_dict = dict(zip(classes.tolist(), class_weights.tolist()))
    # e.g., {0: 0.7..., 1: 1.3...} depending on imbalance

    # Model: 32-16-2 logits
    n_features = X_train.shape[1]
    model = Sequential([
        Dense(16, activation='relu', input_shape=(n_features,)),
        Dense(8, activation='relu'),
        Dense(2)  # logits for classes {0,1}
    ])
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-3),
        loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"]
    )

    # Train — with class weights; shows epoch bar
    model.fit(
        X_train, y_train,
        validation_split=0.2,
        epochs=300,
        batch_size=16,
        class_weight=class_weight_dict,
        verbose=1
    )

    # Accuracy (train/test)
    def split_acc(X, y):
        logits = model.predict(X, verbose=0)
        preds = np.argmax(logits, axis=1)
        return accuracy_score(y, preds), preds

    train_acc, _         = split_acc(X_train, y_train)
    test_acc, preds_test = split_acc(X_test,  y_test)

    # ---- ONNX export from a concrete function (Keras 3–safe)
    spec = [tf.TensorSpec([None, n_features], tf.float32, name="input")]
    @tf.function(input_signature=spec)
    def serving_fn(x):
        return model(x, training=False)
    onnx_model, _ = tf2onnx.convert.from_function(serving_fn, input_signature=spec, opset=13)
    with open(ONNX_PATH, "wb") as f:
        f.write(onnx_model.SerializeToString())

    # Minimal prints
    print(f"label={label_col}")
    print(f"class_weights={class_weight_dict}")
    print(f"train_accuracy={train_acc:.4f}")
    print(f"test_accuracy={test_acc:.4f}")
    print(f"onnx={ONNX_PATH}")

    # ---- Show confusion matrix (no file saved)
    cm = confusion_matrix(y_test, preds_test, labels=[0, 1])
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

if __name__ == "__main__":
    main()
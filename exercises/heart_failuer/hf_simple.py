#!/usr/bin/env python3
# Heart Failure NN (minimal) — train + export ONNX from the trained model (no leftovers)

import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
os.environ.setdefault("CUDA_VISIBLE_DEVICES", "")

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import tf2onnx  # ensure installed

from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dense

import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix



# ---- Hardcoded paths ----
CSV_PATH   = "/home/mohammad/D2AIR/vehicle-tutorial/exercises/heart_failuer/heart_failure_clinical_records_dataset.csv"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ONNX_PATH  = os.path.join(SCRIPT_DIR, "hf_model.onnx")  

np.random.seed(42)
tf.random.set_seed(42)

def main():
    # Load
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"CSV not found: {CSV_PATH}")
    df = pd.read_csv(CSV_PATH)
    if "DEATH_EVENT" not in df.columns:
        raise ValueError("Expected 'DEATH_EVENT' column in the CSV.")

    X = df.drop(columns=["DEATH_EVENT"]).to_numpy(dtype=np.float32)
    y = df["DEATH_EVENT"].to_numpy(dtype=np.int64)

    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # Scale features (cast back to float32!)
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train).astype(np.float32)
    X_test  = scaler.transform(X_test).astype(np.float32)

    # Keep these for Vehicle (same affine map)
    mu = scaler.mean_.astype(np.float32)
    sigma = scaler.scale_.astype(np.float32)

    # Model: 2 logits (no activation)
    n_features = X_train.shape[1]
    model = Sequential([
        Dense(32, activation='relu', input_shape=(n_features,)),
        Dense(8, activation='relu'),
        Dense(2)
    ])
    
    model.summary

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-3),
        loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"]
    )

    # Train — progress bar only
    model.fit(X_train, y_train, validation_split=0.2, epochs=100, batch_size=16, verbose=1)

    # Accuracies only
    def split_acc(X, y):
        logits = model.predict(X, verbose=0)
        preds = np.argmax(logits, axis=1)
        return accuracy_score(y, preds)

    train_acc = split_acc(X_train, y_train)
    test_acc  = split_acc(X_test,  y_test)

    # ---- ONNX export from trained model (stable for Keras 3)
    # Concrete serving function with training=False
    spec = [tf.TensorSpec([None, n_features], tf.float32, name="input")]

    @tf.function(input_signature=spec)
    def serving_fn(x):
        return model(x, training=False)

    onnx_model, _ = tf2onnx.convert.from_function(
        serving_fn,
        input_signature=spec,
        opset=13,
    )

    # Write ONNX next to this script (use ONNX_PATH consistently)
    with open(ONNX_PATH, "wb") as f:
        f.write(onnx_model.SerializeToString())

    # Final minimal prints
    print(f"train_accuracy={train_acc:.4f}")
    print(f"test_accuracy={test_acc:.4f}")
    print(f"onnx={ONNX_PATH}")

    # ---- Confusion matrix (display only) ----
    logits_test = model.predict(X_test, verbose=0)
    preds_test = np.argmax(logits_test, axis=1)
    cm = confusion_matrix(y_test, preds_test, labels=[0, 1])

    plt.figure()
    im = plt.imshow(cm, interpolation="nearest")
    plt.title("Confusion Matrix — Test")
    plt.colorbar(im, fraction=0.046, pad=0.04)
    tick_marks = np.arange(2)
    plt.xticks(tick_marks, ["survive(0)", "death(1)"], rotation=45)
    plt.yticks(tick_marks, ["survive(0)", "death(1)"])

    # annotate counts
    thresh = cm.max() / 2.0
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            plt.text(j, i, format(cm[i, j], "d"),
                    ha="center", va="center",
                    color="white" if cm[i, j] > thresh else "black")

    plt.ylabel("True label")
    plt.xlabel("Predicted label")
    plt.tight_layout()
    plt.show()


    # (Optional) print scaler constants to copy into Vehicle
    # print("mu =", mu.tolist())
    # print("sigma =", sigma.tolist())

if __name__ == "__main__":
    main()

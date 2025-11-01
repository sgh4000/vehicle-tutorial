import numpy as np
import idx2numpy
import pandas as pd
from pathlib import Path

root = Path("/home/mohammad/D2AIR/vehicle-tutorial/exercises/iris-dataset")

def to_native_endian(a: np.ndarray) -> np.ndarray:
    # No-op if already native (byteorder '=' or '|')
    if a.dtype.byteorder in ('=', '|'):
        return a
    # Otherwise convert big- or little-endian to native
    return a.byteswap().newbyteorder()

# --- load ---
X = idx2numpy.convert_from_file(str(root / "iris_test_data.idx"))
y = idx2numpy.convert_from_file(str(root / "iris_test_label.idx"))

# --- normalize endianness ---
X = to_native_endian(np.asarray(X))
y = to_native_endian(np.asarray(y))

# --- shape to (N, features) + (N,) ---
X2 = X.reshape(X.shape[0], -1).astype(np.float64, copy=False)  # force a standard float dtype
assert X2.shape[1] == 4, f"Expected 4 features, got {X2.shape[1]}"

# handle one-hot or flat labels → (N,)
if y.ndim == 1:
    y1 = y
elif y.ndim == 2 and 3 in y.shape:
    y1 = y.argmax(axis=list(y.shape).index(3))
else:
    y1 = y.reshape(-1)
y1 = np.asarray(y1, dtype=np.int64)  # standard int dtype

# --- nice columns & label mapping ---
feature_cols = ["sepal_length", "sepal_width", "petal_length", "petal_width"]
CLASS_NAMES  = {0: "setosa", 1: "versicolor", 2: "virginica"}
CLASS_ORDER  = ["setosa", "versicolor", "virginica"]

# --- dataframe ---
df = pd.DataFrame(X2, columns=feature_cols)
df["label"] = y1
df["label_name"] = pd.Categorical(
    [CLASS_NAMES.get(int(i), f"cls_{int(i)}") for i in y1],
    categories=CLASS_ORDER,
    ordered=True,
)

# --- sort & write ---
df_sorted = df.sort_values(["label_name", "sepal_length"], kind="stable").reset_index(drop=True)
out = root / "iris_test_joint.csv"
df_sorted.to_csv(out, index=False)
print("Wrote", out, "with shape", df_sorted.shape)
print(df_sorted["label_name"].value_counts(sort=False))

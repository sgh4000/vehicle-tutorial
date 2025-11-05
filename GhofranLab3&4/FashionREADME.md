# FMNIST robustness example

Fashion-MNIST is a dataset that contains 28×28 grayscale images of 10 clothing categories, such as T-shirts, trousers, coats, and shoes.
Each image is labeled with one of ten fashion classes (0–9).

This verification experiment uses:

- **Specification file:** fashionRobustness.vcl
- **Neural network model:** fashion1l32n.onnx
- **Datasets:** Individual test samples, each .idx image file contains one 28×28 FMNIST image, and each label file contains its corresponding category.
The larger combined dataset (like 0–49Images.idx and 0–49Labels.idx) caused memory issues when verified with Marabou, leading the process to be killed automatically.
Because of that, each image was verified individually (picked the first 5 images) to ensure successful and stable verification runs.
  * Image0.idx, Label0.idx
  * Image1.idx, Label1.idx
  * Image2.idx, Label2.idx
  * Image3.idx, Label3.idx
  * Image4.idx, Label4.idx


Run commands (pick the property you want):

```bash
# The same command was repeated for the other image–label pairs (Image0–Image4).
# Classification Robustness (L∞):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:Image0.idx \
  --dataset trainingLabels:Label0.idx \
  --parameter epsilon:0.005 \
  --property robust \
  --verifier Marabou

# Strong Classification Robustness (L∞):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:Image0.idx \
  --dataset trainingLabels:Label0.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.1 \
  --property robustStrong \
  --verifier Marabou

# Classification Robustness (L2):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:Image0.idx \
  --dataset trainingLabels:Label0.idx \
  --parameter epsilon2:0.1 \
  --property robustL2 \
  --verifier Marabou
```

### Verification Results  

| **Image** | **Property Tested** | **Type of Robustness** | **Result** | **Meaning of Result** |
|:-----------|:-------------------:|:-----------------------:|:------------:|:----------------------|
| Image 0 | `robust` | **Classification Robustness (L∞)** | ✅ Marabou proved no counterexample exists | The model keeps the same label even when pixels change slightly within ε (0.005). |
| Image 0 | `robustStrong` | **Strong Classification Robustness (L∞)** | ✅ Marabou proved no counterexample exists | The model keeps the same label **and** confidence above η (0.1). |
| Image 0 | `robustL2` | **Classification Robustness (L2)** | ✅ Marabou proved no counterexample exists | The model stays stable for small pixel changes measured by Euclidean (L2) distance. |
| Image 1 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Predictions stayed consistent under small perturbations. |
| Image 2 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Predictions didn’t change under small pixel shifts. |
| Image 3 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Classifier remained robust and confident. |
| Image 4 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Network proved stable and reliable for minor input changes. |





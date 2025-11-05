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

## Verification Results and Interpretation


After running the code we got for different definitions of robustness:

| **Image** | **Property Tested** | **Type of Robustness** | **Result** | **Meaning of Result** |
|:-----------|:-------------------:|:-----------------------:|:------------:|:----------------------|
| Image0 | `robust` | Classification Robustness (L∞) | ✅ Marabou proved no counterexample exists | The model keeps the same label even when pixels change slightly within ε (0.005). |
| Image0 | `robustStrong` | Strong Classification Robustness (L∞) | ✅ Marabou proved no counterexample exists | The model keeps the same label and confidence above η (0.1). |
| Image0 | `robustL2` | Classification Robustness (L2) | ✅ Marabou proved no counterexample exists | The model stays stable for small pixel changes measured by Euclidean (L2) distance. |
| Image1 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Predictions stayed consistent under small perturbations. |
| Image2 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Predictions didn’t change under small pixel shifts. |
| Image3 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Classifier remained robust and confident. |
| Image4 | _same 3 properties_ | _(same as above)_ | ✅ Verified for all | Network proved stable and reliable for minor input changes. |

**Interpretation:** All five tested images showed the same results across the three robustness types.
This means the model behaves consistently for these samples:
- For Classification Robustness (L∞), the model’s predictions stayed the same even with very small pixel changes.
- For Strong Classification Robustness (L∞), it also kept a good confidence level (above η = 0.1).
- For Classification Robustness (L2), it remained stable when changes were measured using the Euclidean distance instead of the infinity norm.

Overall, these results suggest the Fashion-MNIST model is robust and confident against small image noise for these images.


### Classification Robustness (L∞) for Image0 across four ε values:

| **ε** | **Result** | **Meaning** | **Notes (from Marabou)** |
|:------:|:------:|:--------|:---------------------|
| 0.01 | ✅ Verified | No counterexample within ε=0.01 — prediction is stable to very small pixel changes. | `robust!0` proved. |
| 0.05 | ✗ Falsified | A counterexample exists within ε=0.05 — small changes can flip the label. | Marabou returned a specific perturbation (values around ±0.05). |
| 0.10 | ✗ Falsified | A counterexample exists within ε=0.10 — larger allowed changes flip the label. | Marabou returned a specific perturbation (values around ±0.1). |
| 0.50 | ✗ Falsified | A counterexample exists within ε=0.50 — very large changes easily flip the label. | Marabou returned a specific perturbation (values around ±0.5). |

**Interpretation:** robustness holds for tiny noise (ε=0.01), but breaks once the  per-pixel change grows beyond ε≥0.05. It's important to note that I've got the same results for the rest of images (1-4) when testing theie robustness across the same differnt values of ε used for Image0.





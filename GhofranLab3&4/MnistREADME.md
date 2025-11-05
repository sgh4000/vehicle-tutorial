# MNIST robustness example

This is an example of a specification for the widely studied adversarial robustness problem.
At a high-level the specification states that any small small pertubation to the input, e.g. adjusting a few pixels, should not significantly change the output
of the network.

Although this example is specialised to image classification, in particular to the MNIST dataset, it should be relatively easy to tweak to other domains.

This folder contains the following files:

- `mnist-classifier.onnx` - the neural network used to implement the controller.

- `mnist-robustness.vcl` - the specification describing the desired behaviour.

- `t2-images.idx` - a dataset of input images. Doubles between 0.0 and 1.0 inclusive.

- `t2-labels.idx` - a dataset of output labels. Integers between 0 and 9 inclusive.

## Notes

1. The classifier is obtained from [here](https://github.com/onnx/models/blob/main/vision/classification/mnist/model/mnist-12.onnx).

2. The `.idx` files are obtained from [here](http://yann.lecun.com/exdb/mnist/).

3. Note that in the dataset available from the link above, pixels are stored as integers between 0 and 255. In the `idx` files in this folder, their values have been normalised to doubles between 0.0 and 1.0.

4. This specification is particularly expensive to verify (9 queries per image), and therefore the example datasets only contain 2 of the original 10000 test images.
The specification should work for the full dataset without any further changes, although expect verification to take a long time.

## Verifying using Marabou

The outputs of the above Vehicle commands can be found in the test suite:

A network can be verified against the specification by running the following command:

```bash
vehicle verify \
  --specification mnist-robust-Srobust.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.005 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou
```

Note that the epsilon value can be changed, but the memory requirements of Marabou may increase drastically as epsilon increases.


# Results and inteprtations:

## Standard Robustness (L∞ distance):

The property we are checking:
“If we make tiny changes (no bigger than epsilon) to each image, the network should still predict the same digit.”

After running robustness verification for two MNIST images (the first two in the dataset):


```bash
# eps = 0.005
Verifying properties:
  robust!0 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!1 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
robust:
    verified:  2/2
    falsified: 0/2
    timed-out: 0/2
    errored:   0/2
```
**Meaning:** Both of the tested images are robust, i.e. small pixel changes (within epsilon = 0.005) do not confuse the network. That means, the model’s predictions are stable and reliable against tiny noise or adversarial tweaks.

```bash
# eps = 0.01
Verifying properties:
  robust!0 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!1 [============>..........................................] 2/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/ghofran/.vehicle/reproducers/3245576383020918781

which can be run using:

  /home/ghofran/venv_vehicle/bin/Marabou /home/ghofran/.vehicle/reproducers/3245576383020918781/mnist-classifier.onnx /home/ghofran/.vehicle/reproducers/3245576383020918781/robust!1-query2.txt
robust:
    verified:  1/2
    falsified: 0/2
    timed-out: 0/2
    errored:   1/2

# eps = 0.05 or 0.1 or 0.5
Verifying properties:
  robust!0 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/ghofran/.vehicle/reproducers/3103867250748508961

which can be run using:

  /home/ghofran/venv_vehicle/bin/Marabou /home/ghofran/.vehicle/reproducers/3103867250748508961/mnist-classifier.onnx /home/ghofran/.vehicle/reproducers/3103867250748508961/robust!0-query1.txt
  robust!1 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/ghofran/.vehicle/reproducers/7225309814801678315

which can be run using:

  /home/ghofran/venv_vehicle/bin/Marabou /home/ghofran/.vehicle/reproducers/7225309814801678315/mnist-classifier.onnx /home/ghofran/.vehicle/reproducers/7225309814801678315/robust!1-query1.txt
robust:
    verified:  0/2
    falsified: 0/2
    timed-out: 0/2
    errored:   2/2
```
**Meaning:** 
1. For ε = 0.01:
- Image 0: Verified, the model stayed stable even with small pixel changes.
- Image 1: Error, Marabou stopped unexpectedly because it ran out of memory or hit a resource limit, not that the property failed.
2. For ε = 0.05, 0.1, and 0.5: both images failed to complete, Marabou ran out of memory again for all queries.
3. Conclusion: the network is robust for very small ε, but as ε grows, it becomes too complex for the solver because the model likely changes predictions more and the verification itself becomes computationally expensive.


## Strong Robustness (L∞ distance):
Strong Classification Robustness is similar to the normal robustness but here, we add an extra limit on the output score (the model’s confidence).

- **In normal robustness:** if we change the input image a little (within epsilon), the class label shouldn’t change.
- **In strong robustness:** if we change the input image a little (within epsilon), the class label shouldn’t change and the output score (the confidence) for that class should stay above a small threshold η.
- **ε** = how much we can change the image (the noise size).
- **η** = how much the output (confidence score) is allowed to change.

To run the Strong Classification Robustness property:
```bash
vehicle verify \
  --specification mnist-robust-Srobust.vcl \
  --network classifier:mnist-classifier.onnx \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.1 \
  --property robustStrong \
  --verifier Marabou
```
After running:
```bash
Verifying properties:
  robustStrong!0 [=================================================] 1/1 queries
    result: 🗸 - Marabou proved no counterexample exists
  robustStrong!1 [=================================================] 1/1 queries
    result: 🗸 - Marabou proved no counterexample exists
robustStrong:
    verified:  2/2
    falsified: 0/2
    timed-out: 0/2
    errored:   0/2
```
**Meaning:** For both images, no possible small change (within ε = 0.005) could make the network’s confidence in the correct label drop below η = 0.1.

## Standard Robustness (L2 distance):
We already defined robustness using the L∞ distance (each pixel can change at most ε up or down).
Now we redefine robustness using the Euclidean L2 distance (overall change in the whole image is ≤ ε).
- **L∞:** Each pixel can move up to ±ε.
- **L2:** All pixels together move less than ε₂.

True L2 uses squares and square-roots (non-linear), but Marabou only supports linear constraints. That's why we use a linear approximation of the L2 ball:

If the image dimension is 28×28 = 784 pixels, then ensuring
**|Δpixel| ≤ (ε₂ / √784) --> |Δpixel| ≤ (ε₂ / 28)** for every pixel guarantees that the L2 change ≤ ε₂.

To pick ε₂:
- Start small: 0.05 or 0.1.
- Remember that per-pixel bound becomes epsilon2 / 28, if ε₂=0.1 --> per-pixel limit ≈ 0.00357.

To run the Standard Robustness (L2) property:
```bash
vehicle verify \
  --specification mnist-robust-Srobust.vcl \
  --network classifier:mnist-classifier.onnx \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --parameter epsilon2:0.1 \
  --property robustL2 \
  --parameter eta:0.1 \
  --verifier Marabou
```


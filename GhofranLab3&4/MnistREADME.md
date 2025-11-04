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
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.005 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou
```

Note that the epsilon value can be changed, but the memory requirements of Marabou may increase drastically as epsilon increases.


## Results and inteprtations:

The property we are checking:
“If we make tiny changes (no bigger than epsilon) to each image, the network should still predict the same digit.”

After running robustness verification for two MNIST images (the first two in the dataset):


```bash
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

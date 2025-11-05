# FMNIST robustness example

Fashion-MNIST is a dataset that contains 28×28 grayscale images of 10 clothing categories, such as T-shirts, trousers, coats, and shoes.
Each image is labeled with one of ten fashion classes (0–9).

This verification experiment uses:

- Specification file: fashionRobustness.vcl
- Neural network model: fashion1l32n.onnx
- Datasets: Individual test samples, each .idx image file contains one 28×28 FMNIST image, and each label file contains its corresponding category.
The larger combined dataset (like 0–49Images.idx and 0–49Labels.idx) caused memory issues when verified with Marabou, leading the process to be killed automatically.
Because of that, each image was verified individually to ensure successful and stable verification runs.
  * Image0.idx, Label0.idx
  * Image1.idx, Label1.idx
  * Image2.idx, Label2.idx
  * Image3.idx, Label3.idx
  * Image4.idx, Label4.idx


Run commands (pick the property you want)

Classification Robustness (L∞):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:Image0.idx \
  --dataset trainingLabels:Label0.idx \
  --parameter epsilon:0.005 \
  --property robust \
  --verifier Marabou

Strong Classification Robustness (L∞):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:Image0.idx \
  --dataset trainingLabels:Label0.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.1 \
  --property robustStrong \
  --verifier Marabou

Classification Robustness (L2-style, conservative):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:Image0.idx \
  --dataset trainingLabels:Label0.idx \
  --parameter epsilon2:0.1 \
  --property robustL2 \
  --verifier Marabou


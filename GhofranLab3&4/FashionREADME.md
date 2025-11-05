Run commands (pick the property you want)

Classification Robustness (L∞):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:0-5Images.idx \
  --dataset trainingLabels:0-5Labels.idx \
  --parameter epsilon:0.005 \
  --property robust \
  --verifier Marabou

Strong Classification Robustness (L∞):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:0-49Images.idx \
  --dataset trainingLabels:0-49Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.1 \
  --property robustStrong \
  --verifier Marabou

Classification Robustness (L2-style, conservative):
vehicle verify \
  --specification fashionRobustness.vcl \
  --network classifier:fashion1l32n.onnx \
  --dataset trainingImages:0-49Images.idx \
  --dataset trainingLabels:0-49Labels.idx \
  --parameter epsilon2:0.1 \
  --property robustL2 \
  --verifier Marabou


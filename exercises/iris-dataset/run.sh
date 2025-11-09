vehicle verify \
  --specification iris_own_spec.vcl \
  --verifier Marabou \
  --network iris:iris_model.onnx \
  --property property1

vehicle verify \
  --specification iris_own_spec.vcl \
  --verifier Marabou \
  --network iris:iris_model.onnx \
  --property property2

vehicle verify \
  --specification iris_own_spec.vcl \
  --verifier Marabou \
  --network iris:iris_model.onnx \
  --property property3
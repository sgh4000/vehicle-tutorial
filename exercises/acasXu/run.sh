#!/bin/bash

<< com
vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_9.onnx \
  --property property3

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property3

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_7.onnx \
  --property property1

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_8.onnx \
  --property property1


vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_9.onnx \
  --property property1


vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property1

com

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property2


vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property4


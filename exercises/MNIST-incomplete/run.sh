#!/bin/bash

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.005 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou
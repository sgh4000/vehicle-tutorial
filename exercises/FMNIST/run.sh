#!/bin/bash

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.005 \
  --property robustRegular

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.005 \
  --property strongClassificationRobust
#!/bin/bash

# Epsilon ball size 0.005

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.005 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou

<<com

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

com

# Epsilon ball size 0.01

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.01 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou

<<com

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

com

# Epsilon ball size 0.05

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.05 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou

<<com



com

# Epsilon ball size 0.1

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.1 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou

<<com



com

# Epsilon ball size 0.5

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.5 \
  --dataset trainingImages:t2-images.idx \
  --dataset trainingLabels:t2-labels.idx \
  --verifier Marabou

<<com



com

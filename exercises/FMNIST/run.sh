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

<<com

robustRegular:
    verified:  84/100
    falsified: 16/100
    timed-out: 0/100
    errored:   0/100

com

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.005 \
  --property strongClassificationRobust \
  --property stronglyMaximal

<<com 

strongClassificationRobust:
    verified:  100/100
    falsified: 0/100
    timed-out: 0/100
    errored:   0/100

stronglyMaximal:
    verified:  84/100
    falsified: 16/100
    timed-out: 0/100
    errored:   0/100


com


vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.1 \
  --property strongClassificationRobust \
  --property stronglyMaximal

<<com

strongClassificationRobust:
    verified:  100/100
    falsified: 0/100
    timed-out: 0/100
    errored:   0/100

stronglyMaximal:
    verified:  83/100
    falsified: 17/100
    timed-out: 0/100
    errored:   0/100

com

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.2 \
  --property strongClassificationRobust \
  --property stronglyMaximal

<<com

strongClassificationRobust:
    verified:  100/100
    falsified: 0/100
    timed-out: 0/100
    errored:   0/100

stronglyMaximal:
    verified:  83/100
    falsified: 17/100
    timed-out: 0/100
    errored:   0/100


com

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.5 \
  --property strongClassificationRobust \
  --property stronglyMaximal

<<com

strongClassificationRobust:
    verified:  100/100
    falsified: 0/100
    timed-out: 0/100
    errored:   0/100

  stronglyMaximal:
    verified:  80/100
    falsified: 20/100
    timed-out: 0/100
    errored:   0/100

com

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.7 \
  --property strongClassificationRobust \
  --property stronglyMaximal

<<com

strongClassificationRobust:
    verified:  100/100
    falsified: 0/100
    timed-out: 0/100
    errored:   0/100

stronglyMaximal:
    verified:  78/100
    falsified: 22/100
    timed-out: 0/100
    errored:   0/100

com

vehicle \
  verify \
  --specification fmnist-own-solution.vcl \
  --verifier Marabou \
  --network fashionMnist:fashion1l32n.onnx \
  --dataset trainingImages:idxdata/0-99Images.idx \
  --dataset trainingLabels:idxdata/0-99Labels.idx \
  --parameter epsilon:0.005 \
  --parameter eta:0.8 \
  --property strongClassificationRobust \
  --property stronglyMaximal

<<com

strongClassificationRobust:
    verified:  100/100
    falsified: 0/100
    timed-out: 0/100
    errored:   0/100

  stronglyMaximal:
    verified:  77/100
    falsified: 23/100
    timed-out: 0/100
    errored:   0/100

com
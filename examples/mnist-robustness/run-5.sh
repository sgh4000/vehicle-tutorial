#!/bin/bash

########### Using 5 images and labels

# Epsilon ball size 0.005

<<com
vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.005 \
  --dataset trainingImages:5-images.idx \
  --dataset trainingLabels:5-labels.idx \
  --verifier Marabou



Verifying properties:
  robust!0 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!1 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!2 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!3 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!4 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
robust:
    verified:  5/5
    falsified: 0/5
    timed-out: 0/5
    errored:   0/5

com

# Epsilon ball size 0.01

<<com

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.01 \
  --dataset trainingImages:5-images.idx \
  --dataset trainingLabels:5-labels.idx \
  --verifier Marabou



Verifying properties:
  robust!0 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!1 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!2 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!3 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
  robust!4 [=======================================================] 9/9 queries
    result: 🗸 - Marabou proved no counterexample exists
robust:
    verified:  5/5
    falsified: 0/5
    timed-out: 0/5
    errored:   0/5

com

# Epsilon ball size 0.05

vehicle verify \
  --specification mnist-robustness.vcl \
  --network classifier:mnist-classifier.onnx \
  --parameter epsilon:0.05 \
  --dataset trainingImages:5-images.idx \
  --dataset trainingLabels:5-labels.idx \
  --verifier Marabou

<<com

Verifying properties:
  robust!0 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/sgh4000/.vehicle/reproducers/4383222954254996173

which can be run using:

  /usr/local/bin/Marabou /home/sgh4000/.vehicle/reproducers/4383222954254996173/mnist-classifier.onnx /home/sgh4000/.vehicle/reproducers/4383222954254996173/robust!0-query1.txt
  robust!1 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/sgh4000/.vehicle/reproducers/6215848511924382026

which can be run using:

  /usr/local/bin/Marabou /home/sgh4000/.vehicle/reproducers/6215848511924382026/mnist-classifier.onnx /home/sgh4000/.vehicle/reproducers/6215848511924382026/robust!1-query1.txt
  robust!2 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/sgh4000/.vehicle/reproducers/1944754306885549282

which can be run using:

  /usr/local/bin/Marabou /home/sgh4000/.vehicle/reproducers/1944754306885549282/mnist-classifier.onnx /home/sgh4000/.vehicle/reproducers/1944754306885549282/robust!2-query1.txt
  robust!3 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/sgh4000/.vehicle/reproducers/1652969238323258701

which can be run using:

  /usr/local/bin/Marabou /home/sgh4000/.vehicle/reproducers/1652969238323258701/mnist-classifier.onnx /home/sgh4000/.vehicle/reproducers/1652969238323258701/robust!3-query1.txt
  robust!4 [======>................................................] 1/9 queries
    result: ? - Marabou errored

Error: Marabou was killed with the signal '9'. This is often (but not always) a result of the Marabou verifier running out of memory.
A reproducer has been created at:

  /home/sgh4000/.vehicle/reproducers/5200393281354015970

which can be run using:

  /usr/local/bin/Marabou /home/sgh4000/.vehicle/reproducers/5200393281354015970/mnist-classifier.onnx /home/sgh4000/.vehicle/reproducers/5200393281354015970/robust!4-query1.txt
robust:
    verified:  0/5
    falsified: 0/5
    timed-out: 0/5
    errored:   5/5

com
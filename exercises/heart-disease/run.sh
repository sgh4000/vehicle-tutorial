#!/bin/bash

# Property 1

vehicle verify \
  --specification heart_disease.vcl \
  --verifier Marabou \
  --network heart_disease:heart_disease_model-5.onnx \
  --property property1

# Property 2

vehicle verify \
  --specification heart_disease.vcl \
  --verifier Marabou \
  --network heart_disease:heart_disease_model-5.onnx \
  --property property2

# Property 3

vehicle verify \
  --specification heart_disease.vcl \
  --verifier Marabou \
  --network heart_disease:heart_disease_model-5.onnx \
  --property property3

# Property 4

vehicle verify \
  --specification heart_disease.vcl \
  --verifier Marabou \
  --network heart_disease:heart_disease_model-5.onnx \
  --property property4

# Property 5

vehicle verify \
  --specification heart_disease.vcl \
  --verifier Marabou \
  --network heart_disease:heart_disease_model-5.onnx \
  --property property5
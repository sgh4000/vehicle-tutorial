#!/bin/bash


vehicle verify \
    --specification breast_cancer_model.vcl \
    --network cancer:breast_cancer_model.onnx \
    --verifier Marabou \
    --property property0 \
    --property property1 \
    --property property2 \
    --property property3 \
    --property property4


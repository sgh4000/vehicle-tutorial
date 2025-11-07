#!/bin/bash


vehicle verify \
    --specification iris-possible-answers.vcl \
    --network iris:iris_model.onnx \
    --verifier Marabou \
    --property property8

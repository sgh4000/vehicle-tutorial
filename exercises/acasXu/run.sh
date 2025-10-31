#!/bin/bash

# Property 1 - Tested on: all 45 networks.

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

# Property 2 - Tested on: Nx,y for all x≥2 and for all y.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property2

# Property 3 - Tested on: all networks except N1,7, N1,8, and N1,9.

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

# Property 4 - Tested on: all networks except N1,7, N1,8, and N1,9.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property4

# Property 5 - Tested on: N1,1.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_1_1.onnx \
  --property property5

# Property 6 - Tested on: N1,1.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_1_1.onnx \
  --property property6

# Property 7 - Tested on: N1,9.

<<com

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_9.onnx \
  --property property7

com

# Property 8 - Tested on: N2,9.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_2_9.onnx \
  --property property8

# Property 9 - Tested on: N3,3.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_3_3.onnx \
  --property property9

# Property 10 - Tested on: N4,5.

vehicle verify \
  --specification acasXu-incomplete.vcl \
  --verifier Marabou \
  --network acasXu:ACASXU_experimental_v2a_4_5.onnx \
  --property property10
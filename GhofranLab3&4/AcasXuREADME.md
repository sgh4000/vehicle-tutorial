# ACAS Xu example

ACAS Xu is a collection of 45 neural networks that together make up a collision avoidance system
for automonous unmanned aircraft.
The partial verification of the system was first described in the seminal
[Reluplex paper](https://arxiv.org/abs/1702.01135).
This example demonstrates how the entire specification, consisting of all
10 properties, can be written in a single file.
Unlike the equivalent low-level Marabou queries, the specification is written at a high-level and is understandable by a non-expert.

## Input files

- `acasXu.vcl` - the specification describing the desired behaviour.

- `acasXu_1_7.onnx`, `acasXu_1_8.onnx`, `acasXu_1_9.onnx` - 3 out of the 45 networks. The remainder can be found [here](https://github.com/NeuralNetworkVerification/Marabou/tree/master/resources/onnx/acasxu).

## Verifying using Marabou

The following command verifies `property3` for the network `acasXu_1_7.onnx`:

```bash
vehicle verify \
  --specification acasXu.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_7.onnx \
  --property property3
```

The same property can be verified for the other two networks in the folder. The remaining
properties apply to other network components

## Output files

The outputs of the above Vehicle commands can be found in the test suite:

- [Automatically generated Marabou queries](https://github.com/vehicle-lang/vehicle/tree/dev/vehicle/tests/golden/compile/acasXu/acasXu.inputquery)

# Ghofran's Code:

## To run Property 4

This property checks that when the intruder aircraft is very far away (about 50 km or more), the ACAS Xu network advises the pilot that the situation is Clear of Conflict (COC).
To keep verification efficient (faster), all other input variables (angle, heading, and both aircraft speeds) are limited to a narrow, realistic range that represents a steady, straight-flight scenario.

The following command verifies `property4` for the network `acasXu_1_7.onnx`:

```bash
vehicle verify \
  --specification acasXu_prop4_1.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_7.onnx \
  --property property4

# After running:
Verifying properties:
  property4 [=============>........................................] 1/4 queries
    result: ✗ - Marabou found a counterexample
      x: [ 50039.70256, -1.0002828928e-2, 3.120002979776, 697.1288, 668.7324 ]
```
**Meaning:** there is at least one situation where, even though the intruder aircraft is far away (around 50 km), the network did not correctly advise COC. This shows the model may give a wrong advisory in some edge cases.

## To run Property 1

Property 1 (Embedding-gap): If the intruder is distant and is significantly slower than the ownship, the score of a COC advisory will always be below a certain fixed threshold.
Means: when the intruder is far (ρ ≥ 55947.691 m) and much slower (v_own ≥ 1145 m/s, v_int ≤ 60 m/s), the COC score is ≤ 1500.
Because ACAS Xu outputs are scaled as (x − 7.518884)/373.94992, we compare COC against the scaled threshold (1500 − 7.518884)/373.94992.

The following command verifies `property1` for the network `acasXu_1_7.onnx`:

```bash
vehicle verify \
  --specification acasXu_prop4_1.vcl \
  --verifier Marabou \
  --network acasXu:acasXu_1_7.onnx \
  --property property1

# After running:
Verifying properties:
  property1 [======================================================] 1/1 queries
    result: 🗸 - Marabou proved no counterexample exists
```
**Meaning:** Marabou proved that for all valid input ranges, the network always keeps the COC score below the safety threshold. In simple words, the model behaves safely and as expected when the intruder is far and moving much slower.


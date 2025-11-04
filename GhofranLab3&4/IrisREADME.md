# Iris Dataset Classifier Exercise

The files you find here are for Exercise 1 in Chapter 1:  Your first Vehicle specification.
You are asked to examine a data set and a model, write and verify your own soecification for it.
For this purpose, we propose to take the "Hello World" of machine learning --
the [Iris Data set](<https://en.wikipedia.org/wiki/Iris_flower_data_set>)

# To run Ghofran iris verfication

```bash
# Type-check
vehicle check --specification iris_spec.vcl

# Verify each property (pick one, or run all)
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_setosa_box
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_virginica_box
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_versicolor_box
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property7
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property8

# Margin versions with ε = 0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_setosa_box_margin --parameter eps:0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_virginica_box_margin --parameter eps:0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_versicolor_box_margin --parameter eps:0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property7_margin --parameter eps:0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property8_margin --parameter eps:0.01

```

## Results and inteprtations:

- Each property says: “If the input features are in this typical range (box), the network should predict this specific flower class.”
- Property 7: checks that flowers with medium-sized petals and normal sepals are correctly classified as Versicolor.
- Property 8: checks that flowers with very small petals and small sepals are correctly classified as Setosa.

Marabou will try all possible inputs within that range to see if there’s any counterexample where the network chooses a different class.
When result: ✗ - Marabou found a counterexample, means there exists at least one input that breaks the rule.

```bash
(venv_vehicle) (base) ghofran@user:~/venv_vehicle/projects/vehicle-tutorial/GhofranLab3$ vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_setosa_box
Verifying properties:
  property_setosa_box [............................................] 0/2 queries
    result: ✗ - Marabou found a counterexample
      x: [ 4.3, 2.0, 1.0, 0.1 ]
```
**Meaning:** The model did not classify this smallest flower as Setosa (could be predicted Versicolor or Virginica).

```bash
(venv_vehicle) (base) ghofran@user:~/venv_vehicle/projects/vehicle-tutorial/GhofranLab3$ vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_virginica_box
Verifying properties:
  property_virginica_box [.........................................] 0/2 queries
    result: ✗ - Marabou found a counterexample
      x: [ 4.3, 2.0, 6.0, 2.0 ]
```
**Meaning:** Even though the petals are long/wide, the model misclassified this case (maybe because sepal features are small).

```bash
(venv_vehicle) (base) ghofran@user:~/venv_vehicle/projects/vehicle-tutorial/GhofranLab3$ vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_versicolor_box
Verifying properties:
  property_versicolor_box [........................................] 0/2 queries
    result: ✗ - Marabou found a counterexample
      x: [ 4.3, 4.4, 5.0, 1.367714 ]
```
**Meaning:** The model gave another class (Setosa) for this case.

```bash
(venv_vehicle) (base) ghofran@user:~/venv_vehicle/projects/vehicle-tutorial/GhofranLab3$ vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property7
Verifying properties:
  property7 [......................................................] 0/2 queries
    result: ✗ - Marabou found a counterexample
      x: [ 5.8, 2.8, 4.35, 1.35 ]
(venv_vehicle) (base) ghofran@user:~/venv_vehicle/projects/vehicle-tutorial/GhofranLab3$ vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property8
Verifying properties:
  property8 [......................................................] 0/2 queries
    result: ✗ - Marabou found a counterexample
      x: [ 5.2, 2.7, 1.0, 0.1 ]
```
**Meaning:** Marabou found at least one flower in those tight size ranges that the network classified incorrectly.The model sometimes makes mistakes even in the middle of the expected region for Versicolor and Setosa.


## Conclusion:
All properties were falsified as Marabou found counterexamples inside each range.
This shows that the NN is not perfectly consistent with the ideal class boundaries in the Iris dataset.

In particular, even points that look typical for one flower type may be misclassified when other features (like sepal size) take extreme values.
When Marabou finds a counterexample, it means the network made at least one prediction that goes against our rule.
This happens because:
1. **The model isn’t perfect:** it was trained on examples, not exact math rules, so mistakes or overlaps between classes are normal.
2. **Ranges include border areas:** near the edges, classes mix, and the network can easily switch predictions.
3. **Verification is very strict:** Marabou checks every possible input in the range, so even one mismatch makes the property fail. It doesn’t mean the model is completely wrong, it’s just not always right for every value in that range.

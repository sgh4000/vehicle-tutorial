# Iris Dataset Classifier Exercise

In order to run the code for the ACAS Xu challenge, please obtain the model and specification from Vehicle main page ([examples section](<https://github.com/vehicle-lang/vehicle/tree/dev/examples/acasXu>)).

The files you find here are for Exercise 1 in Chapter 1:  Your first Vehicle specification.
You are asked to examine a data set and a model, write and verify your own soecification for it.
For this purpose, we propose to take the "Hello World" of machine learning --
the [Iris Data set](<https://en.wikipedia.org/wiki/Iris_flower_data_set>)

# To run Ghofran iris verfication

'''bash
# Type-check
vehicle check --specification iris_spec.vcl

# Verify each property (pick one, or run all)
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_setosa_box
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_virginica_box
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_versicolor_box

# Margin versions with ε = 0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_setosa_box_margin --parameter eps:0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_virginica_box_margin --parameter eps:0.01
vehicle verify --specification iris_spec.vcl --verifier Marabou --network iris:iris_model.onnx --property property_versicolor_box_margin --parameter eps:0.01
'''


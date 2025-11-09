-- Set up necessary type definitions

type Image = Tensor Real [28, 28]

type Label = Index 10

validImage : Image -> Bool
validImage x = forall i j . 0 <= x ! i ! j <= 1

@network
fashionMnist : Image -> Tensor Real [10]

@parameter
epsilon : Real

@parameter
eta : Real

-- Define both the maximal score and strongly maximal score finding

maximalScore : Image -> Label -> Bool
maximalScore image label = forall j . j != label => fashionMnist image ! label > fashionMnist image ! j

strongAdvises : Image -> Label -> Bool
strongAdvises x i =
  fashionMnist x ! i >= eta

stronglyMaximalScore : Image -> Label -> Bool
stronglyMaximalScore x i =
  forall j . j != i => fashionMnist x ! i >= fashionMnist x ! j + eta


-- Define the robust and strong robust definitions

boundedByEpsilon : Image -> Bool
boundedByEpsilon x = forall i j . -epsilon <= x ! i ! j <= epsilon

robustAround : Image -> Label -> Bool
robustAround image label = forall pertubation .
  let perturbedImage = image - pertubation in
  boundedByEpsilon pertubation and validImage perturbedImage =>
    maximalScore perturbedImage label

strongClassificationRobustAround : Image -> Label -> Bool
strongClassificationRobustAround image label = forall pertubation .
  let perturbedImage = image - pertubation in
  boundedByEpsilon pertubation and validImage perturbedImage =>
    strongAdvises perturbedImage label

stronglyMaximalAround : Image -> Label -> Bool
stronglyMaximalAround image label = forall pertubation .
  let perturbedImage = image - pertubation in
  boundedByEpsilon pertubation and validImage perturbedImage =>
    stronglyMaximalScore perturbedImage label

@parameter(infer=True)
n : Nat

@dataset
trainingImages : Vector Image n

@dataset
trainingLabels : Vector Label n

@property
robustRegular : Vector Bool n
robustRegular = foreach i . robustAround (trainingImages ! i) (trainingLabels ! i)


@property
strongClassificationRobust : Vector Bool n
strongClassificationRobust = foreach i . strongClassificationRobustAround (trainingImages ! i) (trainingLabels ! i)

@property
stronglyMaximal : Vector Bool n
stronglyMaximal = foreach i . stronglyMaximalAround (trainingImages ! i) (trainingLabels ! i)



--------------------------------------------------------------------------------
-- Inputs and outputs

-- Define the type for our input images. Note that the input is two-dimensional

type Image = Tensor Real [28, 28]-- [your answer here]

-- We define the type of the output labels
-- i.e a number between 0 and 9, one for each digit

type Label = Index 10

-- Define a predicate that states that all the pixel values in a given image are in the range 0.0 to 1.0

validImage : Image -> Bool
validImage x = forall i j . 0.0 <= x ! i ! j <= 1.0 -- [your answer here]

--------------------------------------------------------------------------------
-- Network

-- Declare the network used to classify images. The output of the network is a
-- score for each of the digits 0 to 9.
@network
classifier : Image -> Tensor Real [10]

-- The classifier advises that input image `x` has label `i` if the score
-- for label `i` is greater than the score of any other label `j`.

advises : Image -> Label -> Bool
advises x i = forall j . j != i => classifier x ! i > classifier x ! j -- [your answer here]

--------------------------------------------------------------------------------
-- Definition of robustness around a point

-- First we define the parameter `epsilon` that will represent the radius of the ball that we want the network to be robust in. Note that we declare this as a parameter which allows the value of `epsilon` to be specified at compile time rather than be fixed in the specification.

@parameter
epsilon : Real

-- Next we define what it means for an image `x` to be in a ball of
-- size epsilon around 0.

boundedByEpsilon : Image -> Bool
boundedByEpsilon x = forall i j . -epsilon <= x ! i ! j <= epsilon

-- We now define what it means for the network to be robust around an image `x`  that should be classified as `y`. Namely, that for any perturbation no greater 
-- than epsilon then if the perturbed image is still a valid image then the network should still advise label `y` for the perturbed version of `x`.

robustAround : Image -> Label -> Bool
robustAround image label = forall pertubation .
  let perturbedImage = image - pertubation in
  boundedByEpsilon pertubation and validImage perturbedImage =>
  advises perturbedImage label  -- [your answer here]

--------------------------------------------------------------------------------
-- Robustness with respect to a dataset

-- We only really care about the network being robust on the set of images it will encounter. Indeed it is much more challenging to expect the 
-- network to be robust around all possible images. After all most images will be just be random noise.

-- Unfortunately we can't characterise the set of "reasonable" input images.
-- Instead we approximate it using the training dataset, and ask that the
-- network is robust around images in the training dataset.

-- We first specify parameter `n` the size of the training dataset. Unlike
-- the earlier parameter `epsilon`, we set the `infer` option of the
-- parameter `n` to 'True'. This means that it does not need to be provided
--  manually but instead will be automatically inferred by the compiler.
-- In this case it will be inferred from the training datasets.

@parameter(infer=True)
n : Nat

-- We next declare two datasets, the training images and the corresponding
-- training labels. Note that we use the previously declared parameter `n`
-- to enforce that they are the same size.
@dataset
trainingImages : Vector Image n

@dataset
trainingLabels : Vector Label n

----------------------------------------------------------------------------------
-- property 1 (CR (Classification Robustness))

-- We then say that the network is robust if it is robust around every pair
-- of input images and output labels. Note the use of the `foreach`
-- keyword when quantifying over the index `i` in the dataset. Whereas `forall`
-- would return a single `Bool`, `foreach` constructs a `Vector` of booleans,
-- ensuring that Vehicle will report on the verification status of each image in
-- the dataset separately. If `forall` was omitted, Vehicle would only
-- report if the network was robust around *every* image in the dataset, a
-- state of affairs which is unlikely to be true.

@property
property1 : Vector Bool n
property1 = foreach i . robustAround (trainingImages ! i) (trainingLabels ! i) -- [your answer here]

----------------------------------------------------------------------------------
-- property 2 (SCR (Strong Classification Robustness))

-- Strong Classification Robustness in Vehicle
-- |x_hat - x| <= epsilon ------> f(x) >= etha

etha = 20

xHatMinusXLessThanEpsilon_SCR : Image -> Label -> Bool
xHatMinusXLessThanEpsilon_SCR image label = forall perturbation . 
  let perturbedImage = image - perturbation in
  validImage image and
  boundedByEpsilon perturbation and 
  validImage perturbedImage
  => classifier perturbedImage ! label >= etha

@property
property2 : Bool
property2 = forall i . 
  xHatMinusXLessThanEpsilon_SCR (trainingImages ! i) (trainingLabels ! i)   

----------------------------------------------------------------------------------
-- property 3  SR (Standard Robustness)

-- Strong Classification Robustness in Vehicle
-- |x_hat - x| <= epsilon ------> abs(f(x) - f(x_hat)) <= theta

delta = 0.01

xHatMinusXLessThanEpsilon_SR : Image -> Label -> Bool
xHatMinusXLessThanEpsilon_SR image label = forall perturbation . 
  let perturbedImage = image - perturbation in
  validImage image and
  boundedByEpsilon perturbation and 
  validImage perturbedImage
  => -delta <= ((classifier perturbedImage ! label) - (classifier image ! label)) <= delta

@property
property3 : Bool
property3 = forall i . 
  xHatMinusXLessThanEpsilon_SR (trainingImages ! i) (trainingLabels ! i)  



----------------------------------------------------------------------------------
-- property 4  (LR (Lipschitz Robustness))

-- Strong Classification Robustness in Vehicle
-- |x_hat - x| <= epsilon ------> abs(f(x) - f(x_hat)) <= L(x - x_hat)

euclideanSquared : Image -> Image -> Real
euclideanSquared x y =
  let d = x - y in
  let sum = 0 in
  let sum = sum + ((d ! 0 ! 0) * (d ! 0 ! 0)) in
  let sum = sum + ((d ! 0 ! 1) * (d ! 0 ! 1)) in
  sum

lipschitzL : Real
lipschitzL = 1.0  -- <-- fill bound

lipschitzBound : Image -> Image -> Real
lipschitzBound x xhat = lipschitzL * euclideanSquared x xhat

xHatMinusXLessThanEpsilon_LR : Image -> Label -> Bool
xHatMinusXLessThanEpsilon_LR image label = forall perturbation . 
  let perturbedImage = image - perturbation in
  validImage image and
  boundedByEpsilon perturbation and 
  validImage perturbedImage  
  => -(lipschitzBound image perturbedImage) <= ((classifier perturbedImage ! label) - (classifier image ! label)) <= (lipschitzBound image perturbedImage)

@property
property4 : Bool
property4 = forall i . 
  xHatMinusXLessThanEpsilon_LR (trainingImages ! i) (trainingLabels ! i)  
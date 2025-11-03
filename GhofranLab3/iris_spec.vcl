--------------------------------------------------------------------------------
-- Iris — Vehicle specification (Chapter 2 exercise)
-- input order (classic Iris):
--   0: sepalLength (cm)
--   1: sepalWidth  (cm)
--   2: petalLength (cm)
--   3: petalWidth  (cm)
-- output order:
--   0: setosa, 1: versicolor, 2: virginica
--------------------------------------------------------------------------------
-- Types
type Input  = Tensor Real [4]
type Output = Tensor Real [3]

-- Index names (inputs)
sepalLength = 0
sepalWidth  = 1
petalLength = 2
petalWidth  = 3

-- Index names (outputs/classes)
setosa     = 0
versicolor = 1
virginica  = 2

-- The model under verification
@network
iris : Input -> Output

--------------------------------------------------------------------------------
-- Check input data validity
-- Dataset bounds (Iris ranges; give both lower & upper bounds)

withinDatasetRange : Input -> Bool
withinDatasetRange x =
  4.3 <= x ! sepalLength <= 7.9 and
  2.0 <= x ! sepalWidth  <= 4.4 and
  1.0 <= x ! petalLength <= 6.9 and
  0.1 <= x ! petalWidth  <= 2.5


--------------------------------------------------------------------------------
-- Selection specification: class i is chosen (score at i strictly smallest)
advises : Index 3 -> Input -> Bool
advises i x = forall j . i != j => iris x ! i < iris x ! j

--------------------------------------------------------------------------------
-- Simple, well-known rules for the Iris flowers.
-- These small value ranges (boxes) make the verification run faster.
-- The boxes are based on how petal size separates the three flower types,
-- as petal sizes distinguish classes well.

-- Setosa: very short & narrow petals
setosaBox : Input -> Bool
setosaBox x =
  x ! petalLength <= 1.5 and
  x ! petalWidth  <= 0.3

@property
property_setosa_box : Bool
property_setosa_box = forall x .
  withinDatasetRange x and setosaBox x =>
  advises setosa x

-- Virginica: long & wide petals
virginicaBox : Input -> Bool
virginicaBox x =
  x ! petalLength >= 6.0 and
  x ! petalWidth  >= 2.0

@property
property_virginica_box : Bool
property_virginica_box = forall x .
  withinDatasetRange x and virginicaBox x =>
  advises virginica x

-- Versicolor: mid-range petals
versicolorBox : Input -> Bool
versicolorBox x =
  4.0 <= x ! petalLength <= 4.8 and
  1.3 <= x ! petalWidth  <= 1.6

@property
property_versicolor_box : Bool
property_versicolor_box = forall x .
  withinDatasetRange x and versicolorBox x =>
  advises versicolor x

--------------------------------------------------------------------------------
-- Extra: margin (ε) to avoid cases where two classes have the same score.

@parameter
eps : Real
advisesWithMargin : Index 3 -> Input -> Bool
advisesWithMargin i x = forall j . i != j => iris x ! i + eps < iris x ! j

@property
property_setosa_box_margin : Bool
property_setosa_box_margin = forall x .
  withinDatasetRange x and setosaBox x =>
  advisesWithMargin setosa x

@property
property_virginica_box_margin : Bool
property_virginica_box_margin = forall x .
  withinDatasetRange x and virginicaBox x =>
  advisesWithMargin virginica x

@property
property_versicolor_box_margin : Bool
property_versicolor_box_margin = forall x .
  withinDatasetRange x and versicolorBox x =>
  advisesWithMargin versicolor x

--------------------------------------------------------------------------------

-- Property 7

-- If petals are in a clear middle range (typical for Versicolor),
-- and sepals are in a normal range, then the network should classify
-- the input as Versicolor.
-- These limits describe the common Versicolor region in the dataset.
-- and are tighter (centered) to reduce counterexamples
-- and speed up verification.

versicolorMid : Input -> Bool
versicolorMid x =
  4.35 <= x ! petalLength <= 4.65 and
  1.35 <= x ! petalWidth  <= 1.55 and
  5.8  <= x ! sepalLength <= 6.4  and
  2.8  <= x ! sepalWidth  <= 3.1

@property
property7 : Bool
property7 = forall x .
  withinDatasetRange x and versicolorMid x =>
  advises versicolor x

--------------------------------------------------------------------------------
-- Property 8

-- If petals are very small (clearly in the Setosa region),
-- then the network should classify the input as Setosa.
-- This is a stricter version of the Setosa rule from the excercise.


tinyPetal : Input -> Bool
tinyPetal x =
  x ! petalLength <= 1.25 and
  x ! petalWidth  <= 0.20 and
  5.2 <= x ! sepalLength <= 5.8 and
  2.7 <= x ! sepalWidth  <= 3.1

@property
property8 : Bool
property8 = forall x .
  withinDatasetRange x and tinyPetal x =>
  advises setosa x

--------------------------------------------------------------------------------
-- Margin versions for properties 7 & 8
-- require the chosen class to beat others by at least ε

@property
property7_margin : Bool
property7_margin = forall x .
  withinDatasetRange x and versicolorMid x =>
  advisesWithMargin versicolor x

@property
property8_margin : Bool
property8_margin = forall x .
  withinDatasetRange x and tinyPetal x =>
  advisesWithMargin setosa x


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
-- Selection specification: class i is chosen (score at i strictly smallest)
advises : Index 3 -> Input -> Bool
advises i x = forall j . i != j => iris x ! i < iris x ! j

--------------------------------------------------------------------------------
-- Simple, well-known rules for the Iris flowers.
-- These small value ranges (boxes) make the verification run faster.
-- The boxes are based on how petal size separates the three flower types.

-- Setosa: very short & narrow petals
setosaBox : Input -> Bool
setosaBox x =
  x ! petalLength <= 1.8 and
  x ! petalWidth  <= 0.4

@property
property_setosa_box : Bool
property_setosa_box = forall x .
  setosaBox x => advises setosa x

-- Virginica: long & wide petals
virginicaBox : Input -> Bool
virginicaBox x =
  x ! petalLength >= 6.0 and
  x ! petalWidth  >= 2.0

@property
property_virginica_box : Bool
property_virginica_box = forall x .
  virginicaBox x => advises virginica x

-- Versicolor: mid-range petals
versicolorBox : Input -> Bool
versicolorBox x =
  3.5 <= x ! petalLength <= 5.0 and
  1.0 <= x ! petalWidth  <= 1.7

@property
property_versicolor_box : Bool
property_versicolor_box = forall x .
  versicolorBox x => advises versicolor x

--------------------------------------------------------------------------------
-- Extra: margin (ε) to avoid cases where two classes have the same score.

@parameter
eps : Real
advisesWithMargin : Index 3 -> Input -> Bool
advisesWithMargin i x = forall j . i != j => iris x ! i + eps < iris x ! j

@property
property_setosa_box_margin : Bool
property_setosa_box_margin = forall x .
  setosaBox x => advisesWithMargin setosa x

@property
property_virginica_box_margin : Bool
property_virginica_box_margin = forall x .
  virginicaBox x => advisesWithMargin virginica x

@property
property_versicolor_box_margin : Bool
property_versicolor_box_margin = forall x .
  versicolorBox x => advisesWithMargin versicolor x



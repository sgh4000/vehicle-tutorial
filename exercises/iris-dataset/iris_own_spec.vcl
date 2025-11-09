--------------------------------------------------------------------------------
-- Iris Dataset
type Input = Tensor Real [4]

sepalLength = 0   -- measured in centimetres
sepalWidth  = 1   -- measured in centimetres
petalLength = 2   -- measured in centimetres
petalWidth  = 3   -- measured in centimetres

type Output = Tensor Real [3]

setosa      = 0
versicolor  = 1
virginica   = 2

@network
iris : Input -> Output

normalSepalLength : Input -> Bool
normalSepalLength x = 4.3 <= x ! sepalLength <= 7.9

normalSepalWidth : Input -> Bool
normalSepalWidth x = 2.0 <= x ! sepalWidth <= 4.4

normalPetalLength : Input -> Bool
normalPetalLength x = 1.0 <= x ! petalLength <= 6.9

normalPetalWidth : Input -> Bool
normalPetalWidth x = 0.1 <= x ! petalWidth <= 2.5

validInput : Input -> Bool
validInput x = normalSepalLength x and normalSepalWidth x
    and normalPetalLength x and normalPetalWidth x
    and x ! sepalLength > x ! sepalWidth
    and x ! petalLength > x ! petalWidth

maximalScore : Index 3 -> Input -> Bool
maximalScore i x =
  forall j . i != j => iris x ! i >= iris x ! j

minimalScore : Index 3 -> Input -> Bool
minimalScore i x = forall j . i != j => iris x ! i < iris x ! j

isVirginica : Input -> Bool
isVirginica x =
    let scores = iris x in
    forall d . d != virginica => scores ! virginica > scores ! d

--------------------------------------------------------------------------------

-- Properties
-- Iris setosa petal length shouldn't exceed 2cm and sepal length shouldn't exceed 5cm
-- https://medium.com/@elumavictoria/introduction-1e1310086438

isSetosa : Input -> Bool
isSetosa x =
    let scores = iris x in
    forall d . d != setosa => scores ! setosa >= scores ! d

slAndPl : Input -> Bool
slAndPl x =
    x ! sepalLength <= 4 and
    x ! petalLength <= 2

@property
property1 : Bool
property1 = forall x . validInput x and slAndPl x =>
    maximalScore setosa x

@property
property2 : Bool
property2 = forall x .
    validInput x and
    (1 <= x ! sepalLength <= 6) and
    (3.0 <= x ! sepalWidth <= 4.0) and
    (0.5 <= x ! petalLength <= 2) and
    (0.1 <= x ! petalWidth <= 1) =>
    maximalScore setosa x


virginicaBounds x =
    6.5 <= x ! sepalLength <= 7.9 and
    2.5 <= x ! sepalWidth  <= 3.8 and
    4.5 <= x ! petalLength <= 6.9 and
    1.8 <= x ! petalWidth  <= 2.5


@property
property3 : Bool
property3 = forall x .
    validInput x and virginicaBounds x =>
    maximalScore virginica x
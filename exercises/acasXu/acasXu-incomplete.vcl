--------------------------------------------------------------------------------
-- Full specification of the ACAS XU networks

-- Taken from Appendix VI of "Reluplex: An Efficient SMT Solver for Verifying
-- Deep Neural Networks" at https://arxiv.org/pdf/1702.01135.pdf

-- Comments describing the properties are taken directly from the text.

--------------------------------------------------------------------------------
-- Utilities

-- The value of the constant `pi`.
pi = 3.141592

--------------------------------------------------------------------------------
-- Inputs

-- We first define a new name for the type of inputs of the network.
-- In particular, it takes inputs of the form of a vector of 5 rational numbers.

type Input = Tensor Real [5]

-- Next we add meaningful names for the indices.
-- The fact that all vector types come annotated with their size means that it
-- is impossible to mess up indexing into vectors, e.g. if you changed
-- `distanceToIntruder = 0` to `distanceToIntruder = 5` the specification would
-- fail to type-check.

distanceToIntruder = 0   -- measured in metres
angleToIntruder    = 1   -- measured in radians
intruderHeading    = 2   -- measured in radians
speed              = 3   -- measured in metres/second
intruderSpeed      = 4   -- measured in meters/second

--------------------------------------------------------------------------------
-- Outputs

-- Outputs are also a vector of 5 rationals. Each one representing the score
-- for the 5 available courses of action.

type Output = Tensor Real [5]

-- Again we define meaningful names for the indices into output vectors.

clearOfConflict = 0
weakLeft        = 1
weakRight       = 2
strongLeft      = 3
strongRight     = 4

--------------------------------------------------------------------------------
-- The network

-- Next we use the `network` annotation to declare the name and the type of the
-- neural network we are verifying. The implementation is passed to the compiler
-- via a reference to the ONNX file at compile time.

@network
acasXu : Input -> Output

--------------------------------------------------------------------------------
-- Normalisation

-- As is common in machine learning, the network operates over
-- normalised values, rather than values in the problem space
-- (e.g. using standard units like m/s).
-- This is an issue for us, as we would like to write our specification in
-- terms of the problem space values .
-- Therefore before applying the network, we first have to normalise
-- the values in the problem space.

-- For clarity, we therefore define a new type synonym
-- for unnormalised input vectors which are in the problem space.
type UnnormalisedInput = Tensor Real [5]

-- Next we define the minimum and maximum values that each input can take.
-- These correspond to the range of the inputs that the network is designed
-- to work over.
minimumInputValues : UnnormalisedInput
minimumInputValues = [0,0,0,0,0]

maximumInputValues : UnnormalisedInput
maximumInputValues = [60261.0, 2*pi, 2*pi, 1100.0, 1200.0]

-- We can therefore define a simple predicate saying whether a given input
-- vector is in the right range.
validInput : UnnormalisedInput -> Bool
validInput x = forall i . minimumInputValues ! i <= x ! i <= maximumInputValues ! i

-- Then the mean values that will be used to scale the inputs.
meanScalingValues : UnnormalisedInput
meanScalingValues = [19791.091, 0.0, 0.0, 650.0, 600.0]

-- We can now define the normalisation function that takes an input vector and
-- returns the unnormalised version.
normalise : UnnormalisedInput -> Input
normalise x = foreach i .
  (x ! i - meanScalingValues ! i) / (maximumInputValues ! i)

-- Using this we can define a new function that first normalises the input
-- vector and then applies the neural network.
normAcasXu : UnnormalisedInput -> Output
normAcasXu x = acasXu (normalise x)

-- A constraint that says the network chooses output `i` when given the
-- input `x`. We must necessarily provide a finite index that is less than 5
-- (i.e. of type Index 5). The `a ! b` operator lookups index `b` in vector `a`.
minimalScore : Index 5 -> UnnormalisedInput -> Bool
minimalScore i x = forall j . i != j => normAcasXu x ! i < normAcasXu x ! j

maximalScore : Index 5 -> UnnormalisedInput -> Bool
maximalScore i x =
  forall j . i != j => normAcasXu x ! i > normAcasXu x ! j
  
--------------------------------------------------------------------------------

-- Properties

--------------------------------------------------------------------------------

-- Property 1

-- Description: If the intruder is distant and is significantly slower than the
-- ownship, the score of a COC advisory will always be below a certain fixed
-- threshold.
-- Tested on: all 45 networks.
-- Input constraints: ρ≥55947.691, vown ≥1145, vint ≤60.
-- Desired output property: the score for COC is at most 1500.

scale = (1500 - 7.518884)/300

belowThreshold : Input -> Bool
belowThreshold x = (acasXu x ! clearOfConflict) < ((1500-7.518884)/373.94992)


distant : UnnormalisedInput -> Bool
distant y = 
  y ! distanceToIntruder >= 55947.691

significantlySlower : UnnormalisedInput -> Bool
significantlySlower y = 
  y ! speed >= 1145 and
  y ! intruderSpeed <= 60

@property
property1 : Bool
property1 = forall y .
  validInput y and distant y and significantlySlower y =>
    belowThreshold y

--------------------------------------------------------------------------------

-- Property 2

-- Description: If the intruder is distant and is significantly slower than the
-- ownship, the score of a COC advisory will never be maximal.
-- Tested on: Nx,y for all x≥2 and for all y.
-- Input constraints: ρ≥55947.691, vown ≥1145, vint ≤60.
-- Desired output property: the score for COC is not the maximal score.

@property
property2 : Bool
property2 = forall x .
  validInput x and distant x and significantlySlower x =>
    not (maximalScore clearOfConflict x)


--------------------------------------------------------------------------------

-- Property 3

-- Description: If the intruder is directly ahead and is moving towards the
-- ownship, the score for COC will not be minimal.
-- Tested on: all networks except N1,7, N1,8, and N1,9.
-- Input constraints: 1500 ≤ρ≤1800,−0.06 ≤θ≤0.06, ψ≥3.10, vown ≥980,
-- vint ≥960.
-- Desired output property: the score for COC is not the minimal score.

directlyAhead : UnnormalisedInput -> Bool
directlyAhead x =
  1500  <= x ! distanceToIntruder <= 1800 and
  -0.06 <= x ! angleToIntruder    <= 0.06

movingTowards : UnnormalisedInput -> Bool
movingTowards x =
  x ! intruderHeading >= 3.10  and
  x ! speed           >= 980   and
  x ! intruderSpeed   >= 960

@property
property3 : Bool
property3 = forall x .
  validInput x and directlyAhead x and movingTowards x =>
  not (minimalScore clearOfConflict x)

--------------------------------------------------------------------------------

-- Property 4

-- – Description: If the intruder is directly ahead and is moving away from the
-- ownship but at a lower speed than that of the ownship, the score for COC
-- will not be minimal.
-- – Tested on: all networks except N1,7, N1,8, and N1,9.
-- – Input constraints: 1500 ≤ρ≤1800,−0.06 ≤θ ≤0.06, ψ = 0, vown ≥1000,
-- 700 ≤vint ≤800.
-- – Desired output property: the score for COC is not the minimal score.

movingAway : UnnormalisedInput -> Bool
movingAway x =
  1500  <= x ! distanceToIntruder <= 1800 and
  -0.06 <= x ! angleToIntruder <= 0.06 and
  x ! intruderHeading == 0  and
  x ! speed >= 1000 and
  700 <= x ! intruderSpeed  <= 800

@property
property4 : Bool
property4 = forall x .
  validInput x and directlyAhead x and movingAway x =>
  not (minimalScore clearOfConflict x)


--------------------------------------------------------------------------------

-- Property 5

-- – Description: If the intruder is near and approaching from the left, the network
-- advises “strong right”.
--  Tested on: N1,1.
-- – Input constraints: 250 ≤ ρ ≤ 400, 0.2 ≤ θ ≤ 0.4,−3.141592 ≤ ψ ≤
-- −3.141592 + 0.005, 100 ≤vown ≤400, 0 ≤vint ≤400.
-- – Desired output property: the score for “strong right” is the minimal score.

near : UnnormalisedInput -> Bool
near x = 
  250 <= x ! distanceToIntruder <= 400

intruderApproachingFromLeft : UnnormalisedInput -> Bool
intruderApproachingFromLeft x =
  0.2 <= x ! angleToIntruder <= 0.4 and
  -3.141592 <= x ! intruderHeading <= (−3.141592 + 0.005) and
  100 <= x ! speed >= 400 and
  0 <= x ! intruderSpeed  <= 400

@property
property5 : Bool
property5 = forall x .
  validInput x and near x and intruderApproachingFromLeft x =>
  minimalScore clearOfConflict x

--------------------------------------------------------------------------------


-- Property 6

-- – Description: If the intruder is suﬃciently far away, the network advises COC.
-- – Tested on: N1,1.
-- – Input constraints: 12000 ≤ρ≤62000, (0.7 ≤θ≤3.141592) ∨(−3.141592 ≤
-- θ ≤ −0.7),−3.141592 ≤ ψ ≤ −3.141592 + 0.005, 100 ≤ vown ≤ 1200,
-- 0 ≤vint ≤1200.
-- – Desired output property: the score for COC is the minimal score.

far : UnnormalisedInput -> Bool
far x = 
  12000 <= x ! distanceToIntruder <= 62000 
  (0.7 <= x ! angleToIntruder <= 3.141592 or −3.141592 <= x ! angleToIntruder <= −0.7 ) and
  -3.141592 <= x ! intruderHeading <= (−3.141592 + 0.005) and
  100 <= x ! speed >= 12000 and
  0 <= x ! intruderSpeed  <= 1200


@property
property6 : Bool
property6 = forall x .
  validInput x and far x =>
  minimalScore clearOfConflict x


--------------------------------------------------------------------------------

-- Property 7

-- Description: If vertical separation is large, the network will never advise a
-- strong turn.
-- – Tested on: N1,9.
-- – Input constraints: 0 ≤ρ≤60760,−3.141592 ≤θ ≤3.141592,−3.141592 ≤
-- ψ≤3.141592, 100 ≤vown ≤1200, 0 ≤vint ≤1200.
-- – Desired output property: the scores for “strong right” and “strong left” are
-- never the minimal scores.

verticalSeparationLarge : UnnormalisedInput -> Bool
verticalSeparationLarge x = 
  0 <= x ! distanceToIntruder <= 60760
  (−3.141592 <= x ! angleToIntruder <= 3.141592) and
  −3.141592 <= x ! intruderHeading <= (3.141592) and
  100 <= x ! speed >= 12000 and
  0 <= x ! intruderSpeed  <= 1200

@property
property7 : Bool
property7 = forall x .
  validInput x and verticalSeparationLarge x =>
  not (minimalScore strongLeft x) and not (minimalScore strongRight x)


--------------------------------------------------------------------------------

-- Property 8

-- Description: For a large vertical separation and a previous “weak left” advi-
-- sory, the network will either output COC or continue advising “weak left”.
-- – Tested on: N2,9.
-- – Input constraints: 0 ≤ρ≤60760,−3.141592 ≤θ≤−0.75·3.141592,−0.1 ≤
-- ψ≤0.1, 600 ≤vown ≤1200, 600 ≤vint ≤1200.
-- – Desired output property: the score for “weak left” is minimal or the score
-- for COC is minimal.

-- previous is much simpler than I originally thought, can just use the indexing of the network
-- source: https://easychair.org/publications/paper/mmSLW/open
-- Each network is indexed by a pair λ,β where λis an integer denoting previous advisory aprev ∈{COC,WL,WR,SL,SR}

largeVerticalSeparation : UnnormalisedInput -> Bool
largeVerticalSeparation x =
  0 <= x ! distanceToIntruder <= 60760
  (−3.141592 <= x ! angleToIntruder <= -0.75) and
  −0.1 <= x ! intruderHeading <= (-0.1) and
  600 <= x ! speed >= 1200 and
  0 <= x ! intruderSpeed  <= 1200

  -- the testing for only when previous advice was "weak left" comes from indexing of neural net files

@property
property8 : Bool
property8 = forall x .
  validInput x and largeVerticalSeparation x =>
    (minimalScore clearOfConflict x) or (minimalScore weakLeft x)



--------------------------------------------------------------------------------

-- Property 9

-- Description: Even if the previous advisory was “weak right”, the presence of
-- a nearby intruder will cause the network to output a “strong left” advisory
-- instead.
-- – Tested on: N3,3.
-- – Input constraints: 2000 ≤ρ ≤7000,−0.4 ≤θ ≤−0.14,−3.141592 ≤ψ ≤
-- −3.141592 + 0.01, 100 ≤vown ≤150, 0 ≤vint ≤150.
-- – Desired output property: the score for “strong left” is minimal.

nearbyIntruder : UnnormalisedInput -> Bool
nearbyIntruder x =
  2000 <= x ! distanceToIntruder <= 7000
  (-0.4 <= x ! angleToIntruder <= -0.14) and
  −3.141592 <= x ! intruderHeading <= (−3.141592 + 0.01) and
  100 <= x ! speed >= 150 and
  0 <= x ! intruderSpeed  <= 150

@property
property9 : Bool
property9 = forall x .
  validInput x and nearbyIntruder x =>
    (minimalScore strongLeft x)


--------------------------------------------------------------------------------

-- Property 10

-- Description: For a far away intruder, the network advises COC.
--  Tested on: N4,5.
-- – Input constraints: 36000 ≤ρ ≤60760, 0.7 ≤θ ≤3.141592,−3.141592 ≤
-- ψ≤−3.141592 + 0.01, 900 ≤vown ≤1200, 600 ≤vint ≤1200.
-- – Desired output property: the score for COC is minimal.

farAwayIntruder : UnnormalisedInput -> Bool
far x = 
  36000 <= x ! distanceToIntruder <= 60760
  (0.7 <= x ! angleToIntruder <= 3.141592) and
  -3.141592 <= x ! intruderHeading <= (−3.141592 + 0.01) and
  900 <= x ! speed >= 12000 and
  600 <= x ! intruderSpeed  <= 1200


@property
property6 : Bool
property6 = forall x .
  validInput x and far x =>
  minimalScore clearOfConflict x


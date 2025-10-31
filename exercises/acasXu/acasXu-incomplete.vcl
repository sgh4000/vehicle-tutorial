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
advises : Index 5 -> UnnormalisedInput -> Bool
advises i x = forall j . i != j => normAcasXu x ! i < normAcasXu x ! j

--------------------------------------------------------------------------------
-- Property 1

-- If the intruder is distance and 
-- the intuder is significantly slower that the ownership
-- The score of COC advisary should be bellow a certain fixed threshold.

-- @parameter
-- disThresh : Real        -- distance threshold (problem space)    --parameter disThresh:55947.691
disThresh = 55947.691

-- @parameter
-- ownerVmin : Real        -- minimum ownship speed                 --parameter ownerVmin:1145
ownerVmin = 1145

-- @parameter
-- intruderVmax : Real     -- maximum intruder speed                --parameter intruderVmax:60
intruderVmax = 60

-- @parameter
-- cocScoreThresh : Real   -- RAW (unscaled) score threshold        --parameter cocScoreThresh:1500
cocScoreThresh = 1500

intruderIsDistance : Real -> UnnormalisedInput -> Bool
intruderIsDistance disThresh_ x = 
  x ! distanceToIntruder >= disThresh_

intruderIsSlow : Real -> Real -> UnnormalisedInput -> Bool
intruderIsSlow ownerVmin_ intruderVmax_ x = 
  x ! intruderSpeed <= intruderVmax_ and 
  x ! speed >= ownerVmin_

advisesThreshold : Index 5 -> Real -> UnnormalisedInput -> Bool
advisesThreshold i cocScoreThresh_ x =
  ((normAcasXu x ! i) * 373.94992) + 7.518884 <= cocScoreThresh_

@property
property1 : Bool
property1 = forall x . 
  validInput x and
  intruderIsDistance disThresh x and
  intruderIsSlow ownerVmin intruderVmax x  
  => (advisesThreshold clearOfConflict cocScoreThresh x)

--------------------------------------------------------------------------------
-- Property 2

-- If the intruder is distant and 
-- the intuder is significantly slower that the ownership
-- the score of a COC advisory will never be maximal

adviseMaximal : Index 5 -> UnnormalisedInput -> Bool
adviseMaximal i x = forall j . i != j => normAcasXu x ! j < normAcasXu x ! i

@property 
property2 : Bool
property2 = forall x.
  validInput x and
  intruderIsDistance disThresh x and 
  intruderIsSlow ownerVmin intruderVmax x  
  => not(adviseMaximal clearOfConflict x)

--------------------------------------------------------------------------------
-- Property 3

-- If the intruder is directly ahead 
-- and is moving towards the ownship
-- the score for COC will not be minimal.

-- Tested on: all networks except N_{1,7}, N_{1,8}, and N_{1,9}.

directlyAhead : UnnormalisedInput -> Bool
directlyAhead x = 
  1500  <= x ! distanceToIntruder <= 1800 and
  -0.06 <= x ! angleToIntruder    <= 0.06

movingTowards : UnnormalisedInput -> Bool
movingTowards x = 
  x ! intruderHeading >= 3.10 and
  x ! speed           >= 980  and
  x ! intruderSpeed   >= 960 


@property
property3 : Bool
property3 = forall x .
  validInput    x and
  directlyAhead x and
  movingTowards x 
  => not(advises clearOfConflict x)

--------------------------------------------------------------------------------     
-- Property 4

-- If the intruder is directly ahead
-- and is moving away from the ownship 
-- but at a lower speed than that of the ownship
-- the score for COC will not be minimal.

movinfAway : UnnormalisedInput -> Bool
movinfAway x = 
  x ! intruderHeading == 0    and 
  x ! speed           >= 980  and
  x ! intruderSpeed   >= 960 

@property
property4 : Bool
property4 = forall x . 
  validInput x and
  movinfAway x 
  => not(advises clearOfConflict x)
--------------------------------------------------------------------------------
-- Property 5

-- If the intruder is near
-- and approaching from the left
-- the score for “strong right” is the minimal score.

intruderIsNear : UnnormalisedInput -> Bool
intruderIsNear x = 
  250 <= x ! distanceToIntruder <= 400

intruderIsApprochFromLeft : UnnormalisedInput -> Bool
intruderIsApprochFromLeft x = 
  0.2  <= x ! angleToIntruder <= 0.4         and
  -pi  <= x ! intruderHeading <= -pi + 0.005 and
  100  <= x ! speed           <= 400         and
  0    <= x ! intruderSpeed   <= 400 

@property
property5 : Bool
property5 = forall x .
  validInput x and 
  intruderIsNear x and
  intruderIsApprochFromLeft x
  => advises strongLeft x
--------------------------------------------------------------------------------
-- Property 6

-- If the intruder is sufficiently far away
-- the network advises COC.

intruderSufficientFar : UnnormalisedInput -> Bool
intruderSufficientFar x = 
  12000 <= x ! distanceToIntruder <= 62000     and
  (
    0.7 <= x ! angleToIntruder <= pi           or
    -pi <= x ! angleToIntruder <= -0.7
  )                                            and 
  -pi   <= x ! intruderHeading <= -pi + 0.005  and
  100   <= x ! speed           <= 1200         and
  0     <= x ! intruderSpeed   <= 1200 

@property
property6 : Bool
property6 = forall x .
  validInput x and
  intruderSufficientFar x
  => advises clearOfConflict x
--------------------------------------------------------------------------------
-- Property 7

-- If vertical separation is large
-- the network will never advise a strong turn

verticalSeprationIsLarge : UnnormalisedInput -> Bool
verticalSeprationIsLarge x = 
  0    <= x ! distanceToIntruder  <= 60760 and 
  -pi  <= x ! angleToIntruder     <= pi    and
  -pi  <= x ! intruderHeading     <= pi    and
  100  <= x ! speed               <= 1200  and
  0    <= x ! intruderSpeed       <= 1200 

@property
property7 : Bool
property7 = forall x .
  validInput x and
  verticalSeprationIsLarge x
  => not(advises strongLeft x) and not(advises strongRight x)

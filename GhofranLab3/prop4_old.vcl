--------------------------------------------------------------------------------
-- Custom Ghofran Property 4

-- If the intruder is far away (within the valid input range),
-- the score for COC *should be* minimal (the network should advise COC).


-- Define "far away" in the problem space.
farAway : UnnormalisedInput -> Bool
farAway x =
  x ! distanceToIntruder >= 5000.0

@property
property4 : Bool
property4 = forall x .
  validInput x and farAway x =>
  advises clearOfConflict x


--------------------------------------------------------------------------------
-- Extra: Add a small decision margin ε to avoid bounaries.
-- Means: COC must be strictly better than every other action by at least ε.

@parameter 
eps : Real

advisesWithMargin : Index 5 -> UnnormalisedInput -> Bool
advisesWithMargin i x = forall j .
  i != j => normAcasXu x ! i + eps < normAcasXu x ! j

@property
property4_margin : Bool
property4_margin = forall x .
  validInput x and farAway x =>
  advisesWithMargin clearOfConflict x

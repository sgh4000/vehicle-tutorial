-- Couldn't get anything below to actually work :((((

-- Euclidean - purely theoretical as Vehicle doesn't have sum and would need to write 784 pixels manually I think


@property
robustAroundEuclidean : Vector Bool n
robustAroundEuclidean = foreach i . robustAroundEuclidean (trainingImages ! i) (trainingLabels ! i)

robustAroundEuclidean : Image -> Label -> Bool
robustAroundEuclidean image label =
   forall perturbation .
   let perturbedImage = image - perturbation in
    sumSquares(perturbation) <= epsilon * epsilon and validImage perturbedImage =>
      advises perturbedImage label

 sumSquares : Image -> Real
 sumSquares perturbation = forall i . sum(pertubation ! i * pertubation ! i)

--- Exploring other definitions of robustness

-- Lipschitz robustness asserts that the distance between
-- the original output and the perturbed output is at most a constant L times the change in
-- the distance between the inputs.


-- Training for Lipschitz robustness. More recently, a third competing definition of
-- robustness has been proposed: Lipschitz robustness [2]. Inspired by the well-established
-- concept of Lipschitz continuity, Lipschitz robustness asserts that the distance between
-- the original output and the perturbed output is at most a constant Ltimes the change in
-- the distance between the inputs.

--- This is fine in Vehicle (compiles), but can't run as The Marabou query format currently doesn't support properties that involve multiple network applications.

l : Real
l = 10.0      -- Lipschitz constant


boundedPerturbation : Image -> Bool
boundedPerturbation perturbation = forall i j . -epsilon <= perturbation ! i ! j and perturbation ! i ! j <= epsilon


lipschitzConstraint : Image -> Image -> Bool
lipschitzConstraint x y =
  forall j .
    classifier x ! j - classifier y ! j <= l * epsilon and
    classifier y ! j - classifier x ! j <= l * epsilon

lipschitzRobust : Image -> Bool
lipschitzRobust image =
  forall perturbation .
    boundedPerturbation perturbation =>
    lipschitzConstraint image (image + perturbation)

@property
lipschitz : Vector Bool n
lipschitz = foreach i . lipschitzRobust (trainingImages ! i)
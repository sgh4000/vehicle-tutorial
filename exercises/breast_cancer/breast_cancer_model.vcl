-- Veryfying the breast canser

--------------------------------------------------------------------------------
-- Inputs

type Input = Tensor Real [9]

-- add meaningful names for the input indices.
Cl_thickness     = 0   
Cell_size        = 1   
Cell_shape       = 2   
Marg_adhesion    = 3  
Epith_c_size     = 4
Bare_nuclei      = 5   
Bl_cromatin      = 6  
Normal_nucleoli  = 7  
Mitoses          = 8


--------------------------------------------------------------------------------
-- Outputs

type Output = Tensor Real [2]

-- add meaningful names for the output indices.
NonCancer   = 0
Cancer      = 1


--------------------------------------------------------------------------------
-- Network

-- use the `network` annotation to declare the name and the type of the network
@network
cancer : Input -> Output


--------------------------------------------------------------------------------
-- Check input data validity
-- Define normal input ranges (based on training data - min, max values)
normalInput: Input -> Bool
normalInput x = forall i . 
    1 <= x ! i <= 10

validInput : Input -> Bool
validInput x = normalInput x

--------------------------------------------------------------------------------
-- IS MAX Or NOT
isMax : Index 2 -> Input -> Bool
isMax i x = 
    let scores = cancer x in
    forall d . d != i => scores ! i > scores ! d
    
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Property 0

-- Speccification

@property                                      
property0 : Bool
property0 = forall x . 
    validInput x and (x ! Cl_thickness == 1)
    => isMax NonCancer x


@property                                      
property1 : Bool
property1 = forall x . 
    validInput x and (x ! Cl_thickness >= 8)
    => isMax Cancer x


@property
property2 : Bool
property2 = forall x . 
    validInput x and (x ! Cell_size <= 6) and (x ! Cell_shape >= 8)
    => isMax Cancer x


@property
property3 : Bool
property3 = forall x . 
    validInput x and (x ! Marg_adhesion <= 6)
    => isMax Cancer x


@property
property4 : Bool
property4 = forall x . 
    validInput x and 
    x ! Bl_cromatin <= 2 and 
    x ! Cell_size <= 2 and
    x ! Cell_shape <= 2 and
    x ! Epith_c_size <= 2 and 
    x ! Marg_adhesion <= 2 
    => isMax NonCancer x

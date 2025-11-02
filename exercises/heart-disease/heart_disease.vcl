-- I trained this NN in colab, data citation: Janosi, A., Steinbrunn, W., Pfisterer, M., & Detrano, R. (1989). Heart Disease [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C52P4X.

Input = Tensor Real [20]

type Label = Index 2

---------------- Inputs

age_years = 0
resting_bp = 1
serum_chol = 2
max_heart_rate = 3
st_depression = 4
is_male = 5
chest_pain_atypical_angina = 6
chest_pain_non_anginal = 7
chest_pain_asymptomatic = 8
high_fasting_blood_sugar = 9
ecg_st_t_abnormality = 10
ecg_left_ventricular_hypertrophy = 11
exercise_induced_angina = 12
st_slope_flat = 13
st_slope_downsloping = 14
vessels_1 = 15
vessels_2 = 16
vessels_3 = 17
thal_fixed_defect = 18
thal_reversible_defect = 19

---------------- Output

type Output = Tensor Real [2]

no_disease = 0
disease = 1

---------------- Network

@network
heart_disease : Input -> Output

---------------- Max and Min input values

type UnnormalisedInput = Tensor Real [20]

-- Taken from feature_mins.values
minimumInputValues : UnnormalisedInput
minimumInputValues = [29,94,126,71,0.0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

-- Taken from feature_maxs.values
maximumInputValues : UnnormalisedInput
maximumInputValues = [77,200,564,202,6.2,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3]

-- Checks that an input vector is within the expected ranges
validInput : UnnormalisedInput -> Bool
validInput x = forall i . minimumInputValues ! i <= x ! i <= maximumInputValues ! i

-- Taken from scaler.mean_
meanScalingValues : UnnormalisedInput
meanScalingValues = [54.55,130.96,249.84,149.96,1,0.68,0.17,0.26,0.48,0.14,0,0.49,0.33,0.45,0.07,0.22,0.12,0.05,0.05,0.39]

-- Taken from scaler.scale_
scaleValues : UnnormalisedInput
scaleValues = [8.98,17.59,52.74,22.64,1.12,0.47,0.38,0.44,0.5,0.35,0.06,0.5,0.47,0.5,0.25,0.41,0.32,0.22,0.21,0.49]

normalise : UnnormalisedInput -> Input
normalise x = foreach i .
  (x ! i - meanScalingValues ! i) / scaleValues ! i


normHeartDisease : UnnormalisedInput -> Output
normHeartDisease x = heart_disease (normalise x)

predictsHeartDisease : UnnormalisedInput -> Bool
predictsHeartDisease x = (normHeartDisease x ! 0) >= 0.5

notPredictsHeartDisease : UnnormalisedInput -> Bool
notPredictsHeartDisease x = (normHeartDisease x ! 0) <= 0.499

epsilon = 0.001
maximalScore : Index 2 -> UnnormalisedInput -> Bool
maximalScore i x =
  forall j . i != j => heart_disease x ! i >= heart_disease x ! j + epsilon

---------------- Property 1 - Very high risk patient

superHighRisk : UnnormalisedInput -> Bool
superHighRisk x =
    (x ! age_years >= 65) and
    (x ! max_heart_rate <= 80) and
    (x ! serum_chol >= 280) and
    (x ! st_depression >= 1.5) and
    (x ! thal_fixed_defect == 1)

@property
property1 : Bool
property1 = forall y .
  validInput y and superHighRisk y =>
    maximalScore disease y

----------------- Property 2 - Healthy young patient other than chest pain

youngChestPain : UnnormalisedInput -> Bool
youngChestPain x = 
  x ! age_years <= 40 and
  x ! chest_pain_atypical_angina == 1 and
  x ! exercise_induced_angina == 1

@property
property2 : Bool
property2 = forall y .
  validInput y and youngChestPain y=>
    maximalScore disease y

---------------- Property 3 - Young patient with normal vitals

--- Young patient with normal vitals and no issues

youngNormalVitals : UnnormalisedInput -> Bool
youngNormalVitals x = 
  x ! age_years <= 40 and
  x ! serum_chol <= 120 and
  x ! st_depression == 0 and
  x ! max_heart_rate >= 210 and
  x ! chest_pain_atypical_angina == 0 and
  x ! chest_pain_non_anginal == 0 and
  x ! chest_pain_asymptomatic == 0 and
  x ! vessels_1 == 0 and
  x ! vessels_2 == 0 and
  x ! vessels_3 == 0 and
  x ! exercise_induced_angina == 0 and
  x ! thal_fixed_defect == 0 and
  x ! thal_reversible_defect == 0

@property
property3 : Bool
property3 = forall y .
  validInput y and youngNormalVitals y=>
    maximalScore no_disease y

----------------- Property 4 - Healthy senior

--- Healthy female senior: Age 60–65 but excellent vitals: cholesterol ≤ 220, max heart rate ≥ 140, ST depression = 0, no chest pain

healthySenior : UnnormalisedInput -> Bool
healthySenior x = 
  60 <= x ! age_years <= 65 and
  x ! is_male == 0 and
  x ! serum_chol <= 120 and
  x ! st_depression == 0 and
  x ! max_heart_rate >= 210 and
  x ! chest_pain_atypical_angina == 0 and
  x ! chest_pain_non_anginal == 0 and
  x ! chest_pain_asymptomatic == 0 and
  x ! vessels_1 == 0 and
  x ! vessels_2 == 0 and
  x ! vessels_3 == 0 and
  x ! exercise_induced_angina == 0 and
  x ! thal_fixed_defect == 0 and
  x ! thal_reversible_defect == 0

@property
property4 : Bool
property4 = forall y .
  validInput y and healthySenior y=>
    maximalScore no_disease y

----------------- Property 5 - Anyone with really high cholesterol and really low max heart rate

--- Cholesterol >= 300

highCholesterol : UnnormalisedInput -> Bool
highCholesterol x = 
  x ! serum_chol >= 350 and
  (x ! max_heart_rate <= 80)

@property
property5 : Bool
property5 = forall y .
  validInput y and highCholesterol y=>
    maximalScore disease y

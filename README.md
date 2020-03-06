# opioidanalysis

Causal inference project for PUBLPOL 104: Economic Policy Analysis. In this project, we combine data from the CDC Wonder multiple-cause-of-death dataset and Census data to analyze the causal relationship between Medicaid expansion and opioid deaths. We use an interrupted-time-series / differences-in-differences approach, leveraging the fact that not all states chose to adopt the Medicaid expansion, along with the fact that different states expanded Medicaid access in different years. Below we show some key figures and results from the analysis.

## Exploratory Data Analysis

#### Overall opioid death rate in the US from 1999 to 2018
<img src="https://i.imgur.com/JS0LmSq.png" data-canonical-src="https://i.imgur.com/JS0LmSq.png" alt="Overall opioid death rate 1999-2018" width="auto" />

### Covariate analysis

#### Overall opioid death rate by gender in the US from 1999 to 2018
<img src="https://i.imgur.com/RBAO9Qg.png" data-canonical-src="https://i.imgur.com/RBAO9Qg.png" alt="Overall opioid death rate by gender in the US from 1999 to 2018" width="auto" />

#### Overall opioid death rate by race in the US from 1999 to 2018
<img src="https://i.imgur.com/9GiAdFK.png" data-canonical-src="https://i.imgur.com/9GiAdFK.png" alt="Overall opioid death rate by race in the US from 1999 to 2018" width="auto" />

### Stratifying by expansion vs non-expansion

#### Median income in expansion vs non-expansion states
<img src="https://i.imgur.com/qCBs0TU.png" data-canonical-src="https://i.imgur.com/qCBs0TU.png" alt="Median income in expansion vs non-expansion states" width="auto" />

#### Racial composition in expansion vs non-expansion states
<img src="https://i.imgur.com/mL5iNxP.png" data-canonical-src="https://i.imgur.com/mL5iNxP.png" alt="Racial composition in expansion vs non-expansion states" width="auto" />

#### Opioid death rate in expansion vs non-expansion states
Note that expansion for most states occurred in 2014.
<img src="https://i.imgur.com/g7KnA6C.png" data-canonical-src="https://i.imgur.com/g7KnA6C.png" alt="Opioid death rate in expansion vs non-expansion states" width="auto" />

## Regression results
We found significant evidence of an acceleration of opioid deaths over time after states expanded Medicaid.

#### Predicted trends in opioid death rate in non-expansion states and states that expanded in 2014
<img src="https://i.imgur.com/741edas.png" data-canonical-src="https://i.imgur.com/741edas.png" alt="Predicted trends in opioid death rate in non-expansion states and states that expanded in 2014" width="auto" />


#### Predicted trends in opioid death rate in non-expansion states and states
We include all states in our dataset, centering expansion states around the year they expanded Medicaid, and generate quadratic curves that describe opioid death rates over time. 
<img src="https://i.imgur.com/9n8WUFT.png" data-canonical-src="https://i.imgur.com/9n8WUFT.png" alt="Predicted trends in opioid death rate in non-expansion states and states" width="auto" />

#### Robustness check
We test our results if instead of centering around the expansion year, we center treatment states around the year 1, 2, and 3 years before they actually expanded. We find lower R^2 values and generally decreasing significance of coefficients; however, the effects do not totally disappear. Possible reasons include anticipatory effects by insurers.

<img src="https://i.imgur.com/WSdNcZ3.png" data-canonical-src="https://i.imgur.com/WSdNcZ3.png" alt="Robustness check" width="auto" />


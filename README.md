# Small Area Estimation (SAE) Package for Stata
A family of Stata functions for small area estimation, implementing multiple methodologies including the original ELL (Elbers, Lanjouw, and Lanjouw), and a revised Census Empirical Best (Census EB) approach based on the original work from Molina and Rao (2010). Both incorporating Henderson's Method III to obtain model parameters. The package also incorporates Molina and Rao's (2010) EB approach, as well as its two-fold nested error variant from Marhuenda, Molina, Morales, and Rao (2017).


## Latest Updates

The package now includes significant methodological improvements:

- **Revised Census EB Method**: A new implementation that shows substantial improvement over previous approaches
- **Improved Error Estimation**: Better MSE estimation through parametric bootstrap procedures
- **Enhanced Performance**: Significantly reduced bias and improved efficiency compared to previous methods
- **Heteroskedasticity Handling**: Better incorporation of heteroskedasticity and survey weights

## Overview

Small area estimation methods address low representativeness of surveys within areas or lack of data for specific areas/sub-populations by incorporating information from supplementary sources. This package allows users to:

- Combine survey data with census data, administrative records, or geospatial information  
- Generate reliable estimates for small geographic areas or subpopulations
- Calculate poverty and inequality indicators at disaggregated levels
- Process and analyze simulation results

## Key Features

- **Multiple Methodologies**: 
  - Traditional ELL approach
  - Molina and Rao's (2010) EB approach
  - Marhuenda et al's (2017) two-fold nested error EB approach
  - Census EB estimation
  - Parametric bootstrap MSE estimation
- **Modular Design**: Flexible architecture that can be expanded with new estimation techniques
- **Memory Efficient**: Handles large datasets through careful memory management
- **Various Indicators**: Calculates poverty (FGT) and inequality (Gini, GE) measures

## Installation

```stata
github install pcorralrodas/SAE-Stata-Package
```

## Main Commands

### Importing Census Data
```stata
sae data import, datain(string) varlist(string) area(string) uniqid(string) dataout(string)
```

## Model Selection and Estimation

### Model Types

#### 1. One-fold Nested Error Model with REML (EB)
```stata
// Does not incorporate weights or heteroskedasticity
sae model reml depvar indepvars [if] [in], area(varname) 
```
Use when:
- Survey weights not crucial
- Homoskedasticity assumed
- Estimates needed at single level
- Comparable to R's sae package implementation

#### 2. Two-fold Nested Error Model (EB two-fold)
```stata
// For estimates at two different aggregation levels
sae model reml2 depvar indepvars [if] [in], area(#) subarea(varname)
```
Use when:
- Point estimates needed at two levels
- Hierarchical identifiers available
- Survey weights not crucial
- Homoskedasticity assumed

#### 3. Henderson's Method III (H3) - CensusEB
```stata
// Incorporates weights and heteroskedasticity
sae model h3 depvar indepvars [if] [in] [aw], area(varname) [zvar(varnames) 
    yhat(varnames) yhat2(varnames) alfatest(new varname)]
```
Use when:
- Survey weights important
- Heteroskedasticity present
- Only one-fold nesting needed


### Simulation - example

### Monte Carlo Simulation
```stata
sae simulate reml/reml2/eb/ell depvar indepvar [if] [in] [aw pw fw], area(varname) [options]
```

## Estimation Methods

### Unit-Level Models (Recommended when census microdata is available)

#### Census EB (Preferred Approach)
- Makes efficient use of survey data through empirical best prediction
- More precise estimates compared to traditional ELL method  
- Conditions on survey sample data for sampled areas
- Incorporates heteroskedasticity and survey weights through H3 method
- Provides accurate MSE estimates via parametric bootstrap
- Optimal for cases with small sampling fractions (<4% of population)

#### Empirical Best (EB)
- Original method that conditions on survey sample data
- Requires matching survey and census locations
- Optimal predictor in terms of minimizing MSE under model
- Particularly effective for sampled areas
- Nearly identical to Census EB when sample fractions are small
- Replicates R's sae library using REML estimation

#### Two-fold Nested Error Models
- Provides optimal estimates at two different aggregation levels
- Useful when estimates needed at multiple geographic levels
- Currently available without survey weights/heteroskedasticity
- Requires hierarchical area identifiers
- Requires matching survey and census locations at both levels
- Example use case: estimates at both municipality and state levels
- Less efficient than one-fold model if second level not needed

#### Traditional ELL
- Traditional World Bank approach 
- Does not condition on survey data
- Less efficient estimates with larger MSEs
- MSE estimates may understate true error
- May be used when residuals are not normally distributed

### Transformation Methods - used for approximating normally distributed errors

- Log transformation (most common)
- Box-Cox transformation
- Log-shift transformation - with and without weights
- Should be chosen to best approximate normality

## Best Practices

### Model Selection
1. Consider data transformation to achieve normality
2. Remove non-significant covariates sequentially
3. Check for and remove high multicollinearity (VIF > 5)
4. Validate model assumptions and diagnostics

### Random Effects
- Specify random effects at same level as desired estimates
- Avoid estimating at higher levels than random effects
- Use two-fold nested models when estimates needed at multiple levels

### Data Requirements
1. Contemporaneous survey and census recommended
2. Variables must be measured consistently between sources
3. Compare variable distributions across sources
4. Verify survey weights can be replicated in census

### Alpha Model for Heteroskedasticity
- Consider when heteroskedasticity present
- Can improve estimates despite typically low R²
- Available with H3 estimation method
- Test residuals to determine if needed

### Validation Steps
1. Check model diagnostics and assumptions
2. Validate normality of residuals and random effects
3. Examine outliers and influential observations
4. Compare estimates to direct estimators where possible
5. Assess precision through MSE estimates

### MSE Estimation
- Use parametric bootstrap for Census EB
- Bootstrap procedure more computationally intensive but more accurate
- Consider minimum 100 Monte Carlo simulations
- Recommended 200+ bootstrap replications for MSE

### Common Pitfalls to Avoid
1. Specifying random effects at wrong level
2. Residuals are not normally distributed
3. Ignoring heteroskedasticity when present
4. Inadequate model validation
5. Not comparing covariates between census and survey

## Citation

If you use this package in your research, please cite:

```
Corral Rodas, P., Molina, I., & Nguyen, M. (2021). Pull your small area estimates up by the bootstraps. Journal of Statistical Computation and Simulation.

Nguyen, M. C., Corral Rodas, P., Azevedo, J. P., & Zhao, Q. (2017). Small Area Estimation: An extended ELL approach. World Bank.
```

## References

- Corral Rodas, P., Molina, I., & Nguyen, M. (2021). Pull your small area estimates up by the bootstraps. Journal of Statistical Computation and Simulation.
- Elbers, C., Lanjouw, J. O., & Lanjouw, P. (2003). Micro-level estimation of poverty and inequality. Econometrica, 71(1), 355-364.
- Corral Rodas, P., Molina, I., Cojocaru, A., and Segovia, S. (2022). Guidelines to small area estimation for poverty mapping. The World Bank, Washington, DC.
- Molina, I. and Rao, J. (2010). Small area estimation of poverty indicators. Canadian Journal of Statistics, 38(3):369–385.
- Marhuenda, Y., Molina, I., Morales, D., & Rao, J. (2017). Poverty mapping in small areas under a twofold nested error regression model. Journal of the Royal Statistical Society: Series A (Statistics in Society), 180 (4), 1111–1136
- Van der Weide, R. (2014). GLS estimation and empirical bayes prediction for linear mixed models with heteroskedasticity and sampling weights: A background study for the povmap project. World Bank Policy Research Working Paper, (7028).

# Authors

- **Minh Cong Nguyen**  
  The World Bank  
  mnguyen3@worldbank.org

- **Paul Corral Rodas**  
  The World Bank  
  pcorralrodas@worldbank.org

- **João Pedro Azevedo**  
  The World Bank  
  jazevedo@worldbank.org

- **Qinghua Zhao**  
  The World Bank

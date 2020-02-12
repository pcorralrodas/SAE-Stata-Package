{smcl}
{* *! version 1.0.0  11Jan2020}{...}
{cmd:help sae_ell}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{cmd:sae model/sim ell} {hline 1}} Replicates ELL methods and is similar to PovMap - based on Elbers, Lanjouw, and Lanjouw (2010). 
{p2colreset}{...}

{title:Syntax}

{p 8 23 2}
{opt sae model ell} {varlist} {ifin} {weight} {cmd:,}
{opt area(varname)}
[
{opt vce(string)}
{opt alfatest(varname)}
{opt Zvar(varlist numeric fv)} 
{opt yhat(varlist numeric fv)} 
{opt yhat2(varlist numeric fv)}
]

{p 8 23 2}
{opt sae sim elleb} {varlist} {ifin} {weight} {cmd:,}
{opt area(varname)}
{opt UNIQid(varname numeric)}
{opt rep(integer)}
{opt matin(string)}
{opt INDicators(string)} 
{opt aggids(numlist sort)}
{opt pwcensus(string)}
{opt ETA(string)}
{opt EPSilon(string)}
[
{opt ydump(string)}
{opt addvars(string)}
{opt vce(string)}
{opt allmata}
{opt lny}
{opt Zvar(varlist numeric fv)} 
{opt yhat(varlist numeric fv)} 
{opt yhat2(varlist numeric fv)}
{opt seed(string)}
{opt plinevar(string)} 
{opt PLINEs(numlist sort)}
]

{title:Description}

{pstd}
{cmd:sae model/sim ell} Implements the modeling/simulation stage of ELL in similar fashion to PovMap.

{title:Options}

{marker Modeling}{...}
{dlgtab:Modeling}
{synopthdr:Required}
{synoptline}
{phang}
{opt area(varname)} Option is necessary and indicates variable denoting level of area effect. The only constraint is that the variable must be numeric and should match across datasets (survey and census), although it is recommended it follows a hierarchical structure similar to the one proposed by Zhao (2006).

{synopthdr:Optional}
{synoptline}

{phang}
{opt vce(string)} The default option is the variance covariance matrix from a roubst regression, the user may specify robust or clustered variance covariance matrix to replicate the results from the regress command.

{phang}
{opt Zvar(varlist numeric fv)} The zvar option is necessary for specifying the alpha model, the user must place the independent variables of the alpha model (Heteroskedasticity) under the option.

{phang}
{opt yhat(varlist numeric fv)} The yhat option is also a part of the alpha model. Variables listed here will be interacted with the predicted y hat from the OLS model.

{phang}
{opt yhat2(varlist numeric fv)} The yhat2 option is also a part of the alpha model. Variables listed here will be interacted with the predicted y hat squared from the OLS model.


{marker Simulation}{...}
{dlgtab:Simulation}
{synopthdr:Required}
{synoptline}
{phang}
{opt area(varname)} Option is necessary and indicates variable denoting level of area effect. The only constraint is that the variable must be numeric and should match across datasets (survey and census), although it is recommended it follows a hierarchical structure similar to the one proposed by Zhao (2006).

{phang}
{opt UNIQid(varname numeric)} option specifies the numeric variable that indicates the unique identifiers in the census and survey dataset. This is necessary to ensure replicability of the analysis, and the name should match the one of the unique identifier from the source dataset.

{phang}
{opt rep(integer)} Indicates the number of Montecarlo Simulations to be executed.

{phang}
{opt matin(string)} The matin option indicates the path and filename of the Mata format target dataset. The dataset must created with the sae data import command; it is necessary.

{phang}
{opt aggids(numlist sort)} The aggids option indicates the different aggregation levels for which the indicators are to be obtained, values placed here tell the command how many digits to the left to move to get the indicators at that level. Using the same hierarchical id specified in the area option, AAMMEEE, if the user specifies 0, 3, 5, and 7, it would lead to aggregates at each of the levels E, M, A and the national level. Note that it is NOT advised to report results at a higher level than that of area(), it is likely that the MSE is underestimated. Users should specify 0 if they are not using a hierarchical id.

{phang}
{opt pwcensus(string)} Indicates the variable which corresponds to the expansion factors to be used in the target (census) dataset, it must always be specified. The user must have added the variable to the imported data (sae data import) i.e. the census data. 

{phang}
{opt INDicators(string)}  The indicators option is used to request the indicators to be estimated from the
simulated vectors of welfare. Possible indicators are: fgt0, fgt1, fgt2, ge0, ge1, ge2

{phang}
{opt ETA(string)} available options are normal and non-normal, indicates how eta is simulated.

{phang}
{opt EPSilon(string)} available options are normal and non-normal, indicates how epsilon is simulated.

{synopthdr:Optional}
{synoptline}

{phang}
{opt ydump(string)} The ydump option is necessary for the second stage of the analysis. The user must provide path and filename for a Mata format dataset to be created with the simulated dependent variables.

{phang}
{opt addvars(string)} The addvars option allows users to add variables to the dataset created from the simulations. These variables must have been included into the target dataset created with the sae data import command.

{phang}
{opt vce(string)} The default option is the variance covariance matrix from a roubst regression, the user may specify robust or clustered variance covariance matrix to replicate the results from the regress command.

{phang}
{opt Zvar(varlist numeric fv)} The zvar option is necessary for specifying the alpha model, the user must place the independent variables of the alpha model (Heteroskedasticity) under the option.

{phang}
{opt yhat(varlist numeric fv)} The yhat option is also a part of the alpha model. Variables listed here will be interacted with the predicted y hat from the OLS model.

{phang}
{opt yhat2(varlist numeric fv)} The yhat2 option is also a part of the alpha model. Variables listed here will be interacted with the predicted y hat squared from the OLS model.

{phang}
{opt lny} option indicates that the dependent variable in the welfare model is in log form. This is relevant for the second stage of the analysis in order to get appropriate simulated values.

{phang}
{opt seed(integer)} option is necessary for the second stage of the analysis and ensures replicability. Users should be aware that Stata’s default pseudo-random number generator in Stata 14 is different than that of previous versions.

{phang}
{opt plinevar(string)}  option allows users to indicate a variable in the target data set which is to be used as the threshold for the Foster Greer Thorbeck indexes (Foster, Greer, and Thorbeck 1984) to be predicted from the second stage simulations. The user must have added the variable in the sae data import command when preparing the target dataset. Only one variable may be specified.

{phang}
{opt PLINEs(numlist sort)} option allows users to explicitly indicate the threshold to be used, this option is preferred when the threshold is constant across all observations. Additionally, it is possible to specify multiple lines, separated by a space.

{phang}
{opt allmata} The allmata option skips use of the plugin and does all poverty calculations in Mata.


{title:Examples:}

//Modeling stage: ELL estimates
sae model ell Y x1 x2 x3 x4 x5 x6, area(area) 

//Simulation stage: ELL-EB estimates
sae sim ell Y x1 x2 x3 x4 x5 x6, area(area) eta(normal) epsilon(normal) ///
matin("censo") lny seed(31916) rep(500) ///
pwcensus(hhsize) indicators(FGT0 FGT1 FGT2) aggids(0) uniq(hhid_n) plines(16.2) allmata

{title:Authors:}

{pstd}
Minh Cong Nguyen{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
mnguyen3@worldbank.org{p_end}

{pstd}
Paul Corral{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
pcorralrodas@worldbank.org{p_end}

{pstd}
Joao Pedro de Azevedo{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
jazevedo@worldbank.org{p_end}




{title:References}

{pstd}
Molina, I., Marhuenda, Y. (2015). R package sae: Methodology.

{pstd}
Corral, P., Molina, I., Nguyen, M. (2020). Pull your small area estimates up by your bootstraps, MIMEO.

{pstd}
Molina, I. and Rao, J. (2010). Small area estimation of poverty indicators. Canadian Journal of Statistics, 38(3):369–385.

{pstd}
Elbers, C., J. O. Lanjouw, and P. Lanjouw (2003). Micro–level estimation of poverty and inequality. Econometrica 71 (1), 355–364.



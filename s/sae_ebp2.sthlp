{smcl}
{* *! version 1.0.0  17Dec2020}{...}
{cmd:help sae_ebp_two}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{cmd:sae model/sim reml2} {hline 1}} Restricted max. likelihood fitted model with Marhuenda et al. (2017) twofold nested error with EB estimation and Bootstrap MSE. {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 23 2}
{opt sae model reml2} {varlist} {ifin} {cmd:,}
{opt area(numlist max=1) subarea(varname numeric)}

{p 8 23 2}
{opt sae sim reml2} {varlist} {ifin} {cmd:,}
{opt subarea(varname numeric)}
{opt area(numlist max=1)}
{opt UNIQid(varname numeric)}
{opt mcrep(integer)}
{opt bsrep(integer)}
{opt matin(string)}
{opt INDicators(string)} 
{opt aggids(numlist sort)}
{opt pwcensus(string)}
[
{opt pwsurvey(string)}
{opt lny}
{opt bcox}
{opt lnskew}
{opt CONStant(real 0.0)}
{opt seed(string)}
{opt plinevar(string)} 
{opt PLINEs(numlist sort)}
{opt appendsvy}
]

{title:Description}

{pstd}
{cmd:sae model/sim reml2} Supports Marhuenda et al. (2017) EB small area estimation methods with twofold nested errors.  

{title:Options}

{marker Modeling}{...}
{dlgtab:Modeling}
{synopthdr:Required}
{synoptline}
{phang}
{opt subarea(varname)} Option is necessary and indicates variable denoting level of area effect. The only constraint is that the variable must be numeric and should match across datasets (survey and census). The variable must follow a hierarchical structure similar to the one proposed by Zhao (2006). SSAAAMMMM, where SS indicate states, AA indicate areas, and MMMM indicate municipalities.

{phang}
{opt area(varname)} Option is necessary and indicates the aggregation level for the larger area. Values placed here tell the command how many digits to the left to move the hierarchical id placed in the subarea() option to arrive at the larger area. For example using the id from above, if the random effect for the larger area should correspond to areas, then here you should place a value of 4. Note that the structure of the id needs to be the same across Census and survey data.


{marker Simulation}{...}
{dlgtab:Simulation}
{synopthdr:Required}
{synoptline}
{phang}

{phang}
{opt area(varname)} Option is necessary and indicates variable denoting level of area effect. The only constraint is that the variable must be numeric and should match across datasets (survey and census), although it is recommended it follows a hierarchical structure similar to the one proposed by Zhao (2006).

{phang}
{opt UNIQid(varname numeric)} option specifies the numeric variable that indicates the unique identifiers in the census and survey dataset. This is necessary to ensure replicability of the analysis, and the name should match the one of the unique identifier from the source dataset.

{phang}
{opt mcrep(integer)} Indicates the number of Montecarlo Simulations to be executed.

{phang}
{opt bsrep(integer)} Indicates the number of Bootstrap populations to be executed to obtain the MSE estimate. Note that every bootstrap population will execute the number of Montecarlo simulations indicated in mcrep().

{phang}
{opt matin(string)} The matin option indicates the path and filename of the Mata format target dataset. The dataset must created with the sae data import command; it is necessary.

{phang}
{opt INDicators(string)}  The indicators option is used to request the indicators to be estimated from the
simulated vectors of welfare. Possible indicators are: fgt0, fgt1, fgt2, ge0, ge1, ge2

{phang}
{opt aggids(numlist sort)} The aggids option indicates the different aggregation levels for which the indicators are to be obtained, values placed here tell the command how many digits to the left to move to get the indicators at that level. Using the same hierarchical id specified in the area option, AAMMEEE, if the user specifies 0, 3, 5, and 7, it would lead to aggregates at each of the levels E, M, A and the national level. Note that it is NOT advised to report results at a higher level than that of area(), it is likely that the MSE is underestimated. Users should specify 0 if they are not using a hierarchical id.

{phang}
{opt pwcensus(string)} Indicates the variable which corresponds to the expansion factors to be used in the target (census) dataset, it must always be specified. The user must have added the variable to the imported data (sae data import) i.e. the census data. 

{synopthdr:Optional}
{synoptline}

{phang}
{opt pwsurvey(string)} Optional, and only necessary if users are using the appendsvy option.

{phang}
{opt lny} option indicates that the dependent variable in the welfare model is in log form. This is relevant for the second stage of the analysis in order to get appropriate simulated values.

{phang}
{opt bcox} Option tells command to execute bcskew0 (Box-Cox transform - Zero skewness) on the dependent variable of your model.

{phang}
{opt lnskew} Option tells command to execute lnskew0 (log shift transform - Zero skewness) on the dependent variable of your model.

{phang}
{opt CONStant(real 0.0)} Option adds constant value to dependent variable when doing Box-Cox transformation. If bcox is not specified this is irrelevant.

{phang}
{opt seed(integer)} option is necessary for the second stage of the analysis and ensures replicability. Users should be aware that Stata’s default pseudo-random number generator in Stata 14 is different than that of previous versions.

{phang}
{opt plinevar(string)}  option allows users to indicate a variable in the target data set which is to be used as the threshold for the Foster Greer Thorbeck indexes (Foster, Greer, and Thorbeck 1984) to be predicted from the second stage simulations. The user must have added the variable in the sae data import command when preparing the target dataset. Only one variable may be specified.

{phang}
{opt PLINEs(numlist sort)} option allows users to explicitly indicate the threshold to be used, this option is preferred when the threshold is constant across all observations. Additionally, it is possible to specify multiple lines, separated by a space.


{title:Example}
sae sim reml2 Y x1 x2 x3 x4 x5 x6,  area(area)  ///
mcrep(200) bsrep(200) matin("census") lny seed(31916) ///
pwcensus(hhsize) indicators(FGT0 FGT1 FGT2) aggids(0) uniq(hhid_n) plines(16.2)


{title:Authors}	
	{p 4 4 2}Minh Cong Nguyen, mnguyen3@worldbank.org{p_end}
	{p 4 4 2}Paul Andres Corral Rodas, pcorralrodas@worldbank.org{p_end}
	{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
	{p 4 4 2}Qinghua Zhao, qzhao@worldbank.org{p_end}
	{p 4 4 2}World Bank{p_end}


{title:References}

{pstd}
Marhuenda, Y., Molina, I., Morales, D., & Rao, J. (2017). Poverty mapping in small areas under a twofold nested error regression model. Journal of the Royal Statistical Society: Series A (Statistics in Society), 180 (4), 1111–1136.





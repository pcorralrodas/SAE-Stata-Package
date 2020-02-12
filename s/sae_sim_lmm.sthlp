{smcl}
{* *! version 1.0.0  18nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae sim lmm" "mansection SAE saesimlmm"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "[SAE] sae sim lmm" "help sae_sim_lmm"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae sim fh" "help sae_sim_fh"}{...}
{viewerjumpto "Syntax" "sae_sim_lmm##syntax"}{...}
{viewerjumpto "Description" "sae_sim_lmm##description"}{...}
{viewerjumpto "Options" "sae_sim_lmm##options"}{...}
{viewerjumpto "Remarks" "sae_sim_lmm##examples"}{...}
{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{manlink sae sim lmm} {hline 2}}simulate sae data with linear mixed model
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:sae sim lmm} {depvar} {indepvars} {ifin} [{it:{help weight##weight:weight}}] {cmd:,} {cmd:area(}{it:varname numeric}{cmd:)} {cmd:varest(}{it:string}{cmd:)} 
{cmd:eta(}{it:string}{cmd:)} {cmd:epsilon(}{it:string}{cmd:)} {cmd:uniqid(}{it:varname numeric}{cmd:)}
[{cmd:zvar(}{it:varlist}{cmd:)} {cmd:yhat(}{it:varlist}{cmd:)} {cmd:yhat2(}{it:varlist}{cmd:)} {cmd:vce(}{it:string}{cmd:)}
{cmd:psu(}{it:varname numeric}{cmd:)} {cmd:matin(}{it:string}{cmd:)}
{cmd:pwcensus(}{it:string}{cmd:)} {cmd:rep(}{it:integer 1}{cmd:)} {cmd:seed(}{it:integer 123456789}{cmd:)} {cmd:bootstrap} {cmd:ebest}
{cmd:colprocess(}{it:integer 1}{cmd:)} {cmd:lny} {cmd:addvars(}{it:string}{cmd:)} {cmd:ydump(}{it:string}{cmd:)} {cmd:plinevar(}{it:varname numeric}{cmd:)}
{cmd:plines(}{it:numlist sort}{cmd:)} {cmd:aggids(}{it:numlist sort}{cmd:)} {cmd:indicators(}{it:string}{cmd:)} {cmd:results(}{it:string}{cmd:)} {cmd:allmata}]

{marker description}{...}
{title:Description}

{p 4 4 2}
This {cmd:sae} {cmd:sim} {cmd:lmm} export  is useful for bringing in the simulated vectors created by {cmd:sae} into Stata. 
It provides the user the ability to further manipulate these vectors. Due to the unique structure of the Mata data, this command will only
work with data created in the simulation stage.

{marker options}{...}
{title:Options}

{dlgtab:Required}

{p 4 8 2}
{cmd:area(}{it:varname numeric}{cmd:)}: The area option is necessary and specifies at which level the clustering is done, it indicates
at which level the eta_c is obtained at. The only constraint is that the variable must be numeric and
should match across datasets, although it is recommended it follows a hierarchical structure similar to
the one proposed by Zhao (2006).

{p 8 8 2}
Note: The hierarchical id should be of the same length for all observations, for example: AAMMEEE. In the case this were done for a specific country, AA stands for the highest aggregation level, MM stands for the second
highest aggregation level, and EEE, stands for the lowest aggregation level.

{p 4 8 2}
{cmd:varest(}{it:string}{cmd:)}: The varest option allows the user to select between H3 or ELL methods for obtaining the
variance of the decomposed first stage residuals. The selection has repercussions on the options available
afterwards. For example, if the the user selects H3, parameters must be obtained via bootstrapping.

{p 4 8 2}
{cmd:eta(}{it:string}{cmd:)}: The eta option allows users to specify how they would like to draw eta_c for the different clusters
in the second stage of the analysis. The available options are normal and non-normal. If non-normal is chosen empirical Bayes is not available to users.

{p 4 8 2}
{cmd:epsilon(}{it:string}{cmd:)}: The epsilon option allows users to specify how they would like to draw epsilon_ch for the
different observations in the second stage of the analysis. The available options are normal and nonnormal. If non-normal is chosen empirical Bayes is not available to users.

{p 4 8 2}
{cmd:uniqid(}{it:varname numeric}{cmd:)}: The uniqid option specifies the numeric variable that indicates the unique identifiers in
the source and target dataset. This is necessary to ensure replicability of the analysis.

{dlgtab:Optional}

{p 4 8 2}
{cmd:vce(}{it:string}{cmd:)}: The vce option allows users to replicate the variance covariance matrix from the OLS in the
PovMap 2.5 software. The default option is the variance covariance matrix from the PovMap software,
vce(ell), the user may specify robust or clustered variance covariance matrix to replicate the results
from the regress command.

{p 4 8 2}
{cmd:zvar(}{it:varlist}{cmd:)}: The zvar option is necessary for specifying the alpha model, the user must place the independent
variables under the option

{p 4 8 2}
{cmd:yhat(}{it:varlist}{cmd:)}: The yhat option is also a part of the alpha model. Variables listed here will be interacted
with the predicted y_hat = X*beta from the OLS model.

{p 4 8 2}
{cmd:yhat2(}{it:varlist}{cmd:)}: The yhat2 option is also a part of the alpha model. Variables listed here will be interacted
with the predicted y2_hat = (X*beta)^2 from the OLS model.

{p 4 8 2}
{cmd:psu(}{it:varname numeric}{cmd:)}: The psu option indicates the numeric variable in the source data for the level at which bootstrapped
samples are to be obtained. This option is required for the cases when obtaining bootstrapped
parameters is necessary. If not specified, the level defaults to the cluster level, that is the level specified
in the area option.

{p 4 8 2}
{cmd:matin(}{it:string}{cmd:)}: The matin option indicates the path and filename of the Mata format target dataset. The
dataset is created from the sae data import command; it is necessary for the second stage.

{p 4 8 2}
{cmd:pwcensus(}{it:string}{cmd:)}: The pwcensus option indicates the variable which corresponds to the expansion factors
to be used in the target dataset, it must always be specified for the second stage. The user must have
added the variable to the imported data (sae data import) i.e. the target data.

{p 4 8 2}
{cmd:rep(}{it:integer 1}{cmd:)}: The rep option is necessary for the second stage, and indicates the number of Monte-Carlo
simulations to be done in the second stage of the procedure.

{p 4 8 2}
{cmd:seed(}{it:integer 123456789}{cmd:)}: The seed option is necessary for the second stage of the analysis and ensures replicability.
Users should be aware that Stata’s default pseudo-random number generator in Stata 14 is different
than that of previous versions.

{p 4 8 2}
{cmd:bootstrap}: The bootstrap option indicates that the parameters used for the second stage of the
analysis are to be obtained via bootstrap methods. If this option is not specified the default method
is parametric drawing of the parameters.

{p 4 8 2}
{cmd:ebest}: The ebest option indicates that empirical Bayes methods are to be used for the second
stage. If this option is used, it is necessary that eta(normal), epsilon(normal), and bootsrap
options be used.

{p 4 8 2}
{cmd:colprocess(}{it:integer 1}{cmd:)}: The colprocess option is related to the processing of the second stage. Because of
the potential large size of the target data set the default is one column at a time, this however may be
increased with potential gains in speed.

{p 4 8 2}
{cmd:lny}: The lny option indicates that the dependent variable in the welfare model is in log form. This
is relevant for the second stage of the analysis in order to get appropriate simulated values.

{p 4 8 2}
{cmd:addvars(}{it:string}{cmd:)}: The addvars option allows users to add variables to the dataset created from the simulations.
These variables must have been included into the target dataset created with the sae data
import command.

{p 4 8 2}
{cmd:ydump(}{it:string}{cmd:)}: The ydump option is necessary for the second stage of the analysis. The user must provide
path and filename for a Mata format dataset to be created with the simulated dependent variables.

{p 4 8 2}
{cmd:plinevar(}{it:varname numeric}{cmd:)}: The plinevar option allows users to indicate a variable in the target data set which is
to be used as the threshold for the Foster Greer Thorbeck indexes (Foster, Greer, and Thorbeck 1984)
to be predicted from the second stage simulations. The user must have added the variable in the sae
data import command when preparing the target dataset. Only one variable may be specified.

{p 4 8 2}
{cmd:plines(}{it:numlist sort}{cmd:)}: The plines option allows users to explicitly indicate the threshold to be used, this option
is preferred when the threshold is constant across all observations. Additionally, it is possible to specify
multiple lines, separated by a space.

{p 4 8 2}
{cmd:indicators(}{it:string}{cmd:)}: The indicators option is used to request the indicators to be estimated from the
simulated vectors of welfare. The list of possible indicators is:
– The set of Foster Greer Thorbeck indexes (Foster, Greer, and Thorbeck 1984) FGT0, FGT1, and
FGT2 ; also known as poverty head count, poverty gap, and poverty severity respectively.
– The set of inequality indexes: Gini, and Generalized Entropy Index with alpha = 0, 1, 2
– Set of Atkinson indexes

{p 4 8 2}
{cmd:aggids(}{it:numlist sort}{cmd:)}: The aggids option indicates the different aggregation levels for which the indicators are
to be obtained, values placed here tell the command how many digits to the left to move to get the
indicators at that level. Using the same hierarchical id specified in the area option, AAMMEEE, if
the user specifies 0, 3, 5, and 7 would lead to aggregates at the each of the levels E, M, A and the
national level.

{p 4 8 2}
{cmd:results(}{it:string}{cmd:)}: The results option specifies the path and filename for users to save as a txt file the
results the analysis specified in the indicators option.

{p 4 8 2}
{cmd:allmata}: The allmata option skips use of the plugin and does all poverty calculations in Mata.

{title:Saved Results}

{cmd:sae} {cmd:sim} returns results in {hi:e()} format. By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(cmdline)}}the code line used in the session {p_end}

{marker examples}{...}
{title:Examples}

{p 4 4 2}
Due to the unique structure of the Mata data, this command will only work with data created in the simulation stage.

{title:References}

{p 4 4 2} Bedi, T., A. Coudouel, and K. Simler (2007). More than a pretty picture: using poverty maps to design
better policies and interventions. World Bank Publications.{p_end}
{p 4 4 2}Demombynes, G., C. Elbers, J. O. Lanjouw, and P. Lanjouw (2008). How good is a map? putting small
area estimation to the test. Rivista Internazionale di Scienze Sociali, 465–494.{p_end}
{p 4 4 2}Elbers, C., J. O. Lanjouw, and P. Lanjouw (2002). Micro-level estimation of welfare. 2911.{p_end}
{p 4 4 2}Elbers, C., J. O. Lanjouw, and P. Lanjouw (2003). Micro–level estimation of poverty and inequality. Econometrica
71 (1), 355–364.{p_end}
{p 4 4 2}Foster, J., J. Greer, and E. Thorbecke (1984). A class of decomposable poverty measures. Econometrica:
Journal of the Econometric Society, 761–766.{p_end}
{p 4 4 2}Harvey, A. C. (1976). Estimating regression models with multiplicative heteroscedasticity. Econometrica:
Journal of the Econometric Society, 461–465.{p_end}
{p 4 4 2}Haslett, S., M. Isidro, and G. Jones (2010). Comparison of survey regression techniques in the context of
small area estimation of poverty. Survey Methodology 36 (2), 157–170.{p_end}
{p 4 4 2}Henderson, C. R. (1953). Estimation of variance and covariance components. Biometrics 9 (2), 226–252.{p_end}
{p 4 4 2}Huang, R. and M. Hidiroglou (2003). Design consistent estimators for a mixed linear model on survey data.{p_end}
{p 4 4 2}Proceedings of the Survey Research Methods Section, American Statistical Association (2003), 1897–1904.{p_end}
{p 4 4 2}Molina, I. and J. Rao (2010). Small area estimation of poverty indicators. Canadian Journal of Statistics
38 (3), 369–385.{p_end}
{p 4 4 2}Rao, J. N. and I. Molina (2015). Small area estimation. John Wiley & Sons.{p_end}
{p 4 4 2}Tarozzi, A. and A. Deaton (2009). Using census and survey data to estimate poverty and inequality for
small areas. The review of economics and statistics 91 (4), 773–792.{p_end}
{p 4 4 2}Van der Weide, R. (2014). GLS estimation and empirical bayes prediction for linear mixed models with
heteroskedasticity and sampling weights: a background study for the povmap project. World Bank Policy
Research Working Paper (7028).{p_end}
{p 4 4 2}Zhao, Q. (2006). User manual for povmap. World Bank. http://siteresources.worldbank.org/INTPGI/
Resources/342674-1092157888460/Zhao_ManualPovMap.pdf .{p_end}

{title:Authors}	
	{p 4 4 2}Minh Cong Nguyen, mnguyen3@worldbank.org{p_end}
	{p 4 4 2}Paul Andres Corral Rodas, pcorralrodas@worldbank.org{p_end}
	{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
	{p 4 4 2}Qinghua Zhao, qzhao@worldbank.org{p_end}
	{p 4 4 2}World Bank{p_end}

{title:Thanks for citing {cmd: sae} as follows}

{p 4 4 2}{cmd: sae} is a user-written program that is freely distributed to the research community. {p_end}

{p 4 4 2}Please use the following citation:{p_end}
{p 4 4 2}World Bank. (2017). “Small Area Estimation: An extended ELL approach.”. World Bank.
{p_end}

{title:Acknowledgements}
    {p 4 4 2}We would like to thank all the users for their comments during the initial development of the codes. 
	All errors and ommissions are exclusively our responsibility.{p_end}

{smcl}
{* *! version 1.0.0  18nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae model lmm" "mansection SAE saemodellmm"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "[SAE] sae model lmm" "help sae_model_lmm"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae model fh" "help sae_model_fh"}{...}
{viewerjumpto "Syntax" "sae_model_lmm##syntax"}{...}
{viewerjumpto "Description" "sae_model_lmm##description"}{...}
{viewerjumpto "Options" "sae_model_lmm##options"}{...}
{viewerjumpto "Remarks" "sae_model_lmm##examples"}{...}
{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{manlink sae model lmm} {hline 2}}model sae data with linear mixed model
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:sae model lmm} {depvar} {indepvars} {ifin} [{it:{help weight##weight:weight}}] {cmd:,} {cmd:area(}{it:varname numeric}{cmd:)} {cmd:varest(}{it:string}{cmd:)} [{cmd:zvar(}{it:varlist}{cmd:)} {cmd:yhat(}{it:varlist}{cmd:)} {cmd:yhat2(}{it:varlist}{cmd:)} {cmd:alfatest(}{it:string}{cmd:)} {cmd:vce(}{it:string}{cmd:)}]

{marker description}{...}
{title:Description}

{p 4 4 2}
This {cmd:sae} {cmd:model} {cmd:lmm} is the main function to do the modeling of the sae for the linear mixed models. 
See the paper for more examples.

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
highest aggregation level, and EEE, stands for the lowest aggregation level, and so on.

{p 4 8 2}
{cmd:varest(}{it:string}{cmd:)}: The varest option allows the user to select between H3 or ELL methods for obtaining the
variance of the decomposed first stage residuals. The selection has repercussions on the options available
afterwards. For example, if the the user selects H3, parameters must be obtained via bootstrapping.

{dlgtab:Optional}

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
{cmd:alfatest(}{it:string}{cmd:)}: The alfatest option may be run in any stage, but is useful for selecting a proper first
stage. It requests the command to output the the dependent variable of the alpha model for users to
model for heteroskedasticity.

{p 4 8 2}
{cmd:vce(}{it:string}{cmd:)}: The vce option allows users to replicate the variance covariance matrix from the OLS in the
PovMap 2.5 software. The default option is the variance covariance matrix from the PovMap software,
vce(ell), the user may specify robust or clustered variance covariance matrix to replicate the results
from the regress command.

{title:Saved Results}

{cmd:sae} {cmd:model} returns results in {hi:e()} format. By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(cmdline)}}the code line used in the session {p_end}

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

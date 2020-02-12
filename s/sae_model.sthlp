{smcl}
{* *! version 1.0.0  11nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae model" "mansection SAE saemodel"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae model lmm" "help sae_model_lmm"}{...}
{vieweralsosee "[SAE] sae model fy" "help sae_model_fh"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "sae_model##syntax"}{...}
{viewerjumpto "Description" "sae_model##description"}{...}
{viewerjumpto "Remarks" "sae_model##remarks"}{...}
{viewerjumpto "References" "sae_model##references"}{...}
{title:Title}

{p2colset 5 23 25 2}{...}
{p2col :{manlink SAE sae model} {hline 2}}Related functions for modeling sae data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{bf:sae model lmm} ...

{p 4 4 2}
See 
{bf:{help sae_model_lmm:[SAE] sae model lmm}},

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:sae} {cmd:model} performs modeling-related functions for {cmd:sae} data that contain 
original data.


{marker remarks}{...}
{title:Remarks}

{p 4 4 2}
Remarks are presented under the following headings:

	{help sae_model##overview:When to use which sae model command}
	{help sae_model##importstata:Import data into Stata before importing into sae}


{marker overview}{...}
{title:When to use which sae data command}

{p 4 4 2}
{cmd:sae} {cmd:model} {cmd:lmm} imports data recorded in the Stata format
of the target dataset and convert it into a Mata format
dataset to minimize the overall burden put on the system.

{marker importstata}{...}
{title:Import data into Stata before importing into sae}

{p 4 4 2} 
You must import the data into Stata before you can use {cmd:sae} {cmd:model}
to model your data.

{marker references}{...}
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

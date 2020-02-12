{smcl}
{* *! version 1.0.0  18nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae data import" "mansection SAE saedataimport"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "[SAE] sae data export" "help sae_data_export"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae data import" "help sae_data_import"}{...}
{viewerjumpto "Syntax" "sae_data_import##syntax"}{...}
{viewerjumpto "Description" "sae_data_import##description"}{...}
{viewerjumpto "Options" "sae_data_import##options"}{...}
{viewerjumpto "Remarks" "sae_data_import##examples"}{...}
{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{manlink sae data import} {hline 2}}Import sae data to Mata format
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:sae data import}, {cmd:datain(}{it:string}{cmd:)} {cmd:varlist(}{it:string}{cmd:)} {cmd:area(}{it:string}{cmd:)} {cmd:uniqid(}{it:string}{cmd:)} {cmd:dataout(}{it:string}{cmd:)}

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:sae} {cmd:data} {cmd:import} import  the {cmd:sae} data in a Stata file
 to one disk file in Mata matrix format. 
The file will be named based on the {cmd:dataout(}{it:string}{cmd:)}. All options are required for the command.

{marker options}{...}
{title:Options}

{p 4 8 2}
{cmd:datain()} option indicates the path and file name of the Stata format dataset to be converted
into a Mata format dataset.

{p 4 8 2}
{cmd:varlist()} option specifies all the variables to be imported into the Mata format dataset. The
variables specified will be available for the simulation stage of the analysis. Variables must have similar
names between datasets. Additionally, users should include here any additional variables they wish to
include, as well as expansion factors for the target data.

{p 4 8 2}
{cmd:uniqid()} option specifies the numeric variable that indicates the unique identifiers in the target
dataset. This is necessary to ensure replicability of the analysis, and the name should match the one
of the unique identifier from the source dataset.

{p 4 8 2}
{cmd:area()} option is necessary and specifies at which level the clustering is done, it indicates at which
level the eta_c is obtained at. The only constraint is that the variable must be numeric and should
match across datasets, although it is recommended it follows a hierarchical structure similar to the one
proposed by Zhao (2006). The hierarchical id should be of the same length for all observations. For example: AAMMEEE.
This structure facilitiates getting final estimates at different aggregation levels.

{p 4 8 2}
{cmd:dataout()} option indicates the path and filename of the Mata format dataset that will be used
when running the Monte Carlo simulations.

{marker examples}{...}
{title:Examples}

{p 4 4 2}
The {cmd:sae} command requires users to import the target data into a Mata data format file. This is done to
facilitate the process of simulations in the second stage due to the potential large size of the target data.

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

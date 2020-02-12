{smcl}
{* *! version 1.0.0  18nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae data export" "mansection SAE saedataexport"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "[SAE] sae data export" "help sae_data_export"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae data import" "help sae_data_import"}{...}
{viewerjumpto "Syntax" "sae_data_export##syntax"}{...}
{viewerjumpto "Description" "sae_data_export##description"}{...}
{viewerjumpto "Options" "sae_data_export##options"}{...}
{viewerjumpto "Remarks" "sae_data_export##examples"}{...}
{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{manlink sae data export} {hline 2}}export sae data (Mata format) to Stata format
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:sae data export}, {cmd:matasource(}{it:string}{cmd:)} [{cmd:numfiles(}{it:integer 1}{cmd:)} {cmd:prefix(}{it:string}{cmd:)} saveold {cmd:datasave(}{it:string}{cmd:)}]

{marker description}{...}
{title:Description}

{p 4 4 2}
This {cmd:sae} {cmd:data} {cmd:export} export  is useful for bringing in the simulated vectors created by {cmd:sae} into Stata. 
It provides the user the ability to further manipulate these vectors. Due to the unique structure of the Mata data, this command will only
work with data created in the simulation stage.

{marker options}{...}
{title:Options}

{p 4 8 2}
{cmd:matasource()}: The matasource option allows users to specify the source ydump file created by the
{cmd:sae} {cmd:simulate} routine. Because the size of the file can be quite large, it is advisable to use this with
the numfiles option.

{p 4 8 2}
{cmd:numfiles()}: The numfiles option is to be used in conjunction with the {cmd:ydumpdta} option; it specifies
the number of datasets to be created from the simulations.

{p 4 8 2}
{cmd:prefix()}: The prefix option may be used to give a prefix to the simulated vectors.

{p 4 8 2}
{cmd:saveold}: The saveold option can be specified in conjunction with the {cmd:ydumpdta} option, and makes
the files readable by older versions of Stata.

{p 4 8 2}
{cmd:datasave()}: The datasave option allows users to specify a path where to save the exported data,
this is recommended when using the numfiles option.

{marker examples}{...}
{title:Examples}

{p 4 4 2}
Due to the unique structure of the Mata data, this command will only work with data created in the simulation stage.

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

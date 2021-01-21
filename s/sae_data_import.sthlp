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
{p2col :{manlink sae data import} {hline 2}}Imports data for sae to Mata format for use with sae sim functions. Necessary due to large size of census data.
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

{p 4 4 2}Corral, P., Molina, I., Nguyen, M. (2020). Pull your small area estimates up by your bootstraps, World Bank Policy Research Working Paper 9256.{p_end}

{p 4 4 2}Elbers, C., J. O. Lanjouw, and P. Lanjouw (2002). Micro-level estimation of welfare. 2911.{p_end}

{p 4 4 2}Elbers, C., J. O. Lanjouw, and P. Lanjouw (2003). Micro–level estimation of poverty and inequality. Econometrica
71 (1), 355–364.{p_end}

{p 4 4 2}Molina, I. and J. Rao (2010). Small area estimation of poverty indicators. Canadian Journal of Statistics
38 (3), 369–385.{p_end}

{p 4 4 2}Rao, J. N. and I. Molina (2015). Small area estimation. John Wiley & Sons.{p_end}

{p 4 4 2}Van der Weide, R. (2014). GLS estimation and empirical bayes prediction for linear mixed models with
heteroskedasticity and sampling weights: a background study for the povmap project. World Bank Policy
Research Working Paper (7028).{p_end}

{p 4 4 2}Zhao, Q. (2006). User manual for povmap. World Bank. http://siteresources.worldbank.org/INTPGI/
Resources/342674-1092157888460/Zhao_ManualPovMap.pdf .{p_end}




{title:Authors}	
	{p 4 4 2}Minh Cong Nguyen, mnguyen3@worldbank.org{p_end}
	{p 4 4 2}Paul Corral, pcorralrodas@worldbank.org{p_end}
	{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
	{p 4 4 2}Qinghua Zhao, qzhao@worldbank.org{p_end}
	

{title:Thanks for citing {cmd: sae} as follows}

{p 4 4 2}{cmd: sae} is a user-written program that is freely distributed to the research community. {p_end}

{p 4 4 2}Please use the following citation:{p_end}
{p 4 4 2}Nguyen, M., Corral, P., Azevedo, JP, Zhao, Q. (2018). sae: A stata package for unit level small area estimation, World Bank Policy Research Working Paper 8630.
{p_end}

{title:Acknowledgements}
    {p 4 4 2}We would like to thank all the users for their comments during the initial development of the codes. 
	All errors and ommissions are exclusively our responsibility.{p_end}

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

{smcl}
{* *! version 1.0.0  11nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae sim" "mansection SAE saesim"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae sim lmm" "help sae_sim_lmm"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "sae_sim##syntax"}{...}
{viewerjumpto "Description" "sae_sim##description"}{...}
{viewerjumpto "Remarks" "sae_sim##remarks"}{...}
{viewerjumpto "References" "sae_sim##references"}{...}
{title:Title}

{p2colset 5 23 25 2}{...}
{p2col :{manlink SAE sae sim} {hline 2}}Related functions and methods for simulating sae data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{bf:sae sim lmm/h3/ell/elleb/reml} ...

{p 4 4 2}
See 
{bf:{help sae_sim_lmm:[SAE] sae sim lmm}},
{bf:{help sae_ell:[SAE] sae sim ell}},
{bf:{help sae_mc_bs:[SAE] sae sim h3/elleb}},
{bf:{help sae_ebp:[SAE] sae sim reml}},

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:sae} {cmd:sim} performs simulation-related functions for {cmd:sae} data that contain 
original and target data. See the paper for more details on the syntax.


{marker importstata}{...}
{title:Import data into Mata before running simulations}



{p 4 4 2} 
You must import the data into Stata before you can use {cmd:sae} {cmd:model}
to model your data.

{bf:{help sae_data_import:[SAE] sae data import}}


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

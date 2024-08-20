{smcl}
{* *! version 2.5.0  12Dec2022}{...}
{title:Title}

{hline}
help for {cmd:sae} {right:Nguyen, Corral, Azevedo, and Zhao}
{hline}

{p2colset 9 24 22 2}{...}
{p2col :{cmd:sae} {hline 1} Package for small area estimation of poverty indicators developed by World Bank Staff.}{p_end}
{p2colreset}{...}

{p 8 9 9}
{it:[Suggestion:  Read}
{browse "https://openknowledge.worldbank.org/handle/10986/37728":Guidelines to small area estimation for poverty mapping.}
{it:first.]}


{marker description}{...}
{title:Description}

{p 4 4 2}
The {cmd:sae} suite of commands are made for small area estimation. To become familiar with the {cmd:sae} suite of commands see:       
	                                                                  
	1. EB and CensusEB estimation under REML                       
	   using one-fold nested error models see: 
{col 7}{...}
     {bf:{help sae_ebp:[SAE] sae reml}}  
	2. CensusEB estimation under REML using                     
	   two-fold nested error models see: 
{col 7}{...}
     {bf:{help sae_ebp2:[SAE] sae reml2}}  
	3. CensusEB estimation under GLS model allowing 
	   for survey weights and heteroskedasticity with
	   one-fold nested error models see:
{col 7}{...}
	  {bf:{help sae_mc_bs:[SAE] sae h3}} 
	4. ELL estimation under GLS model allowing 
	   for survey weights and heteroskedasticity with
	   one-fold nested error models see:
{col 7}{...}
	  {bf:{help sae_ell:[SAE] sae ell}}  
	   
{p 4 4 2}
To perform data related functions such as to import the target dataset to a more manageable
format for the simulations; to export the resulting simulations to a dataset of the
user’s preference see:

{col 7}{...}
{hline 70}
{col 7}{bf:{help sae_data_import:sae data import}}{...}
{col 30}import {cmd:sae} data into Mata data file
{...}
{...}
{col 7}{bf:{help sae_data_export:sae data export}}{...}
{col 30}export {cmd:sae} Mata data file to Stata data
{...}
{...}
{col 7}{...}
{hline 70}
{p 6 6 2}


{marker references}{...}
{title:References}

{p 4 4 2}Corral, P., Molina, I., Nguyen, M. (2020). Pull your small area estimates up by your bootstraps, World Bank Policy Research Working Paper 9256.{p_end}

{p 4 4 2}Corral, Paul; Molina, Isabel; Cojocaru, Alexandru; Segovia, Sandra. (2022). Guidelines to Small Area Estimation for Poverty Mapping. © Washington, DC : World Bank.{p_end}
 
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
	{p 4 4 2}Paul Andres Corral Rodas, pcorralrodas@worldbank.org{p_end}
	{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
	{p 4 4 2}Qinghua Zhao, qzhao@worldbank.org{p_end}
	{p 4 4 2}World Bank{p_end}
	

{title:Thanks for citing {cmd: sae} as follows}

{p 4 4 2}{cmd: sae} is a user-written program that is freely distributed to the research community. {p_end}

{p 4 4 2}Please use the following citation:{p_end}
{p 4 4 2}Nguyen, M., Corral, P., Azevedo, JP, Zhao, Q. (2018). sae: A stata package for unit level small area estimation, World Bank Policy Research Working Paper 8630.
{p_end}

{title:Acknowledgements}
    {p 4 4 2}We would like to thank all the users for their comments during the initial development of the codes. 
	All errors and ommissions are exclusively our responsibility.{p_end}

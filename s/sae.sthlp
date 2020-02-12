{smcl}
{* *! version 1.0.0  11feb2020}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] intro" "mansection SAE intro"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] Glossary" "help sae_glossary"}{...}
{vieweralsosee "[SAE] intro substantive" "help sae_intro_substantive"}{...}
{vieweralsosee "[SAE] styles" "help sae_styles"}{...}
{vieweralsosee "[SAE] workflow" "help sae_workflow"}{...}
{viewerjumpto "Description" "sae##description"}{...}
{viewerjumpto "Remarks" "sae##remarks"}{...}
{viewerjumpto "Acknowledgments" "sae##ack"}{...}
{title:Title}

{hline}
help for {cmd:sae} {right:World Bank/Poverty and Equity GP - GSG1}
{hline}

{p2colset 5 19 21 2}{...}
{p2col :{manlink SAE intro} {hline 2}}Introduction to sae - small area estimation packages{p_end}
{p2colreset}{...}

{p 8 9 9}
{it:[Suggestion:  Read}
{bf:{help sae_intro_substantive:[SAE] intro substantive}}
{it:first.]}


{marker description}{...}
{title:Description}

    {c TLC}{hline 62}{c TRC}
    {c |} The {cmd:sae} suite of commands deals with small area estimation,{col 68}{c |}
    {c |} abbreviated as {cmd:sae} data. To become familiar with {cmd:sae}{col 68}{c |}
    {c |} as quickly as possible, do the following{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    1.  See {it:{help sae##example:A simple example}} under {...}
{bf:{help sae##remarks:Remarks}} below.{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    2.  If you have data that require simulating, see{col 68}{c |}
    {c |}        {bf:{help sae_data:[SAE] sae data}}{col 68}{c |}
    {c |}        {bf:{help sae_sim:[SAE] sae simulate}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    3.  Alternatively, if you have already simulated data, see{col 68}{c |}
    {c |}        {bf:{help sae_proc:[SAE] sae proc}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    4.  To fit your model, see{col 68}{c |}
    {c |}        {bf:{help sae_model:[SAE] sae model}}{col 68}{c |}
    {c BLC}{hline 62}{c BRC}


{p 4 4 2}
To perform data related functins such as to import the target dataset to a more manageable
format for the simulations; to export the resulting simulations to a dataset of the
user’s preference; and to compare the variables between the sources of data.

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

{p 4 4 2}
To perform first stage estimation on {cmd:sae} data. This routine is for obtaining the GLS estimates of the first stage. The
sub-routines, {bf:{help sae_model_lmm:sae model lmm}} (linear mixed model) and {bf:{help sae_model_povmap:sae model povmap}} (povmap) are used interchangeably

{col 7}{...}
{hline 70}
{col 7}{bf:{help sae_model_lmm:sae model lmm}}{...}
{col 30}model first stage estimations for the linear mixed models
{...}
{...}
{...}
{col 7}{...}
{hline 70}

{p 4 4 2}
To perform second stage estimation on {cmd:sae} data. This routine and sub-routine obtains the GLS estimates of the first
stage, and goes on to perform the Monte Carlo simulations

{col 7}{...}
{hline 70}
{col 7}{bf:{help sae_simulate_lmm:sae sim lmm}}{...}
{col 30}simulate based on first stage models for the linear mixed models
{...}
{...}
{...}
{col 7}{...}
{hline 70}

{p 4 4 2}
The stats and inds sub-routines are useful for processing Mata formatted
simulation output and producing indicators with new thresholds or weights, as well as profiling.

{col 7}{...}
{hline 70}
{col 7}{bf:{help sae_proc_stats:sae proc stats}}{...}
{col 30}produce the statistics based on simulated data
{...}
{...}
{col 7}{bf:{help sae_proc_ind:sae proc ind}}{...}
{col 30}prodiuce Poverty and Inequality indictors based on simulated data
{...}
{...}
{...}
{col 7}{...}
{hline 70}

{marker remarks}{...}
{title:Remarks}

{p 4 4 2}
Remarks are presented under the following headings:

	{help sae##example:A simple example}
	{help sae##order:Suggested reading order}

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

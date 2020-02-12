{smcl}
{* *! version 1.0.0  18nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae proc stats" "mansection SAE saeprocstats"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "[SAE] sae proc stats" "help sae_proc_stats"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae proc ind" "help sae_proc_ind"}{...}
{viewerjumpto "Syntax" "sae_proc_stats##syntax"}{...}
{viewerjumpto "Description" "sae_proc_stats##description"}{...}
{viewerjumpto "Options" "sae_proc_stats##options"}{...}
{viewerjumpto "Remarks" "sae_proc_stats##examples"}{...}
{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{manlink sae proc stats} {hline 2}}processing statistics for sae data with linear mixed model
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:sae proc stats} {cmd:,} {cmd:matasource(}{it:string}{cmd:)} {opt aggids(numlist sort)} 
[{opt contvar(string)} {opt catvar(string)} {opt plinevar(string)} {opt plines(numlist sort)} {opt area(string)} {opt weight(string)}]

{marker description}{...}
{title:Description}

{p 4 4 2}
This {cmd:sae} {cmd:proc} {cmd:stats} is useful for processing poverty statistics from the simulated vectors created by {cmd:sae} from Stata. 
It provides the user the ability to further perform tabulations and summary on these vectors. Due to the unique structure of the Mata data, this command will only
work with data created in the simulation stage.

{marker options}{...}
{title:Options}

{dlgtab:Required}

{p 4 8 2}
{opt matasource()}: The matasource option allows users to specify the source ydump file created by the
sae simulate routine. Because the size of the file can be quite large, it is advisable to use this with
the numfiles option.

{p 4 8 2}
{opt aggids()}: The aggids option indicates the different aggregation levels for which the indicators are
to be obtained, values placed here tell the command how many digits to the left to move to get the
indicators at that level. Using the same hierarchical id specified in the area option, AAMMEEE, if
the user specifies 0, 3, 5, and 7 would lead to aggregates at the each of the levels E, M, A and the
national level.

{dlgtab:Optional}

{p 4 8 2}
{opt contvar()}: The contvar option indicates the continuous variables that the user wants to estimate
the mean/distribution based on poor and non-poor groups defined from the defined poverty lines in
either plines or plinevar. Those statistics will be aggregated at the aggregation levels indicated in
the aggids option. The user must have added the variable in the sae data import command when
preparing the target dataset.

{p 4 8 2}
{opt catvar()}: The catvar option indicates the categorical variables that the user wants to estimate
the two-way frequencies/distributions based on poor and non-poor groups defined from the defined
poverty lines in either plines or plinevar. Those statistics will be aggregated at the aggregation
levels indicated in the aggids option. The user must have added the variable in the sae data import
command when preparing the target dataset.

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

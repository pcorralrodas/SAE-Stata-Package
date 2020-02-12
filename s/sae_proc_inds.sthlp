{smcl}
{* *! version 1.0.0  18nov2017}{...}
{viewerdialog sae "dialog sae"}{...}
{vieweralsosee "[SAE] sae proc ind" "mansection SAE saeprocind"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] intro" "help sae"}{...}
{vieweralsosee "[SAE] sae proc ind" "help sae_proc_ind"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SAE] sae proc stats" "help sae_proc_stats"}{...}
{viewerjumpto "Syntax" "sae_proc_ind##syntax"}{...}
{viewerjumpto "Description" "sae_proc_ind##description"}{...}
{viewerjumpto "Options" "sae_proc_ind##options"}{...}
{viewerjumpto "Remarks" "sae_proc_ind##examples"}{...}
{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{manlink sae proc ind} {hline 2}}model sae data with linear mixed model
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:sae proc indicator} {cmd:,} 
{cmd:matasource(}{it:string}{cmd:)} {opt aggids(numlist sort)} [{opt ind:icator(string)} {cmd:plinevar(}{it:string}{cmd:)}
{opt plines(numlist sort)} {cmd:area(}{it:string}{cmd:)} {cmd:weight(}{it:string}{cmd:)}]

{marker description}{...}
{title:Description}

{p 4 4 2}
This {cmd:sae} {cmd:proc} {cmd:ind} is useful for processing poverty statistics from the simulated vectors created by {cmd:sae} from Stata. 
It provides the user the ability to create basic poverty and inequlity indicators such as FGT and GE, Gini and more on these vectors. Due to the unique structure of the Mata data, this command will only
work with data created in the simulation stage.

{marker options}{...}
{title:Options}

{dlgtab:Required}

{p 4 8 2}
{opt matasource()}: The matasource option allows users to specify the source ydump file created by the
sae simulate routine . Because the size of the file can be quite large, it is advisable to use this with
the numfiles option.

{p 4 8 2}
{opt aggids()}: The aggids option indicates the different aggregation levels for which the indicators are
to be obtained, values placed here tell the command how many digits to the left to move to get the
indicators at that level. Using the same hierarchical id specified in the area option, AAMMEEE, if
the user specifies 0, 3, 5, and 7 would lead to aggregates at the each of the levels E, M, A and the
national level.

{dlgtab:Optional}

{p 4 8 2}
{opt ind:icator(string)}: The indicators option is used to request the indicators to be estimated from the
simulated vectors of welfare. The list of possible indicators is:
– The set of Foster Greer Thorbeck indexes (Foster, Greer, and Thorbeck 1984) FGT0, FGT1, and
FGT2 ; also known as poverty head count, poverty gap, and poverty severity respectively.
– The set of inequality indexes: Gini, and Generalized Entropy Index with alpha = 0, 1, 2
– Set of Atkinson indexes

{p 4 8 2}
{opt plinevar()}: The plinevar option allows users to indicate a variable in the target data set which is
to be used as the threshold for the Foster Greer Thorbeck indexes (Foster, Greer, and Thorbeck 1984)
to be predicted from the second stage simulations. The user must have added the variable in the sae
data import command when preparing the target dataset. Only one variable may be specified.

{p 4 8 2}
{opt plines()}: The plines option allows users to explicitly indicate the threshold to be used, this option
is preferred when the threshold is constant across all observations. Additionally, it is possible to specify
multiple lines, separated by a space.

{p 4 8 2}
{opt area()}: The area option is necessary and specifies at which level the clustering is done, it indicates
at which level the c is obtained at. The only constraint is that the variable must be numeric and
should match across datasets, although it is recommended it follows a hierarchical structure similar to
the one proposed by Zhao (2006). Note that in this step, the default is to use the defined areas from
the simulation step. In this option the user is given the opportunity to change this grouping. The hierarchical id should be of the same length for all observations for example: AAMMEEE.

{p 4 8 2}
{opt weight()}: The weight option indicates the new variable which corresponds to the expansion factors
to be used in the target/ydump dataset. The default option is to use the weight variable saved in the
ydump file, if a variable is specified here all results will be obtained with this new weighing. The user
must have added the variable to the target data imported (sae data import).

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

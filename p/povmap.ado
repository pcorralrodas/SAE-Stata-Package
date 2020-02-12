*! version 0.2.5  31May2017
*! Copyright (C) World Bank 2016-17 - Minh Cong Nguyen & Paul Andres Corral Rodas
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

cap program drop povmap
program define povmap, eclass byable(recall) 
	version 11, missing
	
	mata st_local("StataVersion", lsae_povmapStataVersion()); st_local("CodeVersion", lsae_povmapVersion())
	if `StataVersion' != c(stata_version) | "`CodeVersion'" < "00.06.00" {
		cap findfile "lsae_povmap.mlib"
		while !_rc {
			erase "`r(fn)'"
			cap findfile "lsae_povmap.mlib"
		}
		qui findfile "lsae_povmap.mata"
		run "`r(fn)'"
	}
	
	syntax varlist(min=2 numeric fv) [if] [in] [aw pw fw], area(varname numeric) ///
	stage(string) VARest(string)  ///
	[ETA(string) EPSilon(string) UNIQid(varname numeric) PSU(varname numeric) Zvar(varlist numeric fv) yhat(varlist numeric fv) ///
	yhat2(varlist numeric fv) lny plinevar(string) PLINEs(numlist sort) ///
	rep(integer 0) seed(string) matin(string) matbeta(string) ///
	PWcensus(string) ydump(string) ydumpdta(string) numfiles(integer 1) prefix(string) ///
	saveold RESults(string) addvars(string) BOOTstrap EBest allmata ///
	COLprocess(integer 1) NOOUTput vce(string) INDicators(string) aggids(numlist sort) alfatest(string) new]

	if c(more)=="on" set more off
    local version : di "version " string(_caller()) ", missing:"
	local cmdline: copy local 0
	if ("`seed'"=="") local seed 123456789
	set seed `seed'
	
	//Until vec is fixed.
	local colprocess = 1
	
	//if ("`stage'" == "") local stage second
	
	//housekeeping
	if "`matin'"!="" { //Check if census mata file exists
		cap confirm file "`matin'"
		if _rc!=0 {
			display as error "`matin' not found, please verify"
			error 198
		}
	}

	local epsdecomp `varest'
	local process col
	local hhid `uniqid'             
	foreach vs in stage epsilon eta ebest epsdecomp vce glsmethod alfatest  {
		local `vs' = lower("``vs''")
	}
	
	// Ensure that EB is only done with the new codes...
	if (lower("`varest'")=="h3" & "`stage'"=="second"){
		noi dis as error "Please note that we do not recommend authors use this method of H3, please see Corral, Molina, Nguyen (2020) for the reasons. This is only provided for replication of old results."	
	}
	if (lower("`varest'")=="ell" & "`stage'"=="second" & "`ebest'"!=""){
		if "`new'"=="" & "`bootstrap'"~="" {
			noi dis as error "Please note that we do not recommend authors use this method of ELL, please see Corral, Molina, Nguyen (2020) for the reasons. This is only provided for replication of old results."		
			error 198		
		}
		else noi dis as error "Please note that we do not recommend authors use this method of ELL, please see Corral, Molina, Nguyen (2020) for the reasons. This is only provided for replication of old results."		
	}
	
	//join addvars and plinevar
	if "`plinevar'"!="" & "`plines'"!=""{
		dis as error "You must specify only one option: plinevar or plines"
		error 198
	}
	local plinevar: list uniq plinevar
	local addvars : list addvars | plinevar
	local addvars : list uniq addvars
	if ("`plinevar'"!="" & "`allmata'"=="") {
		if `: list sizeof plinevar' > 1 {
			dis as error "You must specify only one plinevar"
			error 198
			exit
		}
	}

	if  "`indicators'"~="" local indicators `=upper("`indicators'")'
	//missing observation check
	marksample touse
	local flist `"`varlist' `zvar' `yhat' `yhat2' `by' `grvar'"'
	markout `touse' `flist' 
	gettoken lhs varlist: varlist
	_fv_check_depvar `lhs'	
	
	//Selection of X vars
	_rmcoll `varlist' if `touse', forcedrop
	local okvarlist `r(varlist)'
	//fvexpand `okvarlist' 
    //local okvarlist `r(varlist)'
	local okvarlist : list sort okvarlist
	//local okvarlist `varlist' `cons'
	//local okvarlist `varlist'
	
	//CHECK: varinmodel put all variables used in the model here to mask
	local varinmodel "`okvarlist' `pwcensus' `area'"
	local varinmodel : list uniq varinmodel
	local addvars: list uniq addvars
	
	//Model setting
	//hheff household effect alpha model
	if "`zvar'"=="" & "`yhat'"=="" & "`yhat2'"=="" local hheffs 0
	else local hheffs 1
	
	//Change to ensure that if H3 is chosen only bootstrapped drawing of Beta and alpha is done
	if "`bootstrap'"=="" local boots 0
	else local boots 1
	if "`epsdecomp'"=="h3" & `boots'==0 {
		local boots 1
		local bootstrap bootstrap
		display in yellow "You chose H3, parameters must be obtained via bootstrap I changed it for you."
	}

	if "`psu'"!=""{
		local psu1 = 1
		egen __hsyk0_0 = group(`psu' `area')
	}
	else{
		local psu1 = 0
		gen __hsyk0_0 = `area'		
	}
	
	//Stage
	if ("`ebest'"!="")	local ebest 1
	else                local ebest 0
	
	if "`stage'"=="" | "`stage'"=="second" {
	
		if ("`uniqid'"=="") | ("`eta'"=="") | ("`epsilon'"=="") | ("`pwcensus'"==""){
			display as error "Invalid syntax: uniqid, eta, pwcensus, and epsilon are required when running simulations"
			error 198
		}
		
		if "`epsilon'"!="normal" & "`epsilon'"!="nonnormal" {
			dis as error "You must specify drawing method for epsilon as either epsilon(normal) or epsilon(nonnormal)"
			error 198
		}
		if "`epsilon'"=="normal" local epsnormal = 1
		else                     local epsnormal = 0
		
		if "`eta'"!="normal" & "`eta'"!="nonnormal" {
			dis as error "You must specify drawing method for eta as either eta(normal) or eta(nonnormal)"
			error 198
		}
		if "`eta'"=="normal" local etanormal = 1
		else                 local etanormal = 0
		
		if ("`psu'"=="" & "`bootstrap'"!="") {
			display in gr "You have not specified a PSU for bootstrapping, cluster level is used by default"
		}
		//this ebest below is not correct.
		if ("`ebest'"=="ebest" & "`eta'"!="normal") {
			dis as error "Semi-parametric drawing of eta is not allowed under EB"
			error 198
		}
		if ("`epsdecomp'"=="h3" & "`bootstrap'"!="bootstrap") {
			dis as error "Henderson epsilon decomposition is only allowed if bootstrap distribution drawing method is chosen"
			error 198
		}
	} //end stage
	
	if ("`plines'"=="" & "`stage'"=="") {
		display in gr "You have not specified a poverty line, all predicted incomes were saved in `ydump'"
	}
	
	if ("`epsdecomp'"!="h3" & "`epsdecomp'"!="ell") {
		dis as error "Either H3 or ELL method must be specified"
		error 198		
	}
	//why this?
	if ("`stage'"=="" & "`ydump'"=="" & "`results'"=="") {
		dis as error "You have not specified where to save your results. If you'd like to only see the first stage estimates use the stage(first) option."
		error 198
	}
	
	if ("`epsdecomp'"=="h3") local h3 1
	else                     local h3 0
		
	//local nolocation //what is this		
	if ("`lny'"=="lny") {
		dis in gr _n "Note: Dependent variable in logarithmic form"
		local lny 1
	}
	else {
		local lny 0
	}
	if "`allmata'"=="allmata" local matay 1
	else               		  local matay 0
	//VCE option: none, robust, cluster
	if ("`vce'"==""){
		if ("`new'"=="")  local vce ell
		else local vce robust
	}
	if "`vce'"~="robust" &  "`vce'"~="cluster" & "`vce'"~="none" & "`vce'"~="ell" {
		dis in gr "Either vce(robust), vce(cluster), or vce(ell) can be specified; or no vce option can be specified"
		error 198
	}
	if "`vce'"=="none"    local vceopt 0
	if "`vce'"=="robust"  local vceopt 1
	if "`vce'"=="cluster" local vceopt 2
	if "`vce'"=="ell"     local vceopt 3
	
	//GLS method: old ELL or new weighted GLS
	if "`glsmethod'"=="" local glsmethod wgls
	if "`glsmethod'"~="ell" &  "`glsmethod'"~="wgls" {
		dis in gr "Either gls(ell) or gls(wgls) option can be specified"
		error 198
	}
	
	//Weights
	local wvar : word 2 of `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
	
	//Area options
	if ("`area'"=="") {
		tempvar grv
		qui gen `grv' = 1
		local grvar `grv'
	}
	else {
		if (`:word count `area''==1) { // one group variable
			local grvar `area'
		}            
		else { // more than one group variable
			dis as error "Please provide only one hierarchical ID variable."
			error 198
		}
	}
	
	//Remove areas with less than 3 obs per area
	tempvar cue
	qui egen `cue'=count(_n), by(`grvar')
	qui count if `cue'<3
	display in yellow "WARNING: `r(N)' observations removed due to less than 3 observations in the cluster."
	qui drop if `cue'<3
	
	//Setup the variables for the alpha model
	tempname one
	qui gen __mz1_000 = .
	qui gen __myh_000 = .
	qui gen __myh2_000 = .
	qui gen `one' = 1
	if "`zvar'"==""  local zvarn __mz1_000
	else local zvarn : list sort zvar
	if "`yhat'"=="" {
		local yhatn __myh_000
	}
	else if "`yhat'"=="_one" {
		local yhatn "`one'" 
		local yhnames yhat
	}
	else {
		local yhatn : list sort yhat
		local yhnames 
		foreach va of local yhatn {
			local yhnames "`yhnames' `va'_yhat"
		}
	}
	if "`yhat2'"=="" {
		local yhat2n __myh2_000
	}
	else if "`yhat2'"=="_one" {
		local yhat2n "`one'" 
		local yh2names yhat2
	}
	else {
		local yhat2n : list sort yhat2
		local yh2names 
		foreach va of local yhat2n {
			local yh2names "`yh2names' `va'_yhat2"
		}
	}
	
	//name matrix
	local bnames `okvarlist' _cons
	local anames `zvarn' `yhnames' `yh2names' _cons
	//ID check
	if "`hhid'"=="" {
		if lower("`stage'")=="second"{
			dis in green "Note: Identifier is specified, current order of data will be used as ID"
			error 198
			exit
		}
		if lower("`stage'")=="first"{
			tempvar _hHiD
			gen `_hHiD' = _n
			local hhid1 `_hHiD' 
		}
		
	}
	else {
		cap isid `grvar' `hhid'
		if (_rc!=0) {
			dis as error "Warning: Identifier not unique at cluster level, please provide unique identifier"
			error 198
			exit
		}
		else {
			capture confirm numeric variable `hhid'
			if (_rc==0) {
				local hhid1 `hhid'
			}
			else {
				display "Warning: Your household ID in the survey data set is not numeric, please provide numeric IDs."
				error 198
				exit
			} 
		}
	}
	
	qui if ("`stage'"=="first" & "`alfatest'"!="" & "`zvar'"!=""){
		gen `alfatest'_alfa =.
		lab var `alfatest'_alfa "Dependent variable of alfa model, after `epsdecomp' decomposition"
		gen `alfatest'_xb   =.
		lab var `alfatest'_xb "Yhat prediction from first stage ols"
		local alfaerr `alfatest'_alfa
		local exbeta `alfatest'_xb
		local alfatest=1			
	}
	sort `grvar' `hhid1'
	
	//gen __hsyk0_0 = `mmypsu'
	//Estimates from the modeling parts
	
	tempfile srcdata
	qui:save `srcdata'
	
	local cmd1 use `srcdata', replace
	local cmd2 bsample, cluster(__hsyk0_0)
	local cmd3 sort `area'

	noi: mata: _s2cs_base0("`lhs'","`okvarlist'", "`zvarn'", "`yhatn'", "`yhat2n'", "`grvar'", "`wvar'", "`hhid1'", "`touse'")
	//OLS
	mat rownames _vols = `bnames'
	mat colnames _vols = `bnames'
	mat rownames _bols = `lhs'
	mat colnames _bols = `bnames'
	mat vols = _vols
	mat bols = _bols
	di in gr _n "OLS model:"					 
	ereturn post _bols _vols, depname(`lhs') 
	ereturn local cmd "s2sc"
	ereturn display 
	est store bOLS
	if `hheffs'==1 {
		//Alpha model
		mat rownames _vzols = `anames'
		mat colnames _vzols = `anames'
		mat rownames _bzols = Residual
		mat colnames _bzols = `anames'
		mat vzols = _vzols
		mat bzols = _bzols
		di in gr _n "Alpha model:"					 
		ereturn post _bzols _vzols, depname(Residual) 
		ereturn local cmd "s2sc"
		ereturn display 
		est store balphaOLS
	}
	//GLS model
	mat rownames _vgls = `bnames'
	mat colnames _vgls = `bnames'
	mat rownames _bgls = `lhs'
	mat colnames _bgls = `bnames'
	mat bgls = _bgls
	mat vgls = _vgls
	di in gr _n "GLS model:"					 
	ereturn post _bgls _vgls, depname(`lhs') esample(`touse')
	ereturn local cmd "s2sc"
	ereturn local xvar `okvarlist'
	ereturn local zvar `zvarn'
	ereturn local yhat `yhatn'
	ereturn local yhat2 `yhat2n'
	ereturn display 
	est store bGLS
	di in gr _n "Comparison between OLS and GLS models:"
	est table bOLS bGLS
	
	//return stuff after estimation
	ereturn matrix b_beta    =  bols
	ereturn matrix V_beta    =  vols
	ereturn scalar rmse_beta = _rmse_beta[1,1]
	ereturn scalar r2_beta   = _r2_beta[1,1]
	ereturn scalar F_beta    = _F_beta[1,1]
	ereturn scalar r2a_beta  = _r2a_beta[1,1]
	ereturn scalar N_beta    = _N_beta[1,1]
	ereturn scalar dfm_beta  = _dfm_beta[1,1]
	ereturn scalar eta_ratio = _v_ratio[1,1]
	ereturn scalar eta_var   = _v_eta[1,1]
	ereturn scalar eps_var   = _v_eps[1,1]  
	if ("`epsdecomp'"=="ell") ereturn scalar var_eta_var = _fvar_sigeta2[1,1]
	if `hheffs'==1 {
		ereturn matrix b_alpha    =  bzols
		ereturn matrix V_alpha    =  vzols
		ereturn scalar rmse_alpha = _rmse_alpha[1,1]
		ereturn scalar r2_alpha   = _r2_alpha[1,1]
		ereturn scalar F_alpha    = _F_alpha[1,1]
		ereturn scalar r2a_alpha  = _r2a_alpha[1,1]
		ereturn scalar N_alpha    = _N_alpha[1,1]
		ereturn scalar dfm_alpha  = _dfm_alpha[1,1]
	}
	ereturn matrix b_gls    =  bgls
	ereturn matrix V_gls    =  vgls
	
	display _newline in ye "Model settings"
	di as text "{hline 61}"
	display in gr "Error decomposition" _col(50) in ye upper("`epsdecomp'")
		
	if (lower("`stage'")=="second"){
		if ("`bootstrap'"=="") display in gr "Beta drawing" _col(50) in ye "Parametric"
		else                   display in gr "Beta drawing" _col(50) in ye "Bootstrapped"
		if (`ebest'==1) { //Always normal when EB
			display in gr      "Eta drawing method" _col (50) in ye lower("normal")
			display in gr      "Epsilon drawing method" _col (50) in ye lower("normal")
			display in gr    "Empirical best methods" _col (50) in ye "Yes"
		}
		else {
			display in gr      "Eta drawing method" _col (50) in ye lower("`eta'")
			display in gr      "Epsilon drawing method" _col (50) in ye lower("`epsilon'")		
			display in gr    "Empirical best method" _col (50) in ye "No"
		}
	}
	
	display _newline in ye "Beta model diagnostics"
	di as text "{hline 61}"
	display in gr "Number of observations" _col(45) in gr "=" _col(50) in ye e(N_beta)
	display in gr "Adjusted R-squared"  _col(45) in gr "=" _col(50) in ye e(r2a_beta)
	display in gr "R-squared"   _col(45) in gr "=" _col(50) in ye e(r2_beta)
	display in gr "Root MSE"   _col(45) in gr "=" _col(50) in ye e(rmse_beta)
	display in gr "F-stat"  _col(45) in gr "=" _col(50) in ye e(F_beta)
	
	if `hheffs'==1 {
		display _newline in ye "Alpha model diagnostics"
		di as text "{hline 61}"
		display in gr "Number of observations" _col(45) in gr "=" _col(50) in ye e(N_alpha)
		display in gr "Adjusted R-squared"  _col(45) in gr "=" _col(50) in ye e(r2a_alpha)
		display in gr "R-squared" _col(45) in gr "=" _col(50) in ye e(r2_alpha)
		display in gr "Root MSE" _col(45) in gr "=" _col(50) in ye e(rmse_alpha)
		display in gr "F-stat"  _col(45) in gr "=" _col(50) in ye e(F_alpha)
	}
	
	display _newline in ye "Model parameters"
	di as text "{hline 61}"
	display  in gr "Sigma ETA sq.                               = " _col(50) in ye e(eta_var)
	display  in gr "Ratio of sigma eta sq over MSE              = " _col(50) in ye e(eta_ratio)
	display  in gr "Variance of epsilon                         = " _col(50) in ye e(eps_var)
	if ("`epsdecomp'"=="ell") display  in gr "Sampling variance of Sigma eta sq.          = " _col(50) in ye e(var_eta_var)
	di as text "{hline 61}"	                
	display  in ye _col(20) "<End of first stage>"

	local negeta = e(eta_var)
	local negeps = e(eps_var)
	if (`negeta'<0){
		noi dis as error "Your Sigma ETA sq. value is negative, please revise the model or cluster level"
		error 73943
	}
	if (`negeps'<0){
		noi dis as error "Your variance of epsilon value is negative, please revise the model"
		error 121
	}
	cap drop __mz1_000 __myh_000 __myh2_000
	//Processing the census data
	if "`stage'"=="" | "`stage'"=="second" {		
		if (!("`indicators'"!="" & "`aggids'"!="" & ("`plinevar'"!="" | "`plines'"!="")) & ("`ydump'"=="")){
			noi dis as error "You have requested the second stage to run, but forgot to specify"
			noi dis as error "where to save your ydump, or options for processing" _n
			noi dis as error "Options include: indicators(); aggids(); and plinevar() or plines()" _n
			error 121
		}		
		if "`allmata'"~="" {
			//Indicator checklis
			if "`indicators'"=="" local indicators fgt0
			local indicators = lower("`indicators'")
			local fgtlist
			local gelist
			foreach ind of local indicators {
				if  "`ind'"=="fgt0" local fgtlist "`fgtlist' `ind'"
				if  "`ind'"=="fgt1" local fgtlist "`fgtlist' `ind'"
				if  "`ind'"=="fgt2" local fgtlist "`fgtlist' `ind'"
				if  "`ind'"=="ge0" local gelist "`gelist' `ind'"
				if  "`ind'"=="ge1" local gelist "`gelist' `ind'"
				if  "`ind'"=="ge2" local gelist "`gelist' `ind'"
			}	
		}
	
		if "`ydump'"=="" & "`allmata'"=="" {
			tempfile ydumpdata
			local ydump `ydumpdata'
		}
		else { //check we can write or path valid
			//some code here to check if we can write the files before going to mata
		}
		//yhatlist for ydump matadata
		local yhatlist
		forv v=1(1)`rep' {
			local yhatlist "`yhatlist' _YHAT`v'"
		}
		if "`=lower("`process'")'"=="col" { //column-wise calculation
			local _itran
			if `=mod(`rep',`colprocess')'~=0 {
				noi dis as error "Number of simulation should be divisiable by `colprocess'. Please change the number in the colprocess() option."
				error 121
			}
			tempfile estout logout
			di as text "{hline 61}"
			di in gr _n "Initializing the Second Stage, this may take a while..." _n
			sae_closefiles
			noi:mata: _s2sc_sim_cols2("`okvarlist'", "`zvarn'", "`yhatn'", "`yhat2n'", "`grvar'", "`plines'", "`pwcensus'", "`touse'", "`hhid1'", "`matin'")	
			sae_closefiles
			dis  in gr _n "Finished running the Second Stage"
			di as text "{hline 61}"
			
			//allmata or plugin
			if "`allmata'"~="" {
				if "`ydump'"=="" dis  in gr _n "Results are saved into Stata memory"
				else {
					if "`plines'"!=""   sae_proc_inds, matasource(`ydump') aggids(`aggids') ind(`indicators') plines(`plines') 
					if "`plinevar'"!="" sae_proc_inds, matasource(`ydump') aggids(`aggids') ind(`indicators') plinevar(`plinevar')
				}
			}
			else { //plugin
				//Process ydump
				if "`_itran'"=="0" {
					local doydump = ("`indicators'"!="" & "`aggids'"!="" & ("`plinevar'"!="" | "`plines'"!=""))
					if `doydump'==1 {
						local plinesused : list plinevar | plines
						dis in yellow _n "Opening plugin"
						cap program define povc, plugin using("PovcPlugin`=cond(strpos(`"`=c(machine_type)'"',"64"),64,32)'.dll")
						cap plugin call povc, 1 "`ydump'" "`estout'" "`plinesused'" "`aggids'" "`indicators'" "`logout'"
						if _rc==0 {
							if "`results'"~="" {
								cap copy "`estout'" "`results'", replace
								if _rc==0 noi dis as text "Output bas been saved in `results'. Please see the results."
								else error 691
							}
							else {
								cap insheet using "`estout'", clear double case
								if _rc==0 noi dis as text "Output bas been loaded into Stata. Please see the results."
								else noi dis as text "Unable to load the result file into Stata."					
							}
							*cap erase "`ydump'"
							*cap erase "`estout'"
						}
						else {				
							sae_closefiles
							cap erase "`ydump'"
							cap erase "`estout'"
							noi di "`_return_string'"
							error 1002
						} //rc plugin
					} //doydump
					else { //dont do ydump
						dis in yellow "No indicators were procssed, if you want indicators please provide all necessary options"
						dis in yellow "Options include: indicators(); aggids(); and plinevar() or plines()"					
					}
					
					//copy mata ydump if needed
					if "`ydumpdta'"~="" noi sae_data_export, matasource(`ydump') numfiles(`numfiles') prefix(`prefix') datasave(`ydumpdta') `saveold'
				}
				else {
					sae_closefiles
				}
			} //end plugin
		}
		//if "`=lower("`process'")'"=="block" { //block-wise calculation
		//}
	}
	cap drop __hsyk0_0
end

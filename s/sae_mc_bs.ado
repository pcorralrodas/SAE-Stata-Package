*! version 2.2.5  June 17, 2025
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org
*! Joao Pedro Azevedo - jazevedo@worldbank.org
*! Qinghua Zhao  

* This program is free software: you can redistribute it and/or modify
* it under the ter		ms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.


cap program drop sae_mc_bs
program define sae_mc_bs, eclass byable(recall)
	version 11, missing
#delimit;
	syntax varlist(min=2 numeric fv) [if] [in] [aw],
	area(varname numeric)
	mcrep(integer)
	bsrep(integer)
	varest(string)
	matin(string)
	pwcensus(string)
	INDicators(string) 
	aggids(numlist sort)
	UNIQid(varname numeric)
	[
	lny
	bcox
	lnskew
	lnskew_w
	s2s_spec
	Zvar(varlist numeric fv) 
	yhat(varlist numeric fv) 
	yhat2(varlist numeric fv)
	seed(string)
	plinevar(string) 
	PLINEs(numlist sort)
	ydump(string)
	addvars(string)
	method(string)
	BENCHmarklevel(numlist sort max=1)
	BMindicator(string)
	Wbm(varname numeric)
	];
#delimit cr
set more off
	
*===============================================================================
//House keeping
*===============================================================================
	if ("`seed'"=="") local seed 3498743
	local hheffs `zvar' `yhat' `yhat2'
	if ("`hheffs'"=="") local hheffs = 0
	else                local hheffs = 1
	
	local ebest     = 1
	local etanormal = 1
	local epsnormal = 1
	
	foreach vs in varest{
		local `vs' = lower("``vs''")
	}
	
	local lavers c(version)	
	//Matrix inversion method
	if (missing("`method'")) local method invsym
	else{
		local method = lower("`method'")
		local metodos invsym luinv luinv_la cholinv cholinv_la
		local _vale : list method & metodos
		if (missing("`_vale'")){
			dis as error "You've specified matrix inversion method which is not allowed"
			error 198
			exit
		}
	}
	
	if (`lavers'<17 & (regexm("`method'", "lapacke"))){
		dis as error "Your stata version does not support the chosen matrix inversion method"
		error 198
		exit
	}
	
	//Special for S2S
	if ("`s2s_spec'"=="") local s2s_spec = 0
	else                  local s2s_spec = 1
	
	//join addvars and plinevar
	if "`plinevar'"!="" & "`plines'"!=""{
		dis as error "You must specify only one option: plinevar or plines"
		error 198
	}
	local plinevar: list uniq plinevar
	local addvars : list plinevar | addvars
	local addvars : list uniq addvars
	if ("`plinevar'"!="" & "`allmata'"=="") {
		if `: list sizeof plinevar' > 1 {
			dis as error "You must specify only one plinevar"
			error 198
			exit
		}
	}
	
	//Indicator checklist
	if "`indicators'"=="" local indicators fgt0
	local indicators = lower("`indicators'")
	local fgtlist
	local gelist
	local glist
	foreach ind of local indicators {
		if  "`ind'"=="fgt0" local fgtlist "`fgtlist' `ind'"
		if  "`ind'"=="fgt1" local fgtlist "`fgtlist' `ind'"
		if  "`ind'"=="fgt2" local fgtlist "`fgtlist' `ind'"
		if  "`ind'"=="ge0" local gelist "`gelist' `ind'"
		if  "`ind'"=="ge1" local gelist "`gelist' `ind'"
		if  "`ind'"=="ge2" local gelist "`gelist' `ind'"
		if  "`ind'"=="gini" local glist "`glist' `ind'"
	}	
	
	local indicators = upper("`indicators'")
		
	marksample touse23
	
	tokenize `varlist'
	local lhs `1'
	
	macro shift
	local _Xx `*'
	
	//Weights
	local wvar : word 2 of `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
	
	if ("`lny'"!="")      local lny = 1
	else                  local lny = 0
	if ("`bcox'"!="")     local bcox = 1
	else                  local bcox = 0
	if ("`lnskew'"!="")   local lnskew = 1
	else                  local lnskew = 0
	if ("`lnskew_w'"!="") local lnskew_w = 1
	else                  local lnskew_w = 0
	
	if (((`lnskew'+`bcox') ==2)){
		display as error "lnskew option can't be used with bcox option"
		error 198
		exit
	}
	
	//Benchmarking
	local elbm = 1
	local bmindicator = upper("`bmindicator'")
	if (missing("`benchmarklevel'") & ~missing("`bmindicator'")) local elbm = 0
	if (~missing("`benchmarklevel'") & missing("`bmindicator'")) local elbm = 0
	if (`elbm'==0){
		dis as error "benchmarklevel() and bmindicator() must be used together"
		error 198
		exit
	}
	if (~missing("`benchmarklevel'") & missing("`aggids'")){
		dis as error "When using benchmarklevel() you must specify the aggids() option"
		error 198
		exit
	}
	//Check if the bmindicator() was specified in indicartors
	// For now only mean and fgt0
	if (~missing("`bmindicator'")){
		local allowed MEAN FGT0
		local not_in_bm: list bmindicator - allowed
		if (~missing("`not_in_bm'")){
			dis as error "`not_in_bm' are not supported for benchmarking"			
			error 198
			exit
		}
	}
			
*===============================================================================
// Run model...
*===============================================================================
	local original_y `lhs'
	if (`bcox'==1){
		tempvar Thedep
		bcskew0 double `Thedep' = (`lhs') if `touse23'==1
		local lhs `Thedep'
		local lambda = r(lambda)
	}
	if (`lnskew'==1 & `lny'==1){
		tempvar Thedep
		lnskew0 double `Thedep' = exp(`lhs') if `touse23'==1
		local lhs `Thedep'
		local lambda = r(gamma)
	}
	if (`lnskew'==1 & `lny'==0){
		tempvar Thedep
		lnskew0 double `Thedep' = `lhs' if `touse23'==1
		local lhs `Thedep'
		local lambda = r(gamma)
	}
	if (`lnskew_w'==1 & `lny'==1){
		tempvar Thedep
		lnskew0w double `Thedep' = exp(`lhs') if `touse23'==1, weight(`wvar')
		local lhs `Thedep'
		local lambda = r(gamma)
		local lnskew = 1
	}
	if (`lnskew_w'==1 & `lny'==0){
		tempvar Thedep
		lnskew0w double `Thedep' = `lhs' if `touse23'==1, weight(`wvar')
		local lhs `Thedep'
		local lambda = r(gamma)
		local lnskew = 1
	}
	
	povmap `lhs' `_Xx' if `touse23'==1 [aw=`wvar'], area(`area') ///
	varest(`varest') zvar(`zvar') yhat(`yhat') yhat2(`yhat2') ebest uniq(`uniqid') seed(`seed') stage(first) method(`method') new 

*===============================================================================
// Pull necessary information produced by model for simulation
*===============================================================================
	predict double _MyXb, xb
	sort `area' `uniqid'
	
		local okvarlist = e(xvar)
		local zvarn  = e(zvar)
		local yhat2n = e(yhat2)
		local yhatn  = e(yhat)
		
		foreach x in okvarlist zvarn yhatn yhat2n{
			local `x' : list sort `x'
		}
		
		tempvar touse
		qui:gen `touse' = e(sample)
		qui:clonevar __my_tOuse = `touse'
		
		mata: _sige2      = *allest[3,25]
		qui:gen double __SiGma2 = .
		mata: st_store(.,st_varindex(tokens("__SiGma2")),"`touse'",sqrt(_sige2))
	
	tempfile mydata
	qui:save `mydata'
	
*===============================================================================
// Produce benchmark estimates - if requested!!
*===============================================================================
if (~missing("`benchmarklevel'")){
qui{
	//Need to properly back transform...	
	tempvar bm grupo
	if (`lny'==1) gen double `bm' = exp(`original_y')
	else clonevar `bm' = `original_y'
	
	gen double `grupo' = int(`area'/1e`benchmarklevel')
	
	//For now only poverty and mean
	local tocollapse
	local la_fgt0 FGT0
	local la_media MEAN
	local la_fgt0 : list bmindicator & la_fgt0
	if (~missing("`la_fgt0'")){
		if (~missing("`plinevar'")){
			gen fgt0_`plinevar' = `bm' < `plinevar' if !missing(`bm')
			local tocollapse fgt0_`plinevar'
		}
		foreach line of local plines{
			mata: st_local("nom", strtoname(strofreal(`line')))
			gen fgt0`nom' = `bm' < `line' if !missing(`bm')
			local tocollapse `tocollapse' fgt0`nom'
		}		
	}	
	local la_media: list bmindicator & la_media
	if (~missing("`la_media'")){
		clonevar theMean = `bm'
		local tocollapse `tocollapse' theMean
	}
	collapse (mean) `tocollapse' [aw=`wbm'], by(`grupo')
	rename `grupo' Unit2
	tempfile thebm
	save `thebm'
}
}

	
*===============================================================================
// Specify other locals needed for the MC simulation
*===============================================================================
	local rep `mcrep'
	local seed `seed'
	
	local matin `matin'         //CENSUS 
		
	local grvar `area'            //ETA cluster var
	
	local plines  `plines'         //Poverty Line
	local plinevar `plinevar'      //Variable with pov line
	
	//local pwcensus  	    //Census weightvar _ specified above
	
	local hhid1 `uniqid'           //Unique identifier in Census
	
	local hheffs    = `hheffs'  //alfa model	
	local etanormal = 1  		//ETA normal
	local epsnormal = 1  		//EPS Normal
	local ebest     = 1  		//EB indicator
	local lny       `lny'	    //Data as LNY
	
	local varinmodel "`okvarlist' `pwcensus' `area'"
	local varinmodel : list uniq varinmodel
	local addvars: list uniq addvars	
		
	local aggids  `aggids'
	//local indicators -> already specified above
	
	local matay 1
	
	mata: beta = st_matrix("e(b_gls)")
	mata: alfa = st_matrix("e(b_alpha)")
	mata: varU = *allest[3,1]
	mata: varE = *allest[3,2]
	//mata: cens_area = _getuniq("HID")
	mata: _loc        = *allest[4,3]    //areas with eta vector

	mata: _locerr     = _loc[.,1]
	mata: _loc2       = (.,0,varU)
	
	if (`hheffs'!=0){
		mata: _maxA        = *allest[3,6]
		mata: _varr        = *allest[3,7]
		mata: s2eps        = .
	}
	else{
		mata: _maxA        = .
		mata: _varr        = .
		mata: s2eps        = varE
	}
	
	if ("`plines'"=="") local plines `plinevar'
	
	//For the YDUMP
	local yhatlist
	forval z=1 / `rep' {
		local yhatlist `yhatlist' _YHAT`z'
	}

*===============================================================================
// Run the MC sim in mata and keep results
*===============================================================================
	
	mata: _s2sc_sim_molina("`okvarlist'", "`zvarn'", "`yhatn'", "`yhat2n'", "`grvar'", "`plines'", "`pwcensus'", "`touse'", "`hhid1'", "`matin'", beta, alfa,_locerr ,_loc, _loc2, _maxA, _varr, s2eps, varU)
	
	sae_closefiles
	
	local nogo  nSim Unit nHHLDs nIndividuals
	
	foreach x of varlist *{		
		local isin: list x & nogo
		if ("`isin'"==""){
			if (!(regexm("`x'","StdErr")|(regexm("`x'","se_")))){
				local _finvars `_finvars' `x'
			}
		}
	}
	
	keep nSim Unit nHH nIn `_finvars'
	gen double Unit2 = int(Unit/1e`benchmarklevel')
	if (~missing("`benchmarklevel'")){
		qui{
		preserve		
			merge m:1 Unit2 using `thebm'
				drop if _m!=3
				drop _m		
			
			collapse (mean) Mean avg_* (first) `tocollapse' [aw=nIndividuals], by(Unit2)
			foreach x of local tocollapse{
				cap replace `x' = `x'/avg_`x'
				if (_rc) replace `x' = `x'/Mean
				lab var `x' "Benchmark ratio for `x'"
			}
		save `thebm', replace
		restore
			merge m:1 Unit2 using `thebm', keepusing(`tocollapse')
				drop if _m==2
				drop _m
			
			foreach x of local tocollapse{
				cap gen bm_`x' = avg_`x'*`x'
				if (_rc) gen bm_`x' = Mean*`x'
				lab var bm_`x' "Benchmarked SAE for `x'"
			}
			cap rename bm_theMean bm_Mean
		}
	}
	
	tempfile eb_est
	qui:save `eb_est'
	//Ok, so now I have a benchmark for each strata...
	
	
*===============================================================================
// Run the Bootstrap
*===============================================================================

	display _n(1)
	display in yellow "Number of bootstraps: `bsrep'" _n(1)
	mata:display("{txt}{hline 4}{c +}{hline 3} 1 " + "{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " + "{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	local z=1
	local repitio = 0
	while (`z'<=`bsrep' & `repitio'<=20){
			local rep 1	
			local doone = 1
			local ebest = 1
			qui:mata: _s2sc_sim_molina("`okvarlist'", "`zvarn'", "`yhatn'", "`yhat2n'", "`grvar'", "`plines'", "`pwcensus'", "`touse'", "`hhid1'", "`matin'", beta, alfa,_locerr ,_loc, _loc2, _maxA, _varr, s2eps, varU)
			sae_closefiles
			
			//For the benchmark "true values, same as the original"
			if (~missing("`benchmarklevel'")){
				qui{
					foreach var of local tocollapse{
						cap clonevar bm_`var' = avg_`var'
						if (_rc) clonevar bm_`var' = Mean
					}
					cap rename bm_theMean bm_Mean
					if (`z'==1){
						unab _bmvars: bm_* 
						local _finvars `_finvars' `_bmvars'
					}
				}
			}
			
			//eMat is produced in this step....
			
			keep nSim Unit nHH nIn `_finvars'
			
			
			mata: S = st_data(.,"`_finvars'")
			local doone = 0
		

		sae_closefiles
		use `mydata', clear
		if (`z'==1){
			mata: st_view(elarea=.,.,"`area'","__my_tOuse")
			mata: _my_info = panelsetup(elarea,1)
			mata: elarea = elarea[_my_info[.,1]]			
		}
		//Note that the location vectors are sorted
		if (`s2s_spec'==0){
			mata _etamat = _invEB(elarea,Emat)[,2]
			mata: _myxb = st_data(.,"_MyXb","__my_tOuse")
			qui:gen double _NeWy = .
			cap: mata: _XB1=_addetaEB(_etamat,_my_info,_myxb)		
			if (_rc!=0){
				dis as error "ERROR: All areas within the survey should be present within the census data"
				error 459
				exit
			}
		}
		else{
			//elarea is from the survey, Emat is from the census...
			mata _etamat = _invEB(elarea,Emat)
			mata: _myxb = st_data(.,"_MyXb","__my_tOuse")
			qui:gen double _NeWy = .
			cap: mata: _XB1=_elMoritz(_etamat,_my_info, elarea,_myxb, varU)					
		}
		mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse",_XB1)	
		qui:replace _NeWy = _NeWy + rnormal(0, __SiGma2) if __my_tOuse==1
		local seed `c(rngstate)'
			
		*=======================================================================
		//Benchmark
		*=======================================================================
		if (~missing("`benchmarklevel'")){
		preserve
			qui{
				//Backtransform _Newy to get benchmark
				tempvar tt grupo
				if (`bcox'==1 & `lny'==1 & `lnskew'==0){
					gen `tt' = exp(((_NeWy*`lambda'+1)^(1/`lambda'))) 
				}
				if (`bcox'==0 & `lny'==1 & `lnskew'==0){
					gen `tt' = exp(_NeWy)
				}
				if (`bcox'==1 & `lny'==0 & `lnskew'==0){
					gen `tt' = (_NeWy*`lambda'+1)^(1/`lambda')
				}
				if (`bcox'==0 & `lny'==0 & `lnskew'==0){
					clonevar `tt' = _NeWy				
				}
				if (`bcox'==0 & `lny'==0 & `lnskew'==1){
					gen `tt' = exp(_NeWy)+`lambda'
				}
				if (~missing("`la_fgt0'")){
					if (~missing("`plinevar'")){
						gen fgt0_`plinevar' = `tt' < `plinevar' if !missing(`tt')
					}
					foreach line of local plines{
						mata: st_local("nom", strtoname(strofreal(`line')))
						gen fgt0`nom' = `tt' < `line' if !missing(`tt')
					}		
				}
				if (~missing("`la_media'")){
					clonevar theMean = `tt'
				}
				gen double `grupo' = int(`area'/1e`benchmarklevel')
				collapse (mean) `tocollapse' [aw=`wbm'], by(`grupo')
				rename `grupo' Unit2
				save `thebm', replace
			}
		restore
		} //end benchmark
		
		//FIt the model on the bootstrap data		
		qui:cap povmap _NeWy `_Xx' if `touse23'==1 [aw=`wvar'], area(`area') ///
		varest(`varest') zvar(`zvar') yhat(`yhat') yhat2(`yhat2') ebest seed(`seed') uniq(`uniqid') stage(first) method(`method') new
		if (_rc==73943){
			local z=`z'
			dis as error "Negative sigma eta Sq., I'm re-running this iteration...`z'"
			local repitio = `repitio'+1
			if (`repitio'>20){
				dis as error "Reached a max. number of re-runs (20), sigma eta sq is still negative, fix the model"
				error 7498
				exit
			}
		}
		else{
			if (_rc!=0){
				dis as error "I've encountered a problem"
				povmap _NeWy `_Xx' if `touse23'==1 [aw=`wvar'], area(`area') ///
		varest(`varest') zvar(`zvar') yhat(`yhat') yhat2(`yhat2') ebest seed(`seed') uniq(`uniqid') stage(first) method(`method') new
				exit
			}
			mata: betaA = st_matrix("e(b_gls)")
			mata: alfaA = st_matrix("e(b_alpha)")
			mata: varUA = *allest[3,1]
			mata: varEA = *allest[3,2]
			//mata: cens_area = _getuniq("HID")
			mata: _locA        = *allest[4,3]    //areas with eta vector
			mata: _locerrA     = _loc[.,1]       //Not used
			mata: _loc2A       = (.,0,varUA)
			
			if (`hheffs'!=0){
				mata: _maxAA       = *allest[3,6]
				mata: _varrA       = *allest[3,7]
				mata: s2epsA       = .
			}
			else{
				mata: _maxAA       = .
				mata: _varrA       = .
				mata: s2epsA       = varEA
			}
			
			if (`z'==1) mata: all_beta = betaA
			else        mata: all_beta = all_beta\betaA
			
			local rep `mcrep'		
			local ebest = 1
			
			qui:mata:_s2sc_sim_molina("`okvarlist'", "`zvarn'", "`yhatn'", "`yhat2n'", "`grvar'", "`plines'", "`pwcensus'", "`touse'", "`hhid1'", "`matin'", betaA, alfaA,_locerrA ,_locA, _loc2A, _maxAA, _varrA, s2epsA, varUA) 
			sae_closefiles
			if (mod(`z',50)==0){
				display in white ".  `z'" _continue
				display _n(0)
			}
			else display "." _continue
			gen double Unit2 = int(Unit/1e`benchmarklevel')
			if (~missing("`benchmarklevel'")){
				qui{
				preserve		
					merge m:1 Unit2 using `thebm'
						drop if _m!=3
						drop _m		
					
					collapse (mean) Mean avg_* (first) `tocollapse' [aw=nIndividuals], by(Unit2)
					foreach x of local tocollapse{
						cap replace `x' = `x'/avg_`x'
						if (_rc) replace `x' = `x'/Mean
					}
				save `thebm', replace
				restore
					merge m:1 Unit2 using `thebm', keepusing(`tocollapse')
						drop if _m==2
						drop _m
					
					foreach var of local tocollapse{
						cap gen bm_`var' = avg_`var'*`var'
						if (_rc) gen bm_`var' = Mean*`var'					
					}
					cap rename bm_theMean bm_Mean
				}
			}			
						
			mata: S_ = st_data(.,"`_finvars'")
	
			if (`z'==1) mata: MSE = (S-S_):^2
			else        mata: MSE = MSE + (S-S_):^2	
			
			local repitio = 0
			local z=`z'+1
		}
	}
	if (`bsrep'!=0){
		sae_closefiles
		mata: MSE = MSE:/(`bsrep')	
		
		use `eb_est', replace
		
		foreach x of local _finvars{
			qui:gen mse_`x' = .
			local tostore `tostore' mse_`x'
		}
		
		qui:gen MC = `mcrep'
		qui:gen BS = `bsrep'
		qui:drop nSim
		qui: order MC BS, first
		
		qui:mata: st_store(.,st_varindex(tokens("`tostore'")),MSE)
	}
	else{
		use `eb_est', replace
		qui:gen MC = `mcrep'
		qui:gen BS = `bsrep'
		qui:drop nSim
		qui: order MC BS, first
	}
	
end






	
	
	
	

*! version 0.1 September 2, 2019
*! Copyright (C) World Bank 2019 - Minh Cong Nguyen & Paul Andres Corral Rodas
*! Paul Corral - pcorralrodas@worldbank.org 
*! Minh Cong Nguyen - mnguyen3@worldbank.org

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
	CONStant(real 0.0)
	Zvar(varlist numeric fv) 
	yhat(varlist numeric fv) 
	yhat2(varlist numeric fv)
	seed(string)
	plinevar(string) 
	PLINEs(numlist sort)
	ydump(string)
	addvars(string)
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
	
	//Indicator checklist
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
	
	if ("`lny'"!="")  local lny = 1
	else              local lny = 0
	if ("`bcox'"!="") local bcox = 1
	else              local bcox = 0
	
*===============================================================================
// Run model...
*===============================================================================
	if (`bcox'==1){
		tempvar Thedep
		bcskew0 double `Thedep' = (`lhs'+`constant') if `touse23'==1
		local lhs `Thedep'
		local lambda = r(lambda)
	}

	povmap `lhs' `_Xx' if `touse23'==1 [aw=`wvar'], area(`area') ///
	varest(`varest') zvar(`zvar') yhat(`yhat') yhat2(`yhat2') ebest uniq(`uniqid') seed(`seed') stage(first) new

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
	save `mydata'
	
*===============================================================================
// Specify other locals needed for the MC simulation
*===============================================================================
	local rep `mcrep'
	local seed `seed'
	
	local matin `matin'         //CENSUS 
		
	local grvar `area'            //ETA cluster var
	
	local plines  `plines'         //Poverty Line
	local plinevar `plinevar'      //Variable with pov line
	
	if ("`plinevar'"!="") local plines `plinevar'
	
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

*===============================================================================
// Run the MC sim in mata and keep results
*===============================================================================
	
	mata: _s2sc_sim_molina("`okvarlist'", "`zvarn'", "`yhatn'", "`yhat2n'", "`grvar'", "`plines'", "`pwcensus'", "`touse'", "`hhid1'", "`matin'", beta, alfa,_locerr ,_loc, _loc2, _maxA, _varr, s2eps, varU)
	
	sae_closefiles
	
	local nogo  nSim Unit nHHLDs nIndividuals
	
	foreach x of varlist *{		
		local isin: list x & nogo
		if ("`isin'"==""){
			if (!(regexm("`x'","StdErr")|(regexm("`x'","se_fgt")))){
				local _finvars `_finvars' `x'
			}
		}
	}
	
	keep nSim Unit nHH nIn `_finvars'
	
	tempfile eb_est
	qui:save `eb_est'
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
		mata _etamat = _invEB(elarea,Emat)[,2]
		mata: _myxb = st_data(.,"_MyXb","__my_tOuse")
		qui:gen double _NeWy = .
		mata: _XB1=_addetaEB(_etamat,_my_info,_myxb)		
		mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse",_XB1)	
		qui:replace _NeWy = _NeWy + rnormal(0, __SiGma2) if __my_tOuse==1
		local seed `c(rngstate)'
				
		qui:cap povmap _NeWy `_Xx' if `touse23'==1 [aw=`wvar'], area(`area') ///
		varest(`varest') zvar(`zvar') yhat(`yhat') yhat2(`yhat2') ebest seed(`seed') uniq(`uniqid') stage(first) new
		if (_rc==73943){
			local z=`z'
			dis as error "Negative sigma eta Sq., I'm re-running this iteration...`z'"
			local repitio = `repitio'+1
			if (`repitio'>20){
				dis as error "Reached a max. number of re-runs (20), sigma eta sq is still negative, revise model"
				error 7498
				exit
			}
		}
		else{
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






	
	
	
	

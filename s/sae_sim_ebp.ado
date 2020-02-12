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


cap program drop sae_ebp
program define sae_ebp, eclass byable(recall)
	version 11, missing
#delimit;
	syntax varlist(min=2 numeric fv) [if] [in],
	area(varname numeric)
	mcrep(integer)
	bsrep(integer)
	matin(string)
	pwcensus(string)
	pwsurvey(string)
	INDicators(string) 
	aggids(numlist sort)
	UNIQid(varname numeric)
	[
	lny
	seed(string)
	plinevar(string) 
	PLINEs(numlist sort)
	appendsvy
	complex
	];
#delimit cr
set more off
	
*===============================================================================
//House keeping
*===============================================================================
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
		exit
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
	if ("`pwsurvey'"!="") replace `touse23' = 0 if missing(`pwsurvey')
	
	tokenize `varlist'
	local lhs `1'
	
	macro shift
	local _Xx `*'
	
	//Weights
	local exp
	local wvar : word 2 of `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
	
	if ("`lny'"!="") local lny = 1
	else             local lny = 0
	
	if ("`appendsvy'"!="") local appendsvy=1
	else                   local appendsvy=0
	
	if ("`complex'"=="")   local complex=0
	else 				   local complex=1
	
	if (`complex' == 1 & `appendsvy'==1){
		dis as error "Only Census EB is possible with Guadarrama et al's (2016) SAE"
		error 198
		exit
	}
	if ("`seed'"=="") local seed 12345
	set seed `seed'
*===============================================================================
// Run model...
*===============================================================================
	_rmcoll `_Xx' if `touse23', forcedrop
	local _Xx: list uniq _Xx
	local _Xx: list sort _Xx
	
	xtmixed `lhs' `_Xx' if `touse23'==1 || `area':, reml

*===============================================================================
// Pull necessary information produced by model for simulation
*===============================================================================
	mata: beta = st_matrix("e(b)")
	mata: beta = beta[1,1..(cols(beta)-2)]
	
	predict double _Eta, reffects

	sort `area' `uniqid'
	
	local uvar = (exp([lns1_1_1]_cons))^2
	local evar =  (exp([lnsig_e]_cons))^2
	
		local okvarlist `_Xx'
		local zvarn  __mz1_000
		local yhat2n __myh2_000
		local yhatn  __myh_000
	
		foreach x in okvarlist zvarn yhatn yhat2n{
			local `x' : list sort `x'
		}
		
	
		tempvar touse
		qui:gen `touse' = e(sample)
		qui:clonevar __my_tOuse = `touse'
		
		local idio = (exp([lnsig_e]_cons))^2
		mata: _sige2      = `idio'
		gen double __SiGma2 = sqrt(`idio')
				
	tempfile mydata
	save `mydata'	
	
*===============================================================================
// Specify other locals needed for the MC simulation
*===============================================================================
	local rep `mcrep'
	local seed `seed'
	
	local matin `matin'         //CENSUS 
	
	local ydump				    //Needed for function...
	
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
		
	local aggids  `aggids'
	//local indicators -> already specified above
	
	local matay 1
	

	
	mata: varU = `uvar'
	mata: varE = `evar'
	

*===============================================================================
// Run the MC sim in mata and keep results
*===============================================================================
	
	noi:mata: _s2sc_sim_ebp("`okvarlist'", "`lhs'","`grvar'", "`plines'", "`pwsurvey'","`pwcensus'","`touse'","`hhid1'","`matin'","_Eta",beta, varU, varE)
	
	qui:groupfunction [aw=nIndividuals], mean(`_varnames') by(Unit) max(nSim) rawsum(nIndividuals nHHLDs)
	
	order nSim Unit nIndividuals nHHLDs, first
	qui{
		replace nInd = nInd/`rep'
		replace nHHLDs = nHHLDs/`rep'
	}
	
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
// Bootstraps
*===============================================================================
	local seed `c(rngstate)'
	display _n(1)
	display in yellow "Number of bootstraps: `bsrep'" _n(1)
	mata:display("{txt}{hline 4}{c +}{hline 3} 1 " + "{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " + "{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	
	forval z = 1/`bsrep'{
		
		//Section produces the "True Estimates for the Bootstrap"
			use `mydata', clear
			local rep 1	
			local doone = 1 //Used in the mata function to process vectors
			qui:mata: _s2sc_sim_ebp("`okvarlist'", "`lhs'","`grvar'", "`plines'", "`pwsurvey'","`pwcensus'","`touse'","`hhid1'","`matin'","_Eta",beta, varU, varE)
			sae_closefiles
			
			qui:groupfunction [aw=nIndividuals], mean(`_varnames') by(Unit) max(nSim) rawsum(nIndividuals nHHLDs)
	
			order nSim Unit nIndividuals nHHLDs, first
			qui{
				replace nInd = nInd/`rep'
				replace nHHLDs = nHHLDs/`rep'
			}
	
			
			keep nSim Unit nHH nIn `_finvars'
			sae_closefiles
			mata: S = st_data(.,"`_finvars'")
			local doone = 0
						
		//Finished with the production of true estimate
			use `mydata', clear
			qui:mata: st_addvar("double","_NeWy")
			if ("`lny'"=="") qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", _MyebpY) //New Y for the bootstrap
			else qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", ln(_MyebpY)) //New Y for the bootstrap
		
			qui:xtmixed _NeWy `_Xx' if `touse'==1 || `area':, reml
			predict double _EtaA, reffects
				local uvar = (exp([lns1_1_1]_cons))^2
				local evar =  (exp([lnsig_e]_cons))^2
				mata: varUA = `uvar'
				mata: varEA = `evar'
				mata: betaA = st_matrix("e(b)")
				mata: betaA = betaA[1,1..(cols(betaA)-2)]
				
				local rep `mcrep'
				
			qui:mata: _s2sc_sim_ebp("`okvarlist'", "_NeWy","`grvar'", "`plines'", "`pwsurvey'","`pwcensus'","`touse'","`hhid1'","`matin'","_EtaA",betaA, varUA, varEA)
			sae_closefiles
						
			qui:groupfunction [aw=nIndividuals], mean(`_varnames') by(Unit) max(nSim) rawsum(nIndividuals nHHLDs)
	
			order nSim Unit nIndividuals nHHLDs, first
			qui{
				replace nInd = nInd/`rep'
				replace nHHLDs = nHHLDs/`rep'
			}

			keep nSim Unit nHH nIn `_finvars'
				
		if (mod(`z',50)==0){
			display in white ". `z'" _continue
			display _n(0)
		}
		else display "." _continue
					
		mata: S_ = st_data(.,"`_finvars'")

		if (`z'==1) mata: MSE = (S-S_):^2
		else        mata: MSE = MSE + (S-S_):^2		
	}
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
	
end	
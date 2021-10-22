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


cap program drop sae_ebp_two
program define sae_ebp_two, eclass byable(recall)
	version 11, missing
#delimit;
	syntax varlist(min=2 numeric fv) [if] [in],
	subarea(varname numeric)
	area(numlist max=1)
	mcrep(integer)
	bsrep(integer)
	matin(string)
	INDicators(string) 
	aggids(numlist sort)
	pwcensus(string)
	[
		pwsurvey(string)
		UNIQid(string)
		lny
		bcox
		lnskew
		seed(string)
		plinevar(string) 
		PLINEs(numlist sort)
		appendsvy
		complex
		model
		mixed(string)
	];
#delimit cr
set more off
qui{
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
	
	if ("`model'"=="" & "`uniqid'"==""){
		dis as error "Option uniqid() reqired"
		error 198
		exit
		
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
	
	if ("`appendsvy'"!=""){
		local I FGT0 FGT1 FGT2
		local indicators: list indicators & I
		if ("`indicators'"==""){
			dis as error "appendsurvey option only works with FGT indicators"
			error 198
			exit
		}
	} 
		
	marksample touse23
	if ("`pwsurvey'"!="" & "`model'"=="") replace `touse23' = 0 if missing(`pwsurvey')
	
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
	
	if ("`pwsurvey'"==""){
		local pwsurvey `w'
	}
	
	if ("`lny'"!="") local lny = 1
	else             local lny = 0
	
	if ("`bcox'"!="") local bcox = 1
	else              local bcox = 0
	
	if ("`lnskew'"!="") local lnskew = 1
	else                local lnskew = 0
	
	if (((`lnskew'+`bcox') ==2)){
		display as error "lnskew option can's be used with bcox option"
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
	
	if (`bcox'==1){
		tempvar Thedep
		bcskew0 double `Thedep' = `lhs' if `touse23'==1
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

	
	if (length("`=`subarea'[1]'")<`area'){
		dis as error "The digit value for subarea should be less than the number of digits in area()"
		error 198
		exit
	}
	else{
		tempvar _subarea _area
		gen double `_area' = int(`subarea'/1e`area')
		gen double `_subarea' = `subarea'
	}
	
	noi:xtmixed `lhs' `_Xx' if `touse23'==1 || `_area':||`_subarea':, reml difficult `mixed'
	local doagain = e(converged)
	if (`doagain'==0){
		dis as error "xtmixed of your specified model failed to converge"
		error 430
		exit
	}
	
	if ("`model'"==""){ // This part should only run under simulations...
	
*===============================================================================
// Pull necessary information produced by model for simulation
*===============================================================================
		mata: beta = st_matrix("e(b)")
		mata: beta = beta[1,1..(cols(beta)-3)]
		
		predict double _LErrOr_, xb
		predict double _domE_ _tdomE_, reffects //gives me location effects
		replace _LErrOr_ = `lhs' - _LErrOr_ if `touse23'==1 
		egen double _LErrOr1_ = mean(_LErrOr_) if `touse23'==1, by(`_area' `_subarea')
		drop _LErrOr_
		sort `_area' `_subarea' `uniqid'
		
		
		local sig1_2 =  (exp([lns1_1_1]_cons))^2
		local sig2_2 =   exp([lns2_1_1]_cons)^2
		local evar   =  (exp([lnsig_e]_cons))^2
		
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
		
		local grvarS `_subarea'            //ETA cluster var
		local grvarL `_area'            //ETA cluster var
		
		local plines  `plines'         //Poverty Line
		local plinevar `plinevar'      //Variable with pov line
		
		//local pwcensus  	    //Census weightvar _ specified above
		
		local hhid1 `uniqid'           //Unique identifier in Census
		
		local hheffs    = `hheffs'  //alfa model	
		local etanormal = 1  		//ETA normal
		local epsnormal = 1  		//EPS Normal
		local ebest     = 1  		//EB indicator
		local lny       `lny'	    //Data as LNY
		
		local varinmodel "`okvarlist' `pwcensus' `subarea'"
		local varinmodel : list uniq varinmodel
			
		local aggids  `aggids'
		//local indicators -> already specified above
		
		local matay 1	
		
		mata: varUL = `sig1_2'
		mata: varUS = `sig2_2'
		mata: varE = `evar'
		
	if ("`plines'"=="") local plines `plinevar'
	
*===============================================================================
// Run the MC sim in mata and keep results
*===============================================================================
		//Pass subarea here!
		noi:mata: _s2sc_sim_ebp2("`okvarlist'", "`lhs'","`grvarS'", "`plines'", "`pwsurvey'","`pwcensus'","`touse'","`hhid1'","`matin'","_domE_","_tdomE_","_LErrOr1_",beta, varUL, varUS, varE)
	

		
		
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
		//Up to here we are set (Oct. 23, 2020)
*===============================================================================
// Bootstraps
*===============================================================================
		local seed `c(rngstate)'
		noi:display _n(1)
		noi:display in yellow "Number of bootstraps: `bsrep'" _n(1)
		noi:mata:display("{txt}{hline 4}{c +}{hline 3} 1 " + "{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " + "{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
		local z=1
		local repitio = 0
		while (`z'<=`bsrep' & `repitio'<=20){
			
			//Section produces the "True Estimates for the Bootstrap"
			use `mydata', clear
			local rep 1	
			local doone = 1 //Used in the mata function to process vectors
			qui:mata: _s2sc_sim_ebp2("`okvarlist'", "`lhs'","`grvarS'", "`plines'", "`pwsurvey'","`pwcensus'","`touse'","`hhid1'","`matin'","_domE_","_tdomE_","_LErrOr1_",beta, varUL, varUS, varE)
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
			//Add unboxcoxing!! This is why you are getting larger MSE
			if (`lny'==0 & `bcox'==0 & `lnskew'==0) qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", _MyebpY)                      //New Y for the bootstrap
			if (`lny'==1 & `bcox'==0 & `lnskew'==0) qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", ln(_MyebpY))                  //New Y for the bootstrap
			if (`lny'==0 & `bcox'==1 & `lnskew'==0) qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", _bcsk(_MyebpY,`lambda'))      //New Y for the bootstrap
			if (`lny'==1 & `bcox'==1 & `lnskew'==0) qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", (_bcsk(ln(_MyebpY),`lambda'))) //New Y for the bootstrap
			if (`lnskew'==1)						qui:mata: st_store(.,st_varindex(tokens("_NeWy")),"__my_tOuse", (ln(_MyebpY:-`lambda')))                  //New Y for the bootstrap

			qui:xtmixed _NeWy `_Xx' if `touse'==1 || `_area':||`_subarea':, reml difficult `mixed'
			local doagain = e(converged)
			if (`doagain'==0){
				local z = `z'
				dis as error "Negative sigma eta Sq., I'm re-running this iteration...`z'"
				local repitio = `repitio'+1
				if (`repitio'>20){
					dis as error "Reached a max. number of re-runs (20), I have not converged, revise model"
					error 7498
					exit
				}
			}
			else{
				predict double _domEA_ _tdomEA_, reffects
				predict double _LErrOrA_, xb
				replace _LErrOrA_ = _NeWy - _LErrOrA_ if `touse'==1
				egen double _LErrOr1A_ = mean(_LErrOrA_) if `touse'==1, by(`_area' `_subarea')

				local sig1_2A =  (exp([lns1_1_1]_cons))^2
				local sig2_2A =  (exp([lns2_1_1]_cons))^2
				local evarA   =  (exp([lnsig_e]_cons))^2
				
				mata: varULA = `sig1_2A'
				mata: varUSA = `sig2_2A'
				mata: varEA  = `evarA'
				
				mata: betaA = st_matrix("e(b)")
				mata: betaA = betaA[1,1..(cols(betaA)-3)]
				
				local rep `mcrep'
				
				qui:mata: _s2sc_sim_ebp2("`okvarlist'", "_NeWy","`grvarS'", "`plines'", "`pwsurvey'", "`pwcensus'","`touse'", "`hhid1'", "`matin'", "_domEA_","_tdomEA_","_LErrOr1A_",betaA, varULA, varUSA, varEA)
				sae_closefiles
							
				qui:groupfunction [aw=nIndividuals], mean(`_varnames') by(Unit) max(nSim) rawsum(nIndividuals nHHLDs)
			
				order nSim Unit nIndividuals nHHLDs, first
				qui{
					replace nInd = nInd/`rep'
					replace nHHLDs = nHHLDs/`rep'
				}
		
				keep nSim Unit nHH nIn `_finvars'
				
				if (mod(`z',50)==0){
					noi:display in white ". `z'" _continue
					noi:display _n(0)
				}
				else noi:display "." _continue
							
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
	} //END of model if
}		
end

exit

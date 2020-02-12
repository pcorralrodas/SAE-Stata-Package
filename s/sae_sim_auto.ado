*! version 0.1.1  22Dec2018
*! Copyright (C) World Bank 2018-19
*  Paul Corral - World Bank Group 
*  Alexandru Cojocaru - World Bank Group

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

cap set matastrict off
clear mata
cap program drop sae_sim_auto
program define sae_sim_auto, eclass
	version 13
	#delimit ;
	syntax varlist(min=2 numeric fv) [if] [in] [aw pw fw], 
	area(varname numeric) usedata(string) matin(string) 
	[	
	UNIQid(varname numeric) PSU(varname numeric) 
	Zvar(varlist numeric fv) yhat(varlist numeric fv) yhat2(varlist numeric fv) lny 
	plinevar(string) PLINEs(numlist sort)
	rep(integer 0) seed(integer 123456789) 
	PWcensus(string) COLprocess(integer 1) 
	vce(string) aggids(numlist sort) NOIsily INDicators(string)
	];
	#delimit cr	

	if c(more)=="on" set more off
	if ("`indicators'"=="") local indicators fgt0 fgt1 fgt2

qui {	
	tokenize `varlist'
	local depvar `1'
	macro shift
	local indeps `*'

	//Weights
	local wvar : word 2 of `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
		
	local varest ell h3
	local myalfa zvar(`zvar') yhat(`yhat') yhat2(`yhat2')
	local hetero hetero nohetero
	local eb     ebest noebest

	local counter=1
	noi dis _n "Running all simulation options:"
	foreach vest of local varest {
		foreach best of local eb {
			if ("`best'"=="ebest") {
				local epsilon normal
				local eta normal
				local boot bootstrap
			}
			else {
				if ("`vest'"=="h3") local boot bootstrap
				else                local boot bootstrap nobootstrap
				local best 
				local epsilon normal nonnormal
				local eta normal nonnormal			
			}
			
			foreach eps of local epsilon {
				foreach et of local eta {
					foreach b of local boot {
						if ("`b'"=="nobootstrap") local b
						foreach het of local hetero {
							if ("`het'"=="nohetero") local het
							else local het `myalfa'
							
							use "`usedata'", clear							
							noi dis in green `"Running simulation option (`counter'): varest(`vest'), epsilon(`eps'), eta(`et'), `b', `best', `het'"'
							if ("`vest'"=="ell") sae model lmm `depvar' `indeps' [aw=`wvar'], area(`area') varest(`vest')  `het'
							if (e(var_eta_var)==. & "`b'"==""){
								local ++counter
								dis as error "ELL model has missing sampling variance of sigma eta, please check"
								exit
							}
							`noisily' sae sim lmm `depvar' `indeps' [aw=`wvar'], area(`area') ///
							varest(`vest')  vce(`vce') uniqid(`uniqid') psu(`psu') epsilon(`eps') ///
							eta(`et') `b' `best' seed(`seed') col(1) lny pline(`plines') plinevar(`plinevar') ///
							pwcensus(`pwcensus') matin(`matin') aggids(`aggids') ///
							allmata indicators(`indicators') rep(`rep') `het'
							
							gen ebest = "`best'"
							lab var ebest "EBest estimates, empty means no EB"
							gen varest= "`vest'"
							lab var varest "Varest used, ELL or H3"
							gen epsilon = "`eps'"
							lab var epsilon "Epsilon used, normal or nonnormal"
							gen eta     = "`et'"
							lab var eta "Eta used "
							gen bootstrap = "`b'"
							lab var bootstrap  "Bootstrap simulation, empty means parametric"
							gen hetero    = "`het'"
							lab var hetero "Heteroskedastic sim, empty means homoskedastic"
							gen indeps = "`indeps'"
							gen group = `counter'
							lab var group "Variable for grouping simulations"
							
							gen rmse_beta  = e(rmse_beta) 
							gen r2_beta    = e(r2_beta)
							gen F_beta     = e(F_beta)
							gen r2a_beta   = e(r2a_beta) 
							gen N_beta     = e(N_beta) 
							gen dfm_beta   = e(dfm_beta) 
							gen eta_ratio  = e(eta_ratio) 
							gen eta_var    = e(eta_var) 
							gen eps_var    = e(eps_var) 
							gen rmse_alpha = e(rmse_alpha) 
							gen r2_alpha   = e(r2_alpha)
							gen F_alpha    = e(F_alpha) 
							gen r2a_alpha  = e(r2a_alpha) 
							gen N_alpha    = e(N_alpha) 
							gen dfm_alpha  = e(dfm_alpha) 

							tempfile _`counter'
							save `_`counter''
							
							local misarchivos `misarchivos'  _`counter'
							
							local ++counter
						} //het
					} //boot
				} //eta
			} //eps
		} //ebest
	} //vest

	tokenize `misarchivos'
	use ``1'', clear
	macro shift
	local rest `*'
	foreach x of local rest{
		append using ``x''
	}
} //qui
end

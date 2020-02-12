*! version 0.1.2  24Feb2018
*! Copyright (C) World Bank 2018-19 - Minh Cong Nguyen & Paul Andres Corral Rodas
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

cap program drop sae_model_auto
program define sae_model_auto, rclass

	syntax varlist(min=2 numeric fv) [if] [in] [aw pw fw], area(varname numeric) ///
	[VARest(string) UNIQid(varname numeric) lny pr(integer 5) stepvif(integer 5) ///
	seed(integer 123456789) method(string)]
	
	// check and install outside programs
	local extpro vselect 
	foreach pg of local extpro {
		cap which `pg'
		if _rc~=0 cap ssc inst `pg', replace
		if _rc~=0 dis as error "You have to download the external program manually."
	}

	display _newline in ye "Running model selection..."

	if c(more)=="on" set more off
    local version : di "version " string(_caller()) ", missing:"
	local cmdline: copy local 0
	set seed `seed'
	local pr1 =`pr'/100
	
	if ("`varest'"=="") local varest h3
	if ("`method'"=="") local method vselect
	
	//Weights
	local wvar : word 2 of `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}

	//missing observation check
	marksample touse
	local flist `"`varlist' `by' `grvar'"'
	markout `touse' `flist' 
	gettoken lhs varlist: varlist
	_fv_check_depvar `lhs'	
	
	//Selection of X vars
	qui _rmcoll `varlist' if `touse', forcedrop
	local okvarlist `r(varlist)'
	local okvarlist : list sort okvarlist
	
	local n = 1
	local n_insign = 1
	qui while `n_insign' > 0 {
		//reset global
		global selected_x_
		global vary_x_
		global vary2_x_
		global zvar_x_
		global yhat_x_
		global yhat2_x_
		
		reg `lhs' `okvarlist' [aw=`wvar'], robust
		*new
		mat b = e(b)'
		local mm= rowsof(b)
		local nn = `mm'-1
		mat c = b[1..`nn',.]
		local rname : rowfullnames c
		local oname
		foreach vrn of local rname {
			if strpos("`vrn'","o.") == 0 local oname "`oname' `vrn'"
		}
		local okvarlist : list sort oname
		*new 
		
		tempvar todo
		gen `todo' =e(sample)
		mata: ds=_f_stepvif("`okvarlist'", "`wvar'", `stepvif', "`todo'")
		local postvif `vifvar'
		reg `lhs' `vifvar' [aw=`wvar'], robust

		//Selection beta
		//mata code later here
		if "`=lower("`method'")'" == "stepwise" {
			stepwise, pr(`pr1'): reg `lhs' `postvif' [aw = `wvar']
		}
		else if "`=lower("`method'")'" == "vselect" {
			vselect `lhs' `postvif' [aw=`wvar'], forward aic 
		}
		else {
			noi dis "this is new method - maybe in the future"
		}
		
		local temp : colfullnames e(b) 
		local b _cons
		local xvars : list temp - b
		global selected_x_ `xvars'

		reg `lhs' $selected_x_ [aw = `wvar']
		tempvar _yhat
		cap drop `_yhat'
		predict `_yhat' if e(sample), xb

		* No variables sleected for the alpha models
		* this is the same as no variables in alpha model
		sae model lmm `lhs' $selected_x_ [aw=`wvar'], area(`area')  varest(`varest')

		* Create variables for the alpha model
		cap drop *_y_
		cap drop *_y2_
		foreach var of global selected_x_ {
			gen double `var'_y_ = `var'*`_yhat'
			gen double `var'_y2_ = `var'*`_yhat'*`_yhat'
			global vary_x_ "$vary_x_ `var'_y_"
			global vary2_x_ "$vary2_x_ `var'_y2_"
		}
			
		* Getting the dependent variable for the alpha model
		cap drop _res_alfa
		cap drop _res_xb
		tempvar fakevar
		gen `fakevar' = runiform(0,1)
		sae model lmm `lhs' $selected_x_ [aw=`wvar'], area(`area') varest(`varest') alfatest(_res) zvar(`fakevar') 
		
		 * Alpha model selection - here you can do the different model selections until you think that is good
		if "`=lower("`method'")'" == "stepwise" {
			stepwise, pr(`pr1'): reg _res_alfa $selected_x_ $vary_x_ $vary2_x_ [aw=`wvar']
		}
		else if "`=lower("`method'")'" == "vselect" {
			vselect _res_alfa $selected_x_ $vary_x_ $vary2_x_ [aw=`wvar'], forward aic 
		}
		else {
			noi dis "this is new method - maybe in the future"
		}
		
		mat b = e(b)'
		local mm= rowsof(b)
		local nn = `mm'-1
		mat c = b[1..`nn',.]
		local rname : rowfullnames c
		global B = "`rname'"
		global alphalist "$B"

		*reg _res_alfa $alphalist [aw=`wvar']
		*reg _res_alfa $alphalist [aw=`wvar'], robust
		
		foreach var of global alphalist {
			if strpos("`var'","_y2_")>0 {
				global yhat2_x_ "$yhat2_x_ `=substr("`var'", 1, `=strlen("`var'")-4')'"
			}
			else {
				if strpos("`var'","_y_")>0 global yhat_x_ "$yhat_x_ `=substr("`var'", 1, `=strlen("`var'")-3')'"
				else global zvar_x_ "$zvar_x_ `var'"
			}
		}

		* then you pass that to the final model and see the GLS estimates
		sae model lmm `lhs' $selected_x_ [aw=`wvar'], area(`area') varest(`varest') zvar($zvar_x_) yhat($yhat_x_) yhat2($yhat2_x_) 
		* Criteria of the model selections
		* all variables are significant
		* R2 is good, 0.5 and more
		* Ratio of sigma eta sq over MSE: should be less than 0.05
		
		//Auto deseect the insignificant variables - one at a time
		mata: _f_rmv_insignvar()
		if "`rmvvar'"~="" {
			local n_insign = 1
			local ++n
			local okvarlist : list okvarlist - rmvvar
			local prmvvar = r(pv)
			local prmvvar = trim("`: dis %10.4f `prmvvar''")
			noi dis in yellow "p = `prmvvar' >= `pr1'  removing `rmvvar'"
			*noi dis in yellow "Removing insignificant variable (`prmvvar'): `rmvvar'"
		}
		else {
			local n_insign = 0
			display _newline in ye "Final model:"
			noi sae model lmm `lhs' $selected_x_ [aw=`wvar'], area(`area') varest(`varest') zvar($zvar_x_) yhat($yhat_x_) yhat2($yhat2_x_) 
			
			return add
			return local cmdline `cmdline'
			return local xvarlist $selected_x_
			return local zvarlist $zvar_x_
			return local yhatlist $yhat_x_
			return local yhat2list $yhat2_x_
			return local nrun `n'
			
			//reset global
			global selected_x_
			global vary_x_
			global vary2_x_
			global zvar_x_
			global yhat_x_
			global yhat2_x_
		
		} //end mata condition
	} // while loop
	
end

mata:
mata set matalnum on
mata set mataoptimize on

function _f_rmv_insignvar() {
	pval = strtoreal(st_local("pr1"))
	bname = st_matrixcolstripe("e(b_gls)")
	pvalue = 2*(normal(-(abs(st_matrix("e(b_gls)")':/sqrt(diagonal(st_matrix("e(V_gls)")))))))
	idx = selectindex(pvalue:>pval)
	namel = bname[idx,.]
	plist = pvalue[idx]
	p = order(plist,1)
	nlist = namel[p,.]
	if (rows(nlist)>0) {
		st_local("rmvvar", nlist[rows(nlist),2])
		st_numscalar("r(pv)", plist[p][rows(plist)])
	}
	else {
		st_local("rmvvar", "")
	}
}

end

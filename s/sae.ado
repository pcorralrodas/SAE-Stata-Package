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

cap program drop sae
program sae, rclass
	version 11.0
	local version : di "version " string(_caller()) ":"
	set prefix sae
	gettoken subcmd 0 : 0, parse(" :,=[]()+-")
	local l = strlen("`subcmd'")
	
	if ("`subcmd'"=="data") { //data relelated tasks
		gettoken subcmd1 0 : 0, parse(" :,=[]()+-")
		if ("`subcmd1'"=="import") { //import dta to mata file			
			sae_data_import `0'
		}
		else if ("`subcmd1'"=="export") { //export matafile ydump to dta
			sae_data_export `0'
		}
		else {
			if ("`subcmd1'"=="") {
				di as smcl as err "syntax error"
				di as smcl as err "{p 4 4 2}"
				di as smcl as err "{bf:sae data} must be followed by a subcommand."
				di as smcl as err "You might type {bf:sae data import}, or {bf:sae data export}, etc."				
				di as smcl as err "{p_end}"
				exit 198
			}
			capture which sae_data_`subcmd1'
			if (_rc) { 
				if (_rc==1) exit 1								
				di as smcl as err "unrecognized subcommand:  {bf:sae data `subcmd1'}"
				exit 199
				/*NOTREACHED*/
			}
			`version' sae_data_`subcmd1' `0'
		}
	}
	else if ("`subcmd'"=="model") { //model and estimate parameters needed for simulations
		gettoken subcmd1 0 : 0, parse(" :,=[]()+-")
		if ("`subcmd1'"=="ell" | "`subcmd1'"=="h3" | "`subcmd1'"=="lmm") {	
			local 0 = subinstr(`"`0'"',char(34),"",.)
			local 0 : list clean 0
			local 0 = subinstr("`0'", "stage(second)", "stage(first)",.)
			local etapa stage(first)
			local ch: list 0 & etapa
			if ("`ch'"=="") local 0 `0' stage(first)
			
			if ("`subcmd1'"!="lmm") povmap `0' varest(`subcmd1') new
			else  povmap `0'
		}
		else if ("`subcmd1'"=="reml") {
			sae_ebp `0' model mcrep(0) bsrep(0) matin(NO) pwcensus(XX) indicators(fgt0) aggids(0) pwsurvey(XX)
		}
		else {
			if ("`subcmd1'"=="") {
				di as smcl as err "syntax error"
				di as smcl as err "{p 4 4 2}"
				di as smcl as err "{bf:sae model} must be followed by a subcommand."
				di as smcl as err "You might type {bf:sae model h3},etc."				
				di as smcl as err "{p_end}"
				exit 198
			}
			capture which sae_model_`subcmd1'
			if (_rc) { 
				if (_rc==1) exit 1
				di as smcl as err "unrecognized subcommand:  {bf:sae model `subcmd1'}"
				exit 199
				/*NOTREACHED*/
			}
			`version' sae_model_`subcmd1' `0'
		}
    }
	else if ("`subcmd'"=="simulation") | ("`subcmd'"=="sim") {
		gettoken subcmd1 0 : 0, parse(" :,=[]()+-")
		if ("`subcmd1'"=="ell") {
			local 0 = subinstr(`"`0'"',char(34),"",.)
			local 0 : list clean 0
			local 0 = subinstr("`0'", "stage(first)", "stage(second)",.)
			local etapa stage(second)
			local ch: list 0 & etapa
			if ("`ch'"=="") local 0 `0' stage(second)
			povmap `0' varest(ell) new
		}
		else if ("`subcmd1'"=="reml") {
			local 0 = subinstr(`"`0'"',char(34),"",.)
			local 0 : list clean 0
			sae_ebp `0'
		}	
		else{
			if ("`subcmd1'"=="h3"){
				local 0 = subinstr(`"`0'"',char(34),"",.)
				local 0 : list clean 0
				sae_mc_bs `0' varest(h3)
			}
			if ("`subcmd1'"=="elleb"){
				local 0 = subinstr(`"`0'"',char(34),"",.)
				local 0 : list clean 0
				sae_mc_bs `0' varest(ell)
			}
			if ("`subcmd1'"=="lmm"){
				display as error "Please refer to Corral, Molina, and Nguyen (2020), this method has been shown to be less than ideal"
				local 0 = subinstr(`"`0'"',char(34),"",.)
				local 0 : list clean 0
				povmap `0' stage(second)
				display as error "Please refer to Corral, Molina, and Nguyen (2020), this method has been shown to be less than ideal"
			}
			if (~inlist("`subcmd1'","ell","h3","elleb","reml", "lmm")){
				di as smcl as err "unrecognized subcommand:  {bf:sae sim `subcmd1'}"
				exit 199
			}
		}
    }
	else if ("`subcmd'"=="process") | ("`subcmd'"=="proc") { //processing ydump database
		gettoken subcmd1 0 : 0, parse(" :,=[]()+-")
		if ("`subcmd1'"=="indicator") | ("`subcmd1'"=="ind") {
			sae_proc_inds `0'
		}
		else if ("`subcmd1'"=="stats") {
			sae_proc_stats `0'
		}
		else {
			if ("`subcmd1'"=="") {
				di as smcl as err "syntax error"
				di as smcl as err "{p 4 4 2}"
				di as smcl as err "{bf:sae proc} must be followed by a subcommand."
				di as smcl as err "You might type {bf:sae proc ind}, or {bf:sae proc stats}, etc."				
				di as smcl as err "{p_end}"
				exit 198
			}
			capture which sae_proc_`subcmd1'
			if (_rc) { 
				if (_rc==1) exit 1
				di as smcl as err "unrecognized subcommand:  {bf:sae proc `subcmd1'}"
				exit 199
				/*NOTREACHED*/
			}
			`version' sae_proc_`subcmd1' `0'
		}
    }	
	else if ("`subcmd'"=="varselect") | ("`subcmd'"=="varsel") { //variable selection or modelling
		//sae_varsel_stats `0'
    }
	else if ("`subcmd'"=="varcompare") | ("`subcmd'"=="varcomp") { //variable comparisons
		//sae_varcomp_model `0'
    }
	else if ("`subcmd'"=="exp") { //experiential targeting 
		//sae_exp_jde `0'
    }
	else { //none of the above
		if ("`subcmd'"=="") {
			di as smcl as err "syntax error"
			di as smcl as err "{p 4 4 2}"
			di as smcl as err "{bf:sae} must be followed by a subcommand."
			di as smcl as err "You might type {bf:sae data}, or {bf:sae model}, or {bf:sae sim}, etc."			
			di as smcl as err "{p_end}"
			exit 198
		}
		capture which sae_cmd_`subcmd'
		if (_rc) { 
			if (_rc==1) exit 1
			di as smcl as err "unrecognized subcommand:  {bf:sae `subcmd'}"
			exit 199
			/*NOTREACHED*/
		}
		`version' sae_cmd_`subcmd' `0'
	}
	return add
end

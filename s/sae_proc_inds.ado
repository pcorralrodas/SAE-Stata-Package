*! sae_proc_inds.ado version 0.2.0  02jun2017
*! Copyright (C) World Bank 2016-17 - Minh Cong Nguyen & Paul Andres Corral Rodas
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org

cap program drop sae_proc_inds
program define sae_proc_inds
	version 11, missing	
	syntax, matasource(string) aggids(numlist sort) [dtasource(string)  INDicators(string) ///
	plinevar(string) PLINEs(numlist sort) area(string) weight(string)]
		
	if c(more)=="on" set more off
	local cmdline: copy local 0
	local plinevar: list uniq plinevar
	if "`plinevar'"!="" & "`plines'"!="" {
		dis as error "You must specify only one option: plinevar or plines"
		error 198
	}
	if ("`dtasource'"=="" & "`matasource'"=="") | ("`dtasource'"~="" & "`matasource'"~="") {
		dis as error "You must specify only one option for data input: dtasource() or matasource()"
		error 198
	}
	
	//Indicator checklis
	if "`indicators'"=="" local indicators fgt0
	local indicators = lower("`indicators'")
	local fgtlist
	local gelist
	*local ginilist
	*local atklist
	foreach ind of local indicators {
		if  "`ind'"=="fgt0" local fgtlist "`fgtlist' `ind'"
		if  "`ind'"=="fgt1" local fgtlist "`fgtlist' `ind'"
		if  "`ind'"=="fgt2" local fgtlist "`fgtlist' `ind'"
		
		if  "`ind'"=="ge0" local gelist "`gelist' `ind'"
		if  "`ind'"=="ge1" local gelist "`gelist' `ind'"
		if  "`ind'"=="ge2" local gelist "`gelist' `ind'"
		
		*if  "`ind'"=="gini" local ginilist "`ginilist' `ind'"
		*if  "`ind'"=="atk2" local atklist "`atklist' `ind'"
	}
	local plinesused : list plinevar | plines
	if `=wordcount("`area'")' > 1 {
		dis as error "You must specify only one variable for the area() option"
		error 198
	}
	if `=wordcount("`weight'")' > 1 {
		dis as error "You must specify only one variable for the weight() option"
		error 198
	}
	if "`area'"  =="" local area _ID
	if "`weight'"=="" local weight _WEIGHT	
	sae_closefiles	
	mata: _s2sc_inds("`matasource'", "`plinesused'", "`aggids'", "`area'", "`weight'")
	sae_closefiles
end


*! sae_proc_stats.ado version 0.2.0  02jun2017
*! Copyright (C) World Bank 2016-17 - Minh Cong Nguyen & Paul Andres Corral Rodas
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org

cap program drop sae_proc_stats
program define sae_proc_stats
	version 11, missing
	
	syntax, matasource(string) aggids(numlist sort) [INDicators(string)  ///
	contvar(string) catvar(string) plinevar(string) PLINEs(numlist sort) ///
	area(string) weight(string) Row Col std]
	
	if c(more)=="on" set more off
	local cmdline: copy local 0
	local plinevar: list uniq plinevar
	if "`plinevar'"!="" & "`plines'"!="" {
		dis as error "You must specify only one option: plinevar or plines"
		error 198
	}	
	local plinesused : list plinevar | plines
	if `=wordcount("`area'")' > 1 {
		dis as error "You must specify only one variable for the area() option for now"
		error 198
	}
	if `=wordcount("`weight'")' > 1 {
		dis as error "You must specify only one variable for the weight() option for now"
		error 198
	}
	if "`area'"  =="" local area _ID
	if "`weight'"=="" local weight _WEIGHT	
	sae_closefiles
	mata: _s2sc_stats("`matasource'", "`plinesused'", "`aggids'", "`area'", "`weight'")
	sae_closefiles	
	if "`plinevar'"!="" {
		tokenize `plinevar'
		forv i=1(1)`=wordcount("`plinevar'")' {
			la def povline `i' "``i''", add
		}
		la val Povline povline
	}
end


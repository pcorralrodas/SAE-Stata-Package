*! sae_data_import.ado version 0.2.3  31May2017
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org

cap program drop sae_data_import
program define sae_data_import	
	syntax, [if] [in] varlist(string) area(string) UNIQid(string) datain(string) dataout(string) 
	local sortvar `area' `uniqid'
	local varlist `varlist' `sortvar'
	local varlist : list uniq varlist
	local varlist : list sort varlist
	//housekeeping		
	local n_sort = wordcount("`sortvar'")
	if `n_sort'~=2 {
		dis as error "Warning: Identifier not unique, please provide unique identifier"
		dis as error "Please provide only 2 variables for the sorting: area and uniqid."
		error 198
		exit
	}
	local n_comp = wordcount("`varlist'")
	sae_closefiles	
	mata: fh = fopen("`dataout'", "rw")
	//remove name of mata due to mata format file structure
	mata: fputmatrix(fh, (tokens(st_local("varlist")))) 
	cap use `sortvar' using "`datain'", clear
	if _rc==0 { //ID check	
		cap isid `sortvar'
		if (_rc!=0) {
			dis as error "Warning: Identifiers (`sortvar') not unique, please provide unique identifier"
			error 198
			exit
		}
		else {
			foreach var of local sortvar {
				capture confirm numeric variable `var'
				if _rc~=0 {
					display "Warning: Your variable (`var') in the target data set is not numeric, please provide numeric IDs."
					error 198
					exit
				} 
			}
		}
			
		mata: st_view(all=., ., "`sortvar'",.)
		//mata: indexsort = sort((runningsum(J(rows(all),1,1)),all,runningsum(J(rows(all),1,1))),`bsort')[.,1] 
		mata: indexsort = order(all, (1,2)) 
		mata: all=.
	}
	else {
		dis as error "Variables `sortvar' is not in the datain `datain', please check."
		exit 190
	}
	
	_dots 0, title("Saving data variables into mata matrix file") reps(`n_comp')
	local count = 0	
	foreach var in `varlist' {
		cap use `var' using "`datain'", clear
		if _rc==0 {
			mata: st_view(all=., ., "`var'",.)
			mata: fputmatrix(fh, all[indexsort]) 
			mata: all=.
			local count = `count' + 1
			_dots `count' 0			
		}
		else {
			dis as error "Variable `var' is not in the data `datain', please check."
			exit 190
		}
	}
	mata: indexsort=.
	mata: fclose(fh)
end

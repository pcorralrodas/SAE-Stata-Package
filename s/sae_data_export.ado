*! sae_data_export version 0.2, April 9, 2017
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org

cap program drop sae_data_export
program define sae_data_export
	syntax,  matasource(string)   [numfiles(integer 1) prefix(string) datasave(string) saveold]
	clear 
	if ("`saveold'"=="") local saveold save 
	if ("`datasave'"=="") display in yellow "Your output will not be saved, please use the datasave() option"
	sae_closefiles
	mata: yd= fopen("`matasource'", "r")
	mata: _1= fgetmatrix(yd) //info for plugin
	mata: _2= fgetmatrix(yd) //Varlist
	mata: c =cols(_2)
	mata: st_local("nvv", strofreal(c))	
	if (`numfiles'>`nvv'){
		display as error "You have requested more files than variables in the ydump data"
		exit
	}
 
	qui if (`numfiles'==1) {
		mata: for(i=1;i<=c;i++) st_addvar("double",_2[.,i])
		cap recast float _YHAT*
		if ("`prefix'"!="") rename _YHAT* `prefix'*
		mata: _3=fgetmatrix(yd)
		mata: st_addobs(rows(_3))
		mata: for(i=2;i<=c;i++)  _3=_3, fgetmatrix(yd)
		mata: st_store(.,.,_3)
		mata: fclose(yd)
		if ("`datasave'"!="") `saveold' "`datasave'", replace
	}
	qui else {
		mata: c=floor(cols(_2)/`numfiles')
		mata: l=J(1,`numfiles',floor(cols(_2)/`numfiles'))
		mata: l=runningsum(l)
		mata: l[cols(l)]=l[cols(l)]+mod(cols(_2),`numfiles')

		local start = 0
		forval k=1/`numfiles' {
			clear
			cap mata: mata drop _3
			mata: for(i=(`start'+1);i<=l[`k'];i++) st_addvar("double",_2[.,i])	
			cap recast float _YHAT*
			if ("`prefix'"!="") rename _YHAT* `prefix'*			
			mata: _3=fgetmatrix(yd)
			mata: st_addobs(rows(_3))
			mata: for(i=(`start'+2);i<=l[`k'];i++)  _3=_3, fgetmatrix(yd)
			mata: st_store(.,.,_3)
			mata: st_local("start",strofreal(l[`k']))
			if ("`datasave'"!="") `saveold' "`datasave'_`k'", replace
		}
		mata: fclose(yd)
	}
end

set more off
clear all

global dpath "C:\Users\\`c(username)'\OneDrive\WPS_2020\7.twofold\"



run "C:\Users\WB378870\GitHub\SAE-Stata-Package\s\sae_mc_bs.ado"
run "C:\Users\WB378870\GitHub\SAE-Stata-Package\l\lsae_povmap.mata"
run "C:\Users\WB378870\GitHub\SAE-Stata-Package\p\povmap.ado"


//https://onlinelibrary.wiley.com/doi/am-pdf/10.1111/insr.12380

/*
Do file below is a test for a two fold nested error model. It follows the method 
illustrated in the paper from Molina and others in the link below.

We start off by creating a fake data set as illustrated in that same paper.
 https://rss.onlinelibrary.wiley.com/doi/pdf/10.1111/rssa.12306
*/

*===============================================================================
// Parameters for simulated data set
*===============================================================================
	set seed 734137
	global numobs = 20000
	global outsample = 50
	global areasize  = 500
	global psusize   = 50
	
	//We have 2 location effects below
	global sigmaeta   = 0.15   
	global sigmapsu  = 0.07
	//We have household specific errors
	global sigmaeps   = 0.25
	global model x1 x2
	
	local obsnum    = $numobs
	local areasize  = $areasize
	local psusize   = $psusize
	
*===============================================================================
//Create fake dataset
*===============================================================================

	set obs `obsnum'
	
	gen dom = (mod(_n,`areasize')==1)*_n 
	gen psu  = (mod(_n,`psusize')==1)*_n
	
	gen u1 = rnormal(0,$sigmaeta) if dom!=0
	gen u2 = rnormal(0, $sigmapsu)  if psu!=0
	
	replace dom = dom[_n-1] if dom==0
	replace psu = psu[_n-1] if psu==0
	
	replace u1 = u1[_n-1] if u1==.
	replace u2 = u2[_n-1] if u2==.
	gen e      = rnormal(0,$sigmaeps)
	
	foreach i in dom psu{
		egen g2 = group(`i')
		replace `i' = g2
		drop g2
	}
	
	gen tdom=real(substr(string(psu),-1,1))
	replace tdom = 10 if tdom==0
	drop psu
	
	gen x1 = runiform()<(0.2+0.4*dom/40+0.4*tdom/10)
	gen x2 = runiform()<0.2
	
	gen Y = 3 + 0.03*x1 -0.04*x2 + u1 + u2 + e
	
	gen weights = runiform()
	
	gen E_Y = exp(Y) 
	
	sum E_Y,d
	local povline = r(p25)
	
	gen HID = 100*(100+dom) +tdom
	gen hhid = _n
	gen hhsize = 1
	
	gen double pvar = `povline'
	
	gen uno =1
	preserve
		sort hhid
		sample 20, by(HID)
		
		tempfile ladata
		save `ladata'
	restore
	drop if HID==`=HID[1]'
	
	tempfile censo
	save `censo'
	
	preserve
	sae data import, datain("`censo'") varlist(x1 x2 uno hhsize pvar weights) ///
			area(HID) uniqid(hhid) dataout("$dpath\censo") 
	restore	
	
	use `ladata', clear
	

	sae model h3 Y x1 x2, area(dom)
	
	mata: B=st_matrix("e(b)")
	sae model h3 Y x1 x2, area(HID)
	mata: B=B\st_matrix("e(b)")
	mata B
	
	/*//set trace on
	//Options for method: invsym luinv luinv_la cholinv cholinv_la
	sae model h3 Y x1 x2, area(HID) yhat(uno) method(invsym)
	
	
	
	ssss
	*/
	tempfile test
version 16

	sum Y, d
	
	//set trace on 
	//set traced 2

	sae sim h3 Y x1 x2, area(HID) yhat(uno) mcrep(50) bsrep(200) matin("$dpath\censo") ///
	ind(FGT0 gini) aggids(2 0) pwcensus(hhsize) uniqid(hhid) plines(`=exp(2.808841548218)') ///
	 lny s2s_spec method(luinv_la)
	
	
	sss

	
	sae data export, matasource(`test')
	
	
	
	ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
	
	
	rename avg_fgt0 avg_fgt0_pvar
	rename mse_avg_fgt0 mse_avg_fgt0_pvar
	
	sum mse* 
	save "$dpath\tes1t.dta", replace
	
	use `ladata', clear
	
	sae sim h3 Y x1 x2, area(HID) yhat(uno) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0) aggids(2 0) pwcensus(hhsize) uniqid(hhid) plines(`povline') lny	s2s_spec
	
	rename avg_fgt0 avg_fgt0_pvar
	rename mse_avg_fgt0 mse_avg_fgt0_pvar
	
	sum mse* 
	
	cf _all using "$dpath\tes1t.dta", verb
	
	
	use `ladata', clear
	
	sae sim h3 Y x1 x2, area(HID) yhat(uno) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0) aggids(2 0) pwcensus(hhsize) uniqid(hhid) plinevar(pvar) lny	s2s_spec
	

	
	sum mse* 
	
	cf _all using "$dpath\tes1t.dta", verb
	*/
	
	use `ladata', clear
	
	sae sim reml Y x1 x2, area(HID) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0 FGT1) aggids(2 0) pwcensus(hhsize) uniqid(hhid) plines(`povline') lny appendsvy
	
	
	sss
	

	use `ladata', clear
	
	sae sim reml2 Y x1 x2, area(2) subarea(HID) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0 FGT1) aggids(2 0) pwcensus(hhsize) uniqid(hhid) plinevar(pvar) lny
	

	
	
	sss
	restore
	
	sae sim reml2 Y x1 x2, area(2) subarea(HID) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0 FGT1) aggids(2 0) pwcensus(hhsize) uniqid(hhid) pline(`povline') lny
	
	cf _all using `erste'
	
	
	
	
	
	
	
	
	
	

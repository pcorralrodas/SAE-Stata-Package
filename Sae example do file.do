set more off
clear all

global dpath "C:\Users\\`c(username)'\OneDrive\WPS_2020\7.twofold\"




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
	
	gen E_Y = exp(Y) 
	
	sum E_Y,d
	local povline = r(p25)
	
	gen HID = 100*(100+dom) +tdom
	gen hhid = _n
	gen hhsize = 1
	
	gen pvar = `povline'
	
	tempfile censo
	save `censo'
	
	preserve
	sae data import, datain("`censo'") varlist(x1 x2 hhsize pvar) ///
			area(HID) uniqid(hhid) dataout("$dpath\censo") 
	restore
	
	sort hhid
	sample 20, by(HID)
	
	//Test H3 fit CensusEB
	sae sim h3 Y x1 x2, area(HID) mcrep(50) bsrep(0) matin("$dpath\censo") ///
	ind(FGT0 FGT1) aggids(2 0) pwcensus(hhsize) uniqid(hhid) plinevar(pvar) lny	
	
	
	
	
	ssss
	preserve
	
	
	sae sim reml2 Y x1 x2, area(2) subarea(HID) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0 FGT1) aggids(2 0) pwcensus(hhsize) uniqid(hhid) pline(`povline') lny
	
	tempfile erste
	save `erste'
	
	restore
	
	sae sim reml2 Y x1 x2, area(2) subarea(HID) mcrep(50) bsrep(10) matin("$dpath\censo") ///
	ind(FGT0 FGT1) aggids(2 0) pwcensus(hhsize) uniqid(hhid) pline(`povline') lny
	
	cf _all using `erste'
	
	
	
	
	
	
	
	
	
	

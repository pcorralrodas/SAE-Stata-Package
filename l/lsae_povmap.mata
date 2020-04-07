//s2sc and povmap mata functions
*! lsae_povmap 0.5.2 18 April 2018
*! Copyright (C) World Bank 2016-17 - Minh Cong Nguyen & Paul Andres Corral Rodas
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org

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

version 11
mata:
mata clear
mata drop *()
mata set matalnum on
mata set mataoptimize on

string scalar lsae_povmapStataVersion() return("`c(stata_version)'")
string scalar      lsae_povmapVersion() return("00.06.00")

//0- Estimation functions
//Main function
void _s2cs_base0(string scalar yvar, 
				 string scalar xvar, 
				 string scalar zvar, 
				 string scalar yhat, 
				 string scalar yhat2, 
				 string scalar sae1, 
				 string scalar wgt, 
				 string scalar idvar,
				 string scalar touse) 
{
	//real   scalar locationeff,
	y     		= st_data(.,tokens(yvar),  touse)  	
	x     		= st_data(.,tokens(xvar),  touse) 
 	z1    		= st_data(.,tokens(zvar),  touse)  
	yh    		= st_data(.,tokens(yhat),  touse)  
	yh2   		= st_data(.,tokens(yhat2), touse)  
	wt 	  		= st_data(.,tokens(wgt),   touse)
	area  		= st_data(.,tokens(sae1),  touse)	
	id    		= st_data(.,idvar,touse)	
	sim   		= strtoreal(st_local("rep"))
	seed  		= strtoreal(st_local("seed"))
	vce   		= strtoreal(st_local("vceopt"))
	EB    		= strtoreal(st_local("ebest"))
	hheff 		= strtoreal(st_local("hheffs"))
	h3    		= strtoreal(st_local("h3"))
	betaout     = st_local("matbeta")
	if      	(st_local("nolocation")~="") h3 = 2
	boots     	= strtoreal(st_local("boots"))
	etanorm 	= strtoreal(st_local("etanormal"))
	epsnorm 	= strtoreal(st_local("epsnormal"))
	if (boots==1 & (strtoreal(st_local("psu1"))==1)) psu = st_data(.,st_local("psu"),touse)
	external bsim, asim, maxA, varr, sigma, v_sigma, allest, sigma_eps, hherr, locerr, locerr2, bs, loc, loc2, hhbs
	
	//sort data
	if (boots==1 & (strtoreal(st_local("psu1"))==1)) {
		data = area, id, y, x, z1, yh, yh2, wt, psu
		_sort(data, (1,cols(data),2))
		y    = &(data[.,3])
		x    = &(data[.,4..4+cols(x)-1], J(rows(x),1,1))
		z1   = &(data[.,3+cols(*x)..3+cols(*x)+cols(z1)-1])
		yh	 = &(data[.,3+cols(*x)+cols(*z1)..3+cols(*x)+cols(*z1)+cols(yh)-1])
		yh2	 = &(data[.,3+cols(*x)+cols(*z1)+cols(*yh)..3+cols(*x)+cols(*z1)+cols(*yh)+cols(yh2)-1])
		wt   = &(data[.,cols(data)-1])
		area = &(data[.,1])
		psu  = &(data[.,cols(data)])
		info = panelsetup(*area,1)
		info2= panelsetup(*psu,1)
		if (rows(info)>rows(info2)) _error("Your specified PSU variable is at a higher level than your cluster variable")
	}
	else {
		data = area, id, y, x, z1, yh, yh2, wt
		_sort(data, (1,2))		 
		y    = &(data[.,3])
		x    = &(data[.,4..4+cols(x)-1], J(rows(x),1,1))
		z1   = &(data[.,3+cols(*x)..3+cols(*x)+cols(z1)-1])
		yh	 = &(data[.,3+cols(*x)+cols(*z1)..3+cols(*x)+cols(*z1)+cols(yh)-1])
		yh2	 = &(data[.,3+cols(*x)+cols(*z1)+cols(*yh)..3+cols(*x)+cols(*z1)+cols(*yh)+cols(yh2)-1])
		wt   = &(data[.,cols(data)])
		area = &(data[.,1])
		psu  = &(data[.,1])
		info = panelsetup(*area,1)	
		info2 = info
	}
	
	//return results
	//return a matrix of pointers - 
	//row1: bOLS, vbOLS, rmse, r2 fstat, adjr2, Nobs, degree of freedom
	//row2: aOLS, vaOLS, rmse, r2 fstat, adjr2, Nobs, degree of freedom
	//row3: sigma_eta2, sigma_eps2, ratio eta/overall, var of sigmaeta2, maxA, varr
	//row4: bGLS, vbGLS
	allest  = _f_s2sc_estall_eb(*y, *x, *z1, *yh, *yh2, *wt, *area, info, sim, seed, h3, vce, EB, 0, touse)
	//  _f_s2sc_estall_eb(y, x, z, wt, area, info, sim, seed,henderson,hhe)
	if (st_local("nooutput")=="") {
		st_matrix("_bols",       (*allest[1,1])')
		st_matrix("_vols",       (*allest[1,2]))
		st_matrix("_rmse_beta",  (*allest[1,4]))
		st_matrix("_r2_beta",    (*allest[1,5]))
		st_matrix("_F_beta",     (*allest[1,6]))
		st_matrix("_r2a_beta",   (*allest[1,7]))
		st_matrix("_N_beta",     (*allest[1,8]))
		st_matrix("_dfm_beta",   (*allest[1,9]))
		
		if (hheff==1) {
			//Alfa --- Need to include no location option!
			st_matrix("_bzols",       (*allest[2,1])')
			st_matrix("_vzols",       (*allest[2,2]))
			st_matrix("_rmse_alpha",  (*allest[2,4]))
			st_matrix("_r2_alpha",    (*allest[2,5]))
			st_matrix("_F_alpha",     (*allest[2,6]))
			st_matrix("_r2a_alpha",   (*allest[2,7]))
			st_matrix("_N_alpha",     (*allest[2,8]))
			st_matrix("_dfm_alpha",   (*allest[2,9]))
		}	
		
		//Variance
		if (h3==1) { //Henderson
			st_matrix("_v_eta",   (*allest[3,1]))
			st_matrix("_v_eps",   (*allest[3,2]))
			st_matrix("_v_ratio", (*allest[3,3]))
		}
		if (h3==0) { //ELL
			st_matrix("_v_eta",   (*allest[3,1]))
			st_matrix("_v_eps",   (*allest[3,2]))
			st_matrix("_v_ratio", (*allest[3,3]))
			st_matrix("_fvar_sigeta2",	(*allest[3,4]))	
			//st_matrix("_svar_sigeta2",	(*allest[3,5]))		
		}
		if (h3==2) { //No location
			st_matrix("_v_eps",   (*allest[1,4]:^2))
		}
		
		//GLS Results
		st_matrix("_bgls",        (*allest[4,1])')
		st_matrix("_vgls",        (*allest[4,2]))
	}
	//st_matrix("Zn", *allest[4,3])

	//Coefficients for 2nd stage
	if (sim>0) {
		if (boots==0) { //get betas parametric
			if (h3==1) _error("Parametric drawing with H3 option is not allowed")
			if (EB==1) _error("Parametric drawing with EB option is not allowed")
			rseed(seed)
			hherr = locerr = asim = v_sigma = maxA = varr = sigma_eps = sigma = J(1,1,.) //empty matrix storing purpose - which can be overwritten later
			bsim = _f_drawnorm(sim, *allest[4,1]', *allest[4,2], seed)
			//for sigma eta
			if (epsnorm==0)	hherr   = *allest[4,4]
			//epsnorm 1 requires the census!!	
			sigma   = *allest[3,1] //sigma_eta2
			if (*allest[3,4]==.) v_sigma = *allest[3,5]     //simulated variance of sigma_eta2
			else                 v_sigma = *allest[3,4]     //parametric variance of sigma_eta2
			if (etanorm==1) locerr = _f_gammadraw(sigma, v_sigma, sim)
			else            locerr = (*allest[4,3])[.,2]
				
			//for sigma epsilon
			if (hheff==1) { //with household effect
				asim    = _f_drawnorm(sim, *allest[2,1]', *allest[2,2], seed)
				maxA    = J(sim, 1, *allest[3,6])
				varr    = J(sim, 1, *allest[3,7])
			}
			if (hheff==0) { //without household effect
				if (h3==1) sigma_eps = J(sim, 1, (*allest[1,4]-*allest[3,1]))
				if (h3==0) sigma_eps = J(sim, 1, (*allest[3,2]))
				if (h3==2) sigma_eps = J(sim, 1, (*allest[1,4]))
			}
		}  //End of parametric option	
		else { //Get via bootstrap:
			loc = loc2 = hhbs = J(1,sim,NULL)
			cmd1=st_local("cmd1")
			cmd2=st_local("cmd2")
			cmd3=st_local("cmd3")
			bs = _f_bootstrap_estbs(yvar,xvar,zvar,yhat,yhat2,sae1,wgt,sim, seed, h3, vce, EB, *psu, touse, cmd1, cmd2, cmd3)
			//bs = _f_bootstrap_estall(*y, *x, *z1, *yh, *yh2, *wt, *area, info, info2, sim, seed, h3, vce, EB, *psu, touse)
			if ((EB==1) & ((etanorm==0)|(epsnorm==0))) {
				display("I've changed your selection from semi-parametric to normal. When EB is chosen, only normal eta and epsilon drawings are allowed")
				etanorm=1
				epsnorm=1
			}
			varr = maxA =sigma_eps= J(sim,1,.)
			//Ask again why bs[1] here
			bsim = J(sim,cols((*(*bs[1])[4,1])'),.)
			if (hheff==1) asim = J(sim,cols((*(*bs[1])[2,1])'),.)
			//fill up with randomly drawn sigma etas
			if (EB==1) {
				locerr    = (*(*bs[1])[4,3])[.,1]
				locerr2   = .	
			}
			else { //(EB==0)
				if (etanorm==1) locerr = J(sim,1,.)
				else            locerr = J(rows(info),sim,.) //(etanorm==0)
			}
			//if (etanorm==0)             locerr = J(rows(info),sim,.)
			if (epsnorm==0) hherr = J(rows((*(*bs[1])[4,4])),sim,.)
			for(i=1;i<=sim;i++) {
				bsim[i,.] = (*(*bs[i])[4,1])'
				if (EB==1) { 
					loc[i]  = &(*(*bs[i])[4,3])[|.,1 \ .,3|]
					loc2[i] = &(.,0, (*(*bs[i])[3,1]))
				}
				else { //EB==0
					if (etanorm==1) loc[i] = &(*(*bs[i])[3,1])
					else            loc[i] = &(*(*bs[i])[4,3])[.,2]  //etanorm==0
				}
					
				if (hheff==1) {
					asim[i,.] = (*(*bs[i])[2,1])'	
					if (epsnorm==1) {
						maxA[i,1]  = *(*bs[i])[3,6]
						varr[i,1]  = *(*bs[i])[3,7]
					}
				}
				else {
					if (epsnorm==1) {
						if (h3==0) sigma_eps[i,1] = *(*bs[i])[3,2]
						if (h3==1) sigma_eps[i,1] = *(*bs[i])[1,4] - *(*bs[i])[3,1]
						if (h3==2) sigma_eps[i,1] = *(*bs[i])[1,4]
					}
				}
				if (epsnorm==0) hhbs[i] = &(*(*bs[i])[4,4])
			} //sim
		} ////Get via bootstrap:
	} //sim>0	
	//st_matrix("Zn", (*(*bs[1])[4,4]))
	//st_matrix("Zn", mean(*asim))
	
	
	//write the bsim to file - with this order (7 items): asim, sigma, v_sigma, maxA, varr, bsim, sigma_eps
	if ((st_local("stage")=="first") & (st_local("matbeta")!="")) {
		fh = fopen(betaout, "rw")
		fputmatrix(fh, asim)
		fputmatrix(fh, sigma)
		fputmatrix(fh, v_sigma)
		fputmatrix(fh, maxA)
		fputmatrix(fh, varr)
		fputmatrix(fh, bsim)
		fputmatrix(fh, sigma_eps)
		fclose(fh)
	}
}


// We call upon the Henderson or ELL function for 1st stage
function _f_s2sc_estall_eb( real matrix y, 
							real matrix x, 
							real matrix z,
							real matrix yh,
							real matrix yh2,
							real matrix wt, 
							real matrix area, 
							real matrix info,
							real scalar sim, 
							real scalar seed,
							real scalar henderson,
							real scalar vceopt,
							real scalar EB,
							real scalar bs,
							string scalar touse) {
	pointer(real matrix) rowvector estout
	estout = J(10,25,NULL)
	rinfo  = rows(info)
	//OLS
	b_ols = _f_wols(y, x, wt, info, vceopt, bs)
	yhs   = quadcross(x',*b_ols[1,1])	
	
	//RESULTS FROM OLS that are passed on to Stata and other functions
	estout[1,1] = &(*b_ols[1,1])           //Beta model Betas
	estout[1,2] = &(*b_ols[1,2])	       //Beta model VCOV
	estout[1,4] = &(sqrt(*b_ols[1,4]))	   //RMSE
	estout[1,5] = &(*b_ols[1,5])		   //R2
	estout[1,6] = &(*b_ols[1,6])		   //F-Stat
	estout[1,7] = &(*b_ols[1,7])		   //Adj. R2
	estout[1,8] = &(*b_ols[1,8])		   //Num Obs
	estout[1,9] = &(*b_ols[1,9])		   //Degrees of freedom (K-1)
			
	//order matters for z - check alpha variables
	if ((allof(z,.)==1) & (allof(yh,.)==1) & (allof(yh2,.)==1)) {                               //0,0,0
		hheffect = 0
	}
	else {
		yhs2 = yhs:^2
		if ((allof(z,.)==1) & (allof(yh,.)==1) & (allof(yh2,.)==0)) zn = yhs2:*yh2              //0,0,1
		if ((allof(z,.)==1) & (allof(yh,.)==0) & (allof(yh2,.)==1)) zn = yhs :*yh               //0,1,0
		if ((allof(z,.)==1) & (allof(yh,.)==0) & (allof(yh2,.)==0)) zn = yhs :*yh, yhs2:*yh2    //0,1,1
		if ((allof(z,.)==0) & (allof(yh,.)==1) & (allof(yh2,.)==1)) zn = z                      //1,0,0
		if ((allof(z,.)==0) & (allof(yh,.)==1) & (allof(yh2,.)==0)) zn = z, yhs2:*yh2           //1,0,1
		if ((allof(z,.)==0) & (allof(yh,.)==0) & (allof(yh2,.)==1)) zn = z, yhs :*yh            //1,1,0	
		if ((allof(z,.)==0) & (allof(yh,.)==0) & (allof(yh2,.)==0)) zn = z, yhs :*yh, yhs2:*yh2 //1,1,1
		zn = zn, J(rows(zn),1,1)
		hheffect = 1
	}
	
	//Henderson III or ELL or no location effect
	if (henderson==1) { //Henderson III
		H3 = _f_henderson_p1(y, x, wt, area, *b_ols[1,3], info, 1)
		//SIGMAS from HENDERSON
		estout[3,1] = &(*H3[1,2])               //SIGMA ETA
		estout[3,2] = &(*H3[1,1])               //SIGMA EPSilon 
		estout[3,3] = &(*H3[1,2]/(*b_ols[1,4])) //Ratio of Variance over MSE
		estout[3,4] = &(*H3[1,3])               //Ehats
		
		//USE HENDERSON RESULTS FOR ALPHA MODEL
		if (hheffect==1) {
			ech         = *H3[1,3]
			maxA        = 1.05*max(ech:^2)
			lhslog      = ln((ech:^2):/(maxA:-(ech:^2)))
			alpha_ols   = _f_wols(lhslog, zn, wt, info, vceopt, bs)
			
			//RESULTS FROM ALFA
			estout[2,1] = &(*alpha_ols[1,1])		   //Beta
			estout[2,2] = &(*alpha_ols[1,2])           //VCOV
			estout[2,4] = &(sqrt(*alpha_ols[1,4]))	   //RMSE
			estout[2,5] = &(*alpha_ols[1,5])		   //R2
			estout[2,6] = &(*alpha_ols[1,6])		   //F-Stat
			estout[2,7] = &(*alpha_ols[1,7])		   //Adj. R2
			estout[2,8] = &(*alpha_ols[1,8])		   //Num Oalphas
			estout[2,9] = &(*alpha_ols[1,9])		   //Degrees of freedom (K-1)

			bigb      = exp(quadcross(zn',*alpha_ols[1,1]))
			var_r     = *alpha_ols[1,4]
			sige2     = (maxA*(bigb:/(1:+bigb))) + (0.5*var_r)*((maxA*(bigb:*(1:-bigb))):/((1:+bigb):^3))  
			sige2     = *H3[1,1]*(sige2/mean(sige2))
			estout[3,25] = &(sige2)
			estout[3,6] = &(maxA)
			estout[3,7] = &(var_r)
		}	
		else { //hheffect==0
			sige2 = J(*b_ols[1,8], 1, (*b_ols[1,4]-*H3[1,2]))
			estout[3,25] = &(sige2)
		}
			
		//GLS ROY	
		b_gls0 = _f_hh_gls2(y, x, wt, sige2, *H3[1,2], info, 1,bs)	
		//RESULTS FROM GLS H&H
		estout[4,1] = &(*b_gls0[1,1])
		estout[4,2] = &(*b_gls0[1,2])
		
		if (EB==1) {
			ebout = _f_ebmatch(*H3[1,2], wt, sige2, info, area, *b_gls0[1,3])
			estout[4,3] = &(*ebout[1,1])      //ETA
			estout[4,4] = &(*ebout[1,2])      //EPS
		}
		else {
			noebout = _f_hhech(*b_gls0[1,3], wt, info, area)
			estout[4,3] = &(*noebout[1,1])   //ETA
			estout[4,4] = &(*noebout[1,2])   //EPS
		}	
	} //end of Henderson III

	if (henderson==0) { //FOR ELL	
		//obtain sigma_eta2 and sampling variance of sigma_eta2
		sigeta      = _ell_sigeta(*b_ols[1,3], wt, info, 0)
		estout[3,1] = &(*sigeta[1,1])   //Var of ETA
		//Variance of epsilon
		estout[3,2] = &(*b_ols[1,4] - *sigeta[1,1])  //varepsilon
		estout[3,3] = &(*sigeta[1,1]/(*b_ols[1,4]))  //ratiov
		estout[3,4] = &(*sigeta[1,2])                //parametric variance of sigma_eta2
			
		if (hheffect==1) {
			//sige2
			ech = J(rows(*b_ols[1,3]),1,.)
			for (i=1; i<=rinfo; i++) {
				res1 = panelsubmatrix(*b_ols[1,3],i,info)
				m0   = info[i,1],1 \ info[i,2],1
				ech[|m0|] = res1 :- mean(res1)
				
				//if (i==1) area[i,.] ,mean(res1)
				//Future
				//wt1  = panelsubmatrix(wt,i,info)
				//ech[info[i,1]..info[i,2],1] = res1 :- mean(res1, wt1)
				//if (i==1) area[i,.] ,mean(res1,wt1), quadsum(wt1)
				//else dump=dump \ (area[i,.] ,mean(res1,wt1), quadsum(wt1))
			}	
	
			//Standardize Residuals
			ech = ech*(sqrt(*estout[3,2])/sqrt(quadvariance(ech)))
		
			//Alpha OLS
			maxA      = 1.05*max(ech:^2)
			lhslog    = ln((ech:^2):/(maxA:-(ech:^2)))
			alpha_ols = _f_wols(lhslog, zn, wt, info,vceopt, bs)

			//RESULTS FROM ALFA
			estout[2,1] = &(*alpha_ols[1,1])		   //Beta
			estout[2,2] = &(*alpha_ols[1,2])           //VCOV
			estout[2,4] = &(sqrt(*alpha_ols[1,4]))	   //RMSE
			estout[2,5] = &(*alpha_ols[1,5])		   //R2
			estout[2,6] = &(*alpha_ols[1,6])		   //F-Stat
			estout[2,7] = &(*alpha_ols[1,7])		   //Adj. R2
			estout[2,8] = &(*alpha_ols[1,8])		   //Num Oalphas
			estout[2,9] = &(*alpha_ols[1,9])		   //Degrees of freedom (K-1)
							
			bigb      = exp(quadcross(zn',*alpha_ols[1,1]))
			var_r     = *alpha_ols[1,4]
			sige2     = (maxA*(bigb:/(1:+bigb))) + (0.5*var_r)*((maxA*(bigb:*(1:-bigb))):/((1:+bigb):^3))  
			estout[3,25] = &(sige2)
			estout[3,6] =&(maxA)
			estout[3,7] =&(var_r)
		}
		else { //hheffect==0
			sige2 = J(*b_ols[1,8], 1, *estout[3,2])
			estout[3,25] = &(sige2)
		}
				
		//GLS
		//b_gls0 = _f_ell_gls(y, x, wt,info, sige2, *sigeta[1,1])
		b_gls0 = _f_hh_gls2(y, x, wt, sige2, *sigeta[1,1], info, EB, bs)	
		//RESULTS FROM GLS ELL
		estout[4,1] = &(*b_gls0[1,1])
		estout[4,2] = &(*b_gls0[1,2])
					
		if (EB==1) {
			ebout = _f_ebmatch(*sigeta[1,1], wt, sige2, info, area, *b_gls0[1,3])
			estout[4,3] = &(*ebout[1,1])      //ETA
			estout[4,4] = &(*ebout[1,2])      //EPS
		}
		else {
			noebout = _f_hhech(*b_gls0[1,3], wt, info, area)
			estout[4,3] = &(*noebout[1,1])   //ETA
			estout[4,4] = &(*noebout[1,2])   //EPS
		}
					
	} //end of ELL
	
	if (henderson==2) { //No location effect
		EB=0
		//Notice that there's no adjustment made
		if (hheffect==1) {
			ech = *b_ols[1,3]
			//Alpha OLS
			maxA      = 1.05*max(ech:^2)
			lhslog    = ln((ech:^2):/(maxA:-(ech:^2)))
			alpha_ols = _f_wols(lhslog, zn, wt, info, vceopt, bs)
			
			//RESULTS FROM ALFA
			estout[2,1] = &(*alpha_ols[1,1])		   //Beta
			estout[2,2] = &(*alpha_ols[1,2])           //VCOV
			estout[2,4] = &(sqrt(*alpha_ols[1,4]))	   //RMSE
			estout[2,5] = &(*alpha_ols[1,5])		   //R2
			estout[2,6] = &(*alpha_ols[1,6])		   //F-Stat
			estout[2,7] = &(*alpha_ols[1,7])		   //Adj. R2
			estout[2,8] = &(*alpha_ols[1,8])		   //Num Oalphas
			estout[2,9] = &(*alpha_ols[1,9])		   //Degrees of freedom (K-1)
			estout[2,10]= &maxA
		
			bigb      = exp(quadcross(zn',*alpha_ols[1,1]))
			var_r     = *alpha_ols[1,4]
			sige2     = (maxA*(bigb:/(1:+bigb))) + (0.5*var_r)*((maxA*(bigb:*(1:-bigb))):/((1:+bigb):^3))  
		}
		else {
			sige2=J(*b_ols[1,8], 1, *b_ols[1,4])
		}
		
		//GLS
		//b_gls0 = _f_ell_gls(y, x, wt,info, sige2, *sigeta[1,1])
		b_gls0 = _f_hh_gls2(y, x, wt, sige2, 0, info, EB,1)	
		//RESULTS FROM GLS ELL
		estout[4,1] = &(*b_gls0[1,1])
		estout[4,2] = &(*b_gls0[1,2])	
	} //henderson ==2
	
	if ((strtoreal(st_local("alfatest")))==1 & bs==0) {				
		st_store(.,st_varindex(tokens(st_local("alfaerr"))), touse, lhslog)
		st_store(.,st_varindex(tokens(st_local("exbeta"))), touse, yhs )
	}	
	return(estout)	
}

// Prepares vcov matrix for Henderson
function _f_henderson_p1(real matrix y, 
					     real matrix x, 
					     real matrix wt, 
						 real matrix area,
						 real matrix ehat,
						 real matrix info,
						 real scalar EB) 
					  
{
	pointer(real matrix) rowvector sigout2
	sigout2 = J(1,5,NULL)
	
	sxw  = quadcross(x,wt,x)
	sxw2 = quadcross(x,(wt:^2),x)
	rinfo = rows(info)
	
	//These are to be filled in the loop
	xdm  = J(rows(x), cols(x), 0)
	ydm  = J(rows(x), 1, 0)
	sumw = sumw2 = ebar = J(rinfo,1,0)
	xbar = J(rinfo,cols(x),0)
	sse  = sw2 = 0
	
	for (i=1; i<=rinfo; i++) {
		x1	      = panelsubmatrix(x,i,info)
		y1     	  = panelsubmatrix(y,i,info)
		wt1 	  = panelsubmatrix(wt,i,info)
		sw2	      = sw2 + quadsum((wt1:^2))/quadsum(wt1)
		m1        = info[i,1]
		m2        = info[i,2]
		m0        = m1,1 \ m2,1
		ydm[|m0|] = y1 :- mean(y1,wt1)
		xbar[i,.] = mean(x1,wt1)
		m0        = m1,. \ m2,.
		xdm[|m0|] = x1 :- xbar[i,.]
		sumw[i]   = quadsum(wt1)	
		if (EB == 1) {
			sumw2[i] = quadsum((wt1:^2))
			ebar[i]  = mean(panelsubmatrix(ehat,i,info),wt1)
		}
	}
	
	//remove 0 vector columns for inversion
	xdm    = select(xdm,(colsum((xdm:==0)):~=rows(xdm)))
	sxdmw  = quadcross(xdm,wt,xdm)
	_invsym(sxdmw)
		
	sxdmw2 = quadcross(xdm,(wt:^2),xdm)
	yxdmw  = quadcolsum((wt:*ydm):*xdm)
	_invsym(sxw)
	
	sse    = quadcross(wt,(ydm:^2)) - quadcross(quadcross(yxdmw', sxdmw)',yxdmw')
	t2     = trace(quadcross(sxdmw',sxdmw2))
	t3     = trace(quadcross(sxw,sxw2))
	t4     = trace(sxw*quadcross(xbar,(sumw:^2),xbar))
	
	sigma2ech = sse/(quadsum(wt)-sw2-t2)
	sigma2eta = (quadcross(wt,(y:^2)) -
	     		 quadcross(quadcross(quadcross(x,wt,y),sxw)',quadcross(x,wt,y)) - 
		    	(quadsum(wt)-t3)*sigma2ech)/(quadsum(wt)-t4)	
	
	gamma_a = sigma2eta:/(sigma2eta:+(sigma2ech:*(sumw2:/(sumw:^2))))
	//utilde	
	utilde = - (mean(gamma_a:*ebar)):+(gamma_a:*ebar)
	//eps tilde
	epstilde = J(rows(ehat),1,0)
	for (i=1; i<=rinfo; i++) {
		m1 = info[i,1]
		m2 = info[i,2]
		m0 = m1,1 \ m2,1
		epstilde[|m0|] = J(m2-m1+1, 1 , utilde[i])
		//epstilde[|info[i,1],1\info[i,2],1|] = J(rows(epstilde[|info[i,1],1\info[i,2],1|]),1,utilde[i])
	}
	epstilde = -mean(ehat - epstilde ):+(ehat - epstilde)
	//epshat
	epshat   = epstilde:*(sqrt(sigma2ech)/sqrt(quadvariance(epstilde)))
	uhat     = utilde:*(sqrt(sigma2eta)/sqrt(quadvariance(utilde)))
	sigout2[1,3] = &(epshat)
	sigout2[1,4] = &(uhat)
	
	sigout2[1,1] = &(sigma2ech)
	sigout2[1,2] = &(sigma2eta)	
	
	return(sigout2)
	//epshat for alfa model (replaces residuals from OLS and is then used in alfa model)
}

//BOOTSTRAP, adjusted from Minh's
function _f_bootstrap_estall(real matrix y, 
							real matrix x, 
							real matrix z, 
							real matrix yh, 
							real matrix yh2, 
							real matrix wt, 
							real matrix area, 
							real matrix info,
							real matrix info2,
							real scalar sim, 
							real scalar seed, 
							real scalar henderson, 
							real scalar vceopt,
							real scalar EB,
							real matrix psu,
							string scalar touse) {
	pointer(pointer(real matrix) rowvector) colvector bsout
	bsout = J(sim,1,NULL)
	data0 = area, y, x, z, yh, yh2, wt
	rowdata = rows(data0)
	coldata = cols(data0)
	data  = J(rowdata, coldata,.)
	colsx = cols(x)
	colsy = cols(y)
	colsz = cols(z)
	colsyh = cols(yh)
	colsyh2 = cols(yh2)
	rinfo = rows(info2)
	//uniformseed(seed)
	for(s=1;s<=sim;s++) {
		for (i=1; i<=rinfo; i++) {
			dout = panelsubmatrix(data0,i,info2)
			nrow = rows(dout)
			m0   = info2[i,1],1 \ info2[i,2],coldata
			data[|m0|] = dout[ceil(nrow*uniform(nrow,1)), .]
		}
		//_sort(data, 1)
		area1 = &(data[.,1])
		y1    = &(data[.,2])
		x1    = &(data[|.,3 \ .,3+colsx-1|])
		z1    = &(data[|.,3+colsx \ .,3+colsx+colsz-1|]) 
		yhx   = &(data[|.,3+colsx+colsz \.,3+colsx+colsz+colsyh-1|]) 
		yhx2  = &(data[|.,3+colsx+colsz+colsyh \ .,3+colsx+colsz+colsyh+colsyh2-1|]) 
		wt1   = &(data[.,coldata])
		est   = _f_s2sc_estall_eb(*y1, *x1, *z1, *yhx, *yhx2, *wt1, *area1, info, sim, seed, henderson, vceopt, EB,1, touse)	
		//if (*est[3,1]<0) *est[3,1] = 0
		c = 1		
		if (*est[3,1]<0) {
			if (c<=100) {
				s = s - 1		
				c = c + 1
			}
			else _error("Please try a different PSU or select a different seed number.")
		}
		else bsout[s] = f_pointer_clone(est)
	}
	return(bsout)
}

//Column processing function
void _s2sc_sim_cols(string scalar xvar, string scalar zvars, string scalar yhats, string scalar yhats2, string scalar areavar, string scalar plvar, string scalar wgt, string scalar touse, string scalar hhid, string scalar matin) 
{
	count       = strtoreal(st_local("colprocess"))
	sim         = strtoreal(st_local("rep"))
	seed        = strtoreal(st_local("seed"))	
	h3    		= strtoreal(st_local("h3"))
	if          (st_local("nolocation")~="") h3 = 2
	hheff       = strtoreal(st_local("hheffs"))
	boots     	= strtoreal(st_local("boots"))
	etanorm 	= strtoreal(st_local("etanormal"))
	epsnorm 	= strtoreal(st_local("epsnormal"))
	EB    		= strtoreal(st_local("ebest"))
	pline       = strtoreal(st_local("pline"))
	lg			= strtoreal(st_local("lny"))
	varinmod	= tokens(st_local("varinmodel"))	
	//pointer(real matrix) rowvector agginfo
	agglist     = tokens(st_local("aggids"))
	indlist     = tokens(st_local("indicators"))	
	//pointer(real matrix) colvector arealvl
	//agginfo     = J(rows(agglist), 1, NULL)
	mem         = strtoreal(st_local("maxmem"))
	mem         = floor((mem/8/sim))
		
	external bsim, asim, maxA, varr, sigma, v_sigma, sigma_eps, locerr, hherr, locerr2, loc, loc2
	colsbsim = cols(bsim)
	colsasim = cols(asim)	
	if ((EB==1) & ((etanorm==0)|(epsnorm==0))){
		etanorm=1
		epsnorm=1
	}
	
	//WARNING: area must be sorted outside in Stata
	//census data - or use other way, ie seek(fh, (N*8+77)*6 ,-1) to get the 7th column
	fhcensus = fopen(matin, "r")
	varlist = fgetmatrix(fhcensus)	
	p0 = ftell(fhcensus)
	a  = fgetmatrix(fhcensus)
	p1 = ftell(fhcensus)
	N  = rows(a)	
	a  = J(1,1,.)
	
	//The data
	x       = tokens(xvar)
	z1      = tokens(zvars)
	yh      = tokens(yhats)
	yh2     = tokens(yhats2)
	area    = tokens(areavar)
	wt      = tokens(wgt)
	id      = tokens(hhid)
	pl      = tokens(plvar)
	colsx   = cols(x)
	colsz1  = cols(z1)
	colsyh  = cols(yh)
	colsyh2 = cols(yh2)
	
	if (st_local("cuts")!="")  cut = tokens(st_local("cuts"))
	coladd = (st_local("addvars")!="" ? cols(tokens(st_local("addvars"))) : 0) 
	//if (pline==.) st_view(pl,.,tokens(st_local("pline")), .)
	
	//Check if X and other variables (varinmodel local), Z and Yhats are in the code
	e3499 = _fvarscheck(varinmod, varlist)
	if (z1[1]  != "__mz1_000")  	e3499 = _fvarscheck(z1, varlist)
	if (yh[1]  != "__myh_000")  	e3499 = _fvarscheck(yh, varlist)
	if (yh2[1] != "__myh2_000") 	e3499 = _fvarscheck(yh2, varlist)
	if (st_local("addvars")!="")    e3499 = _fvarscheck(tokens(st_local("addvars")), varlist)
	if (e3499==1) {
		errprintf("Variables mentioned above are missing from the target dataset\n")
		_error(3499)
	}

	if (hheff==1) { //zalpha condition - __mz1_000, __myh_000, __myh2_000
		if ((z1[1]=="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "000"  //0,0,0
		if ((z1[1]=="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "001"  //0,0,1
		if ((z1[1]=="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "010"  //0,1,0
		if ((z1[1]=="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "011"  //0,1,1
		if ((z1[1]~="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "100"  //1,0,0
		if ((z1[1]~="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "101"  //1,0,1
		if ((z1[1]~="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "110"  //1,1,0	
		if ((z1[1]~="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "111"  //1,1,1
	}	
	
	//sort is done before and setup area panel
	area_v = _fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0)
	//wt_v   = _fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0)
	//pl_v   = _fgetcoldata(_fvarindex(pl[1], varlist), fhcensus, p0, p1-p0)
	info   = panelsetup(area_v, 1)	
	rowsinfo = rows(info)
	//for (r=1; r<=cols(agglist); r++) agginfo[r,1] = &(panelsetup(_ftruncateID(area_v, agglist[r]), 1))	
	//area_v = 1
	
	//create the mark index (0 and 1)
	mask = _fdatamark(N, varinmod, varlist, fhcensus, p0, p1-p0)
	//N = quadcolsum(mask)
	
	//New mata structure: key, matrixobs, matrixvar, _ByID, _ID, _WEIGHT, _YHAT1..._YHAT100, _POVLINE, addition vars
	if (st_local("ydump")!="") { 
		if (st_local("plinevar")!="") ncols = 3 + sim + 1 + coladd
		else ncols = 3 + sim + coladd
		yd = fopen(st_local("ydump"),"rw")		
		//"DATA_MATRIX", "VARIABLE_MATRIX" are removed from the matrix variable
		varname = "_ByID", "_ID", "_WEIGHT"
		varname = varname, tokens(st_local("yhatlist"))
		//if (st_local("plinevar")!="") varname = varname, "_POVLINE"
		if (st_local("addvars")!="") varname = varname, tokens(st_local("addvars"))
		fputmatrix(yd, (87801, quadcolsum(mask), ncols, sim, quadsum(strlen(varname))))     //DATA_MATRIX
		if (st_local("addvars")!="") fputmatrix(yd, ("_ByID", "_ID", "_WEIGHT", tokens(st_local("yhatlist")), tokens(st_local("addvars"))))  //VARIABLE_MATRIX		
		else                         fputmatrix(yd, ("_ByID", "_ID", "_WEIGHT", tokens(st_local("yhatlist"))))  //VARIABLE_MATRIX		
		fputmatrix(yd, select(J(N,1,1), mask)) //_ByID
		fputmatrix(yd, select(_fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0), mask)) //_ID
		fputmatrix(yd, select(_fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0), mask)) //_WEIGHT
		//if (st_local("plinevar")!="") fputmatrix(yd, select(_fgetcoldata(_fvarindex(st_local("plinevar"), varlist), fhcensus, p0, p1-p0), mask)) //_POVLINE
	}
	
	//Simulation dots
	if (boots==0) display("Parametric drawing of betas")
	else          display("Bootstrapped drawing of betas and parameters")
	
	//count = 20 //need to be based on memory available
	printf("{txt}\nNumber of simulations: {res}%g{txt}", sim)
	printf("{txt}\nEach dot (.) represents {res}%g{txt} simulation(s).\n", count)
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
			"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
			"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	
	//Getting etamat for all area and all simulations
	//do this because we keep the sequential draw: for each area within each simulation, then repeat each simulation.
	if (boots==0){
		if (etanorm==0) {
			itsbs  = cols(locerr)!=1
			etamat = _f_sampleeps(rowsinfo, 1, locerr[.,1])'
			if (itsbs==1) for (j=2; j<=sim; j++) etamat = etamat, _f_sampleeps(rowsinfo, 1, locerr[.,j])'
			else for (j=2; j<=sim; j++) etamat = etamat, _f_sampleeps(rowsinfo, 1, locerr[.,1])'
		}
		else { //(etanorm==1)
			etamat = rnormal(rowsinfo,1,0,sqrt(locerr[1]))
			for (j=2; j<=sim; j++) etamat = etamat, rnormal(rowsinfo,1,0,sqrt(locerr[j]))
		}
	} 
	area_v = NULL
	for (s=1; s<=sim; s=s+count) {
	
		if (EB==1) {
			cens_area = J(rowsinfo,1,.)
			for(r=1; r<=rowsinfo; r++) cens_area[r,1] = area_v[info[r,1],1]
			D = _ebcensus4(cens_area, loc[s], loc2[s], info)
			etamat = rnormal(1,1,D[.,2*1-1],sqrt(D[.,1*2]))  //j==1
			for(j=2; j<=sim; j++) etamat = etamat, rnormal(1,1,D[.,2*j-1],sqrt(D[.,j*2]))
			cens_area = D = NULL
		}
	
		//xb and epsnorm
		m0 = s,1 \ s+count-1,1
		m1 = .,s \ .,s+count-1
		xb = J(N,1,1)*bsim[|s,colsbsim \ s+count-1,colsbsim|]' //change to 0 for nocons 
		for (v=1; v<=colsx; v++) xb = xb :+ _fgetcoldata(_fvarindex(x[v], varlist), fhcensus, p0, p1-p0)*bsim[|s,v \ s+count-1,v|]'
		if (epsnorm==1) {
			if (hheff==1) {
				if (zcond == "100") { //xb = (zi,J(rows(zi),1,1))*asim'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)*asim[|s,v \ s+count-1,v|]'
				}
				if (zcond == "110") { //xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0) *asim[|s,v \ s+count-1,v|]'					
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]'):*xb
				}
				if (zcond == "111") { //xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)  *asim[|s,v \ s+count-1,v|]'
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]'):*xb
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1+colsyh \ s+count-1,v+colsz1+colsyh|]'):*(xb:^2)
				}
				if (zcond == "010") { //xb = (yhi*asim[.,cols(asim)-1]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 					
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*xb
				}
				if (zcond == "011") { //xb = (yhi*asim[.,1..cols(yhi)]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim')+ J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*xb
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsyh \ s+count-1,v+colsyh|]'):*(xb:^2)
				}
				if (zcond == "001") { //xb = (yh2i*asim[.,1..cols(yh2i)]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') +  J(rows(yh2i),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 					
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*(xb:^2)
				}
				if (zcond == "101") { //xb = zi*asim[|.,1 \.,cols(zi)|]' + (yh2i*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi2)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yh2i),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++)  zb = zb +  _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)    *asim[|s,v \ s+count-1,v|]'					
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]' ):*(xb:^2)
				}
				zb = exp(zb)
				zb = (maxA[|m0|]':*(zb:/(1:+zb))) :+ (.5*varr[|m0|])':*((maxA[|m0|]':*(zb:*(1:-zb))):/((1:+zb):^3))
				//_editmissing(zb, maxA)
				xb = xb + colshape(vec(rnormal(1,1,0,sqrt(zb))'),N)' 	//checked OK on 1 sim or many sim			 
				zb = NULL //release zb
			}
			else { // hheff==0
				xb = xb + rnormal(N,1,0,sqrt(sigma_eps[|m0|])') //checked OK on 1 sim or many sim
			}
		}
		else { //epsnorm==0
			xb = xb + _f_sampleeps(count, N, hherr[|m1|]) //checked OK on 1 sim or many sim
		}
		
		//etanorm
		for(j=1; j<=rowsinfo; j++) {
			m2 = info[j,1],. \ info[j,2],.
			xb[|m2|] = xb[|m2|] :+ etamat[j, s..s+count-1]		 
		}
		//now we have xb, let do the calculation fgt, gini, etc.
		
		//Write col by col to the mata data
		if (st_local("ydump")!="") { 
			if (lg==1) for (m=1; m<=count; m++) fputmatrix(yd, exp(select(xb[.,m], mask))) 
			else       for (m=1; m<=count; m++) fputmatrix(yd, select(xb[.,m], mask))
		}
		printf(".")
		if (mod(s,50)==0) printf(" %5.0f\n",s)
		displayflush()
	} //end of s
	xb = area_v = wt_v = pl_v = NULL
	
	//Add additional variables to the ydump
	if (st_local("ydump")!="") {
		if (st_local("addvars")!="") {
			addvarlist = tokens(st_local("addvars"))
			for (v=1; v<=coladd; v++) fputmatrix(yd, select(_fgetcoldata(_fvarindex(addvarlist[v], varlist), fhcensus, p0, p1-p0), mask)) //_ID
		}
		fclose(yd)	
	}
	fclose(fhcensus)
	st_local("_itran","0")
}


//Column processing function + on the fly
void _s2sc_sim_cols2(string scalar xvar, 
					 string scalar zvars, 
					 string scalar yhats, 
					 string scalar yhats2, 
					 string scalar areavar, 
					 string scalar plvar, 
					 string scalar wgt, 
					 string scalar touse, 
					 string scalar hhid, 
					 string scalar matin) 
{
	count       = strtoreal(st_local("colprocess"))
	sim         = strtoreal(st_local("rep"))
	seed        = strtoreal(st_local("seed"))	
	h3    		= strtoreal(st_local("h3"))
	if          (st_local("nolocation")~="") h3 = 2
	hheff       = strtoreal(st_local("hheffs"))
	boots     	= strtoreal(st_local("boots"))
	etanorm 	= strtoreal(st_local("etanormal"))
	epsnorm 	= strtoreal(st_local("epsnormal"))
	EB    		= strtoreal(st_local("ebest"))	
	lg			= strtoreal(st_local("lny"))
	varinmod	= tokens(st_local("varinmodel"))	
	//pointer(real matrix) rowvector agginfo	
	indlist     = tokens(st_local("indicators"))	
	
	//pline       = strtoreal(st_local("pline"))	
	yesmata = strtoreal(st_local("matay"))
	agglist = strtoreal(tokens(st_local("aggids")))
	fgtlist = tokens(st_local("fgtlist"))
	gelist  = tokens(st_local("gelist"))
	pl      = strtoreal(tokens(plvar))
	plreal = 1
	if (missing(pl)>0) {
		pl = tokens(plvar)	
		plreal = 0
	}

	external bsim, asim, maxA, varr, sigma, v_sigma, sigma_eps, locerr, hherr, locerr2, loc, loc2, hhbs
	colsbsim = cols(bsim)
	colsasim = cols(asim)	
	if ((EB==1) & ((etanorm==0)|(epsnorm==0))){
		etanorm=1
		epsnorm=1
	}
	
	//WARNING: area must be sorted outside in Stata
	//census data - or use other way, ie seek(fh, (N*8+77)*6 ,-1) to get the 7th column
	fhcensus = fopen(matin, "r")
	varlist = fgetmatrix(fhcensus)	
	p0 = ftell(fhcensus)
	a  = fgetmatrix(fhcensus)
	p1 = ftell(fhcensus)
	N  = rows(a)	
	a  = J(1,1,.)
	
	//The data
	x       = tokens(xvar)
	z1      = tokens(zvars)
	yh      = tokens(yhats)
	yh2     = tokens(yhats2)
	area    = tokens(areavar)
	wt      = tokens(wgt)
	id      = tokens(hhid)
	//pl      = tokens(plvar)
	colsx   = cols(x)
	colsz1  = cols(z1)
	colsyh  = cols(yh)
	colsyh2 = cols(yh2)
	
	if (st_local("cuts")!="")  cut = tokens(st_local("cuts"))
	coladd = (st_local("addvars")!="" ? cols(tokens(st_local("addvars"))) : 0) 
	//if (pline==.) st_view(pl,.,tokens(st_local("pline")), .)
	
	//Check if X and other variables (varinmodel local), Z and Yhats are in the code
	e3499 = _fvarscheck(varinmod, varlist)
	if (z1[1]  != "__mz1_000")  e3499 = _fvarscheck(z1, varlist)
	if (yh[1]  != "__myh_000")  e3499 = _fvarscheck(yh, varlist)
	if (yh2[1] != "__myh2_000") e3499 = _fvarscheck(yh2, varlist)
	if (st_local("addvars")!="")    e3499 = _fvarscheck(tokens(st_local("addvars")), varlist)
	if (e3499==1) {
		errprintf("Variables mentioned above are missing from the target dataset\n")
		_error(3499)
	}

	if (hheff==1) { //zalpha condition - __mz1_000, __myh_000, __myh2_000
		if ((z1[1]=="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "000"  //0,0,0
		if ((z1[1]=="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "001"  //0,0,1
		if ((z1[1]=="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "010"  //0,1,0
		if ((z1[1]=="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "011"  //0,1,1
		if ((z1[1]~="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "100"  //1,0,0
		if ((z1[1]~="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "101"  //1,0,1
		if ((z1[1]~="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "110"  //1,1,0	
		if ((z1[1]~="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "111"  //1,1,1
	}	
	
	//sort is done before and setup area panel
	area_v = _fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0)
	display("{it:Number of observations in target dataset:}")
	rows(area_v)	
	if (rows(area_v)==0){
		errprintf("\n Your target dataset has no observations, please check")
		_error(3862)	
	}
	display("")
	//wt_v   = _fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0)
	//pl_v   = _fgetcoldata(_fvarindex(pl[1], varlist), fhcensus, p0, p1-p0)
	info   = panelsetup(area_v, 1)	
	rowsinfo = rows(info)
	display("{it:Number of clusters in target dataset:}")
	rowsinfo
	display("")
	//for (r=1; r<=cols(agglist); r++) agginfo[r,1] = &(panelsetup(_ftruncateID(area_v, agglist[r]), 1))	
	//area_v = 1
	
	//create the mark index (0 and 1)
	mask = _fdatamark(N, varinmod, varlist, fhcensus, p0, p1-p0)
	//N = quadcolsum(mask)
	
	//Prep for on the fly calculation		
	if (yesmata==1 & st_local("ydump")=="") {
		wt_v = select(_fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0), mask)
		nHHLDs = rows(wt_v)
		area2 = select(area_v, mask)
		nagg = cols(agglist)
		npovlines = cols(pl)
		infov = areaid = nhh = J(1, nagg, NULL)
		nrow = J(1, nagg, .)
		for (j=1; j<=nagg; j++) {
			idfake    = trunc(area2/10^agglist[j])
			infov[j]   = &(panelsetup(idfake, 1))
			areaid[j] = &(idfake[(*infov[j])[(1::rows(*infov[j])),2],.])
			nhh[j]    = &((*infov[j])[.,2] - (*infov[j])[.,1] :+ 1)
			nrow[j]   = rows(*infov[j])
		}
		idfake = NULL
		
		//Unit	nHHLDs	nDroppedHHLD	nIndividuals	YTrimed	nSim	Min_Y	Max_Y	Mean	StdErr
		rmatnames = "nSim", "Unit", "nHHLDs", "nIndividuals", "Mean"
		senames = "StdErr"
		nfgts = cols(fgtlist)
		if (nfgts>0) {
			for (l=1; l<=npovlines; l++) {
				for (ind=1; ind<=nfgts; ind++) {
					plname = (plreal==1 ? strtoname(strofreal(pl[l])) : "_" + pl[l])
					rmatnames = rmatnames, "avg_" + fgtlist[ind] + plname
					senames = senames, "se_" + fgtlist[ind] + plname
				}
			}
		}
		nges = cols(gelist)
		if (nges>0) {
			for (ind=1; ind<=nges; ind++) {
				rmatnames = rmatnames, "avg_" + gelist[ind]
				senames = senames, "se_" + gelist[ind]
			}
		}
		rmatnames = rmatnames, senames

		if (npovlines>0 & nfgts>0 & plreal==0) {
			plvalue = J(1,npovlines, NULL)
			for (l=1; l<=npovlines; l++) plvalue[l] = &((_fgetcoldata(_fvarindex(pl[l], varname), fhcensus, p0, p1-p0), mask))		
		}		
	}
	
	//New mata structure: key, matrixobs, matrixvar, _ByID, _ID, _WEIGHT, _YHAT1..._YHAT100, _POVLINE, addition vars
	if (st_local("ydump")!="") { 
		if (st_local("plinevar")!="") ncols = 3 + sim + 1 + coladd
		else ncols = 3 + sim + coladd
		yd = fopen(st_local("ydump"),"rw")		
		//"DATA_MATRIX", "VARIABLE_MATRIX" are removed from the matrix variable
		varname = "_ByID", "_ID", "_WEIGHT"
		varname = varname, tokens(st_local("yhatlist"))
		//if (st_local("plinevar")!="") varname = varname, "_POVLINE"
		if (st_local("addvars")!="") varname = varname, tokens(st_local("addvars"))
		fputmatrix(yd, (87801, quadcolsum(mask), ncols, sim, quadsum(strlen(varname))))     //DATA_MATRIX
		if (st_local("addvars")!="") fputmatrix(yd, ("_ByID", "_ID", "_WEIGHT", tokens(st_local("yhatlist")), tokens(st_local("addvars"))))  //VARIABLE_MATRIX		
		else                         fputmatrix(yd, ("_ByID", "_ID", "_WEIGHT", tokens(st_local("yhatlist"))))  //VARIABLE_MATRIX		
		fputmatrix(yd, select(J(N,1,1), mask)) //_ByID
		fputmatrix(yd, select(_fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0), mask)) //_ID
		fputmatrix(yd, select(_fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0), mask)) //_WEIGHT
		//if (st_local("plinevar")!="") fputmatrix(yd, select(_fgetcoldata(_fvarindex(st_local("plinevar"), varlist), fhcensus, p0, p1-p0), mask)) //_POVLINE
	}
	
	//Simulation dots
	if (boots==0) display("Parametric drawing of betas")
	else          display("Bootstrapped drawing of betas and parameters")
	
	//count = 20 //need to be based on memory available
	printf("{txt}\nNumber of simulations: {res}%g{txt}", sim)
	printf("{txt}\nEach dot (.) represents {res}%g{txt} simulation(s).\n", count)
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
			"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
			"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	
	//Getting etamat for all area and all simulations
	//do this because we keep the sequential draw: for each area within each simulation, then repeat each simulation.
	if (EB==1){
		cens_area = area_v[info[.,1],1]
	}
	else{
		if (boots==0){
			if (etanorm==0) {
				itsbs  = cols(locerr)!=1
				etamat = _f_sampleeps(rowsinfo, 1, locerr[.,1])'
				if (itsbs==1) for (j=2; j<=sim; j++) etamat = etamat, _f_sampleeps(rowsinfo, 1, locerr[.,j])'
				else for (j=2; j<=sim; j++) etamat = etamat, _f_sampleeps(rowsinfo, 1, locerr[.,1])'
			}
			else { //(etanorm==1)
				etamat = rnormal(rowsinfo,1,0,sqrt(locerr[1]))
				for (j=2; j<=sim; j++) etamat = etamat, rnormal(rowsinfo,1,0,sqrt(locerr[j]))
			}
		}
		else{
			if (etanorm==0) {
				etamat = _f_sampleeps(rowsinfo, 1, (*loc[1]))'
				for (j=2; j<=sim; j++) etamat = etamat, _f_sampleeps(rowsinfo, 1, (*loc[j]))'
			}
			else{
				etamat = rnormal(rowsinfo,1,0,sqrt((*loc[1])))
				for (j=2; j<=sim; j++) etamat = etamat, rnormal(rowsinfo,1,0,sqrt((*loc[j])))
			}
		}
	} 
 
	if (yesmata==0) area_v = NULL
	else {
		if (st_local("ydump")==""){
			block = J(1, 5 + nfgts*npovlines + nges,.)
			sim0 = 1
		}
	}
	
	for (s=1; s<=sim; s=s+count) {
		if (EB==1) {
			D = _ebcensus4(cens_area, (*loc[s]), (*loc2[s]), info)
			etamat = rnormal(1,1,D[.,2*1-1],sqrt(D[.,1*2]))  //j==1			
		}

		//xb and epsnorm
		m0 = s,1 \ s+count-1,1
		m1 = .,s \ .,s+count-1
		xb = J(N,1,1)*bsim[|s,colsbsim \ s+count-1,colsbsim|]' //change to 0 for nocons 
		for (v=1; v<=colsx; v++) xb = xb :+ _fgetcoldata(_fvarindex(x[v], varlist), fhcensus, p0, p1-p0)*bsim[|s,v \ s+count-1,v|]'
		if (epsnorm==1) {
			if (hheff==1) {
				if (zcond == "100") { //xb = (zi,J(rows(zi),1,1))*asim'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)*asim[|s,v \ s+count-1,v|]'
				}
				if (zcond == "110") { //xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0) *asim[|s,v \ s+count-1,v|]'					
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]'):*xb
				}
				if (zcond == "111") { //xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)  *asim[|s,v \ s+count-1,v|]'
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]'):*xb
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1+colsyh \ s+count-1,v+colsz1+colsyh|]'):*(xb:^2)
				}
				if (zcond == "010") { //xb = (yhi*asim[.,cols(asim)-1]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 					
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*xb
				}
				if (zcond == "011") { //xb = (yhi*asim[.,1..cols(yhi)]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim')+ J(rows(yhi),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*xb
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsyh \ s+count-1,v+colsyh|]'):*(xb:^2)
				}
				if (zcond == "001") { //xb = (yh2i*asim[.,1..cols(yh2i)]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') +  J(rows(yh2i),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 					
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*(xb:^2)
				}
				if (zcond == "101") { //xb = zi*asim[|.,1 \.,cols(zi)|]' + (yh2i*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi2)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yh2i),1,1)*asim[.,cols(asim)]'
					zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
					for (v=1; v<=colsz1; v++)  zb = zb +  _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)    *asim[|s,v \ s+count-1,v|]'					
					for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]' ):*(xb:^2)
				}
				zb = exp(zb)
				zb = (maxA[|m0|]':*(zb:/(1:+zb))) :+ (.5*varr[|m0|])':*((maxA[|m0|]':*(zb:*(1:-zb))):/((1:+zb):^3))
				//_editmissing(zb, maxA)
				xb = xb + colshape(vec(rnormal(1,1,0,sqrt(zb))'),N)' 	//checked OK on 1 sim or many sim			 
				zb = NULL //release zb
			}
			else { // hheff==0
				xb = xb + rnormal(N,1,0,sqrt(sigma_eps[|m0|])') //checked OK on 1 sim or many sim
			}
		}
		else { //epsnorm==0
			if (boots==0) xb = xb + _f_sampleeps(count, N, hherr[.,1]) //Parametric only has one vector!
			else xb = xb + _f_sampleeps(count, N, (*hhbs[s])) //checked OK on 1 sim or many sim
		}
		
		//etanorm
		for(j=1; j<=rowsinfo; j++) {
			m2 = info[j,1],. \ info[j,2],.
			if (EB==1) 	xb[|m2|] = xb[|m2|] :+ etamat[j]		 
			else       	xb[|m2|] = xb[|m2|] :+ etamat[j, s..s+count-1]
		}
				
		//Write col by col to the mata data
		if (st_local("ydump")!="") { 
			if (lg==1) for (m=1; m<=count; m++) fputmatrix(yd, exp(select(xb[.,m], mask))) 
			else       for (m=1; m<=count; m++) fputmatrix(yd, select(xb[.,m], mask))
		}
		
		//now we have xb, let do the calculation fgt, gini, etc.		
		if (yesmata==1 & st_local("ydump")=="") {
			xb = select(xb, mask)
			for (m=1; m<=count; m++) {
				block0 = J(1,5,.)
				wt_m = wt_v
				if (lg==1) y = exp(xb[.,m])
				else       y = xb[.,m]
				if (colmissing(y)>0) {
					_editmissing(y, 0)	
					wt_m[selectindex(rowmissing(y)),.] = J(rows(selectindex(rowmissing(y))),1,0)		
				}
				wy = wt_m:*y
				running = quadrunningsum(wt_m,0), quadrunningsum(wy,0)	
				//minmaxy = minmax(y)
				for (j=1; j<=nagg; j++) {
					if (nrow[j] >=2) {
						A = running[(*infov[j])[1,2],.] \ running[(*infov[j])[(2::nrow[j]),2],.] - running[(*infov[j])[(1::nrow[j]-1),2],.]
						block0 = block0 \ J(nrow[j],1,sim0), *areaid[j], *nhh[j], A[.,1]           , A[.,2]:/A[.,1]
					}
					else block0 = block0 \ sim0            , 0         ,  nHHLDs, running[nHHLDs,1], running[nHHLDs,2]/running[nHHLDs,1]
				}
				A = NULL
				block0 = block0[2..rows(block0),.]
				if (nfgts>0) {
					for (l=1; l<=npovlines; l++) {
						if (plreal==1) {
							wt_p = (y:<= pl[l]):*wt_m
							rgap = 1:-(y:/ pl[l])
						}
						else {
							wt_p = (y:<= *plvalue[l]):*wt_m
							rgap = 1:-(y:/ *plvalue[l])				
						}
						for (ind=1; ind<=nfgts; ind++) {
							if (fgtlist[ind]=="fgt0") currfgt = running[.,1], quadrunningsum(wt_p,0)
							if (fgtlist[ind]=="fgt1") currfgt = running[.,1], quadrunningsum(wt_p:*rgap,0)
							if (fgtlist[ind]=="fgt2") currfgt = running[.,1], quadrunningsum(wt_p:*rgap:*rgap,0)
							fgtx = J(1,1,.)
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = currfgt[(*infov[j])[1,2],.] \ currfgt[(*infov[j])[(2::nrow[j]),2],.] - currfgt[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx  \ A[.,2]           :/ A[.,1]
								}
								else fgtx = fgtx \ currfgt[nHHLDs,2]:/ currfgt[nHHLDs,1]
							}
							block0 = block0, fgtx[2..rows(fgtx),1]
							A = fgtx = currfgt = NULL
						} //ind
					} //plines
				} //nfgt
				if (nges>0) {
					lny = ln(y)
					wlny = wt_m:*lny
					for (ind=1; ind<=nges; ind++) {
						if (gelist[ind]=="ge0") current = running, quadrunningsum(wlny,0)
						if (gelist[ind]=="ge1") current = running, quadrunningsum(wy:*lny,0)
						if (gelist[ind]=="ge2") current = running, quadrunningsum(wy:*y,0)	
						fgtx = J(1,1,.)
						if (gelist[ind]=="ge0") {
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx  \ -(A[.,3]:/A[.,1])                       :+ ln(A[.,2]:/A[.,1])
								}
								else fgtx = fgtx \ -(current[nHHLDs,3]:/current[nHHLDs,1]) :+ ln(current[nHHLDs,2]:/current[nHHLDs,1])
							}
						}
						if (gelist[ind]=="ge1") {
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx \ (A[.,3]:/A[.,2])                       :- ln(A[.,2]:/A[.,1])
								}
								else fgtx = fgtx \ (current[nHHLDs,3]:/current[nHHLDs,2]) :- ln(current[nHHLDs,2]:/current[nHHLDs,1])
							}
						}
						if (gelist[ind]=="ge2") {
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx \ 0.5*((((A[.,2]           :/A[.,1])           :^-2):*(A[.,3]:/A[.,1])):-1)
								}
								else fgtx = fgtx \ 0.5*((((current[nHHLDs,2]:/current[nHHLDs,1]):^-2):*(current[nHHLDs,3]:/current[nHHLDs,1])):-1)
							}
						}
						block0 = block0, fgtx[2..rows(fgtx),1]
						A = fgtx = current = NULL	
					} //ind
				} //nges
				//add blocks
				block = block \ block0
				sim0 = sim0 + 1
			} //m
		} //yesmata
		
		printf(".")
		if (mod(s,50)==0) printf(" %5.0f\n",s)
		displayflush()
	} //end of s
	xb = area_v = wt_v = wt_m = pl_v = NULL
	block0 = y = wt0 = wt = area = wy = running = wt_p = rgap = plvalue = lny = wlny = info = areaid = nhh = NULL

	//Add additional variables to the ydump
	if (st_local("ydump")!="") {
		if (st_local("addvars")!="") {
			addvarlist = tokens(st_local("addvars"))
			for (v=1; v<=coladd; v++) fputmatrix(yd, select(_fgetcoldata(_fvarindex(addvarlist[v], varlist), fhcensus, p0, p1-p0), mask)) //_ID
		}
		fclose(yd)	
	}
	fclose(fhcensus)
	
	//export results to Stata
	if (yesmata==1 & st_local("ydump")=="") {
		block = block[2..rows(block),.]
		_sort(block, (2,1))
		infov = panelsetup(block,2)
		rinfo = rows(infov)
		outsim = J(1, 4+(cols(block)-4)*2, .)
		for (i=1; i<=rinfo; i++) {
			rr  = infov[i,1],5 \ infov[i,2],.
			out = quadmeanvariance(block[|rr|])
			outsim = outsim \ infov[i,2]-infov[i,1]+1, block[infov[i,1],2::4], out[1,.], sqrt(diagonal(out[2..rows(out),.])')
		}
		out = block = NULL
		outsim = outsim[2..rows(outsim),.]
		stata("clear")	
		(void) st_addvar("double", rmatnames)	
		st_addobs(rows(outsim))
		st_store(.,.,outsim)
		outsim = NULL
	}
	st_local("_itran","0")
}

// OLS with weight and vce option 0 none, 1 robust, 2 cluster, 3 povmap adjustment
function _f_wols(real matrix y, real matrix x, real matrix wt, real matrix info, real scalar vce, real scalar bs) {
	pointer(real matrix) rowvector olsout
	olsout = J(1,9,NULL)
	nobs   = rows(x) // N Obs
	ncolx  = cols(x)
	if (bs==0) {
		xwx   = invsym(quadcross(x,wt,x))
		b_ols = quadcross(xwx,quadcross(x,wt,y))			
		res   = y - quadcross(x',b_ols)
		N     = rows(info)
		//USE MSE FROM POVMAP, it will not match that from stata!
		mse   = quadcross(res,wt,res)/(mean(wt))/(nobs - ncolx)	
		if (vce==0) v_ols = (quadcross(res,wt,res)*xwx)/(nobs - ncolx) //regular WOLS COV
		if (vce==1) v_ols = (nobs/(nobs - ncolx))*quadcross(xwx',quadcross(quadcross((wt:*res):*x,(wt:*res):*x)',xwx)) //aw robust or pw: correct stata way
		if (vce==2) { //cluster
			if (N>1) { //VCE cluster COV				
				M = J(ncolx, ncolx, 0)
				for(i=1; i<=N; i++) {
					xi = panelsubmatrix(x, i, info)
					ei = panelsubmatrix(res, i, info)
					wi = panelsubmatrix(wt, i, info)
					we = quadcross((wi:*ei)' ,(wi:*ei)')
					M  = M + quadcross(quadcross(xi,we)',xi)
				}
				v_ols = ((nobs - 1)/(nobs - ncolx))*(N/(N-1))*quadcross(quadcross(xwx',M)',xwx)
			}
			else { //Robust OLS COV		
				v_ols = (nobs/(nobs - ncolx))*quadcross(xwx',quadcross(quadcross((wt:*res):*x,(wt:*res):*x)',xwx))
			}
		}
		if (vce==3) v_ols = quadcross(quadcross(xwx',quadcross(x,(wt:^2),x))',xwx):*mse // Povmap method with adjustment	
		//estimate other statistics for OLS
		df    = ncolx - 1	 //Degrees of freedom
		R2    = 1 - quadcross(res,wt,res)/quadcrossdev(y, mean(y,wt), wt, y, mean(y,wt))	//R2
		fstat = (R2/(1-R2))*((nobs - ncolx)/df)	        //Fstat
		aR2   = 1 - ((nobs - 1)/(nobs - ncolx))*(1-R2)  //Adjusted R2
	} //bs
	else {
		b_ols = quadcross(invsym(quadcross(x,wt,x)),quadcross(x,wt,y))
		res   = y - quadcross(x',b_ols)
		mse   = quadcross(res,wt,res)/(mean(wt))/(nobs - ncolx)
	}
	olsout[1,1]= &(b_ols)
	olsout[1,2]= &(v_ols)
	olsout[1,3]= &(res)
	olsout[1,4]= &(mse)
	olsout[1,5]= &(R2)
	olsout[1,6]= &(fstat)
	olsout[1,7]= &(aR2)
	olsout[1,8]= &(nobs)
	olsout[1,9]= &(df)
	return(olsout)
}

//GLS Roy's paper
function _f_hh_gls2(real matrix y, real matrix x, real matrix wt, real matrix sig_e, real scalar sig_n, real matrix info, real scalar EB, real scalar bs) {
	pointer(real matrix) rowvector glsout2
	glsout2 = J(1,3,NULL)
	//Capital sigma matrix for GLS	
	xtwex = xtwewx = J(cols(x), cols(x), 0)
	xtwey = J(cols(x), 1, 0)
	N = rows(info)
	//Loop through clusters 
	for (i=1; i<=N; i++) {	
		thesub = info[i,1],. \ info[i,2],.
		cv     = sig_e[|thesub|]  
		//panelsubmatrix(sig_e,i,info)
		v      = diag(cv) + J(rows(cv),rows(cv),sig_n)
		wt1    = wt[|thesub|]
		//panelsubmatrix(wt,i,info)
		cv     = diag(cv:/wt1) + (quadsum(wt1)/quadsum(wt1:^2))*J(rows(cv),rows(cv),sig_n)
		x1     = x[|thesub|]
		y1     = y[|thesub|]
		_invsym(cv)
		xt     = quadcross(x1,cv)
		xtwex  = xtwex + quadcross(xt',x1)
		xtwey  = xtwey + quadcross(xt',y1)
		xtwewx = xtwewx + quadcross(quadcross(xt',v)',quadcross(cv,x1))
	}
	if (bs==0) {
		_invsym(xtwex)
		Beta2 = quadcross(xtwex,xtwey)
		vcov2 = quadcross(quadcross((xtwex),xtwewx)',(xtwex))
	}
	else {
		//Beta2 = lusolve(xtwex,xtwey)
		Beta2 = quadcross(invsym(xtwex),xtwey)
	}
	//following estimates GLS residuals for EB
	glsout2[1,1] = &(Beta2)
	glsout2[1,2] = &(vcov2)
	glsout2[1,3] = &(y -quadcross(x',Beta2))
	return(glsout2)
}

// Sigma eta for ELL
function _ell_sigeta(real matrix uch, real matrix wt, real matrix info, real scalar sim) {
	pointer(real matrix) rowvector ellsig
	ellsig = J(1,2,NULL)
	N      = rows(info)
	tau2c  = wc = ucdot = nc = J(N,1,.)
	wall   = quadsum(wt)
	data   = uch, wt
	
	for (a=1; a<=N; a++) {	
	   //Get weights
	    datai 		= panelsubmatrix(data, a, info)
		wi    		= datai[.,cols(datai)]	
		wc[a] 		= (quadsum(wi)/wall)
		//Get Tau_c
		ucdot[a]    = mean(datai[.,1],wi)
		nc[a]       = rows(datai)
		ech         = datai[.,1] :- ucdot[a]
		tau2c[a]    = (1/(nc[a]*(nc[a]-1)))*quadcrossdev(ech,mean(ech),ech,mean(ech))
		//end of Tau		
	}
	
	num1 = quadcrossdev(ucdot,(mean(ucdot,wc)),wc,ucdot,(mean(ucdot,wc)))	
	num2 = quadcross((wc:*tau2c),(1:-wc))
	den  = quadcross(wc,(1:-wc))
	
	sigmas    = ((num1-num2)/den),0
	varsigma2 = max(sigmas)
	
	ellsig[1,1] = &(varsigma2)
	
	if (sim==0) {
		sig2n_hat = 0
		for (a=1; a<=N; a++) {	
			sig2n_hat = sig2n_hat +2*(((wc[a]/den)^2)*((varsigma2^2)+(tau2c[a]^2)+2*varsigma2*tau2c[a])+(((wc[a]*(1-wc[a]))/den)^2)*((tau2c[a]^2)/(nc[a]-1)))			
		}
		ellsig[1,2]   = &(sig2n_hat)	
	}	
	return(ellsig)
}

//ELL GLS, no longer used in PovMap. Offer as option?
function _f_ell_gls(real matrix y, real matrix x, real matrix wt, real matrix info, real matrix sig_e, real scalar sig_n) {
	pointer(real matrix) rowvector glsout
	glsout = J(1,2,NULL)
	N = rows(info)
	//Capital sigma matrix for GLS	
	xtwex = xtwewx = J(cols(x), cols(x), 0)
	xtwey = J(cols(x), 1, 0)
	
	//Loop through clusters 		
	for (i=1; i<=N; i++) {		
		cv     = diag(panelsubmatrix(sig_e,i,info)) 
		cv     = cv + J(rows(cv),cols(cv),sig_n)			
		x1     = panelsubmatrix(x,i,info)
		wt1    = panelsubmatrix(wt,i,info)
		y1     = panelsubmatrix(y,i,info)		
		xt     = quadcross(x1,wt1,luinv(cv))
		xtwex  = xtwex + quadcross(xt',x1)
		xtwey  = xtwey + quadcross(xt',y1)	
		xtwewx = xtwewx + quadcross(xt',wt1,x1) 		
	}
	
	Beta2 = quadcross(luinv(xtwex)',xtwey)
	vcov2 = quadcross(quadcross(luinv(xtwex)',xtwewx)',luinv(xtwex))
	
	//VCOV is not symmetric, it must be symmetric, we follow Haslett, 2005 pg 160
	vcov2 =(1/2)*(vcov2+vcov2')
	glsout[1,1] = &(Beta2)
	glsout[1,2] = &(vcov2)		
	return(glsout)
}	

//function to draw multivariate normal distribution
function _f_drawnorm(real scalar n, real matrix M, real matrix V, real scalar seed) {
	return(M :+ invnormal(uniform(n,cols(V)))*cholesky(V)')
}

//function to draw multivariate normal distribution - POVMAP's way
function _f_drawnorm2(real scalar n, real matrix M, real matrix vcov) {					
	U=V=D=J(rows(vcov),rows(vcov),.)
	svd(vcov,U,D,V)	
	return(M:+ (invnormal(uniform(n,rows(vcov)))*(U*diag(sqrt(D))*U')))	
}

//Random drawing with replacement of epsilons
function _f_sampleeps(real scalar n, real scalar dim, real matrix eps) {				  
	sige2 = J(dim,n,0)
	N = rows(eps)
	if (cols(eps)==1) for(i=1; i<=n; i++) sige2[.,i]=eps[ceil(N*runiform(dim,1)),1]
	else              for(i=1; i<=n; i++) sige2[.,i]=eps[ceil(N*runiform(dim,1)),i]
	//for(i=1; i<=n; i++) sige2[.,i]=eps[ceil(rows(eps)*runiform(dim,1)),i]
	return(sige2)	
}
//	data[|m0|] = dout[ceil(nrow*uniform(nrow,1)), .]
//Gamma sampler for sigeta
function _f_gammadraw(real matrix seta, real matrix var_seta, real scalar n) {					  
	return(rgamma(n,1,(seta^2/var_seta), (var_seta/seta)))				
}
//Function to match location error for EB?
function _f_ebmatch(real matrix sigeta, real matrix wt, real matrix sigeps, real matrix info, real matrix area, real matrix res) {
	pointer(real matrix) colvector ebout
	ebout = J(1,2,NULL)
	N = rows(info)
	sigout = J(N,3,.) //sigout -> Area, uhat, sigmaeta
	for(i=1;i<=N;i++) {
		sige = panelsubmatrix(sigeps,i,info)
		peso = panelsubmatrix(wt,i,info)
		resi = panelsubmatrix(res,i,info)
		alfach = ((peso:/sige) :/ quadsum((peso:/sige)))
		//alfach = quadcross(sige,(((peso:/sige):/quadsum((peso:/sige))):^2))
		gammau = sigeta/(sigeta+(quadsum((peso:^2))/(quadsum(peso)*quadsum((peso:/sige)))))				
		//sigout[i,.] = area[info[i,1]], (gammau*(alfach*quadsum(resi))), (sigeta - (gammau^2)*(sigeta + alfach))
		sigout[i,.] = area[info[i,1]], (gammau*quadcross(resi,alfach)), (sigeta - (gammau^2)*(sigeta + quadcross(sige,(alfach:^2))))
		res[|info[i,1],1 \ info[i,2],1|] = -(gammau*quadcross(resi,alfach)):+resi				
	}
	ebout[1,1]=&sigout
	ebout[1,2]=&res
	return(ebout)
}
//Function to ..?
function _f_hhech(real matrix res, real matrix wt, real matrix info, real matrix area) {
	pointer(real matrix) colvector echout
	echout=J(1,2,NULL)
	N = rows(info)
	eta=J(N,2,0)
	for(i=1;i<=N;i++) {
		peso = panelsubmatrix(wt,i,info)
		resi = panelsubmatrix(res,i,info)
		eta[i,.] = area[info[i,1]],mean(resi,peso)		
		res[|info[i,1],1 \ info[i,2],1|] = -eta[i,2]:+resi
	}
	echout[1,1] = &eta
	echout[1,2] = &res
	return(echout)	
}
//Pointer Function to clone pointers
pointer (transmorphic matrix) scalar f_pointer_clone(transmorphic matrix X) {
	transmorphic matrix Y
	return(&(Y = X))
}

//To assign etas and sigetas to census areas for EB
function _ebcensus4(real matrix area1, real matrix etabs, real matrix etabs2, real matrix info1) {
	_etabs = etabs
	N = rows(info1)
	cens_etas=J(N,1,etabs2[1,2..3])
	for(i=1; i<=N; i++) {
		k=0
		for(j=1;((j<=rows(_etabs)) & (k==0));j++) {
			if (area1[i,1]==_etabs[j,1]) {
				cens_etas[i,.] = _etabs[|j,2\j,cols(_etabs)|]
				k=1
			}
		}
	}
	return(cens_etas)
}


//To assign etas and sigetas to census areas for EB
function _ebcensus5(real matrix area1, real matrix etabs, real matrix info1) {
	N = rows(info1)
	nrow = rows(etabs)
	ncol = cols(etabs)
	cens_etas=J(N,1,(nrow+1))
	for(i=1; i<=nrow;i++) for(j=1; j<=N;j++) if (area1[j,1]==etabs[i,1]) cens_etas[j,1]=i
	return(cens_etas)
}

//1- DATA related functions

//function to find the position of the variable
//indlist is tokenize string matrix, strfind is string input
//_fvarindex("roof", indlist) //varlist = tokens(strall), 0 is not found
function _fvarindex(strfind, varlist) {
	match = 0
	nvars = cols(varlist)
	for (i=1; i<=nvars; i++) {
		if (strmatch(varlist[i], strfind) == 1) {
			match = i
			i = nvars
		}
	}
	return(match)
}

//function to get the column from the mata matrix datafile
//bytestart=p0, bytelength=p1-p0
function _fgetcoldata(colpos, filehandler, bytestart, bytelength) {
	if (colpos > 0) {
		fseek(filehandler, (colpos-1)*bytelength + bytestart ,-1)
		return(fgetmatrix(filehandler))
	}
	else {
		exit(error(2000))
	}
}
function _fgetcoldata2(colpos, filehandler, n) {
	fseek(filehandler, (n*8+77)*colpos ,-1) //this is because there is 1 vector before the data so colpos is the same, otherwise colspos-1
	return(fgetmatrix(filehandler))
}
//function to mark 0 and 1 to use in calculation (remove missing)
function _fdatamark(obs, varmod, varlist, filehandler, bytestart, bytelength) {
	mark = J(obs,1,1)	
	col = cols(varmod)	
	for (i=1; i<=col; i++) mark = mark:*((_fgetcoldata(_fvarindex(varmod[i], varlist), filehandler, bytestart, bytelength)):~=.)
	return(mark)
}

//function to truncate IDs by the position of the ID
function _ftruncateID(real matrix ids, real scalar pos) {
	return(trunc(ids:/(10^pos)))
}
//function to save ydump2dta
function _fydump2dta(ydump, dtaout) {
	dtafcol = strtoreal(st_local("dtacol"))
	dtafsize = strtoreal(st_local("dtasize"))
	
	yd = fopen(ydump,"r")
	info = fgetmatrix(yd)
	varname = fgetmatrix(yd)
	header = 77+5*8+4*info[3]+77+info[5]
	addvar = info[3]-info[4]
	filesize = (info[2]*info[3]*8 + 4*info[2])/1024^2
	ncolperfile = floor((dtafsize*(1024^2) - 4*info[2])/(8*info[2]))
	nfiles = ceil(filesize/dtafsize)
	//first file _seq, _ByID, _ID, _WEIGHT, addvars, sim
	//second file _seq, _ByID, _ID, _WEIGHT, sim	
}
//function to get levelsof from Andrew Maurer/statalist.org
real vector _fintlevelsof(real vector A) {
	real scalar maxA, minA, rangeA, offset
	real vector minmaxA, b
	minmaxA = minmax(A)
	minA = minmaxA[1,1]
	maxA = minmaxA[1,2]
	rangeA = maxA-minA+1
	offset = -minA+1
	if (rangeA > 10^9) _error(9,"range of vector must be less than 1 billion")
	b = J(rangeA, 1, 0)
	b[A:+offset,1] = J(length(A),1,1)
	return(selectindex(b):-offset)
}
//function to check the variable in the list, return 0/1 and local _itran
function _fvarscheck(varscheck, varlist) {
	nvarscheck = cols(varscheck)
	ret = 0 
	for (v=1; v<=nvarscheck; v++) {
		if (_fvarindex(varscheck[v], varlist)==0) {
			st_local("_itran","9999")
			errprintf("Variable %s not found\n", varscheck[v])
			ret = 1
		}
	}
	return(ret)
}
//function to expand the col in data by info structure
//data = unit, trans;, info is panel info matrix, areaid is id from each subgroup
function _fdataexpand(data, info, areaid) {
	if (rows(data)~=rows(areaid)) exit(error(3200))
	else {
		nrow = rows(info)
		out = J(info[rnrow,2],1,.)
		for (i=1; i<=nrow; i++) {
			j = selectindex(areaid:==data[i,1])
			out[info[j,1]..info[j,2]] = J(info[j,2]-info[j,1], 1, data[i,2])
		}
		return(out)
	}
}

//2- CALCULATION functions

// function to compute indicators, X = inclist, wt, pline
// y = nHHLDs, nIndividuals, min_y, max_y, mean, (indicator)
function _fgetinds(x, wt, pl, lny) {
	//if (lny==1) x = exp(x)
	if (lny==1) pl = ln(pl)
	//we also can do the ln of poverty line, this is much faster than the exp(x)
	indlist = tokens(st_local("indicators"))
	y = J(cols(x),1,rows(x)), J(cols(x),1,quadsum(wt)), colminmax(x)', mean(x,wt)'   
	for (i=1; i<=cols(indlist); i++) {
		if (indlist[i]=="fgt0")  y = y , _fFGT(x, pl, wt, 0)'
		if (indlist[i]=="fgt1")  y = y , _fFGT(x, pl, wt, 1)'
		if (indlist[i]=="fgt2")  y = y , _fFGT(x, pl, wt, 2)'
		if (indlist[i]=="gini")  y = y , _fGinis(x, wt)'
		if (indlist[i]=="ge0")   y = y , _fGE(x, wt, 0)' 
		if (indlist[i]=="ge1")   y = y , _fGE(x, wt, 1)' 
		if (indlist[i]=="ge2")   y = y , _fGE(x, wt, 2)' 
	}
	return(y)
}

// need to add different weights

//function to simulate the budget allocation - JDE paper
void _s2sc_inds_sim(string scalar ydump, string scalar plines, string scalar aggids, string scalar areavar, string scalar wgtvar, real matrix transdata) {
	//agglist = strtoreal(tokens(st_local("aggids")))
	agglist = strtoreal(tokens(aggids))	
	fgtlist = tokens(st_local("fgtlist"))
	gelist  = tokens(st_local("gelist"))
	pl      = strtoreal(tokens(plines))
	plreal = 1
	if (missing(pl)>0) {
		pl = tokens(plines)	
		plreal = 0
	}

	in = fopen(ydump, "r" )	
	size = fgetmatrix(in)
	varname = fgetmatrix(in)
	p0 = ftell(in)
	id = fgetmatrix(in)
	p1 = ftell(in)
	id = NULL	
	area = _fgetcoldata(_fvarindex(areavar, varname), in, p0, p1-p0)	
	wt0  = _fgetcoldata(_fvarindex(wgtvar, varname), in, p0, p1-p0)
	p2 = 2*(p1-p0)+p1
	nHHLDs = rows(wt0)
	nagg = cols(agglist)
	npovlines = cols(pl)
	info = areaid = nhh = J(1, nagg, NULL)

	nrow = J(1, nagg, .)
	for (j=1; j<=nagg; j++) {
		idfake    = trunc(area/10^agglist[j])
		info[j]   = &(panelsetup(idfake, 1))
		areaid[j] = &(idfake[(*info[j])[(1::rows(*info[j])),2],.])
		nhh[j]    = &((*info[j])[.,2] - (*info[j])[.,1] :+ 1)
		nrow[j]   = rows(*info[j])
	}
	idfake = NULL
	
	//Unit	nHHLDs	nDroppedHHLD	nIndividuals	YTrimed	nSim	Min_Y	Max_Y	Mean	StdErr
	rmatnames = "nSim", "Unit", "nHHLDs", "nIndividuals", "Mean"
	senames = "StdErr"
	nfgts = cols(fgtlist)
	if (nfgts>0) {
		for (l=1; l<=npovlines; l++) {
			for (ind=1; ind<=nfgts; ind++) {							
				plname = (plreal==1 ? strtoname(strofreal(pl[l])) : "_" + pl[l])
				rmatnames = rmatnames, "avg_" + fgtlist[ind] + plname
				senames = senames, "se_" + fgtlist[ind] + plname
			}
		}
	}
	//nges = cols(gelist)
	nges = 0
	if (nges>0) {
		for (ind=1; ind<=nges; ind++) {
			rmatnames = rmatnames, "avg_" + gelist[ind]
			senames = senames, "se_" + gelist[ind]
		}
	}
	rmatnames = rmatnames, senames

	if (npovlines>0 & nfgts>0 & plreal==0) {
		plvalue = J(1,npovlines, NULL)
		for (l=1; l<=npovlines; l++) plvalue[l] = &(_fgetcoldata(_fvarindex(pl[l], varname), in, p0, p1-p0))		
	}
	fseek(in, p2, -1)
	block = J(1, 5 + nfgts*npovlines + nges,.)
	printf("{txt}\nComputing indicators for {res}%g{txt} simulation(s).\n", size[4])
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
		"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
		"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	for (sim=1; sim<=size[4]; sim++) {		
		block0 = J(1,5,.)
		y0 = fgetmatrix(in)
		wt = wt0
		if (colmissing(y0)>0) {
			_editmissing(y0, 0)	
			index = selectindex(rowmissing(y0))
			wt[index,.] = J(rows(index),1,0)	
		}
		index = NULL
		wy = wt:*y0
		running = quadrunningsum(wt,0), quadrunningsum(wy,0)	
		//minmaxy = minmax(y) 
		for (j=1; j<=nagg; j++) { //no mean
			if (nrow[j] >=2) {
				A = running[(*info[j])[1,2],.] \ running[(*info[j])[(2::nrow[j]),2],.] - running[(*info[j])[(1::nrow[j]-1),2],.]
				block0 = block0 \ J(nrow[j],1,sim), *areaid[j], *nhh[j], A[.,1]           , J(rows(A),1,0)
			}
			else block0 = block0 \ sim            , 0         ,  nHHLDs, running[nHHLDs,1], 0
		}
		A = NULL
		block0 = block0[2..rows(block0),.]
		if (nfgts>0) {
			for (l=1; l<=npovlines; l++) {
				for (ind=1; ind<=nfgts; ind++) {
					fgtx = J(1,1,.)
					for (j=1; j<=nagg; j++) {
						y = y0 + _fdataexpand(*data[j,l], *info[j], *areaid[j])
						if (plreal==1) {
							wt_p = (y:<= pl[l]):*wt
							rgap = 1:-(y:/ pl[l])
						}
						else {
							wt_p = (y:<= *plvalue[l]):*wt
							rgap = 1:-(y:/ *plvalue[l])				
						}
						if (fgtlist[ind]=="fgt0") currfgt = running[.,1], quadrunningsum(wt_p,0)
						if (fgtlist[ind]=="fgt1") currfgt = running[.,1], quadrunningsum(wt_p:*rgap,0)
						if (fgtlist[ind]=="fgt2") currfgt = running[.,1], quadrunningsum(wt_p:*rgap:*rgap,0)
						
						if (nrow[j] >=2) {
							A = currfgt[(*info[j])[1,2],.] \ currfgt[(*info[j])[(2::nrow[j]),2],.] - currfgt[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx  \ A[.,2]           :/ A[.,1]
						}
						else fgtx = fgtx \ currfgt[nHHLDs,2]:/ currfgt[nHHLDs,1]
					}
					block0 = block0, fgtx[2..rows(fgtx),1]
					A = fgtx = currfgt = NULL
				} //ind
			} //plines
		} //nfgt	
			
		if (nges>0) {
			lny = ln(y)
			wlny = wt:*lny
			for (ind=1; ind<=nges; ind++) {
				if (gelist[ind]=="ge0") current = running, quadrunningsum(wlny,0)
				if (gelist[ind]=="ge1") current = running, quadrunningsum(wy:*lny,0)
				if (gelist[ind]=="ge2") current = running, quadrunningsum(wy:*y,0)	
				fgtx = J(1,1,.)
				if (gelist[ind]=="ge0") {
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = current[(*info[j])[1,2],.] \ current[(*info[j])[(2::nrow[j]),2],.] - current[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx  \ -(A[.,3]:/A[.,1])                       :+ ln(A[.,2]:/A[.,1])
						}
						else fgtx = fgtx \ -(current[nHHLDs,3]:/current[nHHLDs,1]) :+ ln(current[nHHLDs,2]:/current[nHHLDs,1])
					}
				}
				if (gelist[ind]=="ge1") {
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = current[(*info[j])[1,2],.] \ current[(*info[j])[(2::nrow[j]),2],.] - current[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx \ (A[.,3]:/A[.,2])                       :- ln(A[.,2]:/A[.,1])
						}
						else fgtx = fgtx \ (current[nHHLDs,3]:/current[nHHLDs,2]) :- ln(current[nHHLDs,2]:/current[nHHLDs,1])
					}
				}
				if (gelist[ind]=="ge2") {
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = current[(*info[j])[1,2],.] \ current[(*info[j])[(2::nrow[j]),2],.] - current[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx \ 0.5*((((A[.,2]           :/A[.,1])           :^-2):*(A[.,3]:/A[.,1])):-1)
						}
						else fgtx = fgtx \ 0.5*((((current[nHHLDs,2]:/current[nHHLDs,1]):^-2):*(current[nHHLDs,3]:/current[nHHLDs,1])):-1)
					}
				}
				block0 = block0, fgtx[2..rows(fgtx),1]
				A = fgtx = current = NULL	
			} //ind
		} //nges
		//add blocks
		block = block \ block0
		printf(".")
		if (mod(sim,50)==0) printf(" %5.0f\n",sim)
		displayflush()
	} //sim
	block0 = y = y0 =  wt0 = wt = area = wy = running = wt_p = rgap = plvalue = lny = wlny = info = areaid = nhh = NULL
	fclose(in)
	block = block[2..rows(block),.]
	_sort(block, (2,1))

	info = panelsetup(block,2)
	rinfo = rows(info)
	outsim = J(1, 4+(cols(block)-4)*2, .)
	for (i=1; i<=rinfo; i++) {
		rr  = info[i,1],5 \ info[i,2],.
		out = quadmeanvariance(block[|rr|])
		outsim = outsim \ info[i,2]-info[i,1]+1, block[info[i,1],2::4], out[1,.], sqrt(diagonal(out[2..rows(out),.])')
	}
	out = block = NULL
	outsim = outsim[2..rows(outsim),.]
	stata("clear")	
	(void) st_addvar("double", rmatnames)	
	st_addobs(rows(outsim))
	st_store(.,.,outsim)
	outsim = NULL
}

// function to process indicators for ydump, save output to dta
void _s2sc_inds(string scalar ydump, string scalar plines, string scalar aggids, string scalar areavar, string scalar wgtvar) {
	//agglist = strtoreal(tokens(st_local("aggids")))
	agglist = strtoreal(tokens(aggids))	
	fgtlist = tokens(st_local("fgtlist"))
	gelist  = tokens(st_local("gelist"))
	pl      = strtoreal(tokens(plines))
	plreal = 1
	if (missing(pl)>0) {
		pl = tokens(plines)	
		plreal = 0
	}

	in = fopen(ydump, "r" )	
	size = fgetmatrix(in)
	varname = fgetmatrix(in)
	p0 = ftell(in)
	id = fgetmatrix(in)
	p1 = ftell(in)
	id = NULL	
	area = _fgetcoldata(_fvarindex(areavar, varname), in, p0, p1-p0)	
	wt0  = _fgetcoldata(_fvarindex(wgtvar, varname), in, p0, p1-p0)
	p2 = 2*(p1-p0)+p1
	nHHLDs = rows(wt0)
	nagg = cols(agglist)
	npovlines = cols(pl)
	info = areaid = nhh = J(1, nagg, NULL)

	nrow = J(1, nagg, .)
	for (j=1; j<=nagg; j++) {
		idfake    = trunc(area/10^agglist[j])
		info[j]   = &(panelsetup(idfake, 1))
		areaid[j] = &(idfake[(*info[j])[(1::rows(*info[j])),2],.])
		nhh[j]    = &((*info[j])[.,2] - (*info[j])[.,1] :+ 1)
		nrow[j]   = rows(*info[j])
	}
	idfake = NULL

	//Unit	nHHLDs	nDroppedHHLD	nIndividuals	YTrimed	nSim	Min_Y	Max_Y	Mean	StdErr
	rmatnames = "nSim", "Unit", "nHHLDs", "nIndividuals", "Mean"
	senames = "StdErr"
	nfgts = cols(fgtlist)
	if (nfgts>0) {
		for (l=1; l<=npovlines; l++) {
			for (ind=1; ind<=nfgts; ind++) {				
				plname = (plreal==1 ? strtoname(strofreal(pl[l])) : "_" + pl[l])
				rmatnames = rmatnames, "avg_" + fgtlist[ind] + plname
				senames = senames, "se_" + fgtlist[ind] + plname
			}
		}
	}
	nges = cols(gelist)
	if (nges>0) {
		for (ind=1; ind<=nges; ind++) {
			rmatnames = rmatnames, "avg_" + gelist[ind]
			senames = senames, "se_" + gelist[ind]
		}
	}
	rmatnames = rmatnames, senames

	if (npovlines>0 & nfgts>0 & plreal==0) {
		plvalue = J(1,npovlines, NULL)
		for (l=1; l<=npovlines; l++) plvalue[l] = &(_fgetcoldata(_fvarindex(pl[l], varname), in, p0, p1-p0))		
	}
	fseek(in, p2, -1)
	block = J(1, 5 + nfgts*npovlines + nges,.)
	printf("{txt}\nComputing indicators for {res}%g{txt} simulation(s).\n", size[4])
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
		"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
		"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	for (sim=1; sim<=size[4]; sim++) {		
		block0 = J(1,5,.)
		y = fgetmatrix(in)
		wt = wt0
		if (colmissing(y)>0) {
			index = selectindex(rowmissing(y0))
			wt[index,.] = J(rows(index),1,0)	
			_editmissing(y, 0)
		}
		index = NULL
		wy = wt:*y
		running = quadrunningsum(wt,0), quadrunningsum(wy,0)	
		//minmaxy = minmax(y)
		for (j=1; j<=nagg; j++) {
			if (nrow[j] >=2) {
				A = running[(*info[j])[1,2],.] \ running[(*info[j])[(2::nrow[j]),2],.] - running[(*info[j])[(1::nrow[j]-1),2],.]
				block0 = block0 \ J(nrow[j],1,sim), *areaid[j], *nhh[j], A[.,1]           , A[.,2]:/A[.,1]
			}
			else block0 = block0 \ sim            , 0         ,  nHHLDs, running[nHHLDs,1], running[nHHLDs,2]/running[nHHLDs,1]
		}
		A = NULL
		block0 = block0[2..rows(block0),.]
		if (nfgts>0) {
			for (l=1; l<=npovlines; l++) {
				if (plreal==1) {
					wt_p = (y:<= pl[l]):*wt
					rgap = 1:-(y:/ pl[l])
				}
				else {
					wt_p = (y:<= *plvalue[l]):*wt
					rgap = 1:-(y:/ *plvalue[l])				
				}
				for (ind=1; ind<=nfgts; ind++) {
					if (fgtlist[ind]=="fgt0") currfgt = running[.,1], quadrunningsum(wt_p,0)
					if (fgtlist[ind]=="fgt1") currfgt = running[.,1], quadrunningsum(wt_p:*rgap,0)
					if (fgtlist[ind]=="fgt2") currfgt = running[.,1], quadrunningsum(wt_p:*rgap:*rgap,0)
					fgtx = J(1,1,.)
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = currfgt[(*info[j])[1,2],.] \ currfgt[(*info[j])[(2::nrow[j]),2],.] - currfgt[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx  \ A[.,2]           :/ A[.,1]
						}
						else fgtx = fgtx \ currfgt[nHHLDs,2]:/ currfgt[nHHLDs,1]
					}
					block0 = block0, fgtx[2..rows(fgtx),1]
					A = fgtx = currfgt = NULL
				} //ind
			} //plines
		} //nfgt	
			
		if (nges>0) {
			lny = ln(y)
			wlny = wt:*lny
			for (ind=1; ind<=nges; ind++) {
				if (gelist[ind]=="ge0") current = running, quadrunningsum(wlny,0)
				if (gelist[ind]=="ge1") current = running, quadrunningsum(wy:*lny,0)
				if (gelist[ind]=="ge2") current = running, quadrunningsum(wy:*y,0)	
				fgtx = J(1,1,.)
				if (gelist[ind]=="ge0") {
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = current[(*info[j])[1,2],.] \ current[(*info[j])[(2::nrow[j]),2],.] - current[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx  \ -(A[.,3]:/A[.,1])                       :+ ln(A[.,2]:/A[.,1])
						}
						else fgtx = fgtx \ -(current[nHHLDs,3]:/current[nHHLDs,1]) :+ ln(current[nHHLDs,2]:/current[nHHLDs,1])
					}
				}
				if (gelist[ind]=="ge1") {
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = current[(*info[j])[1,2],.] \ current[(*info[j])[(2::nrow[j]),2],.] - current[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx \ (A[.,3]:/A[.,2])                       :- ln(A[.,2]:/A[.,1])
						}
						else fgtx = fgtx \ (current[nHHLDs,3]:/current[nHHLDs,2]) :- ln(current[nHHLDs,2]:/current[nHHLDs,1])
					}
				}
				if (gelist[ind]=="ge2") {
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = current[(*info[j])[1,2],.] \ current[(*info[j])[(2::nrow[j]),2],.] - current[(*info[j])[(1::nrow[j]-1),2],.]
							fgtx = fgtx \ 0.5*((((A[.,2]           :/A[.,1])           :^-2):*(A[.,3]:/A[.,1])):-1)
						}
						else fgtx = fgtx \ 0.5*((((current[nHHLDs,2]:/current[nHHLDs,1]):^-2):*(current[nHHLDs,3]:/current[nHHLDs,1])):-1)
					}
				}
				block0 = block0, fgtx[2..rows(fgtx),1]
				A = fgtx = current = NULL	
			} //ind
		} //nges
		//add blocks
		block = block \ block0
		printf(".")
		if (mod(sim,50)==0) printf(" %5.0f\n",sim)
		displayflush()
	} //sim
	block0 = y = wt0 = wt = area = wy = running = wt_p = rgap = plvalue = lny = wlny = info = areaid = nhh = NULL
	fclose(in)
	block = block[2..rows(block),.]
	_sort(block, (2,1))

	info = panelsetup(block,2)
	rinfo = rows(info)
	outsim = J(1, 4+(cols(block)-4)*2, .)
	for (i=1; i<=rinfo; i++) {
		rr  = info[i,1],5 \ info[i,2],.
		out = quadmeanvariance(block[|rr|])
		outsim = outsim \ info[i,2]-info[i,1]+1, block[info[i,1],2::4], out[1,.], sqrt(diagonal(out[2..rows(out),.])')
	}
	out = block = NULL
	outsim = outsim[2..rows(outsim),.]
	stata("clear")	
	(void) st_addvar("double", rmatnames)	
	st_addobs(rows(outsim))
	st_store(.,.,outsim)
	outsim = NULL
}

// need to add different options for weights
// function to process tabulations for ydump, save output to dta
void _s2sc_stats(string scalar ydump, string scalar plines, string scalar aggids, string scalar areavar, string scalar wgtvar) {
	agglist = strtoreal(tokens(aggids))	
	indlist = tokens(st_local("indicators"))
	addvars = tokens(st_local("catvar"))
	naddvar = cols(addvars)
	convars = tokens(st_local("contvar"))
	nconvar = cols(convars)
	pl      = strtoreal(tokens(plines))
	plreal  = 1
	if (missing(pl)>0) {
		pl = tokens(plines)	
		plreal = 0
	}
	
	in = fopen(ydump, "r")
	size = fgetmatrix(in)
	varname = fgetmatrix(in)
	p0 = ftell(in)
	id = fgetmatrix(in)
	p1 = ftell(in)
	id = NULL
	area = _fgetcoldata(_fvarindex(areavar, varname), in, p0, p1-p0)	
	wt0  = _fgetcoldata(_fvarindex(wgtvar, varname), in, p0, p1-p0)
	p2 = 2*(p1-p0)+p1	
	nobs = rows(wt0)	
	nagg = cols(agglist)
	npovlines = cols(pl)
		
	info = areaid = J(1, nagg, NULL)
	nrow = J(1, nagg, .)
	for (j=1; j<=nagg; j++) {
		idfake    = trunc(area/10^agglist[j])
		info[j]   = &(panelsetup(idfake, 1))
		areaid[j] = &(idfake[(*info[j])[(1::rows(*info[j])),2],.])
		nrow[j] = rows(*info[j])
	}
	idfake = NULL
	ffgtall = J(quadsum(nrow)+1,1,.)
	
	ncells = 0	
	rmatnames = "nSim", "Unit", "Povline"
	senames = "se"
	if (naddvar > 0) {
		addlvl = add = J(1, naddvar, NULL)
		for (v=1; v<=naddvar; v++) {
			add[.,v] = &(_fgetcoldata(_fvarindex(addvars[v], varname), in, p0, p1-p0))
			addlvl[v] = &(_fintlevelsof(*add[.,v]))
			ncells = ncells + rows(*addlvl[v])
			for (cat=1; cat<=rows(*addlvl[v]); cat++) {
				for (c=0; c<=1; c++) {					
					rmatnames = rmatnames, "avg_poor_" + strofreal(c) + "_" + addvars[v] + "_" + strofreal(cat) + "_" + "r"
					senames   = senames, "se_poor_" + strofreal(c) + "_" + addvars[v] + "_" + strofreal(cat) + "_" + "r"
				}
			}
		}	
	}	
	if (nconvar > 0) {
		cont = J(1, nconvar, NULL)
		for (v=1; v<=nconvar; v++) {
			ncells = ncells + 1
			cont[.,v] = &(_fgetcoldata(_fvarindex(convars[v], varname), in, p0, p1-p0))
			for (c=0; c<=1; c++) {				
				rmatnames = rmatnames, "avg_poor_" + strofreal(c) + "_" + convars[v]
				senames = senames, "se_poor_" + strofreal(c) + "_" + convars[v]
			}
		}
	}
	rmatnames = rmatnames, senames[2..cols(senames)]
	if (npovlines>0 & plreal==0) {
		plvalue = J(1,npovlines, NULL)
		for (l=1; l<=npovlines; l++) plvalue[l] = &(_fgetcoldata(_fvarindex(pl[l], varname), in, p0, p1-p0))
	}
	
	printf("{txt}\nComputing statistics for {res}%g{txt} simulation(s).\n", size[4])
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
		"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
		"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	
	fseek(in, p2, -1)
	fcell = J(1,3+2*ncells,.)
	for (sim=1; sim<=size[4]; sim++) {
		y = fgetmatrix(in)	
		wt = wt0
		if (colmissing(y)>0) {
			index = selectindex(rowmissing(y0))
			wt[index,.] = J(rows(index),1,0)	
			_editmissing(y, 0)
		}
		index = NULL
		//wt_running = quadrunningsum(wt,0)	
		block0 = J(1,3,.)
		for (l=1; l<=npovlines; l++) {
			if (plreal==1) plv = pl[l]
			else           plv = l
			for (j=1; j<=nagg; j++) {
				if (nrow[j] >=2) block0 = block0 \ (J(nrow[j],1,sim), *areaid[j], J(nrow[j],1, plv))
				else             block0 = block0 \ (sim             ,          0, plv)
			}
		}
		block0 = block0[2::rows(block0),.]
		
		if (naddvar > 0) {
			fcell1 = J(quadsum(nrow)*npovlines,1,.)	
			for (v=1; v<=naddvar; v++) {
				lvl    = rows(*addlvl[v])
				cumwt  = J(3, lvl, NULL)
				cum    = J(1, 2, NULL)
				fcell0 = J(1, 2*lvl, .)			
					
				for (l=1; l<=npovlines; l++) {
					cum[1] = &(J(nobs, 1, 0))
					cum[2] = &(J(nobs, 1, 0))
					if (plreal==1) dummy = y:<= pl[l]				
					else           dummy = y:<= *plvalue[l]				
					for (cat=1; cat<=lvl; cat++) {
						cumwt[1,cat] = &(quadrunningsum(wt:* (dummy:==0) :* (*add[.,v]:==(*addlvl[v])[cat]),0))
						cumwt[2,cat] = &(quadrunningsum(wt:* (dummy:==1) :* (*add[.,v]:==(*addlvl[v])[cat]),0))
						cumwt[3,cat] = &(*cumwt[1,cat] :+ *cumwt[2,cat])
						cum[1] = &(*cum[1] :+ *cumwt[1,cat])
						cum[2] = &(*cum[2] :+ *cumwt[2,cat])
					}
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							rowcell = J(nrow[j],1,.)
							for (cat=1; cat<=lvl; cat++) {
								for (c=1; c<=2; c++) {
									cell = (*cumwt[c,cat])[(*info[j])[1,2],.] \ (*cumwt[c,cat])[(*info[j])[(2::nrow[j]),2],.] - (*cumwt[c,cat])[(*info[j])[(1::nrow[j]-1),2],.]
									rtot =       (*cum[c])[(*info[j])[1,2],.] \       (*cum[c])[(*info[j])[(2::nrow[j]),2],.] -       (*cum[c])[(*info[j])[(1::nrow[j]-1),2],.]
									rowcell = rowcell, (cell:/rtot)	
								}
							}					
							fcell0 = fcell0 \ rowcell[.,2::cols(rowcell)]
						}
						else {
							r0cell = J(1,1,.)
							for (cat=1; cat<=lvl; cat++) {
								for (c=1; c<=2; c++) r0cell = r0cell, (*cumwt[c,cat])[nobs,.] :/ (*cum[c])[nobs,.]												
							}					
							fcell0 = fcell0 \ r0cell[.,2::cols(r0cell)]						
						}
					} //nagg				
				} //npovlines
				fcell1 = fcell1, fcell0[2::rows(fcell0),.]
				fcell0 = NULL
			} //addvars		
			fcell1 = fcell1[.,2::cols(fcell1)]	
			cum = cumwt = dummy = NULL
		} //if naddvar
		
		if (nconvar > 0) {
			fgtcont = J(quadsum(nrow)*npovlines,1,.)
			for (v=1; v<=nconvar; v++) {
				fgtx = J(1,2,.)
				for (l=1; l<=npovlines; l++) {
					if (plreal==1) dummy = y:<= pl[l]				
					else           dummy = y:<= *plvalue[l]	
					curr1 = quadrunningsum(wt:* (dummy:==1) ,0), quadrunningsum(wt:* *cont[.,v] :* (dummy:==1) ,0)
					curr0 = quadrunningsum(wt:* (dummy:==0) ,0), quadrunningsum(wt:* *cont[.,v] :* (dummy:==0) ,0)					
					for (j=1; j<=nagg; j++) {
						if (nrow[j] >=2) {
							A = curr0[(*info[j])[1,2],.] \ curr0[(*info[j])[(2::nrow[j]),2],.] - curr0[(*info[j])[(1::nrow[j]-1),2],.]
							B = curr1[(*info[j])[1,2],.] \ curr1[(*info[j])[(2::nrow[j]),2],.] - curr1[(*info[j])[(1::nrow[j]-1),2],.]							
							fgtx = fgtx  \ (A[.,2] :/ A[.,1], B[.,2] :/ B[.,1])
						}
						else fgtx = fgtx \ (curr0[nobs,2]:/ curr0[nobs,1], curr1[nobs,2]:/ curr1[nobs,1])						
					} //nagg
					A = B = NULL
				} //povlines
				fgtcont = fgtcont, fgtx[2::rows(fgtx),.]
			} //nconvar
			fgtcont = fgtcont[.,2::cols(fgtcont)]
			curr1 = curr0 = dummy = fgtx = NULL
		} //if nconvar
		
		if (naddvar > 0 & nconvar > 0) fcell = fcell \ (block0, fcell1, fgtcont)
		if (naddvar > 0 & nconvar ==0) fcell = fcell \ (block0, fcell1)
		if (naddvar ==0 & nconvar > 0) fcell = fcell \ (block0, fgtcont)
		fcell1 = fgtcont = block0 = NULL
		printf(".")
		if (mod(sim,50)==0) printf(" %5.0f\n",sim)
		displayflush()
	} //sim
	block0 = y = wt0 = wt = area = wy = dummy = plvalue = info = areaid = addlvl = add = cont=  NULL
	fclose(in)
	fcell = fcell[2::rows(fcell),.]
	_sort(fcell, (3,2,1))
	
	info = panelsetup(strofreal(fcell[.,2])+strofreal(fcell[.,3]),1)
	rinfo = rows(info)
	outsim = J(1, 3+(cols(fcell)-3)*2, .)
	for (i=1; i<=rinfo; i++) {
		rr  = info[i,1],4 \ info[i,2],.
		out = quadmeanvariance(fcell[|rr|])
		outsim = outsim \ info[i,2]-info[i,1]+1, fcell[info[i,1],2::3], out[1,.], sqrt(diagonal(out[2..rows(out),.])')
	}
	out = fcell = NULL
	outsim = outsim[2..rows(outsim),.]
	stata("clear")	
	(void) st_addvar("double", rmatnames)	
	st_addobs(rows(outsim))
	st_store(.,.,outsim)
	outsim = NULL
}

//Generalized entropy index GE(0)=MLD, GE(1)= Theil
function _fGE(y, w, alpha) {
	if      (alpha==0) return(-quadcolsum(w:*ln(y:/mean(y,w))):/quadcolsum(w))	
	else if (alpha==1) return(mean((ln(y:/mean(y,w)):*(y:/mean(y,w))),w))
	else               return((1/(alpha*(alpha-1))):*(quadcolsum(w:*(((y:/mean(y,w)):^alpha):-1)):/quadcolsum(w))) 	
}

function theil(y,w){
	one=ln(y:/mean(y,w))
	two=one:*(y:/mean(y,w))
	return(mean(two,w))
}

//Gini coefficient (fastgini formula) x and w are vectors
function _fGini(x, w) {
	t = x,w
	_sort(t,1)
	x=t[.,1]
	w=t[.,2]
	xw = x:*w
	rxw = quadrunningsum(xw) :- (xw:/2)
	return(1- 2*((quadcross(rxw,w)/quadcross(x,w))/quadcolsum(w)))
}

//Gini coefficient (fastgini formula) x and w are vectors
function _fGininew(x, w) {
	t = x,w
	_collate(t,1)	
	xw = t[.,1]:*t[.,2]
	rxw = quadrunningsum(t[.,1]:*t[.,2]) :- ((t[.,1]:*t[.,2]):/2)
	return(1- 2*((quadcross(rxw,t[.,2])/quadcross(t[.,1],t[.,2]))/quadcolsum(t[.,2])))
}


//Gini coefficient (fastgini formula) x is MATRIX, w is vector
function _fGinis(x, w) {
	out = J(1,0,.)
	ncols = cols(x)
	for(i=1;i<=ncols;i++) out = out, _fGini(x[.,i], w)
	return(out)
}

// function to return 1 if matrix is between z0, z1
function _franges(inc, z0, z1) {
	if (allof(z0,0)==1) {         
		return(inc:< z1)
	}
	else {
		a = z0 :<= inc
		b = inc:< z1
		c = a:+b
		return(c:==2)
	}       
}

//FGT functions
function _fFGT(inc, z1, wt, alpha) {
	return(mean(((inc:<z1):*(((z1:-inc):/z1):^alpha)),wt))
}
//FGT0 in percentage
function _fFGT0(inc, z0, z1, wt) {      
	return(100*mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^0),wt))
}
//FGT1 in percentage
function _fFGT1(inc, z0, z1, wt) {                              
	return(100*mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^1),wt))
}
//FGT2 in percentage
function _fFGT2(inc, z0, z1, wt) {              
	return(100*mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^2),wt))
}
//CLK
function _fCLK(inc, z0, z1, wt, alpha) {
	return(mean(_franges(inc, z0, z1):*((1:-((inc:/z1):^alpha)):/alpha), wt))
}
//Watts
function _fWatts(inc, z0, z1, wt) {
	return(mean(_franges(inc, z0, z1):*(ln(z1):-ln(inc)),wt))
}
//Create variable containing percentiles - X is a vector
function _fpctile(real colvector X, real scalar nq, |real colvector w) {
	if (args()==2) w = J(rows(X),1,1)
	if (rows(X) < nq) {
		_error(3200, "Number of bins is more than the number of observations")
		exit(error(3200))       
	}
	data = runningsum(J(rows(X),1,1)), X, w
	_sort(data,(2,1))
	nq0 = quadsum(data[.,3])/nq     
	q = trunc((quadrunningsum(data[.,3]):/nq0):-0.0000000000001):+1 
	data = data, q
	_sort(data,1)
	return(data[.,4])
}
//bottom mean function
function _fbottom(x, w, btm) {
	x1 = x, w, _fpctile(x, 100, w)
	x2 = select(x1, x1[.,cols(x1)]:<=btm)
	return(mean(x2[.,1], x2[.,2]))
}
//top mean function
function _ftop(x, w, top) {
	x1 = x, w, _fpctile(x, 100, w)
	x2 = select(x1, x1[.,cols(x1)]:>=top)
	return(mean(x2[.,1], x2[.,2]))
}
//ratio of bottom mean over all mean
function _fratio(x, w, btm) {
	x1 = x, w, _fpctile(x, 100, w)
	x2 = select(x1, x1[.,cols(x1)]:<=btm)
	return(mean(x2[.,1], x2[.,2])/mean(x,w))
}


//Block processing function
void _s2sc_sim_break(string scalar xvar,
					 string scalar zvars,
					 string scalar yhats, 
					 string scalar yhats2, 
					 string scalar areavar, 
					 string scalar wgt, 
					 string scalar touse,  
					 string scalar hhid) 
{

	sim         = strtoreal(st_local("rep"))
	seed        = strtoreal(st_local("seed"))	
	h3    		= strtoreal(st_local("h3"))
	if          (st_local("nolocation")~="") h3 = 2
	hheff       = strtoreal(st_local("hheffs"))
	boots     	= strtoreal(st_local("boots"))
	etanorm 	= strtoreal(st_local("etanormal"))
	epsnorm 	= strtoreal(st_local("epsnormal"))
	EB    		= strtoreal(st_local("ebest"))
	pline       = strtoreal(st_local("pline"))
	lg			= strtoreal(st_local("lny"))
	ydump       = strtoreal(st_local("ydump1"))
	res			= strtoreal(st_local("results1"))
	fgt0d       = strtoreal(st_local("fgt0"))
	fgt1d       = strtoreal(st_local("fgt1"))
	fgt2d       = strtoreal(st_local("fgt2"))
	mem         = strtoreal(st_local("maxmem"))
	mem         = floor((mem/8/sim))
	external bsim, asim, maxA, varr, sigma, v_sigma, sigma_eps, locerr, hherr, locerr2
			
	//The data
	st_view(x   ,.,tokens(xvar), touse)
	st_view(z1  ,.,tokens(zvars), touse)
	st_view(yh  ,.,tokens(yhats), touse)
	st_view(yh2 ,.,tokens(yhats2), touse)
	st_view(area,.,tokens(areavar), touse)
	st_view(wt,.,tokens(wgt), touse)
	st_view(id  ,.,tokens(hhid), touse)
	if (st_local("cuts")!="")  st_view(cut ,.,tokens(st_local("cuts")),touse)
	if (st_local("addvars")!="")  st_view(add ,.,tokens(st_local("addvars")),touse)
	if (pline==.) st_view(povline,.,tokens(st_local("pline")), touse)
	
	totmem=rows(x)

	if (hheff==1) {
		//zalpha condition
		if ((allof(z1,.)==1) & (allof(yh,.)==1) & (allof(yh2,.)==1)) zcond = "000"  //0,0,0
		if ((allof(z1,.)==1) & (allof(yh,.)==1) & (allof(yh2,.)==0)) zcond = "001"  //0,0,1
		if ((allof(z1,.)==1) & (allof(yh,.)==0) & (allof(yh2,.)==1)) zcond = "010"  //0,1,0
		if ((allof(z1,.)==1) & (allof(yh,.)==0) & (allof(yh2,.)==0)) zcond = "011"  //0,1,1
		if ((allof(z1,.)==0) & (allof(yh,.)==1) & (allof(yh2,.)==1)) zcond = "100"  //1,0,0
		if ((allof(z1,.)==0) & (allof(yh,.)==1) & (allof(yh2,.)==0)) zcond = "101"  //1,0,1
		if ((allof(z1,.)==0) & (allof(yh,.)==0) & (allof(yh2,.)==1)) zcond = "110"  //1,1,0	
		if ((allof(z1,.)==0) & (allof(yh,.)==0) & (allof(yh2,.)==0)) zcond = "111"  //1,1,1
	}	
	
	//sort is done before and setup area panel
	info = panelsetup(area,1)
	
	if((any((info[.,2]-info[.,1]):>mem)))  _error("One of your cluster's memory requirements exceeds the amount of memory you specified, increase maxmem")
		
	infi2 = _fuptohere(mem,info, totmem)
	inf2  = panelsetup(infi2,1) 
	
	//Prepare ydump file
	if (ydump==1) { 
		yd = fopen(st_local("ydump"),"rw")
		//append the weight variable for ydump
		numcol = cols(area) + cols(wt) + cols(id)
		if (st_local("cuts")!="") numcol = numcol + cols(cut)
		if (st_local("addvars")!="") numcol = numcol + cols(add)
		fputmatrix(yd, st_local("ydnames"))
		fputmatrix(yd, numcol)
		fputmatrix(yd, sim)
		fputmatrix(yd, area)
		fputmatrix(yd, wt)	
		fputmatrix(yd, id)
		if (st_local("cuts")!="") fputmatrix(yd, cut)
		if (st_local("addvars")!="") fputmatrix(yd, add)		
	}
	if (res==1) {
		indis = fopen(st_local("results"),"rw")
		unit = J(rows(info),3,.)
		fputmatrix(indis, ("Area Observations Weights"))
		fputmatrix(indis, 3)
		fputmatrix(indis,fgt0d)
		fputmatrix(indis,fgt1d)
		fputmatrix(indis,fgt2d)
	}

	if (fgt0d==1)	fgt0 = J(rows(info),sim,.)		
	if (fgt1d==1)	fgt1 = J(rows(info),sim,.)		
	if (fgt2d==1)	fgt2 = J(rows(info),sim,.)		
	
	if (boots==0) {	
		display("Parametric drawing of betas")
		maggie=0
		for(i=1;i<=rows(inf2);i++) {
			infin = info[|inf2[i,1],.\inf2[i,2],.|]
		
			panelsubview(xi,x,.,infin)
			panelsubview(zi,z1,.,infin)		
			panelsubview(yhi,yh,.,infin)
			panelsubview(yh2i,yh2,.,infin)
			panelsubview(areai,area,.,infin)
			panelsubview(wti,wt,.,infin)
			if (pline==.)   panelsubview(povi,povline,.,infin)
			if (fgt0d==1)   fgt0i = J(rows(infin),sim,.) 
			if (fgt1d==1)   fgt1i = J(rows(infin),sim,.) 
			if (fgt2d==1)   fgt2i = J(rows(infin),sim,.) 
			if (res==1)     uniti = J(rows(infin),3,.)

			lisa = panelsetup(areai,1)
		
			if (i!=1) rseed(lastseed1)
			if ((epsnorm==1) & (hheff==1)) {
				if (zcond == "100") xb = (zi,J(rows(zi),1,1))*asim'
				if (zcond == "110") xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "111") xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "010") xb = (yhi*asim[.,cols(asim)-1]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "011") xb = (yhi*asim[.,1..cols(yhi)]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim')+ J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "001") xb = (yh2i*asim[.,1..cols(yh2i)]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') +  J(rows(yh2i),1,1)*asim[.,cols(asim)]'
				if (zcond == "101") xb = zi*asim[|.,1 \.,cols(zi)|]' + (yh2i*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yh2i),1,1)*asim[.,cols(asim)]'
				xb      =exp(xb)
				xb      = (maxA[1,1]*(xb:/(1:+xb))) + (.5*varr[1,1])*((maxA[1,1]*(xb:*(1:-xb))):/((1:+xb):^3))
				xb      = rnormal(1,1,0,sqrt(xb)) + ((xi,J(rows(xi),1,1))*bsim')
			}
			
			
			if (epsnorm==0)                xb = (xi,J(rows(xi),1,1))*bsim'+ _f_sampleeps(sim, rows(xi), hherr)
			if ((epsnorm==1) & (hheff==0)) xb = (xi,J(rows(xi),1,1))*bsim'+ rnormal(rows(xi),sim,0,sqrt(sigma_eps[1,1]))
						
			//to ensure that when we partition blocks we get the same seeds
			lastseed1=rseed()
			
			if (i!=1) rseed(lastseed2)
			for(j=1;j<=rows(lisa);j++) {
				if (etanorm==1)	xb[|lisa[j,1],. \ lisa[j,2],.|] = xb[|lisa[j,1],. \ lisa[j,2],.|]:+ rnormal(1,1,0,sqrt(locerr'))
				if (etanorm==0) xb[|lisa[j,1],. \ lisa[j,2],.|] = xb[|lisa[j,1],. \ lisa[j,2],.|]:+ _f_sampleeps(sim,1, locerr)
				if ((fgt0d==1) & (lg==1)) 	fgt0i[j,.] = _fFGT(exp(xb[|lisa[j,1],.\lisa[j,2],.|]), povi[|lisa[j,1],1 \ lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],0)
				if ((fgt0d==1) & (lg==0))   fgt0i[j,.] = _fFGT((xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],0)
				if ((fgt1d==1) & (lg==1)) 	fgt1i[j,.] = _fFGT(exp(xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],1)
				if ((fgt1d==1) & (lg==0))   fgt1i[j,.] = _fFGT((xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],1)
				if ((fgt2d==1) & (lg==1)) 	fgt2i[j,.] = _fFGT(exp(xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],2)
				if ((fgt2d==1) & (lg==0))   fgt2i[j,.] = _fFGT((xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],2)
			
				uniti[j,.] = areai[lisa[j,1],1], rows(wti[|lisa[j,1],1\lisa[j,2],1|]), quadsum(wti[|lisa[j,1],1\lisa[j,2],1|])
				maggie=maggie+1
			}

			//Outputs for povmap
			if (ydump==1) fputmatrix(yd, xb)
			if (fgt0d==1) fgt0[|inf2[i,1],. \ inf2[i,2],.|]  = fgt0i
			if (fgt1d==1) fgt1[|inf2[i,1],. \ inf2[i,2],.|]  = fgt1i
			if (fgt2d==1) fgt2[|inf2[i,1],. \ inf2[i,2],.|]  = fgt2i
			if (res==1)   unit[|inf2[i,1],. \ inf2[i,2],.|]  = uniti
		
			//to ensure that when we partition blocks we get the same seeds
			lastseed2=rseed()	
		}
		
		if ((res==1)){
			fputmatrix(indis,(unit))
			if (fgt0d==1){
				fgt0 = quadmeanvariance(fgt0')
				fgt0 = fgt0[1,.]',sqrt(diagonal(fgt0[|2,1 \ .,.|]))
				fputmatrix(indis,fgt0)
			}
			if (fgt1d==1){
				fgt1 = quadmeanvariance(fgt1')
				fgt1 = fgt1[1,.]',sqrt(diagonal(fgt1[|2,1 \ .,.|]))
				fputmatrix(indis,fgt1)
			}	
			if (fgt2d==1){
				fgt2 = quadmeanvariance(fgt2')
				fgt2 = fgt2[1,.]',sqrt(diagonal(fgt2[|2,1 \ .,.|]))
				fputmatrix(indis,fgt2)
			}	
		}
	} //boots==0
	
	if (boots==1) {
		display("Bootstrapped drawing of betas and parameters")
		for(i=1;i<=rows(inf2);i++) {
			infin = info[|inf2[i,1],.\inf2[i,2],.|]
		
			panelsubview(xi,x,.,infin)
			panelsubview(zi,z1,.,infin)		
			panelsubview(yhi,yh,.,infin)
			panelsubview(yh2i,yh2,.,infin)
			panelsubview(areai,area,.,infin)
			panelsubview(wti,wt,.,infin)
			if (pline==.)   panelsubview(povi,povline,.,infin)
			if (fgt0d==1)   fgt0i = J(rows(infin),sim,.) 
			if (fgt1d==1)   fgt1i = J(rows(infin),sim,.) 
			if (fgt2d==1)   fgt2i = J(rows(infin),sim,.) 
			if (res==1)     uniti = J(rows(infin),3,.)
		
		
			lisa = panelsetup(areai,1)
			if (EB==1) {
				cens_area = J(rows(lisa),1,.)
				for(r=1;r<=rows(lisa);r++){
					cens_area[r,1]=areai[lisa[r,1],1]
				}
				D = _ebcensus4(cens_area,locerr,locerr2, lisa)
			}
			
			if (i!=1) rseed(lastseed1)
			
			if ((epsnorm==1) & (hheff==1)) {
				if (zcond == "100") xb = (zi,J(rows(zi),1,1))*asim'
				if (zcond == "110") xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "111") xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "010") xb = (yhi*asim[.,cols(asim)-1]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "011") xb = (yhi*asim[.,1..cols(yhi)]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim')+ J(rows(yhi),1,1)*asim[.,cols(asim)]'
				if (zcond == "001") xb = (yh2i*asim[.,1..cols(yh2i)]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') +  J(rows(yh2i),1,1)*asim[.,cols(asim)]'
				if (zcond == "101") xb = (zi*asim[|.,1 \.,cols(zi)|]')+ (yh2i*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yh2i),1,1)*asim[.,cols(asim)]'
				xb      = exp(xb)
				xb      = (maxA':*(xb:/(1:+xb))) + (.5*varr'):*((maxA':*(xb:*(1:-xb))):/((1:+xb):^3))
				xb      = rnormal(1,1,0,sqrt(xb)) + ((xi,J(rows(xi),1,1))*bsim')
			}
			if (epsnorm==0)                xb = (xi,J(rows(xi),1,1))*bsim'+ _f_sampleeps(sim, rows(xi), hherr)
			if ((epsnorm==1) & (hheff==0)) xb = (xi,J(rows(xi),1,1))*bsim'+ rnormal(rows(xi),1,0,sqrt(sigma_eps)')

			//to ensure that when we partition blocks we get the same seeds
			lastseed1=rseed()
			if (i!=1) rseed(lastseed2)

			//ETA PARTS
			for(j=1;j<=rows(lisa);j++) {
				if ((EB==0) & (etanorm==0)) xb[|lisa[j,1],. \ lisa[j,2],.|] = xb[|lisa[j,1],. \ lisa[j,2],.|]:+_f_sampleeps(sim,1, locerr)
				if ((EB==0) & (etanorm==1)) xb[|lisa[j,1],. \ lisa[j,2],.|] = xb[|lisa[j,1],. \ lisa[j,2],.|]:+rnormal(1,1,0,sqrt(locerr'))
				if (EB==1) {
					dd = rowshape(D[j,.]',sim)
					xb[|lisa[j,1],. \ lisa[j,2],.|] = xb[|lisa[j,1],. \ lisa[j,2],.|]:+rnormal(1,1,dd[.,1]',sqrt(dd[.,2]'))
				}
				
				if ((fgt0d==1) & (lg==1)) 	fgt0i[j,.] = _fFGT(exp(xb[|lisa[j,1],.\lisa[j,2],.|]), povi[|lisa[j,1],1 \ lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],0)
				if ((fgt0d==1) & (lg==0))   fgt0i[j,.] = _fFGT((xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],0)
				if ((fgt1d==1) & (lg==1)) 	fgt1i[j,.] = _fFGT(exp(xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],1)
				if ((fgt1d==1) & (lg==0))   fgt1i[j,.] = _fFGT((xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],1)
				if ((fgt2d==1) & (lg==1)) 	fgt2i[j,.] = _fFGT(exp(xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],2)
				if ((fgt2d==1) & (lg==0))   fgt2i[j,.] = _fFGT((xb[|lisa[j,1],.\lisa[j,2],.|]),povi[|lisa[j,1],1\lisa[j,2],1|],wti[|lisa[j,1],1\lisa[j,2],1|],2)

				uniti[j,.]   = areai[lisa[j,1],1], rows(wti[|lisa[j,1],1\lisa[j,2],1|]), quadsum(wti[|lisa[j,1],1\lisa[j,2],1|])
			}
			
			//Outputs for povmap
			if (ydump==1)   fputmatrix(yd, xb)
			if (fgt0d==1)   fgt0[|inf2[i,1],. \ inf2[i,2],.|]  = fgt0i
			if (fgt1d==1)   fgt1[|inf2[i,1],. \ inf2[i,2],.|]  = fgt1i
			if (fgt2d==1)   fgt2[|inf2[i,1],. \ inf2[i,2],.|]  = fgt2i
			if (res==1)     unit[|inf2[i,1],. \ inf2[i,2],.|]  = uniti
			
			//to ensure that when we partition blocks we get the same seeds
			lastseed2=rseed()	
		}
		if (res==1){
			fputmatrix(indis,(unit))
			if (fgt0d==1){
				fgt0 = quadmeanvariance(fgt0')
				fgt0 = fgt0[1,.]',sqrt(diagonal(fgt0[|2,1 \ .,.|]))
				fputmatrix(indis,fgt0)
			}
			if (fgt1d==1){
				fgt1 = quadmeanvariance(fgt1')
				fgt1 = fgt1[1,.]',sqrt(diagonal(fgt1[|2,1 \ .,.|]))
				fputmatrix(indis,fgt1)
			}	
			if (fgt2d==1){
				fgt2 = quadmeanvariance(fgt2')
				fgt2 = fgt2[1,.]',sqrt(diagonal(fgt2[|2,1 \ .,.|]))
				fputmatrix(indis,fgt2)
			}	
		}
	} //boots==1
	if (ydump==1) fclose(yd)	
	if (res==1) fclose(indis)
	st_local("marge", strofreal(rows(info)))
}

//Function to select cell numbers
function  _fuptohere(mem, info, totmem) {
	wiggins = ceil(totmem/mem)
	krusty = select((info[.,2]:<=mem),(info[.,2]:<=mem))
	for(i=2;i<=wiggins;i++) {
		krusty = krusty\(select((info[|(rows(krusty)+1),2\rows(info),2|]:<=(mem*i)),(info[|(rows(krusty)+1),2\rows(info),2|]:<=(mem*i))):*i)
	}
	return(krusty)	
}

//Process indicators
function _f_inds() {
	res    = fopen(st_local("results"), "r")
	names  = fgetmatrix(res)
	numcol = fgetmatrix(res)
	f0     = fgetmatrix(res)
	f1     = fgetmatrix(res)
	f2     = fgetmatrix(res)
	yhat   = fgetmatrix(res)
	
	if (f0==1) yhat=yhat,fgetmatrix(res)
	if (f1==1) yhat=yhat,fgetmatrix(res)
	if (f2==1) yhat=yhat,fgetmatrix(res)
	
	fclose(res)
	return(yhat)
}

//stepwise vif function based on a threshold, remove one var at at time, return index
function _f_stepvif(string scalar xvar, string scalar wvar, real scalar threshold, string scalar touse) {
	varname = tokens(xvar)	
	x0     = st_data(.,tokens(xvar), touse)
	wt     = st_data(.,tokens(wvar), touse)
	vif    = _f_vif_mata(x0, wt)
	matind = selectindex(vif:<max(vif))'

	if (max(vif) <= threshold) {				
		st_local("vifvar", invtokens(varname[matind]))
		return(matind)
	}
	else {	
		while (max(vif) > threshold) {
			vif    = _f_vif_mata(x0[., matind], wt)
			matind = matind[selectindex(vif :< max(vif))']
		}				
		st_local("vifvar", invtokens(varname[matind]))
		return(matind)
	}
}

//simple remove index function (i<=n)
function _f_rmindex(real scalar i, real scalar n) {
	if (i==1) return(2..n)
	else if (i==n) return(1..n-1)
	else {
		if (i>n | i<0 | n<0) {
			errprintf("Wrong input; must be i<=n and both i and n are positive\n")
			_error(3499)
		}
		else return(1..i-1,i+1..n)
	}
}

//function to select variables based on the VIF information with intercept, x0 does not contain constant, return vif
function _f_vif_mata(real matrix x0, real matrix wt) {
	nobs   = rows(x0) 
	x0     = x0, J(nobs,1,1)
	ncolx  = cols(x0)
	ncolx1 = ncolx-1
	xpx0   = quadcross(x0,wt,x0)
	vif    = J(ncolx1,1,.)
	
	for (i=1; i<=ncolx1; i++) {
		ind = _f_rmindex(i,ncolx)
		y = x0[.,i]
		x = x0[.,ind]
		res   = y - quadcross(x',quadcross(invsym(xpx0[ind, ind])', quadcross(x,wt,y)))		
		R2    = 1 - quadcross(res,wt,res)/quadcrossdev(y, mean(y,wt), wt, y, mean(y,wt))	//R2
		aR2   = 1 - ((nobs - 1)/(nobs - ncolx))*(1-R2)  //Adjusted R2
		vif[i] = 1/(1-aR2)
	}
	return(vif)	
}

//BOOTSTRAP new bs
function _f_bootstrap_estbs(string scalar yvar,
							string scalar xvar,
							string scalar zvar,
							string scalar yhat, 
							string scalar yhat2, 
							string scalar sae1, 
							string scalar wgt,
							real scalar sim, 
							real scalar seed, 
							real scalar henderson, 
							real scalar vceopt,
							real scalar EB,
							real matrix psu,
							string scalar touse,
							string scalar cmdline1,
							string scalar cmdline2,
							string scalar cmdline3) {
	pointer(pointer(real matrix) rowvector) colvector bsout
	bsout = J(sim,1,NULL)
	for(s=1;s<=sim;s++) {
		stata(cmdline1) 
		stata(cmdline2)
		stata(cmdline3)
		
		area1 = st_data(.,tokens(sae1),  touse)
		y1    = st_data(.,tokens(yvar),  touse) 
		x1    = st_data(.,tokens(xvar),  touse),J(rows(y1),1,1)
		z1    = st_data(.,tokens(zvar),  touse)
		yhx   = st_data(.,tokens(yhat),  touse)
		yhx2  = st_data(.,tokens(yhat2), touse)
		wt1   = st_data(.,tokens(wgt),   touse)
		
		info = panelsetup(area1,1)	
		est   = _f_s2sc_estall_eb(y1, x1, z1, yhx, yhx2, wt1, area1, info, sim, seed, henderson, vceopt, EB,1, touse)	
		//if (*est[3,1]<0) *est[3,1] = 0
		c = 1		
		if (*est[3,1]<0) {
			if (c<=100) {
				s = s - 1		
				c = c + 1
			}
			else _error("Please try a different PSU or select a different seed number.")
		}
		else bsout[s] = f_pointer_clone(est)
	}
	return(bsout)
}

//Gets unique observations
function _getuniq(string scalar areas){
	st_view(c_ar = ., .,tokens(areas))
	info = panelsetup(c_ar,1)
	return(c_ar[info[.,1]])
}

//Adds ETA to the simulations...
function _addetaEB(etamat,info, xb){
		for(j=1; j<=rows(info); j++) {
			m2 = info[j,1],. \ info[j,2],.
			xb[|m2|] = xb[|m2|] :+ etamat[j]		 
		}
		
		return(xb)
}

//Function does inverse EB for Molina BS... locations is Sx1 mat with location 
// codes in survey, loceta is DX2 location codes and eta values from Census
function _invEB(real matrix locations, real matrix loceta){
	_mloc = rows(locations)
	_meta = rows(loceta)
	k = 0
	for(i=1; i<=_mloc; i++){
		for(j=1; j<=_meta; j++){
			if (k==0){
				if (loceta[j,1]==locations[i]){
					_toSvy = locations[i],loceta[j,2]
					k=1
				}				
			}
			else{
				if (loceta[j,1]==locations[i]) _toSvy = _toSvy\(locations[i],loceta[j,2])
			}
		}
		
	}
	return(_toSvy)
}

//Does the new simulation for efficient MSE estimation
void _s2sc_sim_molina(string scalar xvar, 
					 string scalar zvars, 
					 string scalar yhats, 
					 string scalar yhats2, 
					 string scalar areavar, 
					 string scalar plvar, 
					 string scalar wgt, 
					 string scalar touse, 
					 string scalar hhid, 
					 string scalar matin,
					 real matrix bsim,
					 real matrix asim,
					 real matrix locerr,
					 real matrix loc,
					 real matrix loc2,
					 real matrix maxA,
					 real matrix varr, 
					 real matrix sigma_eps,
					 real scalar varU)
{


	sim         = strtoreal(st_local("rep"))
	seed        = strtoreal(st_local("seed"))	
	hheff       = strtoreal(st_local("hheffs"))
	doone       = strtoreal(st_local("doone"))
	
	boots       = 0
	count       = 1

	etanorm 	= strtoreal(st_local("etanormal"))
	epsnorm 	= strtoreal(st_local("epsnormal"))
	EB    		= strtoreal(st_local("ebest"))	
	lg			= strtoreal(st_local("lny"))
	bcox        = strtoreal(st_local("bcox"))		     //Box Cox conversion
	LAMBDA      = strtoreal(st_local("lambda"))			//Lambda for boxcox
	varinmod	= tokens(st_local("varinmodel"))	
	//pointer(real matrix) rowvector agginfo	
	indlist     = tokens(st_local("indicators"))	
	
	//pline       = strtoreal(st_local("pline"))	
	yesmata = strtoreal(st_local("matay"))
	agglist = strtoreal(tokens(st_local("aggids")))
	fgtlist = tokens(st_local("fgtlist"))
	gelist  = tokens(st_local("gelist"))
	pl      = strtoreal(tokens(plvar))
	plreal = 1
	if (missing(pl)>0) {
		pl = tokens(plvar)	
		plreal = 0
	}
	
	colsbsim = cols(bsim)
	colsasim = cols(asim)	
	if ((EB==1) & ((etanorm==0)|(epsnorm==0))){
		etanorm=1
		epsnorm=1
	}
	
	//WARNING: area must be sorted outside in Stata
	//census data - or use other way, ie seek(fh, (N*8+77)*6 ,-1) to get the 7th column
	fhcensus = fopen(matin, "r")
	varlist = fgetmatrix(fhcensus)	
	p0 = ftell(fhcensus)
	a  = fgetmatrix(fhcensus)
	p1 = ftell(fhcensus)
	N  = rows(a)	
	a  = J(1,1,.)
	
	//The data
	x       = tokens(xvar)
	z1      = tokens(zvars)
	yh      = tokens(yhats)
	yh2     = tokens(yhats2)
	area    = tokens(areavar)
	wt      = tokens(wgt)
	id      = tokens(hhid)
	//pl      = tokens(plvar)
	colsx   = cols(x)
	colsz1  = cols(z1)
	colsyh  = cols(yh)
	colsyh2 = cols(yh2)
	
	coladd = (st_local("addvars")!="" ? cols(tokens(st_local("addvars"))) : 0) 

	
	//Check if X and other variables (varinmodel local), Z and Yhats are in the code
	e3499 = _fvarscheck(varinmod, varlist)
	if (z1[1]  != "__mz1_000")  e3499 = _fvarscheck(z1, varlist)
	if (yh[1]  != "__myh_000")  e3499 = _fvarscheck(yh, varlist)
	if (yh2[1] != "__myh2_000") e3499 = _fvarscheck(yh2, varlist)
	if (st_local("addvars")!="")    e3499 = _fvarscheck(tokens(st_local("addvars")), varlist)
	if (e3499==1) {
		errprintf("Variables mentioned above are missing from the target dataset\n")
		_error(3499)
	}
	
	if (hheff==1) { //zalpha condition - __mz1_000, __myh_000, __myh2_000
		if ((z1[1]=="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "000"  //0,0,0
		if ((z1[1]=="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "001"  //0,0,1
		if ((z1[1]=="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "010"  //0,1,0
		if ((z1[1]=="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "011"  //0,1,1
		if ((z1[1]~="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "100"  //1,0,0
		if ((z1[1]~="__mz1_000") & (yh[1]=="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "101"  //1,0,1
		if ((z1[1]~="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]=="__myh2_000")) zcond = "110"  //1,1,0	
		if ((z1[1]~="__mz1_000") & (yh[1]~="__myh_000") & (yh2[1]~="__myh2_000")) zcond = "111"  //1,1,1
	}
	
//sort is done before and setup area panel
	area_v = _fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0)
	display("{it:Number of observations in target dataset:}")
	rows(area_v)	
	if (rows(area_v)==0){
		errprintf("\n Your target dataset has no observations, please check")
		_error(3862)	
	}
	display("")	
	
	info   = panelsetup(area_v, 1)	
	rowsinfo = rows(info)
	display("{it:Number of clusters in target dataset:}")
	rowsinfo
	display("")

	mask = _fdatamark(N, varinmod, varlist, fhcensus, p0, p1-p0)

	wt_v = select(_fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0), mask)
	nHHLDs = rows(wt_v)
	area2 = select(area_v, mask)
	nagg = cols(agglist)
	npovlines = cols(pl)
	infov = areaid = nhh = J(1, nagg, NULL)
	nrow = J(1, nagg, .)
	for (j=1; j<=nagg; j++) {
		idfake    = trunc(area2/10^agglist[j])
		infov[j]   = &(panelsetup(idfake, 1))
		areaid[j] = &(idfake[(*infov[j])[(1::rows(*infov[j])),2],.])
		nhh[j]    = &((*infov[j])[.,2] - (*infov[j])[.,1] :+ 1)
		nrow[j]   = rows(*infov[j])
	}
	idfake = NULL
	
	//Unit	nHHLDs	nDroppedHHLD	nIndividuals	YTrimed	nSim	Min_Y	Max_Y	Mean	StdErr
	rmatnames = "nSim", "Unit", "nHHLDs", "nIndividuals", "Mean"
	senames = "StdErr"
	nfgts = cols(fgtlist)
	if (nfgts>0) {
		for (l=1; l<=npovlines; l++) {
			for (ind=1; ind<=nfgts; ind++) {
				plname = (plreal==1 ? strtoname(strofreal(pl[l])) : "_" + pl[l])
				rmatnames = rmatnames, "avg_" + fgtlist[ind] + plname
				senames = senames, "se_" + fgtlist[ind] + plname
			}
		}
	}
	
	nges = cols(gelist)
	if (nges>0) {
		for (ind=1; ind<=nges; ind++) {
			rmatnames = rmatnames, "avg_" + gelist[ind]
			senames = senames, "se_" + gelist[ind]
		}
	}
	rmatnames = rmatnames, senames

	if (npovlines>0 & nfgts>0 & plreal==0) {
		plvalue = J(1,npovlines, NULL)
		
		for (l=1; l<=npovlines; l++){
		    plvalue[l] = &((_fgetcoldata(_fvarindex(pl[l], varlist), fhcensus, p0, p1-p0), mask))		
		}
	}	

	
	if (st_local("ydump")!="") { 
		if (st_local("plinevar")!="") ncols = 3 + sim + 1 +coladd
		else ncols = 3 + sim +coladd
		yd = fopen(st_local("ydump"),"rw")		
		//"DATA_MATRIX", "VARIABLE_MATRIX" are removed from the matrix variable
		varname = "_ByID", "_ID", "_WEIGHT"
		varname = varname, tokens(st_local("yhatlist"))
		//if (st_local("plinevar")!="") varname = varname, "_POVLINE"
		if (st_local("addvars")!="") varname = varname, tokens(st_local("addvars"))
		fputmatrix(yd, (87801, quadcolsum(mask), ncols, sim, quadsum(strlen(varname))))     //DATA_MATRIX
		if (st_local("addvars")!="") fputmatrix(yd, ("_ByID", "_ID", "_WEIGHT", tokens(st_local("yhatlist")), tokens(st_local("addvars"))))  //VARIABLE_MATRIX		
		else                         fputmatrix(yd, ("_ByID", "_ID", "_WEIGHT", tokens(st_local("yhatlist"))))  //VARIABLE_MATRIX		
		fputmatrix(yd, select(J(N,1,1), mask)) //_ByID
		fputmatrix(yd, select(_fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0), mask)) //_ID
		fputmatrix(yd, select(_fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0), mask)) //_WEIGHT
		//if (st_local("plinevar")!="") fputmatrix(yd, select(_fgetcoldata(_fvarindex(st_local("plinevar"), varlist), fhcensus, p0, p1-p0), mask)) //_POVLINE
	}
	
	printf("{txt}\nNumber of simulations: {res}%g{txt}", sim)
	printf("{txt}\nEach dot (.) represents {res}%g{txt} simulation(s).\n", count)
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
			"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
			"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
			
	if (EB==1){
		cens_area = area_v[info[.,1],1]
	}
 
	
	
		block = J(1, 5 + nfgts*npovlines + nges,.)
		sim0 = 1


	for (s=1; s<=sim; s=s+count) {
			
			if (doone==1){
				Emat = cens_area,rnormal(rows(cens_area),1,0, sqrt(varU))
				etamat = Emat[.,2]
				external Emat
			}
			else{
				if (s==1) D = _ebcensus4(cens_area, (loc), (loc2), info)
				etamat = rnormal(1,1,D[.,1],sqrt(D[.,2]))  //j==1	
			}

		//xb and epsnorm
		m0 = s,1 \ s+count-1,1
		m1 = .,s \ .,s+count-1
		if (s==1){
			xb1 = J(N,1,1)*bsim[|1,colsbsim \ 1+count-1,colsbsim|]' //change to 0 for nocons 
			for (v=1; v<=colsx; v++) xb1 = xb1 :+ _fgetcoldata(_fvarindex(x[v], varlist), fhcensus, p0, p1-p0)*bsim[|1,v \ 1+count-1,v|]'
		}
		xb=xb1
		if (epsnorm==1) {
			if (hheff==1 ) {
				if (s==1){
					if (zcond == "100") { //xb = (zi,J(rows(zi),1,1))*asim'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
						for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)*asim[|s,v \ s+count-1,v|]'
					}
					if (zcond == "110") { //xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
						for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0) *asim[|s,v \ s+count-1,v|]'					
						for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]'):*xb
					}
					if (zcond == "111") { //xb = zi*asim[|.,1\.,cols(zi)|]' + (yhi*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi)|]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
						for (v=1; v<=colsz1; v++) zb = zb + _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)  *asim[|s,v \ s+count-1,v|]'
						for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]'):*xb
						for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1+colsyh \ s+count-1,v+colsz1+colsyh|]'):*(xb:^2)
					}
					if (zcond == "010") { //xb = (yhi*asim[.,cols(asim)-1]'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yhi),1,1)*asim[.,cols(asim)]'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 					
						for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*xb
					}
					if (zcond == "011") { //xb = (yhi*asim[.,1..cols(yhi)]'):*((xi,J(rows(xi),1,1))*bsim') + (yh2i*asim[|.,1+cols(yhi) \ .,cols(yhi)+cols(yh2i)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim')+ J(rows(yhi),1,1)*asim[.,cols(asim)]'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
						for (v=1; v<=colsyh; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*xb
						for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsyh \ s+count-1,v+colsyh|]'):*(xb:^2)
					}
					if (zcond == "001") { //xb = (yh2i*asim[.,1..cols(yh2i)]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') +  J(rows(yh2i),1,1)*asim[.,cols(asim)]'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 					
						for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v \ s+count-1,v|]'):*(xb:^2)
					}
					if (zcond == "101") { //xb = zi*asim[|.,1 \.,cols(zi)|]' + (yh2i*asim[|.,1+cols(zi) \ .,cols(zi)+cols(yhi2)|]'):*((xi,J(rows(xi),1,1))*bsim'):*((xi,J(rows(xi),1,1))*bsim') + J(rows(yh2i),1,1)*asim[.,cols(asim)]'
						zb = J(N,1,1)*asim[|s,colsasim \ s+count-1,colsasim|]' //change to 0 for nocons 
						for (v=1; v<=colsz1; v++)  zb = zb +  _fgetcoldata(_fvarindex(z1[v], varlist), fhcensus, p0, p1-p0)    *asim[|s,v \ s+count-1,v|]'					
						for (v=1; v<=colsyh2; v++) zb = zb + ((_fgetcoldata(_fvarindex(yh2[v], varlist), fhcensus, p0, p1-p0))*asim[|s,v+colsz1 \ s+count-1,v+colsz1|]' ):*(xb:^2)
					}
					zb = exp(zb)
					zb = (maxA:*(zb:/(1:+zb))) :+ (.5*varr)':*((maxA:*(zb:*(1:-zb))):/((1:+zb):^3)) //Convert ZB to SIGMAS
				}
				
				//_editmissing(zb, maxA)
				xb = xb + colshape(vec(rnormal(1,1,0,sqrt(zb))'),N)' 	//checked OK on 1 sim or many sim			 
			}
			else { // hheff==0
				xb = xb + rnormal(N,1,0,sqrt(sigma_eps)) //checked OK on 1 sim or many sim
			}
		}
		
		//etanorm
		for(j=1; j<=rowsinfo; j++) {
			m2 = info[j,1],. \ info[j,2],.
			xb[|m2|] = xb[|m2|] :+ etamat[j]		 
		}
				
		//Write col by col to the mata data
		if (st_local("ydump")!="") { 
			if (bcox==1 & lg==1) for (m=1; m<=count; m++) fputmatrix(yd,select(exp(_unbcsk(xb[.,m],LAMBDA)),mask))
			if (bcox==0 & lg==1) for (m=1; m<=count; m++) fputmatrix(yd, exp(select(xb[.,m], mask))) 
			if (bcox==1 & lg==0) for (m=1; m<=count; m++) fputmatrix(yd, select(_unbcsk(xb[.,m],LAMBDA), mask))
			if (bcox==0 & lg==0) for (m=1; m<=count; m++) fputmatrix(yd, select(xb[.,m], mask))
		}
		
		//now we have xb, let do the calculation fgt, gini, etc.		
		xb = select(xb, mask)
		for (m=1; m<=count; m++) {
			block0 = J(1,5,.)
			wt_m = wt_v
			if (bcox==1 & lg==1) y = exp(_unbcsk(xb[.,m],LAMBDA))
			if (bcox==0 & lg==1) y = exp(xb[.,m]) 
			if (bcox==1 & lg==0) y = _unbcsk(xb[.,m],LAMBDA)
			if (bcox==0 & lg==0) y = xb[.,m]
			if (colmissing(y)>0) {
				_editmissing(y, 0)	
				wt_m[selectindex(rowmissing(y)),.] = J(rows(selectindex(rowmissing(y))),1,0)		
			}
			wy = wt_m:*y
			running = quadrunningsum(wt_m,0), quadrunningsum(wy,0)	
			//minmaxy = minmax(y)
			for (j=1; j<=nagg; j++) {
				if (nrow[j] >=2) {
					A = running[(*infov[j])[1,2],.] \ running[(*infov[j])[(2::nrow[j]),2],.] - running[(*infov[j])[(1::nrow[j]-1),2],.]
					block0 = block0 \ J(nrow[j],1,sim0), *areaid[j], *nhh[j], A[.,1]           , A[.,2]:/A[.,1]
				}
				else block0 = block0 \ sim0            , 0         ,  nHHLDs, running[nHHLDs,1], running[nHHLDs,2]/running[nHHLDs,1]
			}
			A = NULL
			block0 = block0[2..rows(block0),.]
			if (nfgts>0) {
				for (l=1; l<=npovlines; l++) {
					if (plreal==1) {
						wt_p = (y:<= pl[l]):*wt_m
						rgap = 1:-(y:/ pl[l])
					}
					else {
						wt_p = (y:<= (*plvalue[l])[.,1]):*wt_m
						rgap = 1:-(y:/ (*plvalue[l])[.,1])				
					}
					for (ind=1; ind<=nfgts; ind++) {
						if (fgtlist[ind]=="fgt0") currfgt = running[.,1], quadrunningsum(wt_p,0)
						if (fgtlist[ind]=="fgt1") currfgt = running[.,1], quadrunningsum(wt_p:*rgap,0)
						if (fgtlist[ind]=="fgt2") currfgt = running[.,1], quadrunningsum(wt_p:*rgap:*rgap,0)
						fgtx = J(1,1,.)
						for (j=1; j<=nagg; j++) {
							if (nrow[j] >=2) {
								A = currfgt[(*infov[j])[1,2],.] \ currfgt[(*infov[j])[(2::nrow[j]),2],.] - currfgt[(*infov[j])[(1::nrow[j]-1),2],.]
								fgtx = fgtx  \ A[.,2]           :/ A[.,1]
							}
							else fgtx = fgtx \ currfgt[nHHLDs,2]:/ currfgt[nHHLDs,1]
						}
						block0 = block0, fgtx[2..rows(fgtx),1]
						A = fgtx = currfgt = NULL
					} //ind
				} //plines
			} //nfgt
			if (nges>0) {
				lny = ln(y)
				wlny = wt_m:*lny
				for (ind=1; ind<=nges; ind++) {
					if (gelist[ind]=="ge0") current = running, quadrunningsum(wlny,0)
					if (gelist[ind]=="ge1") current = running, quadrunningsum(wy:*lny,0)
					if (gelist[ind]=="ge2") current = running, quadrunningsum(wy:*y,0)	
					fgtx = J(1,1,.)
					if (gelist[ind]=="ge0") {
						for (j=1; j<=nagg; j++) {
							if (nrow[j] >=2) {
								A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
								fgtx = fgtx  \ -(A[.,3]:/A[.,1])                       :+ ln(A[.,2]:/A[.,1])
							}
							else fgtx = fgtx \ -(current[nHHLDs,3]:/current[nHHLDs,1]) :+ ln(current[nHHLDs,2]:/current[nHHLDs,1])
						}
					}
					if (gelist[ind]=="ge1") {
						for (j=1; j<=nagg; j++) {
							if (nrow[j] >=2) {
								A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
								fgtx = fgtx \ (A[.,3]:/A[.,2])                       :- ln(A[.,2]:/A[.,1])
							}
							else fgtx = fgtx \ (current[nHHLDs,3]:/current[nHHLDs,2]) :- ln(current[nHHLDs,2]:/current[nHHLDs,1])
						}
					}
					if (gelist[ind]=="ge2") {
						for (j=1; j<=nagg; j++) {
							if (nrow[j] >=2) {
								A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
								fgtx = fgtx \ 0.5*((((A[.,2]           :/A[.,1])           :^-2):*(A[.,3]:/A[.,1])):-1)
							}
							else fgtx = fgtx \ 0.5*((((current[nHHLDs,2]:/current[nHHLDs,1]):^-2):*(current[nHHLDs,3]:/current[nHHLDs,1])):-1)
						}
					}
					block0 = block0, fgtx[2..rows(fgtx),1]
					A = fgtx = current = NULL	
				} //ind
			} //nges
			//add blocks
			block = block \ block0
			sim0 = sim0 + 1
		} //m

		
		printf(".")
		if (mod(s,50)==0) printf(" %5.0f\n",s)
		displayflush()
	} //end of s
	xb1=xb = area_v = wt_v = wt_m = pl_v = NULL
	block0 = y = wt0 = wt = area = wy = running = wt_p = rgap = plvalue = lny = wlny = info = areaid = nhh = NULL
	
	//export results to Stata
	block = block[2..rows(block),.]
	_sort(block, (2,1))
	infov = panelsetup(block,2)
	rinfo = rows(infov)
	outsim = J(1, 4+(cols(block)-4)*2, .)
	for (i=1; i<=rinfo; i++) {
		rr  = infov[i,1],5 \ infov[i,2],.
		out = mean(block[|rr|])
		outsim = outsim \ infov[i,2]-infov[i,1]+1, block[infov[i,1],2::4], out[1,.], J(1,cols(out),.)
	}
	out = block = NULL
	outsim = outsim[2..rows(outsim),.]
	stata("clear")	
	(void) st_addvar("double", rmatnames)	
	st_addobs(rows(outsim))
	st_store(.,.,outsim)
	outsim = NULL
	
	if (st_local("ydump")!="") fclose(yd)
	st_local("_itran","0")
}
//Does the new simulation for efficient MSE estimation
void _s2sc_sim_ebp(string scalar xvar, 
				   string scalar yvar,
				   string scalar areavar, 
				   string scalar plvar, 
				   string scalar wvar,
				   string scalar wgt, 
				   string scalar touse, 
				   string scalar hhid, 
				   string scalar matin,
				   string scalar etavec,
				   real matrix bsim,
				   real scalar sigma2U,
				   real scalar sigma2e)
{
	sim         = strtoreal(st_local("rep"))  //number of MC sims
	seed        = strtoreal(st_local("seed")) //seed for sim
	doone       = strtoreal(st_local("doone")) //to indicate that just one sim is to be done
	appendit    = strtoreal(st_local("appendsvy"))  //Asks to append the Y vector from the survey
	_complex     = strtoreal(st_local("complex"))    //Uses Guadarrama et al. 2016 complex EB
	
	lg			= strtoreal(st_local("lny"))         //Logarithm conversion
	bcox        = strtoreal(st_local("bcox"))		     //Box Cox conversion
	LAMBDA      = strtoreal(st_local("lambda"))			//Lambda for boxcox
	
	varinmod	= tokens(st_local("varinmodel"))	 //Variables needed to bring from mata census
	indlist     = tokens(st_local("indicators"))     //Indicator list
	agglist = strtoreal(tokens(st_local("aggids")))  //aggregation levels
	fgtlist = tokens(st_local("fgtlist"))            //FGT list
	gelist  = tokens(st_local("gelist"))			 //GE list
	pl      = strtoreal(tokens(plvar))               //Pov Line
	plreal = 1
	if (missing(pl)>0) {
		pl = tokens(plvar)	
		plreal = 0
	}
	
	colsbsim = cols(bsim)  //Num of beta
	
	
	//WARNING: area must be sorted outside in Stata
	//census data - or use other way, ie seek(fh, (N*8+77)*6 ,-1) to get the 7th column
	fhcensus = fopen(matin, "r")
	varlist = fgetmatrix(fhcensus)	
	p0 = ftell(fhcensus)
	a  = fgetmatrix(fhcensus)
	p1 = ftell(fhcensus)
	N  = rows(a)	
	a  = J(1,1,.)
	
	//The data
	x       = tokens(xvar)
	area    = tokens(areavar)
	wt      = tokens(wgt)
	id      = tokens(hhid)

	//From survey...
	xsvy    = st_data(.,tokens(xvar),  touse) //I add the constant below
	ysvy    = st_data(.,tokens(yvar),  touse)
	wsvy    = st_data(.,tokens(wvar),  touse)
	areasvy    = st_data(.,tokens(areavar),  touse)
	etasvy     = st_data(.,tokens(etavec),  touse)
	svyobs     = rows(xsvy)
	
	//Dimensions of data...
	colsx   = cols(x)

	
	//Check if X and other variables (varinmodel local)
	e3499 = _fvarscheck(varinmod, varlist)
	if (e3499==1) {
		errprintf("Variables mentioned above are missing from the target dataset\n")
		_error(3499)
	}
	

	//sort is done before and setup area panel
	area_v = _fgetcoldata(_fvarindex(area[1], varlist), fhcensus, p0, p1-p0)
	display("{it:Number of observations in target dataset:}")
	rows(area_v)	
	if (rows(area_v)==0){
		errprintf("\n Your target dataset has no observations, please check")
		_error(3862)	
	}
	display("")	
	
	info   = panelsetup(area_v, 1)	
	rowsinfo = rows(info)
	display("{it:Number of clusters in target dataset:}")
	rowsinfo
	display("")

	mask = _fdatamark(N, varinmod, varlist, fhcensus, p0, p1-p0)	
	
	//Check for WEIGHT on Survey
	if (appendit==1 & _complex==0){
		totweight=quadsum(wsvy)	
		if (totweight>(20*rows(wsvy))){
			errprintf("\n Your weights are more than 20 times your number of observations, this is inconsistent with appending")
			_error(4443)
		}
	}
	
	
	wt_v = select(_fgetcoldata(_fvarindex(wt[1], varlist), fhcensus, p0, p1-p0), mask)
	nHHLDs = rows(wt_v)
	area2 = select(area_v, mask)
	nagg = cols(agglist)
	npovlines = cols(pl)
	infov = areaid = nhh = J(1, nagg, NULL)
	nrow = J(1, nagg, .)
	for (j=1; j<=nagg; j++) {
		idfake    = trunc(area2/10^agglist[j])
		infov[j]   = &(panelsetup(idfake, 1))
		areaid[j] = &(idfake[(*infov[j])[(1::rows(*infov[j])),2],.])
		nhh[j]    = &((*infov[j])[.,2] - (*infov[j])[.,1] :+ 1)
		nrow[j]   = rows(*infov[j])
	}
	idfake = NULL
	
	if (appendit==1){
		nHHLDs11 = rows(wsvy)
		infov11  = areaid11 = nhh11 = J(1, nagg, NULL)
		nrow11   = J(1, nagg, .)
		for (j=1; j<=nagg; j++) {
			idfake11     = trunc(areasvy/10^agglist[j])
			infov11[j]   = &(panelsetup(idfake11, 1))
			areaid11[j]  = &(idfake11[(*infov11[j])[(1::rows(*infov11[j])),2],.])
			nhh11[j]     = &((*infov11[j])[.,2] - (*infov11[j])[.,1] :+ 1)
			nrow11[j]    = rows(*infov11[j])
		}
		idfake11 = NULL
	}
	
	//Unit	nHHLDs	nDroppedHHLD	nIndividuals	YTrimed	nSim	Min_Y	Max_Y	Mean	StdErr
	rmatnames = "nSim", "Unit", "nHHLDs", "nIndividuals", "Mean"
	senames = "StdErr"
	nfgts = cols(fgtlist)
	if (nfgts>0) {
		for (l=1; l<=npovlines; l++) {
			for (ind=1; ind<=nfgts; ind++) {
				plname = (plreal==1 ? strtoname(strofreal(pl[l])) : "_" + pl[l])
				rmatnames = rmatnames, "avg_" + fgtlist[ind] + plname
				senames = senames, "se_" + fgtlist[ind] + plname
			}
		}
	}
	nges = cols(gelist)
	if (nges>0) {
		for (ind=1; ind<=nges; ind++) {
			rmatnames = rmatnames, "avg_" + gelist[ind]
			senames = senames, "se_" + gelist[ind]
		}
	}
	rmatnames = rmatnames, senames

	if (npovlines>0 & nfgts>0 & plreal==0) {
		plvalue = J(1,npovlines, NULL)
		for (l=1; l<=npovlines; l++) plvalue[l] = &((_fgetcoldata(_fvarindex(pl[l], varname), fhcensus, p0, p1-p0), mask))		
	}		
	
	
	printf("{txt}\nNumber of simulations: {res}%g{txt}", sim)
	printf("{txt}\nEach dot (.) represents {res}%g{txt} simulation(s).\n", 1)
	display("{txt}{hline 4}{c +}{hline 3} 1 " +
			"{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
			"{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
	
	if (st_local("ydump")==""){
		block = J(1, 5 + nfgts*npovlines + nges,.)
		sim0 = 1
		if (appendit==1){
			block11=block
			sim011 = sim0
		}
	}
	
	if (_complex==1){
		svyinfo = panelsetup(areasvy,1)
		etasvy = complex_eta(ysvy, xsvy, wsvy, svyinfo, sigma2U, sigma2e, bsim, areasvy) //Guad has: areacode, eta, sigmagamma
		eb_eta = ebp_match(etasvy[.,1],etasvy[.,2],etasvy[.,3],area_v[info[.,1],1],sigma2U,svyinfo)
	}
	else{
		//Build survey info...
		svyinfo = panelsetup(areasvy,1)
		etasvy  = (areasvy,etasvy)[svyinfo[.,1],.] //pull eta vector for survey areas
		etasvy = etasvy, ((svyinfo[.,2] - svyinfo[.,1]):+1)
		etasvy[.,3]  = (sigma2U:*(1:-(sigma2U:/(sigma2U:+(sigma2e:/etasvy[.,3])))))
	}	
	//etasvy now has id,eta,sigmagamma
	eb_eta = ebp_match(etasvy[.,1],etasvy[.,2], etasvy[.,3], area_v[info[.,1],1],sigma2U,svyinfo)
	
	//eb_eta output has eta, sigmagamma, info_col1, info_col2
	
	
	//SIMULATION>>>>
	for (s=1; s<=sim; s++){
		m0 = s,1 \ s,1
		m1 = .,s \ .,s
		if (s==1){
			xb = J(N,1,1)*bsim[|1,colsbsim \ 1,colsbsim|]' //change to 0 for nocons 
			for (v=1; v<=colsx; v++) xb = xb :+ _fgetcoldata(_fvarindex(x[v], varlist), fhcensus, p0, p1-p0)*bsim[|1,v \ 1,v|]'	
			if (doone==1) xsvy = quadcross((xsvy,J(rows(xsvy),1,1))',bsim')
		}
		xb1=xb
		//add eta
		if (doone==1){
			for(j=1; j<=rowsinfo; j++) {
				m2 = info[j,1],. \ info[j,2],.
				eta =  rnormal(1,1,0,sqrt(sigma2U))	
				xb1[|m2|] = xb1[|m2|] :+ eta
				
				if (eb_eta[j,3]!=0){
					m3 = eb_eta[j,3],. \ eb_eta[j,4],.
					xsvy[|m3|] = xsvy[|m3|] :+eta
				}
				
			}
			
		}
		else{
			for(j=1; j<=rowsinfo; j++) {
				m2 = info[j,1],. \ info[j,2],.
				eta =  rnormal(1,1,eb_eta[j,1],sqrt(eb_eta[j,2]))			
				xb1[|m2|] = xb1[|m2|] :+ eta
			}
		}
				
		//Add residual...
		xb1 = xb1 + rnormal(N,1,0,sqrt(sigma2e))
		if (doone==1){
			xsvy = xsvy + rnormal(rows(xsvy),1,0,sqrt(sigma2e))
		}
				
		//now we have xb, let do the calculation fgt, gini, etc.		
		
			xb1 = select(xb1, mask)
			for (m=1; m<=1; m++) {
				block0 = J(1,5,.)
				wt_m = wt_v
				if (bcox==1 & lg==1) y = exp(_unbcsk(xb1[.,m],LAMBDA))
				if (bcox==0 & lg==1) y = exp(xb1[.,m]) 
				if (bcox==1 & lg==0) y = _unbcsk(xb1[.,m],LAMBDA)
				if (bcox==0 & lg==0) y = xb1[.,m]
				if (colmissing(y)>0) {
					_editmissing(y, 0)	
					wt_m[selectindex(rowmissing(y)),.] = J(rows(selectindex(rowmissing(y))),1,0)		
				}
				wy = wt_m:*y
				running = quadrunningsum(wt_m,0), quadrunningsum(wy,0)	
				//minmaxy = minmax(y)
				for (j=1; j<=nagg; j++) {
					if (nrow[j] >=2) {
						A = running[(*infov[j])[1,2],.] \ running[(*infov[j])[(2::nrow[j]),2],.] - running[(*infov[j])[(1::nrow[j]-1),2],.]
						block0 = block0 \ J(nrow[j],1,sim0), *areaid[j], *nhh[j], A[.,1]           , A[.,2]:/A[.,1]
					}
					else block0 = block0 \ sim0            , 0         ,  nHHLDs, running[nHHLDs,1], running[nHHLDs,2]/running[nHHLDs,1]
				}
				A = NULL
				block0 = block0[2..rows(block0),.]
				if (nfgts>0) {
					for (l=1; l<=npovlines; l++) {
						if (plreal==1) {
							wt_p = (y:<= pl[l]):*wt_m
							rgap = 1:-(y:/ pl[l])
						}
						else {
							wt_p = (y:<= *plvalue[l]):*wt_m
							rgap = 1:-(y:/ *plvalue[l])				
						}
						for (ind=1; ind<=nfgts; ind++) {
							if (fgtlist[ind]=="fgt0") currfgt = running[.,1], quadrunningsum(wt_p,0)
							if (fgtlist[ind]=="fgt1") currfgt = running[.,1], quadrunningsum(wt_p:*rgap,0)
							if (fgtlist[ind]=="fgt2") currfgt = running[.,1], quadrunningsum(wt_p:*rgap:*rgap,0)
							fgtx = J(1,1,.)
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = currfgt[(*infov[j])[1,2],.] \ currfgt[(*infov[j])[(2::nrow[j]),2],.] - currfgt[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx  \ A[.,2]           :/ A[.,1]
								}
								else fgtx = fgtx \ currfgt[nHHLDs,2]:/ currfgt[nHHLDs,1]
							}
							block0 = block0, fgtx[2..rows(fgtx),1]
							A = fgtx = currfgt = NULL
						} //ind
					} //plines
				} //nfgt
				if (nges>0) {
					lny = ln(y)
					wlny = wt_m:*lny
					for (ind=1; ind<=nges; ind++) {
						if (gelist[ind]=="ge0") current = running, quadrunningsum(wlny,0)
						if (gelist[ind]=="ge1") current = running, quadrunningsum(wy:*lny,0)
						if (gelist[ind]=="ge2") current = running, quadrunningsum(wy:*y,0)	
						fgtx = J(1,1,.)
						if (gelist[ind]=="ge0") {
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx  \ -(A[.,3]:/A[.,1])                       :+ ln(A[.,2]:/A[.,1])
								}
								else fgtx = fgtx \ -(current[nHHLDs,3]:/current[nHHLDs,1]) :+ ln(current[nHHLDs,2]:/current[nHHLDs,1])
							}
						}
						if (gelist[ind]=="ge1") {
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx \ (A[.,3]:/A[.,2])                       :- ln(A[.,2]:/A[.,1])
								}
								else fgtx = fgtx \ (current[nHHLDs,3]:/current[nHHLDs,2]) :- ln(current[nHHLDs,2]:/current[nHHLDs,1])
							}
						}
						if (gelist[ind]=="ge2") {
							for (j=1; j<=nagg; j++) {
								if (nrow[j] >=2) {
									A = current[(*infov[j])[1,2],.] \ current[(*infov[j])[(2::nrow[j]),2],.] - current[(*infov[j])[(1::nrow[j]-1),2],.]
									fgtx = fgtx \ 0.5*((((A[.,2]           :/A[.,1])           :^-2):*(A[.,3]:/A[.,1])):-1)
								}
								else fgtx = fgtx \ 0.5*((((current[nHHLDs,2]:/current[nHHLDs,1]):^-2):*(current[nHHLDs,3]:/current[nHHLDs,1])):-1)
							}
						}
						block0 = block0, fgtx[2..rows(fgtx),1]
						A = fgtx = current = NULL	
					} //ind
				} //nges
				//add blocks
				block = block \ block0
				sim0 = sim0 + 1
			} //m
		//yesmata
		if (appendit==1 & s==1){
			for (m=1; m<=1; m++) {
				block01 = J(1,5,.)
				wt_m = wsvy

				if (doone==1){
					if (bcox==1 & lg==1) y = exp(_unbcsk(xsvy,LAMBDA))
					if (bcox==0 & lg==1) y = exp(xsvy) 
					if (bcox==1 & lg==0) y = _unbcsk(xsvy,LAMBDA)
					if (bcox==0 & lg==0) y = xsvy
				}
				else{
					if (bcox==1 & lg==1) y = exp(_unbcsk(ysvy,LAMBDA))
					if (bcox==0 & lg==1) y = exp(ysvy) 
					if (bcox==1 & lg==0) y = _unbcsk(ysvy,LAMBDA)
					if (bcox==0 & lg==0) y = ysvy
				}
		
				wy = wt_m:*y
				running = quadrunningsum(wt_m,0), quadrunningsum(wy,0)	
				//minmaxy = minmax(y)
				for (j=1; j<=nagg; j++) {
					if (nrow11[j] >=2) {
						A = running[(*infov11[j])[1,2],.] \ running[(*infov11[j])[(2::nrow11[j]),2],.] - running[(*infov11[j])[(1::nrow11[j]-1),2],.]
						block01 = block01 \ J(nrow11[j],1,sim011), *areaid11[j], *nhh11[j], A[.,1]           , A[.,2]:/A[.,1]
					}
					else block01 = block01 \ sim011            , 0         ,  nHHLDs11, running[nHHLDs11,1], running[nHHLDs11,2]/running[nHHLDs11,1]
				}
				A = NULL
				block01 = block01[2..rows(block01),.]
				if (nfgts>0) {
					for (l=1; l<=npovlines; l++) {
						if (plreal==1) {
							wt_p = (y:<= pl[l]):*wt_m
							rgap = 1:-(y:/ pl[l])
						}
						else {
							wt_p = (y:<= *plvalue[l]):*wt_m
							rgap = 1:-(y:/ *plvalue[l])				
						}
						for (ind=1; ind<=nfgts; ind++) {
							if (fgtlist[ind]=="fgt0") currfgt = running[.,1], quadrunningsum(wt_p,0)
							if (fgtlist[ind]=="fgt1") currfgt = running[.,1], quadrunningsum(wt_p:*rgap,0)
							if (fgtlist[ind]=="fgt2") currfgt = running[.,1], quadrunningsum(wt_p:*rgap:*rgap,0)
							fgtx = J(1,1,.)
							for (j=1; j<=nagg; j++) {
								if (nrow11[j] >=2) {
									A = currfgt[(*infov11[j])[1,2],.] \ currfgt[(*infov11[j])[(2::nrow11[j]),2],.] - currfgt[(*infov11[j])[(1::nrow11[j]-1),2],.]
									fgtx = fgtx  \ A[.,2]           :/ A[.,1]
								}
								else fgtx = fgtx \ currfgt[nHHLDs11,2]:/ currfgt[nHHLDs11,1]
							}
							block01 = block01, fgtx[2..rows(fgtx),1]
							A = fgtx = currfgt = NULL
						} //ind
					} //plines
				} //nfgt
				if (nges>0) {
					lny = ln(y)
					wlny = wt_m:*lny
					for (ind=1; ind<=nges; ind++) {
						if (gelist[ind]=="ge0") current = running, quadrunningsum(wlny,0)
						if (gelist[ind]=="ge1") current = running, quadrunningsum(wy:*lny,0)
						if (gelist[ind]=="ge2") current = running, quadrunningsum(wy:*y,0)	
						fgtx = J(1,1,.)
						if (gelist[ind]=="ge0") {
							for (j=1; j<=nagg; j++) {
								if (nrow11[j] >=2) {
									A = current[(*infov11[j])[1,2],.] \ current[(*infov11[j])[(2::nrow11[j]),2],.] - current[(*infov11[j])[(1::nrow11[j]-1),2],.]
									fgtx = fgtx  \ -(A[.,3]:/A[.,1])                       :+ ln(A[.,2]:/A[.,1])
								}
								else fgtx = fgtx \ -(current[nHHLDs11,3]:/current[nHHLDs11,1]) :+ ln(current[nHHLDs11,2]:/current[nHHLDs11,1])
							}
						}
						if (gelist[ind]=="ge1") {
							for (j=1; j<=nagg; j++) {
								if (nrow11[j] >=2) {
									A = current[(*infov11[j])[1,2],.] \ current[(*infov11[j])[(2::nrow11[j]),2],.] - current[(*infov11[j])[(1::nrow11[j]-1),2],.]
									fgtx = fgtx \ (A[.,3]:/A[.,2])                       :- ln(A[.,2]:/A[.,1])
								}
								else fgtx = fgtx \ (current[nHHLDs11,3]:/current[nHHLDs11,2]) :- ln(current[nHHLDs11,2]:/current[nHHLDs11,1])
							}
						}
						if (gelist[ind]=="ge2") {
							for (j=1; j<=nagg; j++) {
								if (nrow11[j] >=2) {
									A = current[(*infov11[j])[1,2],.] \ current[(*infov11[j])[(2::nrow11[j]),2],.] - current[(*infov11[j])[(1::nrow11[j]-1),2],.]
									fgtx = fgtx \ 0.5*((((A[.,2]           :/A[.,1])           :^-2):*(A[.,3]:/A[.,1])):-1)
								}
								else fgtx = fgtx \ 0.5*((((current[nHHLDs11,2]:/current[nHHLDs11,1]):^-2):*(current[nHHLDs11,3]:/current[nHHLDs11,1])):-1)
							}
						}
						block01 = block01, fgtx[2..rows(fgtx),1]
						A = fgtx = current = NULL	
					} //ind
				} //nges
				//add blocks
				block11 = block11 \ block01
			} //m
		}
		if (appendit==0 & doone==1){
			if (bcox==1 & lg==1) y = exp(_unbcsk(xsvy,LAMBDA))
			if (bcox==0 & lg==1) y = exp(xsvy) 
			if (bcox==1 & lg==0) y = _unbcsk(xsvy,LAMBDA)
			if (bcox==0 & lg==0) y = xsvy
		}
		
		printf(".")
		if (mod(s,50)==0) printf(" %5.0f\n",s)
		displayflush()	
	} //Sim
	xb1=xb = area_v = wt_v = wt_m = pl_v = NULL
	if (doone==1){
		_MyebpY = y
		block0 = block01 = wt0 = wt = area = y = wy = running = wt_p = rgap = plvalue = lny = wlny = info = areaid = nhh = NULL		
		external _MyebpY
	}
	else{
		block0 = block01 = wt0 = wt = y =area = wy = running = wt_p = rgap = plvalue = lny = wlny = info = areaid = nhh = NULL
	}
	

	//Export results to STata
	block = block[2..rows(block),.] 
	_sort(block, (2,1))
	stata("clear")
	(void) st_addvar("double", rmatnames[1,1..cols(block)])	
	st_addobs(rows(block))
	st_store(.,.,block)
	
		rmats=""
		for(j=5; j<=cols(block); j++) rmats = rmats+" "+ rmatnames[1,j]
		st_local("_varnames",rmats)
	
	
	if (appendit==1){
		block11[.,4] = block11[.,4]*sim 
		block11[.,3] = block11[.,3]*sim 
		block11=block11[2..rows(block11),.]
		st_addobs(rows(block11))
		stata("gen svy = missing(nSim)")
		svy = "svy"
		st_store(.,(1..cols(block11)),svy,block11)
	}
	out = block = block11 = NULL	

}

//I need a function to match svy locations to census...
function ebp_match(_myid, _myeta, _mySG, _mycensusid, sigma2U, _myinfo){
	_mloc  = rows(_myid)
	_mlocC = rows(_mycensusid)
	k = 0
	cens_etas = J(_mlocC,1,(0,sigma2U,0,0))
	for(i=1; i<=_mloc; i++){
		for(j=1; j<=_mlocC; j++){
			if(_myid[i]==_mycensusid[j]){
				cens_etas[j,] = _myeta[i],_mySG[i],_myinfo[i,.]
			}			
		}
	}
	
	return(cens_etas)
}

function complex_eta(ysvy, xsvy, wsvy, svyinfo, sigma2U, sigma2e, bsim, areasvy){
	_mloc = rows(svyinfo)
	for (i=1; i<=_mloc; i++){
		m23 = svyinfo[i,1],. \ svyinfo[i,2],.
		nn = svyinfo[i,2] - svyinfo[i,1] + 1
		_etaef   = (mean(ysvy[|m23|],wsvy[|m23|]) - quadcross(mean((xsvy[|m23|],J(nn,1,1)),wsvy[|m23|])',bsim'))
		_gammaef = quadsum((wsvy[|m23|]:^2))/(quadsum(wsvy[|m23|])^2)
		_gammaef = sigma2U/(sigma2U+sigma2e*_gammaef)
		_etaef   = _etaef*_gammaef
		_gammaef = sigma2U*(1-_gammaef)
		
		if (i==1) Guad = areasvy[svyinfo[i,1]],_etaef,_gammaef
		else      Guad = Guad\( areasvy[svyinfo[i,1]],_etaef,_gammaef)		
	}
	return(Guad)  //Guad has: areacode, eta, sigmagamma
}

//Box Cox untransform, note that negative values will be negative
function _unbcsk(y,L){
	return(((y*L):+1):^(1/L))
}
function _bcsk(y,L){
	return(((y:^L):-1):/L)
}

//lnskew0
function _unlnsk(y,L){
	return(exp(y):+L)
}

//FUnction to pull put 95CI from new BStrap
function the95(CI, lo, hi){
	pointer(real matrix) rowvector _95out
	_95out = J(1,2,NULL)
	colci = cols(CI)
	_sort(CI,1)
	info_1 = panelsetup(CI,1)
	rowinfo = rows(info_1)
	
	for(i=1; i<=rowinfo; i++){		
		for(j=2; j<=colci; j++){
			pX=sort(CI[|info_1[i,1],j \ info_1[i,2],j|],1)
			if (j==2){
				LO_ci = pX[lo]
				UP_ci = pX[hi]
			}
			else{				
				LO_ci = LO_ci,pX[lo]
				UP_ci = UP_ci,pX[hi]
			}
		}
		if (i==1){
			theLO = LO_ci
			theHI = UP_ci
		}
		else{
			theLO = theLO \ LO_ci
			theHI = theHI \ UP_ci
		}
	}
	
	_95out[1,1] = &(theLO)
	_95out[1,2] = &(theHI)
	return(_95out)
}



mata mlib create lsae_povmap, dir("`c(sysdir_plus)'l") replace
mata mlib add lsae_povmap *(), dir("`c(sysdir_plus)'l")
mata mlib index
end

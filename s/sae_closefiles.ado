*! version 0.3.0  July 3, 2020
*! Minh Cong Nguyen - mnguyen3@worldbank.org
*! Paul Andres Corral Rodas - pcorralrodas@worldbank.org
*! Joao Pedro Azevedo - jazevedo@worldbank.org
*! Qinghua Zhao    

program sae_closefiles
	version 9
	forvalues i=0(1)10 {
		capture mata: fclose(`i')
	}
end

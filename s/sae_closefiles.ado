program sae_closefiles
	version 9
	forvalues i=0(1)10 {
		capture mata: fclose(`i')
	}
end

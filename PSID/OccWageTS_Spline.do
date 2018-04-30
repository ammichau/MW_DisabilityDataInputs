*OccWageTS_Spline.do
*-------------------v.7-31-2017; @A. Michaud for DIoption w/ DW---------------------------------*
*-------------------------------------------------------------------------------------------------	
*Here we want to estimate the changing wages paid in each occupation. 
*	-We're going to use cubic splines w/ 5 knots
*	Why?
*		-We can't just feed in wages, remember, too much selection going on!
*		-This balances number of coefficients we need to match in the model GMM w/ the fit to the data
*-------------------------------------------------------------------------------------------------
* Outputs
*	-Many time-series graphs on the above robustness variations 
*		(1) The estimated payments by Onet component and year effects
*		(2) Predicted wages for occupations
*	-.csv files with estimated coefficients for input into FORTRAN calibration.
*	- $InputDTAs_dir\OccPredTwages.dta with occupation predictions for ModvDataRegs.do
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-calibdata2.dta; created by MainCalib_StartHere.do
*	-ONETpca.dta; Occupation tasks principal components from "Risky Occ Paper", see DW.
*	-HRSmerge.dta; DI outcomes by occupation from "Risky Occ Paper", see DW.
***************************************************************************************************************
*----------------------------------------------------------------------
*----------------------------------------------------------------------
*----------------------------------------------------------------------

*Section 1: Set up

   use $InputDTAs_dir\calibdata2, clear
	gen nWhite = 1 if Race~=1
	replace nWhite = 0 if Race==1

	gen Female =(Sex==2)
	drop if (x11101ll==. | Age<30 | Age>65)

*clean wages
		gen crHrlyW= rwage
		replace crHrlyW=. if crHrlyW>400
	*Get rid of really low real wage (<$3 in 1996 dollars) and top codes.
		replace crHrlyW=. if (rwage<3)
	*Major changes in SSDI, so we drop these years
		drop if (wave<1983)
		gen lrwage = ln(crHrlyW)

*Follow L&P: Drop those with outlier wage growth,
	xtset x11101ll wave
	by x11101ll:gen grly=(HrlyW/L.HrlyW)-1
	replace grly=. if grly==-1
	gen suspect=0
	qui su grly,d
	replace suspect=grly<-0.85|(grly>5 & grly!=.)	
	egen ss=sum(suspect),by(x11101ll)				
	
	*Merge in Onet data for wage reg 
		*Interpretation is that skills are related to longest-occupation, not current
		*gen SOC=Currocc
		gen SOC=LifeOcc2
		merge m:1 SOC using $InputDTAs_dir\ONETpca.dta, keepusing(*PC* ) gen(_merge_ONET1)
		rename PhysPC1 ONETPhysPC1_jl
		rename PhysPC2 ONETPhysPC2_jl

		rename KsaPC1 ONETKsaPC1_jl
		rename KsaPC2 ONETKsaPC2_jl
		rename KsaPC3 ONETKsaPC3_jl
		rename KsaPC4 ONETKsaPC4_jl
		rename KsaPC5 ONETKsaPC5_jl

		drop SOC
		
	*Merge in measure of health outcomes by Occ from HRS
		gen SOC=LifeOcc2
		merge m:1 SOC using $InputDTAs_dir\HRSmerge.dta
		drop SOC _merge
		
	*normalize them all
	foreach vi of varlist *ONET*PC*{
		qui sum `vi'
		replace `vi' = (`vi'-r(mean))/r(sd)
	}

	
	*Age variables (Experience is just age-30 so it is more interpretable)
	gen Exp = Age-30
	gen Exp2=Exp^2	
	gen Exp3 =Exp^3	
		
	gen selectOLS=(wave>1983  & dead~=1 & Age<63 & Age>30 & Female==0  & Latino==0 &  ss==0 & Col==0)
	
	*Due to small sample size, wages get weird after 2010 in SOC 5
	replace lrwage=. if LifeOcc2==5 & wave>2010

***************************************************************************************************************
* Run regs and store predictions
*-------------------------------------------------------------------------------------------------------------
		
gen time = wave-1983

	
	****************
	*Cubic Splines- 5 knots*
	****************		

    mkspline timeC = time, cubic nknots(5)
	
    reg lrwage Exp Exp2 HS  nWhite  married  ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl timeC* ///
		c.ONETPhysPC1_jl#c.timeC* c.ONETKsaPC1_jl#c.timeC* c.ONETKsaPC2_jl#c.timeC*	 if (selectOLS==1  )
		estimates save $OUT_dir\WageCSpline2, replace	
		estimate store WageCSpline		
				
		*Test fit of the cubic
		predict WageCspline_r , residuals 
		replace WageCspline_r = WageCspline_r^2	
		
	*** Write to Latex:		
	ssc install estout
		esttab WageLSpline using $OUT_dir\WageCSpline2.tex ///
		   , ar2 b(4) cells("b se") stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		   nomtitles numbers /// mtitles("(1)" "(2)" "(3)" "(4)") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
	*------
	*Keep some values to make predictions for the time series by occupation.
			gen p1coefphys= _b[ONETPhysPC1_jl]
			gen p1coefksa1= _b[ONETKsaPC1_jl]
			gen p1coefksa2= _b[ONETKsaPC2_jl]

			gen ts1coefphys= _b[c.ONETPhysPC1_jl#c.timeC1]
			gen ts1coefksa1= _b[c.ONETKsaPC1_jl#c.timeC1]
			gen ts1coefksa2= _b[c.ONETKsaPC2_jl#c.timeC1]	
			gen ts2coefphys= _b[c.ONETPhysPC1_jl#c.timeC2]
			gen ts2coefksa1= _b[c.ONETKsaPC1_jl#c.timeC2]
			gen ts2coefksa2= _b[c.ONETKsaPC2_jl#c.timeC2]
			gen ts3coefphys= _b[c.ONETPhysPC1_jl#c.timeC3]
			gen ts3coefksa1= _b[c.ONETKsaPC1_jl#c.timeC3]
			gen ts3coefksa2= _b[c.ONETKsaPC2_jl#c.timeC3]
			gen ts4coefphys= _b[c.ONETPhysPC1_jl#c.timeC4]
			gen ts4coefksa1= _b[c.ONETKsaPC1_jl#c.timeC4]
			gen ts4coefksa2= _b[c.ONETKsaPC2_jl#c.timeC4]			
			
			gen ts1coef= _b[timeC1]
			gen ts2coef= _b[timeC2]
			gen ts3coef= _b[timeC3]
			gen ts4coef= _b[timeC4]			
		
		gen constnt= _cons			


	
*-------------------------------------------------------------------------------------------------
* Going to print some plots of the predicted wage trends because I am a visual person
***************************************************************************************************************

*Label Occupations more nicely
		label define sSOC_lbl 1 `"Managerial"'
		label define sSOC_lbl 2 `"Professional"', add
		label define sSOC_lbl 3 `"Sales"', add
		label define sSOC_lbl 4 `"Clerical"', add
		label define sSOC_lbl 5 `"Service: household & building"', add
		label define sSOC_lbl 6 `"Service: protection "', add
		label define sSOC_lbl 7 `"Service: food "', add
		label define sSOC_lbl 8 `"Service: Health "', add
		label define sSOC_lbl 9 `"Service Personal "', add
		label define sSOC_lbl 10 `"Farming, forestry, fishing "', add
		label define sSOC_lbl 11 `"Mechanics and repair "', add
		label define sSOC_lbl 12 `"Construction & extractors "', add
		label define sSOC_lbl 13 `"Precision production "', add
		label define sSOC_lbl 14 `"Operators: machine "', add
		label define sSOC_lbl 15 `"Operators: transport"', add
		label define sSOC_lbl 16 `"Operators: handlers"', add
		
		label values LifeOcc2 sSOC_lbl 	

*-------------------------------------------------------------------------------
* Set up predictions
*--------------------------------------------------------
	preserve
		

** SPECIFICATION (3)				
	rename time xtime
	drop if (selectOLS~=1 )
	collapse (median) lrwage p1* ts* ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl (mean) WageCspline_r timeC1 timeC2 timeC3 timeC4, by(xtime LifeOcc2) 
	rename xtime time
	xtset LifeOcc2 time
	tsfill	
	*Predictions using the cubic spline specification
		by LifeOcc2, sort: gen CpredW = timeC1*ts1coef + timeC2*ts2coef + timeC3*ts3coef + timeC4*ts4coef ///
										+ p1coefphys*ONETPhysPC1_jl + p1coefksa1*ONETKsaPC1_jl + p1coefksa2*ONETKsaPC2_jl ///
										+ ts1coefphys*ONETPhysPC1_jl*timeC1 + ts2coefphys*ONETPhysPC1_jl*timeC2 + ts3coefphys*ONETPhysPC1_jl*timeC3 + ts4coefphys*ONETPhysPC1_jl*timeC4  ///
										+ ts1coefksa1*ONETKsaPC1_jl*timeC1 + ts2coefksa1*ONETKsaPC1_jl*timeC2 + ts3coefksa1*ONETKsaPC1_jl*timeC3 + ts4coefksa1*ONETKsaPC1_jl*timeC4   ///
										+ ts1coefksa2*ONETKsaPC2_jl*timeC1 + ts2coefksa2*ONETKsaPC2_jl*timeC2 + ts3coefksa2*ONETKsaPC2_jl*timeC3  + ts4coefksa2*ONETKsaPC2_jl*timeC4 

		gen CpredTime =  timeC1*ts1coef + timeC2*ts2coef + timeC3*ts3coef + timeC4*ts4coef
		gen CpredPhys = p1coefphys*ONETPhysPC1_jl + ts1coefphys*ONETPhysPC1_jl*timeC1 + ts2coefphys*ONETPhysPC1_jl*timeC2 + ts3coefphys*ONETPhysPC1_jl*timeC3 + ts4coefphys*ONETPhysPC1_jl*timeC4
		gen CpredKsa1 = p1coefksa1*ONETKsaPC1_jl + ts1coefksa1*ONETKsaPC1_jl*timeC1 + ts2coefksa1*ONETKsaPC1_jl*timeC2 + ts3coefksa1*ONETKsaPC1_jl*timeC3 + ts4coefksa1*ONETKsaPC1_jl*timeC4
		gen CpredKsa2 = p1coefksa2*ONETKsaPC2_jl + ts1coefksa2*ONETKsaPC2_jl*timeC1 + ts2coefksa2*ONETKsaPC2_jl*timeC2 + ts3coefksa2*ONETKsaPC2_jl*timeC3 + ts4coefksa2*ONETKsaPC2_jl*timeC4 		
		}
		
		
	*Normalize raw wages
		by LifeOcc2, sort: egen meanw = median(lrwage)
		gen  nrmW = lrwage - meanw
		
	label values LifeOcc2 sSOC_lbl 
	gen Year = time+1983
	label variable LifeOcc2 "Occupation"
	
*-------------------------------------------------------------------------------
* Graph predicted Wages
*--------------------------------------------------------	

		
	*Cubic Spline
	twoway (line CpredW Year,  by(LifeOcc2) ) ,  /*
	*/  ytitle("Predicted Log-Wage") xtitle("Year") legend(lab(1 "Cubic Spline") )  /*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot))  yline(0, lcolor(red)) ysc(r(-0.6 0.3))
		graph export $OUT_dir\PredW_Occ_CS2.eps, as(eps) preview(on) replace
		graph export $OUT_dir\PredW_Occ_CS2.pdf, as(pdf) replace		
		
	twoway (line WageCspline_r Year ,  by(LifeOcc2) ) ,  /*
	*/  ytitle("Residual") xtitle("Year") legend(lab(1 "Cubic Spline") )  /*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot))  yline(0, lcolor(red)) 
		graph export $OUT_dir\ResidW_Occ_CS2.eps, as(eps) preview(on) replace
		graph export $OUT_dir\ResidW_Occ_CS2.pdf, as(pdf) replace	
		
		
*-------------------------------------------------------------------------------
* Graph payments to factors
*--------------------------------------------------------			

	*------ Cubic Spline ------*
	twoway (line CpredTime Year if LifeOcc2==1),     ///
		title("Cubic Spline") xtitle("Year") ytitle("Predicted Wage") ///
		graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot))  yline(0, lcolor(red)) ysc(r(-0.3 0.4)) ylabel(-0.3(0.1)0.4) ///
		saving($OUT_dir\Cyear, replace)
		
	twoway (line CpredPhys Year if LifeOcc2==1),      ///
		title("Physical Component") xtitle("Year") ytitle("Predicted Wage") ///
		graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot))  yline(0, lcolor(red)) ysc(r(-0.3 0.4)) ylabel(-0.3(0.1)0.4) ///
		saving($OUT_dir\CPhys, replace)
		 
	twoway (line CpredKsa1 Year if LifeOcc2==1),     ///
		title("Knowledge-Skill Task Component #1") xtitle("Year") ytitle("Predicted Wage") ///
		graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot))  yline(0, lcolor(red)) ysc(r(-0.3 0.4)) ylabel(-0.3(0.1)0.4) ///
		saving($OUT_dir\CKsa1, replace)
		 
	twoway (line CpredKsa2 Year if LifeOcc2==1),     ///
		title("Knowledge-Skill Task Component #2") xtitle("Year") ytitle("Predicted Wage") ///
		graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot))  yline(0, lcolor(red)) ysc(r(-0.3 0.4)) ylabel(-0.3(0.1)0.4) ///
		saving($OUT_dir\CKsa2, replace)
		
	graph combine $OUT_dir\Cyear.gph $OUT_dir\CPhys.gph $OUT_dir\CKsa1.gph $OUT_dir\CKsa2.gph 
	graph export $OUT_dir\TimeComponents_CS2.eps, as(eps) preview(on) replace
	graph export $OUT_dir\TimeComponents_CS2.pdf, as(pdf) replace			
	
	

***********************************************************************		
	rename Year wave
		keep CpredW LifeOcc2 wave lrwage
		rename CpredW nrmW
		rename LifeOcc2 SOC

		save $InputDTAs_dir\OccPredTwages_CS2.dta, replace
			
		
			
************************************************************************
	restore
*-------------------------------------------------------------------------------
* Graph by physical quartile
*--------------------------------------------------------				
preserve

	xtile quart = ONETPhysPC1_jl, nq(4)
	rename time xtime
	collapse (mean) lrwage p1* t* ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl, by( quart xtime ) 
	rename xtime time
	xtset quart time
	tsfill
		
	gen Year = time+1983
	label variable quart "Physical Task Quartile"
		label define quart_lbl 1 `"0-25th Percentile Physical Task"'
		label define quart_lbl 2 `"26-50th Percentile Physical Task"', add
		label define quart_lbl 3 `"51-75th Percentile Physical Task"', add
		label define quart_lbl 4 `"75-100th Percentile Physical Task"', add
		
		label values quart quart_lbl				


	*Predictions 
		by quart, sort: gen CpredW = timeC1*ts1coef + timeC2*ts2coef + timeC3*ts3coef + timeC4*ts4coef ///
										+ p1coefphys*ONETPhysPC1_jl + p1coefksa1*ONETKsaPC1_jl + p1coefksa2*ONETKsaPC2_jl ///
										+ ts1coefphys*ONETPhysPC1_jl*timeC1 + ts2coefphys*ONETPhysPC1_jl*timeC2 + ts3coefphys*ONETPhysPC1_jl*timeC3 + ts4coefphys*ONETPhysPC1_jl*timeC4  ///
										+ ts1coefksa1*ONETKsaPC1_jl*timeC1 + ts2coefksa1*ONETKsaPC1_jl*timeC2 + ts3coefksa1*ONETKsaPC1_jl*timeC3 + ts4coefksa1*ONETKsaPC1_jl*timeC4   ///
										+ ts1coefksa2*ONETKsaPC2_jl*timeC1 + ts2coefksa2*ONETKsaPC2_jl*timeC2 + ts3coefksa2*ONETKsaPC2_jl*timeC3  + ts4coefksa2*ONETKsaPC2_jl*timeC4 	
		tssmooth ma sCpredW=CpredW, window(2 1 2)
		
		twoway (line CpredW Year,  by(quart)  ) ,  /*
	*/  ytitle("Predicted Log-Wage") xtitle("Year") legend( lab(1 "Quadratic Specification") ) /*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) yline(0, lcolor(red)) 
		graph export $OUT_dir\PredW_PhysQrt_CS2.eps, as(eps) preview(on) replace
		graph export $OUT_dir\PredW_PhysQrt_CS2.pdf, as(pdf) replace							

************************************************************************		
restore
*-------------------------------------------------------------------------------
* Produce .csv's to read into FORTRAN
*--------------------------------------------------------	

preserve	
	collapse (median) ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl, by(LifeOcc2) 
	export delimited using $OUT_dir\OccupationOnetValues, replace
restore


preserve	
	collapse (median) timeC*, by(time) 
	export delimited using $OUT_dir\time_CS2, replace
restore


	putexcel set $OUT_dir\OLSWage4DW_CS2,  replace
	putexcel A1 = ("Regressor") B1=("Cubic Spline") ///
	A2 = ("Exp") A3 = ("Exp2")   ///
	A4 = ("HS") A5 = ("not white") A6 = ("married")  ///
	 A7 = ("Phys") A8 = (" Ksa1 ") A9 = (" Ksa2 ") A10 = ("timeC1") ///
	A11 = ("timeC2") A12 = ("timeC3") A13 = ("timeC4") A14 = ("Phys*timeC1") ///
	 A15= ("Phys*timeC2") A16= ("Phys*timeC3") A17= ("Phys*timeC4") ///
	 A18 = ("Ksa1*timeC1") A19= ("Ksa1*timeC2") A20= ("Ksa1*timeC3") A21= ("Ksa1*timeC4") ///
	 A22 = ("Ksa2*timeC1") A23= ("Ksa2*timeC2") A24= ("Ksa2*timeC3") A25= ("Ksa2*timeC4")
	 A26= ("constant")

	 
		estimates use $OUT_dir\WageCSpline2
		matrix b = e(b)'
		putexcel B2 = matrix(b)	



*HealthTrans.do
*-------------------v.7-28-2017; @A. Michaud for DIoption w/ DW---------------------------------*
global OUT_dir "OUT"
***************************************************************************************************************
* This code computes statistics related to the transition between health states. Specicially:
*	1) Estimate linear probability model for health transitions and death
*	2) Compute distribution of health status by age
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-calibdata2.dta; created by MainCalib_StartHere.do
*	-ONETpca.dta; Occupation tasks principal components from "Risky Occ Paper", see DW.
***************************************************************************************************************
*Section 1: Set up

   use $InputDTAs_dir\calibdata2, clear
   
	drop if Age<23
	gen w69 = wpts if wave==1983
	by x11101ll, sort: egen w69m = mode(w69)
	*We don't use females or latino subsample
	gen select=(  Sex==1 & Latino==0 )

	ssc install ivreg2
	ssc install ranktest
	
*Merge in Onet data to match to lifetime occupation
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
*normalize them all
foreach vi of varlist *ONET*PC*{
	qui sum `vi'
	replace `vi' = (`vi'-r(mean))/r(sd)
}

***************************************************************************************************************
*This section estimates health transitions using a linear probability model.
*	-Why linear? 1) It is the closest to our model assumption; ie: transitions are not duration dependent
*				 2) It also allows us to sensibly IV for the impact of occupation on health.
*	-Estimates are done separately for the movement of health state "i" to state "j"
*		-Notation: Hmat_0_1 means moving from disability==0 to disability==1
*		-Disability codes: 0=none, 1=moderate, 2= severe as coded in "health.do"
*	-Mortality risk is done separately and does not include occupation effects
*		-Interpretation: occupation affects mortality only through current health state
*		-Mortality has one more age group, those over 65.
*-------------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------------
*Create biniary variables and lags
xtset x11101ll wave
	gen Wlimit0LP=1 if (WlimitLP==0)
	replace Wlimit0LP=0 if (WlimitLP==1 | WlimitLP==2)
	gen Wlimit1LP=1 if (WlimitLP==1)
	replace Wlimit1LP=0 if (WlimitLP==0 | WlimitLP==2)
	gen Wlimit2LP=1 if (WlimitLP==2)
	replace Wlimit2LP=0 if (WlimitLP==1 | WlimitLP==0)
	gen lWlimLP = L.WlimitLP

*Run linear probability regression.
	*Alternative: linear w/ physical NO IV
		*reg Wlimit1 ageD* ONETPhysPC1_jl [pw=wpts] if (select==1 & lWlim==0 & Age<66 & wave<1997), robust
	*In use: linear w/ IV
	forvalues i=0/2{
		forvalues j=0/2{
		*From health status i to health status j
		ivreg2 Wlimit`j'LP ageD* old (ONETPhysPC1_jl =ONETKsaPC1_jl ONETKsaPC2_jl ONETKsaPC3_jl)  [pw=wpts] if (select==1 & lWlimLP==`i' & Age>29 & Age<66 & wave<1997), savefirst robust endog(ONETPhysPC1_jl)
			estimates save $OUT_dir\Hmat_`i'_`j', replace	
			estimate store Hmat_`i'_`j'
			*To make residual plot
				reg Wlimit`j'vAM ONETPhysPC1_jl ageD* old  [pw=wpts] if (select==1 & lWlim==`i' & Age>29 & Age<66 & wave<1997)			
				predict Hmat_`i'_`j'_r , residuals 
		}
		}
		*Death
	forvalues i=0/2{
		reg dead ageD* old  [pw=wpts] if (select==1 & lWlimLP==`i'  & wave<1997), robust
		estimates save $OUT_dir\Hmat_`i'_dead, replace
		estimate store Hmat_`i'_dead
	}

*2) Write .tex stuff for pretty paper purposes
	ssc install estout
	esttab Hmat_0_1 Hmat_0_2 Hmat_0_dead Hmat_1_0 Hmat_1_2 Hmat_1_dead Hmat_2_0 Hmat_2_1 Hmat_2_dead ///
                   using $OUT_dir\Hmat.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		   nomtitles numbers /// mtitles("(1)" "(2)" "(3)" "(4)") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace
			   
***************************************************************************************************************
	*Residual plots for EACH transition as an IV validity
	*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
		reg ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl ONETKsaPC3_jl ageD* old  [pw=wpts] if (select==1 & Age<66 & wave<1997)			
			predict OnetReg_r , residuals 		
			
/*	forvalues i=0/2{
		forvalues j=0/2{
		reg Hmat_`i'_`j'_r OnetReg_r [pw=wpts]  if (select==1 & lWlim==`i' & Age>29 & Age<66 & wave<1997) 
		local beta = round(_b["OnetReg_r"] ,0.0001) 
		local sd   = round(_se["OnetReg_r"] ,0.0001) 

		twoway (scatter Hmat_`i'_`j'_r OnetReg_r, msymbol(O) msize(large)) (lfit Hmat_`i'_`j'_r OnetReg_r, estopts(nocons))  if (select==1 & Age>29  & Age<66 & wave<1997), /// 
		xtitle("O*NET non-physical (residuals)") ytitle("Transition Probability (residuals)")  /// 
		legend(order( 2 "Fit line: `beta' (`sd')") ring(0) position(8)) /// 
		title("`i' to `j'") graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) 
		graph export $OUT_dir\Hmat_`i'_`j'_partialresid.eps, replace 
		graph export $OUT_dir\Hmat_`i'_`j'_partialresid.pdf, replace
	}
	}	
*/
	
***************************************************************************************************************
*This Section makes all the output from the health transition regressions and tabs the distribution by age
* 1) stuff for computation into csvs
* 2) stuff for paper into latex
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
*1) write csv stuff for comp inputs
	*This section does two things.
		*1) Prints complete coefficient estimates from the linear probabilitiy IV	
		*2) Estimates "baseline" hazard for each occupaiton. In this case that would be the hazard for the ommitted age group, those <46
	
	putexcel set $OUT_dir\HmatIn4DW, modify
	putexcel A1 = ("Stat") B1 = ("from 0 to 1") C1 = ("from 0 to 2") D1 = ("from 1 to 0") E1 = ("from 1 to 2") ///
    F1 = ("from 2 to 0") G1 = ("from 2 to 1") H1 = ("from 0 to dead") I1 = ("from 1 to dead") J1 = ("from 2 to dead") ///
	A3 = ("Age>45 & Age<56") A4 = ("Age>55 & Age<61") A5 = ("Age>60 & Age<66")  ///
	A2 = ("Coefficient on Occ IV") A6 = ("Age>65") A7 = ("Constant")  
	
	*Too lazy to loop this nicely
		estimates use $OUT_dir\Hmat_0_1
		*matrix list e(b)
		matrix b = e(b)'
	  *Here are the full coefficients
		putexcel B2 = matrix(b) 
	  *Here is the baseline estimate
		predict base_0_1 if Age<46	
			
		estimates use $OUT_dir\Hmat_0_2
		matrix b = e(b)'
		putexcel C2 = matrix(b) 
		predict base_0_2 if Age<46	
		
		estimates use $OUT_dir\Hmat_1_0
		matrix b = e(b)'
		putexcel D2 = matrix(b) 
		predict base_1_0 if Age<46	
		
		estimates use $OUT_dir\Hmat_1_2
		matrix b = e(b)'
		putexcel E2 = matrix(b)
		predict base_1_2 if Age<46	

		estimates use $OUT_dir\Hmat_2_0
		matrix b = e(b)'
		putexcel F2 = matrix(b)
		predict base_2_0 if Age<46	
		
		estimates use $OUT_dir\Hmat_2_1
		matrix b = e(b)'
		putexcel G2 = matrix(b) 
		predict base_2_1 if Age<46	
		
		estimates use $OUT_dir\Hmat_0_dead
		matrix b = e(b)'
		putexcel H3 = matrix(b) 
		
		estimates use $OUT_dir\Hmat_1_dead
		matrix b = e(b)'
		putexcel I3 = matrix(b) 	
		
		estimates use $OUT_dir\Hmat_2_dead
		matrix b = e(b)'
		putexcel J3 = matrix(b) 

	preserve
		collapse (median) base_0_1 base_0_2 base_1_0 base_1_2 base_2_0 base_2_1, by(LifeOcc2)
		sort LifeOcc2
		export delimited using $OUT_dir\Hmat_OccBase.csv, replace
	restore
		


*3) Stationary dist
svyset x11101ll [pw=wpts]
	
putexcel set $OUT_dir\Hdist4DW, modify
	putexcel A1 = ("Age group") B1 = ("0") C1 = ("moderate") D1 = ("severe")  ///
	A2= ("Age>29 & Age<46") A3 = ("Age>45 & Age<56") A4 = ("Age>55 & Age<61") A5 = ("Age>60 & Age<66") 
 	
	svy: tabulate WlimitLP  if (Age>29 & Age<46 & WlimitLP<3), format(%11.3g) percent	
	matrix b = e(b)	
	putexcel B2 = matrix(b) 	
	
	svy: tabulate WlimitLP  if (ageD2==1 & WlimitLP<3), format(%11.3g) percent	
	matrix b = e(b)	
	putexcel B3 = matrix(b) 	
	
	svy: tabulate WlimitLP  if (ageD3==1 & WlimitLP<3), format(%11.3g) percent	
	matrix b = e(b)	
	putexcel B4 = matrix(b) 	
	
	svy: tabulate WlimitLP  if (ageD4==1 & WlimitLP<3), format(%11.3g) percent	
	matrix b = e(b)	
	putexcel B5 = matrix(b) 		

****************************************************************************************************
** NOT IN USE ** NOT IN USE ** NOT IN USE ** NOT IN USE ** NOT IN USE ** NOT IN USE ** NOT IN USE **	
****************************************************************************************************
*-------------------------------------------------------------------------------------------------
* Coding Chunk: Markov transitions
*	These are the raw markov transitions for each age group. They do not include the effect of occupation
*-------------------------------------------------------------------------------------------------	
*Short detour to calc summary statistics of the transistion matrix
*svyset [pweight=wpts]
*estpost svy: tab lWlim WlimitLPvAM if (Age>21 & Age<46 & lWlim~=3), row
*	esttab  using "Age1_Hmat.csv", b(4) nostar unstack mtitle(`e(colvar)') plain replace
*estpost svy: tab lWlim WlimitLPvAM if (Age>45 & Age<56 & lWlim~=3), row
*	esttab  using "Age2_Hmat.csv", b(4) nostar unstack mtitle(`e(colvar)') plain replace
*estpost svy: tab lWlim WlimitLPvAM if (Age>55 & Age<61 & lWlim~=3), row
*	esttab  using "Age3_Hmat.csv", b(4) nostar unstack mtitle(`e(colvar)') plain replace
*estpost svy: tab lWlim WlimitLPvAM if (Age>60 & Age<66 & lWlim~=3), row
*	esttab  using "Age4_Hmat.csv", b(4) nostar unstack mtitle(`e(colvar)') plain replace
*estpost svy: tab lWlim dead if (Age>65 & lWlim~=3), row
*	esttab  using "Old_Deathmat.csv", b(4) nostar unstack mtitle(`e(colvar)') plain replace
	
*svy: mean Yrs2Death  if Age==65 & WlimitLPvAM==1 & Yrs2Death<50
*svy: mean Yrs2Death  if Age==65 & WlimitLPvAM==2 & Yrs2Death<50
*svy: mean Yrs2Death  if Age==65 & WlimitLPvAM==0 & Yrs2Death<50

*************************************************************************************************	

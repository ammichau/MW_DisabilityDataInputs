*ModvDataRegs.do
*-------------------v.7-31-2017; @A. Michaud for DIoption w/ DW---------------------------------*
*Be sure to set up directories according to MainCalib_StartHere and run all of the PSID and CPS set-up files first.
***************************************************************************************************************
* This code runs regressions in the PSID data that we will also run in the model to check the key implications of our theory.
*---------------------------------------------------------------------------------------------------
* Regression 1: Logit on Long run wage decline and DI
*		*Dependent = DI in t+1
		*Independent: dummies for age and health groups;
				*ln(aggregate unemployment) 
				*z-shocks
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-$InputDTAs_dir\OccPredTwages.dta: z-shocks; created by PSID_dir\OccWageTS.do
*	-$InputDTAs_dir\CPS_Urates.dta: Unemplyoment rates; created by CPS_dir\CPS_ExclRestr.do
*	-$InputDTAs_dir\who.dta: The file identifying who is on DI; created by PSID_dir\SumStats_WhoGoes.do
***************************************************************************************************************

*-----------------------------------------------------
*Section 1: Set up
*-----------------
*---File Setup
	*Bring in file ID-ing DI
	use $InputDTAs_dir\who, clear
	*Drop ommitted demographics and years
		drop if (x11101ll==. | Age<30 | Age>65 | Sex==2)
			* could also drop if selectDIstats==0
		gen year = wave	
		drop if (year<1984 | year>1997)
		
		keep x11101ll wave x11102 xsqnr wpts LifeOcc2 ageD2 ageD3 ageD4 EdBin AgeBin WlimitLP WlimitLPvAM SSDI SSDI_LP SSDIv2 newSSDI newSSDIv2 selectDIstats year
	*Merge files
		*Occupation wage times series
			rename LifeOcc2 SOC
			merge m:1 SOC wave using $InputDTAs_dir\OccPredTwages_1.dta
			drop if _merge==2
			drop  _merge	
			rename SOC LifeOcc2
		*Demographic unemployment time series
			merge m:1 year using $InputDTAs_dir\CPS_Urates.dta
			drop  _merge
			drop if (year<1984 | year>1997)

*---Variables Setup			
	*DI in t+1
		xtset x11101ll year
		gen f1SSDI_LP= F1.SSDI_LP
	*Work limitation dummies
		gen WlimD1=(WlimitLPvAM==1)
		gen WlimD2=(WlimitLPvAM==2)
	*Match age group specific
		gen FTFYurate_Age = FTFYurate_Age1 if AgeBin==1
		gen ANYurate_Age = ANYurate_Age1 if AgeBin==1
		forvalues a =2/4{
			replace FTFYurate_Age = FTFYurate_Age`a' if AgeBin==`a'
			replace ANYurate_Age = ANYurate_Age`a' if AgeBin==`a'
		}
	*take logs of urate
	foreach v of varlist tFTFYurate tANYurate FTFYurate_noCol ANYurate_noCol FTFYurate_Age ANYurate_Age {
		gen l`v' = ln(`v')
		}
*-----------------------------------------------------
*Section 2: Analyze
*		Tried Several Specification, robust over all of them
*-----------------
		
	* 1) Aggregate Rates 
		*FTFY unemployment
			 logit f1SSDI_LP nrmW ltFTFYurate ageD* WlimD* if selectDIstats==1 
				estimates save $OUT_dir\ZLogit_tFTFY, replace	
				estimate store ZLogit_tFTFY
		*ANY unemployment
			 logit f1SSDI_LP nrmW ltANYurate ageD* WlimD* if selectDIstats==1 
				estimates save $OUT_dir\ZLogit_tFTFY, replace	
				estimate store ZLogit_tANY
	* 2) <college				
		*FTFY unemployment
			 logit f1SSDI_LP nrmW lFTFYurate_noCol ageD* WlimD* if selectDIstats==1 
				estimates save $OUT_dir\ZLogit_FTFYnc, replace	
				estimate store ZLogit_FTFYnc
		*ANY unemployment
			 logit f1SSDI_LP nrmW lANYurate_noCol ageD* WlimD* if selectDIstats==1 
				estimates save $OUT_dir\ZLogit_ANYnc, replace	
				estimate store ZLogit_ANYnc
	* 3) Age group specific
		*FTFY unemployment
			 logit f1SSDI_LP nrmW lFTFYurate_Age ageD* WlimD* if selectDIstats==1 
				estimates save $OUT_dir\ZLogit_FTFYnc, replace	
				estimate store ZLogit_FTFYage
		*ANY unemployment
			 logit f1SSDI_LP nrmW lANYurate_Age ageD* WlimD* if selectDIstats==1 
				estimates save $OUT_dir\ZLogit_ANYnc, replace	
				estimate store ZLogit_ANYage

*-----------------------------------------------------
*Section 3: Print Output
*-----------------

esttab ZLogit_tFTFY ///
                   using $OUT_dir\zLogit.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Relationship between Economic Shocks and Flows onto DI (PSID))       ///			   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
















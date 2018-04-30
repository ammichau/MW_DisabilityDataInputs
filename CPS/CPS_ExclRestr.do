*CPS_ExclRestr.do
*-------------------@A. Michaud for DIoption w/ DW---------------------------------*
	*Current: v.4-30-2018 @A. Michaud; v.GitHub: final specifications only
	*O.G.: v.7-24-2017 @A. Michaud
	*!!!Be sure to configure directories in PSID/MainCalib_StartHere.do!!*
***************************************************************************************************************
* This code creates exclusion restrictions for first step of Heckit Regression
*---------------------------------------------------------------------------------------------------
* We consider one year and five year changes in FTFY aggregate employment within a demographic group.
*	-Specifically, first and fifth difference of ln(Employment) estimated from CPS
* Specification of Demographic Group:
*	- AgeXEducation
* Where:
*	- Occupation= 16 SOC codes
*	- Age = 4 demographic groups (age>29 & age<46); (age>45 & age<56); (age>55 & age<61); (age>60 & age<66)
*	- Education = 3 groups: <HS; HS or some college; 4+ yr college
* ADDENDUM (7-24-2017):
*	We also use this code to calculate Unemployment rates for use in model validation regressions
*	-(see SumStats_WhoGoes)
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-CPSfull2017.dta- this is the raw data extract from CPS using IPUMS 
***************************************************************************************************************
*Section 1: Set up

cd $PSID_dir	
*Create files to append in later loops
	clear all
	set more off
	gen dummy=1
	save $InputDTAs_dir\CPS_ExclRestr, replace

cd $root_dir
*Open CPS data and code occupations, employment, and demographics
use $CPS_dir\CPSfull2017, clear

	*Use codes from occ90
	rename occ1990 occ90
	gen SOC = 1 if (occ90>002 & occ90<38)
	replace SOC = 2 if (occ90>042 & occ90<236)
	replace SOC = 3 if (occ90>242 & occ90<286)
	replace SOC = 4 if (occ90>302 & occ90<390)
	replace SOC = 5 if (occ90>402 & occ90<408)
	replace SOC = 6 if (occ90>412 & occ90<428)
	replace SOC = 7 if (occ90>432 & occ90<445)
	replace SOC = 8 if (occ90>444 & occ90<448)
	replace SOC = 9 if (occ90>447 & occ90<470)
	replace SOC = 10 if (occ90>472 & occ90<500)
	replace SOC = 11 if (occ90>502 & occ90<550)
	replace SOC = 12 if (occ90>552 & occ90<618)
	replace SOC = 13 if (occ90>632 & occ90<700)
	replace SOC = 14 if (occ90>702 & occ90<800)
	replace SOC = 15 if (occ90>802 & occ90<860)
	replace SOC = 16 if (occ90>862 & occ90<890)
	drop if SOC>889
	drop occ90

	label define SOC_lbl 1 `"Manager"'
	label define SOC_lbl 2 `"Professional"', add
	label define SOC_lbl 3 `"Sales"', add
	label define SOC_lbl 4 `"Clerical, admin"', add
	label define SOC_lbl 5 `"Service: clean/maint"', add
	label define SOC_lbl 6 `"Service: protect"', add
	label define SOC_lbl 7 `"Service: food"', add
	label define SOC_lbl 8 `"Health"', add
	label define SOC_lbl 9 `"Service: Personal"', add
	label define SOC_lbl 10 `"Farm, forest, fish"', add
	label define SOC_lbl 11 `"Mechanic"', add
	label define SOC_lbl 12 `"Constr"', add
	label define SOC_lbl 13 `"Production"', add
	label define SOC_lbl 14 `"Op: machine"', add
	label define SOC_lbl 15 `"Op: transport"', add
	label define SOC_lbl 16 `"Op: handlers"', add

	label values SOC SOC_lbl 

*Code demographics
	*First age bins corresponding  to our model bins
		gen ageD1=(age>29 & age<46)
		gen ageD2=(age>45 & age<56)
		gen ageD3=(age>55 & age<61)
		gen ageD4=(age>60 & age<66)
	*Next, education levels
		gen Educ1=(educ<72)
		gen Educ2=(educ>71 & educ<110)
		gen Educ3=(educ>109)
		
	gen AgeEdBin=.	
	gen EdBin=.
	*Bins will be the cross products
		forvalues a =1/4{
			forvalues e=1/3 {
			local aa= `a'*10
				replace AgeEdBin=`aa'+`e' if (ageD`a'==1 & Educ`e'==1)
				replace EdBin=`e' if Educ`e'==1
		}
		}
		
*Define employment		
  *=> 50 weeks at 30+hrs/wk
	gen FTFYemp=((empstat==10 | empstat==12) & (wkswork1>49 & wkswork1<53) & (uhrswork>29 & uhrswork<80))
  *=> Any Employment
	gen ANYemp=((empstat==10 | empstat==12) )
	
*Define labor force	
	gen LF=((empstat==20 | empstat==21) | ANYemp==1 )
	
*Since we are going with men only, I'll do the same here.
	drop if (sex==2 | AgeEdBin==.)
	
cd $PSID_dir
	*********************************************************************************
	*DETOUR: Calculate Urate for model validation Logits.
	********************************************************************************		
	
	*Aggregate (total across all demographics)
	preserve
		collapse (sum) FTFYemp ANYemp LF  [pw= wtsupp], by(year)
				gen tFTFYurate = 1-FTFYemp/LF
				gen tANYurate = 1-ANYemp/LF		
			save $InputDTAs_dir\CPS_Urates, replace
	restore
	
	*By Education- <Col only
	preserve	
		drop if EdBin==3
		collapse (sum) FTFYemp ANYemp LF  [pw= wtsupp], by(year)
				gen FTFYurate_noCol = 1-FTFYemp/LF
				gen ANYurate_noCol = 1-ANYemp/LF	
			merge 1:1 year using $InputDTAs_dir\CPS_Urates.dta
			drop _merge
			save $InputDTAs_dir\CPS_Urates, replace
	restore
	
	*By Age	
	preserve	
		gen AgeBin=1 if ageD1==1
			forvalues a =2/4{
			replace AgeBin=`a' if ageD`a'==1
			replace AgeBin=`a' if ageD`a'==1
			replace AgeBin=`a' if ageD`a'==1
			}
			
		collapse (sum) FTFYemp ANYemp LF [pw= wtsupp], by(AgeBin year)
				forvalues a =1/4{
					gen FTFYurate_Age`a' = 1-FTFYemp/LF if AgeBin==`a'
					gen ANYurate_Age`a' = 1-ANYemp/LF if AgeBin==`a'
					}
		collapse (mean) FTFYurate_Age* ANYurate_Age*, by(year)
			merge 1:1 year using $InputDTAs_dir\CPS_Urates.dta
			drop _merge
			save $InputDTAs_dir\CPS_Urates, replace
	restore
	
	
	
	*********************************************************************************
	*Calculate national employment changes for AgeXEd bins
	********************************************************************************
	forvalues a =1/4{
		forvalues e=1/3 {			
		preserve	
		local aa= `a'*10
		drop if AgeEdBin~=`aa'+`e'
		
		collapse (sum) FTFYemp [pw= wtsupp], by(year SOC)
		
		*Total across all occupations
		by year, sort: egen tFTFYemp = total(FTFYemp)
			
		gen tlFTFYemp = ln(tFTFYemp)
			
		tsset SOC year
		*First difference of logs
			gen d5_EtlFTFYemp = tlFTFYemp-L4.tlFTFYemp
			gen d1_EtlFTFYemp = tlFTFYemp-L.tlFTFYemp		
		
		
			gen AgeEdBin = `aa'+`e'
			
			append using $InputDTAs_dir\CPS_ExclRestr
			save $InputDTAs_dir\CPS_ExclRestr, replace
			
      restore	
	  }
	  }
	
	  		
*********************************************************************************
*Clean and apply labels 
********************************************************************************		
		
use $InputDTAs_dir\CPS_ExclRestr.dta, clear		
	keep  d1_EtlFTFYemp d5_EtlFTFYemp year SOC AgeEdBin	
	
	*Name variables
		label var d5_EtlFTFYemp "5 year diff of AgeXEd FTFY Empl"
		label var d5_EtlFTFYemp "1 year diff of AgeXEd FTFY Empl"
	
	*These values can be mysterious, so:
		label define AgeEdBin_lbl 11 `"Age 30-45; lsHS"'
		label define AgeEdBin_lbl 12 `"Age 30-45; HS"', add
		label define AgeEdBin_lbl 13 `"Age 30-45; Col"', add
		label define AgeEdBin_lbl 21 `"Age 46-55; lsHS"', add
		label define AgeEdBin_lbl 22 `"Age 46-55; HS"', add
		label define AgeEdBin_lbl 23 `"Age 46-55; Col"', add
		label define AgeEdBin_lbl 31 `"Age 56-60; lsHS"', add
		label define AgeEdBin_lbl 32 `"Age 56-60; HS"', add
		label define AgeEdBin_lbl 33 `"Age 56-60; Col"', add
		label define AgeEdBin_lbl 41 `"Age 61-65; lsHS"', add
		label define AgeEdBin_lbl 42 `"Age 61-65; HS"', add
		label define AgeEdBin_lbl 43 `"Age 61-65; Col"', add

		label values AgeEdBin AgeEdBin_lbl
		
	*Consistent names for merging in "HeckitRegs.do"
		rename SOC LifeOcc2		
		rename year wave

save $InputDTAs_dir\CPS_ExclRestr, replace



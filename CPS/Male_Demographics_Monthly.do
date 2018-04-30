*CPS_ExclRestr.do
cd $root_dir
cd $CPS_dir 
*-------------------@A. Michaud for DIoption w/ DW---------------------------------*
	*Current: v.4-30-2018 @A. Michaud; v.GitHub: final specifications only
	*O.G.: v.3-7-2018 @A. Michaud
	*!!!Be sure to configure directories in PSID/MainCalib_StartHere.do!!*

***************************************************************************************************************
* This code computes demographic shares of full time/ full year employment over the transition.
*---------------------------------------------------------------------------------------------------
* OUTPUT:
* 1) Initial Demographic shares: Male_Initial_AgeXSOC_Demog.csv
* 2) Evolving Age Shares: Male_Age_Demog.csv
* 3) Evolving Occupation Shares: Male_SOC_Demog.csv
*
* SPECIFICATION DETAILS:
* Males only (as the name of this file quite obviously indicates)
* Monthly
*-------------------------------------------------------------------------------------------------
* INPUT REQUIREMENTS:
*	-CPSfull2018.dta- this is the raw data extract from CPS using IPUMS
*
***************************************************************************************************************
*Section 1: Set up
	
*Open CPS data and code occupations, employment, and demographics
use CPS_MONTHLY, clear

*Since we are going with men only, I'll do the same here.
	drop if (sex==2)
	
drop if asecflag==2
drop serial asecflag month pernum

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
	gen ageG=1 if (age>24 & age<45)
	replace ageG=2 if (age>44 & age<50)
	replace ageG=3 if (age>49 & age<55)
	replace ageG=4 if (age>54 & age<60)
	replace ageG=5 if (age>59 & age<65)
		
*Define employment		
  *=> 50 weeks at 30+hrs/wk
	gen FTFYemp=((empstat==10 | empstat==12) & (wksworkorg>49 & wksworkorg<53) & (uhrsworkorg>29 & uhrsworkorg<80))
  *=> Any Employment
	gen ANYemp=((empstat==10 | empstat==12) )
	
*Define labor force	
	gen LF=((empstat==20 | empstat==21) | ANYemp==1 )
	
	drop if ageG==.
	drop if SOC==.
	
	gen counter=1

	preserve
		
		collapse (sum) counter [pw= wtfinl], by(year ageG)
		by year, sort: egen tPop = total(counter)
		xtset ageG year
		gen Ashare = counter/tPop
		drop counter tPop
		reshape wide Ashare, i(year) j(ageG)	
	
		export delimited year Ashare* using "Male_Age_Demog", replace
	
	restore

	preserve
		drop if ANYemp==0
		collapse (sum) counter [pw= wtfinl], by(year SOC)
		by year, sort: egen tPop = total(counter)
		xtset SOC year
		gen SOCshare = counter/tPop	
		drop counter tPop
		reshape wide SOCshare, i(year) j(SOC)	
	
		export delimited year SOCshare* using "Male_SOC_Demog", replace
	
	restore
	
	preserve
		drop if year>1985
		drop if ANYemp==0
		collapse (sum) counter [pw= wtfinl], by(ageG SOC)
		egen tPop = total(counter)
		gen SOC_x_Ageshare = counter/tPop	
		drop counter tPop
		reshape wide SOC_x_Ageshare, i(ageG) j(SOC)	
	
		export delimited ageG SOC_x_Ageshare* using "Male_Initial_AgeXSOC_Demog", replace			
	
	restore	

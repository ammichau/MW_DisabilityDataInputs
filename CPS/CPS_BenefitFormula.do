*CPS_BenefitFormula.do
*-------------------v.1-29-2018; @A. Michaud for DIoption w/ DW---------------------------------*
*This file calculates the raw nominal annual labor income for our demographic of interest- men without college
*	to be combined with the bendpoints for model calibration of policy parameters
***************************************************************************************************************

*-------------------------------------------------------------------------------------------------
* Requirements:
*	-CPSfull2017.dta- this is the raw data extract from CPS using IPUMS
*
***************************************************************************************************************
*Section 1: Set up
	clear all
	set more off
	cd $root_dir

	use $CPS\CPSfull2017.dta

*Code demographics
	*We may be most interested in prime age
	gen Age50s=(age>49 & age<61)
	*Next, education levels
		gen Educ1=(educ<72)
		gen Educ2=(educ>71 & educ<110)
		gen Educ3=(educ>109)
	
*Define employment		
  *=> 50 weeks at 30+hrs/wk
	gen FTFYemp=((empstat==10 | empstat==12) & (wkswork1>49 & wkswork1<53) & (uhrswork>29 & uhrswork<80))
  *=> Any Employment
	gen ANYemp=((empstat==10 | empstat==12) )
	
*Define labor force	
	gen LF=((empstat==20 | empstat==21) | ANYemp==1 )
	
*May want to do male and female separate
	gen Male=(sex==1 )
	
*Top codes
replace incwage = . if (incwage>=50000 & (year==1980| year==1981))
replace incwage = . if (incwage>=75000 & (year>1981 & year<1985))
replace incwage = . if (incwage>=199998 & (year>1988| year<1996))

svyset _n [pweight=wtsupp],

	putexcel set MedianWages,  modify
	putexcel A1=("Year") B1=("Male") C1=("Male- No Col, prime") D1=("Male- No Col") E1=("Female- No Col") E1=("Male- No Col, Age 50's") F1=("Male- No Col, Age 50's")
	forvalues y=1980/2015 {
		local row= `y'-1978
		qui summarize incwage if (ANYemp==1 & Male==1 & year==`y' & incwage>1000), det
			putexcel  B`row'=(r(p50))	
		qui summarize incwage if (ANYemp==1 & Male==1 & (Educ1==1 | Educ2==1) & year==`y' & incwage>1000), det
			putexcel  C`row'=(r(p50))	
		qui summarize incwage if (ANYemp==1 & Male==0 & (Educ1==1 | Educ2==1) & year==`y' & incwage>1000), det
			putexcel  D`row'=(r(p50))		
		qui summarize incwage if (ANYemp==1 & Male==1 & (Educ1==1 | Educ2==1) & Age50s==1 & year==`y' & incwage>1000), det
			putexcel  E`row'=(r(p50))	
		qui summarize incwage if (ANYemp==1 & Male==0 & (Educ1==1 | Educ2==1) & Age50s==1 & year==`y' & incwage>1000), det
			putexcel  F`row'=(r(p50))				
		}

	


	

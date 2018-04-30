*occhist.do
*-------------------v.5-1-2017; @A. Michaud for DIoption w/ DW---------------------------------*
cd $PSID_dir
***************************************************************************************************************
* This code reads in and cleans occupation variables from PSID
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-You have to have files set up for psiduse in folder "Mdta", a subdirectory of PSID_dir set in main file
*	-"occ1970_occ1990dd.dta"; David Dorn's crosswalk from 1970 to 1990 codes.
***************************************************************************************************************

clear all
set more off
ssc install psidtools
*help psid
*psid install using Mdta
 *psid install 1968(1)1992 using Mdta


psid use || HretroOcc [68]V197_A [69]V640_A [70]V1279_A [71]V1984_A [72]V2582_A [73]V3115_A ///
					  [74]V3530_A [75]V3968_A [76]V4459_A [77]V5374_A [78]V5873_A [79]V6497_A [80]V7100_A ///
		 || WretroOcc [68]V243_A [69]V609_A [70]V1367_A [71]V2074_A [72]V2672_A [73]V3183_A ///
					  [74]V3601_A [75]V4055_A [76]V4605_A [77]V5507_A [78]V6039_A [79]V6596_A [80]V7198_A ///
		 || HoccCur   [81]V7712 [82]V8380 [83]V9011 [84]V10460 [85]V11651 [86]V13054 [87]V14154 ///
					  [88]V15162 [89]V16663 [90]V18101 [91]V19401 [92]V20701 [93]V22456 [94]ER4017 [95]ER6857 ///
					  [96]ER9108 [97]ER12085 [99]ER13215 [01]ER17226 ///
		 || WoccCur   [81]V7885 [82]V8544 [83]V9194 [84]V10678 [85]V12014 [86]V13233 [87]V14329 ///
				 	  [88]V15464 [89]V16982 [90]V18403 [91]V19703 [92]V21003 [93]V22809 [94]ER4048 [95]ER6888 ///
					  [96]ER9139 [97]ER12116 [99]ER13727 [01]ER17796 ///		  
		 || Tenure1	  [69]V642 [70]V1281 [71]V1987 [72]V2585 [73]V3118 [74]V3533 [75]V3984 ///	 
		 || Tenure2	  [76]V4488 [77]V5397 [78]V5888 [79]V6499 [80]V7102 [81]V7722 [82]V8390 [83]V9021 [84]V10520 [85]V11669 [86]V13069 [87]V14167 ///
		 || Sameocc   [70]V1460 [71]V2172 [72]V2798 [73]V3224 [74]V3646 [75]V4121 [76]V4665 [77]V5585 [78]V6134 [79]V6731 [80]V7364 [81]V8016 ///
					  [82]V8640 [83]V9326 [84]V10973 [85]V11913 [86]V13540 [87]V14587 [88]V16061 [89]V17458 [90]V18789 [91]V20089 [92]V21395 ///
					  [93]V23252 [94]ER3918 [95]ER6788 [96]ER9034 [97]ER11899 [99]ER15983 [01]ER20044 [03]ER23480 [05]ER27448 ///	
		 || WSameocc  [76]V4994 [85]V12268 ///						  
		 || H_age	  [68]V117 [69]V1008 [70]V1239 [71]V1942 [72]V2542 [73]V3095 [74]V3508 [75]V3921 [76]V4436 [77]V5350 [78]V5850 [79]V6462 ///
					  [80]V7067 [81]V7658 [82]V8352 [83]V8961 [84]V10419 [85]V11606 [86]V13011 [87]V14114 [88]V15130 [89]V16631 [90]V18049 [91]V19349 ///
					  [92]V20651 [93]V22406 [94]ER2007 [95]ER5006 [96]ER7006 [97]ER10009 [99]ER13010 [01]ER17013 ///
		 || W_age	  [68]V118 [69]V1011 [70]V1241 [71]V1944 [72]V2544 [73]V3097 [74]V3510 [75]V3923 [76]V4438 [77]V5352 [78]V5852 [79]V6464 [80]V7069 ///
					  [81]V7660 [82]V8354 [83]V8963 [84]V10421 [85]V11608 [86]V13013 [87]V14116 [88]V15132 [89]V16633 [90]V18051 [91]V19351 [92]V20653 ///
					  [93]V22408 [94]ER2009 [95]ER5008 [96]ER7008 [97]ER10011 [99]ER13012 [01]ER17015 ///		  
		 using Mdta , clear design(3)
		save $InputDTAs_dir\occHist, replace

***************************************************************************************************************************		
	
***************************************************************************************************************************		
*Notes:
*	-CurrOcc uses 1970s census codes
*	-#retroOcc recoded retrospectively into 1970s Census codes
*	-After 2001, important changes. Call occhistory2000 separately
*   -Head =10, wife =20 or 22	
*	-For Occs coded 1-7:
* 		1	Professional, technical, and kindred workers
*		2	Managers, officials, and proprietors
*		3	Self-employed businessmen
*		4	Clerical and sales workers
*		5	Craftsmen, foremen, and kindred workers
*		6	Operatives and kindred workers
*		7	Laborers and service workers, farm laborers
*		8	Farmers and farm managers
*		9	Miscellaneous (armed services, protective workers); NA; DK
*		0	Inap.: no father/surrogate; deceased; never worked
*	-Occupations after 1999 coded in 2000 codes
*************************************************************************************************
*Set up
*------------------------------------------------------------------------------------------------
* Go long
psid long

gen HH=(xsqnr==1)
gen HW=(xsqnr==2)

xtset x11101ll wave

* Find Main Job
	
	*Code Head's occ as current if reported in current survey, retro if reported later.
	gen Hocc = HoccCur
	replace Hocc = HretroOcc if Hocc==.
	*Assign to person
	gen occ = Hocc if HH==1
	
	*Same for Wifey
    gen Wocc = WoccCur
	replace Wocc = WretroOcc if Wocc==.
	replace occ = Wocc if HW==1

	
* Merge with David Dorn's nice stuff to go 1970>1990, later to HRS
	*Head
    merge m:1 occ using $InputDTAs_dir\occ1970_occ1990dd.dta
	drop occ 
	rename occ1990dd occ
	drop if _merge==2
	drop _merge 
	
*Clean house
drop HoccCur WoccCur Hretro* Wretro*

*************************************************************************************************
*Create variables used to define what it means to be a lifetime occ in the main code.
*	
*------------------------------------------------------------------------------------------------
*Tenure variables, only need for quite old jobs and need to check >5yrs.
* 1969-1975
*	1	Under 12 months
*   2	1 year, but not more than 19 months
*   3	2 - 3 years or 19 - 42 months
*   4	4 - 9 years
*   5   10 - 19 years
*	6	20 years or more
* 1976-1987
* 	number of months, 998=998 or more, 999= missing

	gen Tnre = 1 if (Tenure1==1 & HH==1)
	replace Tnre = 2 if (Tenure1==2 & HH==1)
	replace Tnre = 3 if (Tenure1==3 & HH==1)
	replace Tnre = 5 if (Tenure1==4 & HH==1)
	replace Tnre = 15 if (Tenure1==5 & HH==1)
	replace Tnre = 25 if (Tenure1==6 & HH==1)
	replace Tnre = 1 if (Tnre==. & Tenure2>0 & Tenure2<13 & HH==1)
	replace Tnre = 2 if (Tnre==. & Tenure2>12 & Tenure2<25 & HH==1)
	replace Tnre = 3 if (Tnre==. & Tenure2>24 & Tenure2<37 & HH==1)
	replace Tnre = 4 if (Tnre==. & Tenure2>35 & Tenure2<49 & HH==1)
	replace Tnre = 5 if (Tnre==. & Tenure2>48 & Tenure2<999 & HH==1)

*Going to meet our threshold for a long job if they've held mostly the same job by age 40
* 3	Both; have had a number of different kinds of jobs but mostly the same occupation; mentions two kinds of jobs
* 5	Mostly the same occupation; same job all of working life
	gen longjob=1 if (H_age>39 & H_age<90 & (Sameocc==3 | Sameocc==5) &HH==1)
	replace longjob=1 if (longjob==. & W_age>39 & W_age<90 & (WSameocc==3 | WSameocc==5) & HW==1)

 keep x11101ll wave x11102 xsqnr occ Tnre longjob  
	save occhist, replace
	append using $InputDTAs_dir\occHist2000.dta
	drop SOC HW HH
	save $InputDTAs_dir\occhist, replace

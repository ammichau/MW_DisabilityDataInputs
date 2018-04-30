*MainCalib_StartHere.do

*-------------------@A. Michaud for DIoption w/ DW---------------------------------*
	*Current: v.4-30-2018 @A. Michaud; v.GitHub: final specifications only
	*O.G.: v.5-1-2017 @A. Michaud
	*!!!Make sure you have an output directory "$root_dir/OUT"!!!

clear all
set more off

*Set your root here
global root_dir "SET YOUR ROOT DIRECTORY HERE"
global PSID_dir "PSID"
global CPS_dir "CPS"
global InputDTAs_dir "PSID\InputDTAs"
global ExtrasOut_dir "Extras"
global OUT_dir "OUT_2"

cd $root_dir
	
***************************************************************************************************************
* As the name would suggest, this is the main shell file that executes all of the work for the calibration targets.
* The main outputs relate to:
*	-Stats about health transitions and distributions by age
*	-Health imapcts of lifetime occupation
*	-Wage impacts of health
*	-Time series for prices of "skills" as defined as lifetime occupation
*-------------------------------------------------------------------------------------------------
* Requirements:
* +Do-files called:
*	SET UP DO'S
*		-occhistory2000.do
*		-occhist.do
*		-work.do
*		-health.do
*	COMPUTATION AND OUTPUT DO'S
*		-HealthTrans.do
*		-HeckitRegs.do
*		-OccWageTS_Spline.do
* +Datasets used:
*		-ONETpca.dta; Occupation tasks principal components from "Risky Occ Paper", see DW.
*		-CPS_ExclRestr.dta and CPS_ExclRestrByEd.dta; created by "CPS_ExlRestr.do" in folder "CPS"
*		-occ1970_occ1990dd.dta; David Dorn's crosswalk from 1970 to 1990 codes.
*		-occ2000_occ1990dd.dta; David Dorn's crosswalk from 2000 to 1990 codes.
*
*									++++++++IMPORTANT++++++++		
* +PSIDUSE MUST BE INSTALLED AND SET UP!
*	-All of the set-up .do files use psiduse
*	-I have specified the sub-folder "Mdta" as having all of the raw data files.
*	-These files are huge, so we're leaving it to the user to fetch and install them properly. 
*	-O/w the user may download variables directly from PSID. The variable codes are clearly listed in the set-up do-files.
*-------------------------------------------------------------------------------------------------	

***************************************************************************************************************
*Section 1: Set up
************
*Set-up	
	*These do-files clean and create needed variables. See files for details
		do $PSID_dir\occhistory2000
			cd $root_dir
		do $PSID_dir\occhist
			cd $root_dir
		do $PSID_dir\work
			cd $root_dir
		do $PSID_dir\health
			cd $root_dir
			global InputDTAs_dir "PSID\InputDTAs"
	*Merge completed .dta's from above .do files
		use $InputDTAs_dir\occhist.dta, clear
		merge m:m x11101ll wave using $InputDTAs_dir\work.dta
		drop _merge
		merge m:m x11101ll wave using $InputDTAs_dir\health.dta
		drop _merge
		save $InputDTAs_dir\calibdata1.dta, replace
*--------------------------------------------------------------------------------------------------		
* Choose the definition of "lifetime occupation" that you want to use.

	global OUT_dir "OUT"
	
	use $InputDTAs_dir\calibdata1.dta, clear

	drop if wave>2015
	 duplicates drop x11101ll wave, force 
*SEO sample- these guys have wpts==0, but L&P include and so will we
	gen SEO=(x11102<7000)
	gen Latino=(x11102>4999 & x11102<7001)
*Coding of Heads and Wives
	*We use both because there are meaningful transitions from head status to "wife" status associated with exiting the labor force.
	replace HW=1 if xsqnr==2
	replace HH=1 if xsqnr==1

*************************************************************************************************
*Coding Chunk 1: Recode Occupations, calculate longest held occupation and merge in risks
*------------------------------------------------------------------------------------------------	
*-------------------------------------------------------------------------------------------------	
	gen occ1990dd = occ
		gen SOC = 1 if (occ1990dd>002 & occ1990dd<38)
		replace SOC = 2 if (occ1990dd>042 & occ1990dd<236)
		replace SOC = 3 if (occ1990dd>242 & occ1990dd<286)
		replace SOC = 4 if (occ1990dd>302 & occ1990dd<390)
		replace SOC = 5 if (occ1990dd>402 & occ1990dd<408)
		replace SOC = 6 if (occ1990dd>412 & occ1990dd<428)
		replace SOC = 7 if (occ1990dd>432 & occ1990dd<445)
		replace SOC = 8 if (occ1990dd>444 & occ1990dd<448)
		replace SOC = 9 if (occ1990dd>447 & occ1990dd<470)
		replace SOC = 10 if (occ1990dd>472 & occ1990dd<500)
		replace SOC = 11 if (occ1990dd>502 & occ1990dd<550)
		replace SOC = 12 if (occ1990dd>552 & occ1990dd<618)
		replace SOC = 13 if (occ1990dd>632 & occ1990dd<700)
		replace SOC = 14 if (occ1990dd>702 & occ1990dd<800)
		replace SOC = 15 if (occ1990dd>802 & occ1990dd<860)
		replace SOC = 16 if (occ1990dd>862 & occ1990dd<890)


		label define SOC_lbl 1 `"Managerial specialty (003-037)"'
		label define SOC_lbl 2 `"Professional specialty operation and technical support(043-235)"', add
		label define SOC_lbl 3 `"Sales (243-285)"', add
		label define SOC_lbl 4 `"Clerical, administrative support (303-389)"', add
		label define SOC_lbl 5 `"Service: private household, cleaning and building services (403-407)"', add
		label define SOC_lbl 6 `"Service: protection (413-427)"', add
		label define SOC_lbl 7 `"Service: food preparation (433-444)"', add
		label define SOC_lbl 8 `"Health services (445-447)"', add
		label define SOC_lbl 9 `"Personal services (448-469)"', add
		label define SOC_lbl 10 `"Farming, forestry, fishing (473-499)"', add
		label define SOC_lbl 11 `"Mechanics and repair (503-549)"', add
		label define SOC_lbl 12 `"Construction trade and extractors (553-617)"', add
		label define SOC_lbl 13 `"Precision production (633-699)"', add
		label define SOC_lbl 14 `"Operators: machine (703-799)"', add
		label define SOC_lbl 15 `"Operators: transport, etc. (803-859)"', add
		label define SOC_lbl 16 `"Operators: handlers, etc. (863-889)"', add
		
		label values SOC SOC_lbl 
		rename SOC Currocc
		drop occ1990dd


*------------------------------------------------------------------------------------------------
*Coding Chunk 1b: Occupational history risk
*------------------------------------------------------------------------------------------------	
	*Find longest held occupation
	by x11101ll, sort: egen Occ2 = mode(Currocc), maxmode

	*Calculate number of years held
		*71.5% of observations of "current occ" are equal to longest held occupation
		*	Number increases to 75% for those over 50
		*27% of the movements are to manager or professional, kind of consistent w/ career ladder.
		*	That's why I use "max" to break ties-- lower numbers are more managerial
			gen d=1 if Currocc==Occ2
				replace d=0 if Currocc~=Occ2
			gen d2 = Tnre if Currocc==Occ2
	
	by x11101ll, sort: egen yrs = sum(d)
	by x11101ll, sort: egen maxTnre = max(d2)
	
	*Define lifetime Occ: require 9 observations and at least 9 years on longest occ
			gen lifeoccI2=((yrs>9 | maxTnre> 9)) 		

	gen LifeOcc2=Occ2 if (lifeoccI2==1)

	drop lastOcc*
	
	gen sameocc= 1 if LifeOcc2==Currocc
	replace sameocc= 0  if LifeOcc2~=Currocc & LifeOcc2~=. & Currocc~=.
*************************************************************************************************
*Coding Chunk 2: Age, disability catagorical dummies
*------------------------------------------------------------------------------------------------	
*-------------------------------------------------------------------------------------------------	
*Use later to merge Aggregate Data	
		gen ageD1=(Age>29 & Age<46)
		gen ageD2=(Age>45 & Age<56)
		gen ageD3=(Age>55 & Age<61)
		gen ageD4=(Age>60 & Age<66)
		gen old=(Age>65)
	*Next, education levels
		rename EdBin EdBin1
		gen EdBin=EdBin2
		replace EdBin= EdBin1 if EdBin1<EdBin
		
		replace lsHS=(EdBin==1)
		replace HS=(EdBin==2)
		replace Col=(EdBin==3)
		gen Educ1=(EdBin==1)
		gen Educ2=(EdBin==2)
		gen Educ3=(EdBin==3)
	
	gen AgeBin=.
	gen AgeEdBin=.
	*Bins will be the cross products
		forvalues a =1/4{
		replace AgeBin=`a' if ageD`a'==1
			forvalues e=1/3 {
			local aa= `a'*10
				replace AgeEdBin=`aa'+`e' if (ageD`a'==1 & Educ`e'==1)
		}
		}
		
		drop ageD1

*Health section
	replace WlimitLPvAM=3 if dead==1
	*drop if Yrs2Death<0
	
	xtset x11101ll wave
	
*make some lags and dummies
	gen lWlim = L.WlimitLPvAM
	gen l2Wlimit123 = L2.WlimitLPvAM

	gen Wlimit2vAM= 1 if WlimitLPvAM==2
	replace Wlimit2vAM = 0  if (WlimitLPvAM==0 | WlimitLPvAM==1)
	gen Wlimit1vAM= 1 if WlimitLPvAM==1
	replace Wlimit1vAM = 0  if (WlimitLPvAM==0 | WlimitLPvAM==2)
	gen Wlimit0vAM= 1 if WlimitLPvAM==0
	replace Wlimit0vAM = 0  if (WlimitLPvAM==1 | WlimitLPvAM==2)

save $InputDTAs_dir\calibdata2.dta, replace

*************************************************************************************************	
*-------------------------------------------------------------------------------------------------
* Coding Chunk 3: Health Transitions
*-------------------------------------------------------------------------------------------------	
do $PSID_dir\HealthTrans.do
*-------------------------------------------------------------------------------------------------	

*************************************************************************************************	
*-------------------------------------------------------------------------------------------------
* Coding Chunk 4: HECKIT
*-------------------------------------------------------------------------------------------------	
do $CPS_dir\CPS_ExclResr.do
do $PSID_dir\HeckitRegs.do
*-------------------------------------------------------------------------------------------------	

*************************************************************************************************	
*-------------------------------------------------------------------------------------------------
* Coding Chunk 5: Task Price Time Series
*-------------------------------------------------------------------------------------------------	
do $PSID_dir\OccWageTS_Spline.do
*-------------------------------------------------------------------------------------------------	


*************************************************************************************************	
*-------------------------------------------------------------------------------------------------
* Coding Chunk 6: Summary Statistics- does not need to be done by occupation
*-------------------------------------------------------------------------------------------------	
*do $PSID_dir\SumStats_WhoGoes.do
*-------------------------------------------------------------------------------------------------	


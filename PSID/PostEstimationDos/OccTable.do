*OccTable.do
*-------------------v.7-30-2017; @A. Michaud for DIoption w/ DW---------------------------------*
*-------------------------------------------------------------------------------------------------	
*I would like to make a table for the paper of "what is an occupation"
*	1) Facts on EU/UE flows including means and volatility
*	2) Facts on wages including means and long-run declines.
*	3) Facts on the health hazards associated with the occupation.
*-------------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-InputDTAs\OccPredTwages.dta; created by OccWageTS.do
*	-InputDTAs\ONETpca.dta; Occupation tasks principal components from "Risky Occ Paper", see DW.
*	-DW\SOC_EUUE.dta; DW's calcs
*	-DW\Pr(d=2-wage-60,occupation).xls ; Iterating on the markov matrix
***************************************************************************************************************

*------------------------------
*Section 2: EU/UE Series
*------------------------------	
* Import DW Data:
import excel using "DW\SOC_EUUE.xlsx", ///
	sheet("SOC_EUUE") cellrange(B1:G6913) firstrow clear
	

* Label Occupations
	label variable SOC "Occupation"
	label variable EU ""
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
		
		label values SOC sSOC_lbl 	

		gen date = ym(Year, Month)
		drop if date==0671
		xtset SOC date, monthly
		
* Calculate the volatility of year over year changes

*Difference
	gen fdEU = EU-F12.EU
	gen fdUE = EU-F12.UE

*Mean
	by SOC, sort: egen avEU = mean(EU)
	by SOC, sort: egen avUE = mean(UE)

*StDev
	by SOC, sort: egen stdEU = sd(EU)
	by SOC, sort: egen stdUE = sd(UE)

collapse av* std*, by(SOC)	


*Normalize- Standard Score
foreach v of varlist avEU avUE stdEU stdUE {
	egen t_av`v' = mean(`v')
	egen t_std`v' = sd(`v')
	gen n`v' = (`v'-t_av`v')/t_std`v'
}

keep SOC n*

*------------------------------
*Section 2: Wage Time Series 
*------------------------------

merge 1:m SOC using $InputDTAs_dir\OccPredTwages.dta
drop if SOC==.
drop _merge

xtset SOC wave

*Calc 10 yr rolling average change
	by SOC, sort: gen D10_wage = F5.nrmW-L5.nrmW
	by SOC, sort: egen avD10_wage = mean(D10_wage)
	egen t_avD10 = mean(avD10_wage)
	egen t_stdD10 = sd(avD10_wage)
	gen nav_D10_wage = (avD10_wage-t_avD10)/t_stdD10
*Calc mean wage and standardize it
	by SOC, sort: egen av_wage = mean(lrwage)
	egen t_avWage = mean(av_wage)
	egen t_stdWage = sd(av_wage)
	gen nav_wage = (av_wage-t_avWage)/t_stdWage
	
	drop nrmW

	drop if wave~=1990
	keep SOC n* avD* n* av_wage
*------------------------------
*Section 3: Health
*------------------------------	
preserve

import excel using "DW\Pr(d=2-age-60, occupation).xlsx", ///
	sheet("Sheet1") cellrange(A2:B18) firstrow clear
	
	rename occ SOC
	label variable D2 "Severe Limitation"
	
	save $InputDTAs_dir\OccPredHealth.dta, replace
	
import excel using "DW\Pr(d=2-age-60, occupation).xlsx", ///
	sheet("Sheet1") cellrange(D2:E18) firstrow clear
	
	rename occ SOC
	label variable D0 "Any Limitation"
	
	merge 1:1 SOC using $InputDTAs_dir\OccPredHealth.dta	
	drop _merge
	save $InputDTAs_dir\OccPredHealth.dta, replace

	restore

	merge 1:1 SOC using $InputDTAs_dir\OccPredHealth.dta	
	drop _merge
*------------------------------
*Section 4: O*NET Characteristics
*------------------------------
merge 1:1 SOC using "PSID\InputDTAs\ONETpca.dta"	
	
keep SOC n* avD* D* av_wage PhysPC1 KsaPC1 KsaPC2	
*****************************************************************************
* GRAPHS AND TABLES
*-----------------------------------------------------------------------------

*----------
*Flow Graph
*----------
label variable navEU "Average EU"
label variable navUE "Average UE"
label variable nstdEU "Std. Dev. EU"
label variable nstdUE "Std. Dev. UE"

graph bar (asis) navEU navUE nstdEU nstdUE , by(, title("Occupation Employment Flows") subtitle("Relative to Standardized Mean")) by(SOC) /*
*/ legend(r(1) bm(tiny) region(margin(tiny)) symxsize(8)) yline(0, lcolor(red))
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\FlowStats_Occ.eps", as(eps) preview(on) replace
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\FlowStats_Occ.pdf", as(pdf) replace	

*----------
*Wage Trend Graph
*----------	
label variable nav_wage "Average Real Wage"
label variable nav_D10_wage "Average 10 year Real Wage Growth (Rolling Window Log-Difference)"

graph bar (asis) nav_wage nav_D10_wage , by(, title("Occupation Wages") subtitle("Relative to Standardized Mean")) by(SOC) /*
*/ legend(r(2) bm(tiny) region(margin(tiny)) symxsize(8)) yline(0, lcolor(red))
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\WageStats_Occ.eps", as(eps) preview(on) replace
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\WageStats_Occ.pdf", as(pdf) replace	

	
*----------
*Health Graph
*----------	
graph bar (asis) D0 D2 , by(, title("Occupational Work Limitation Risk") subtitle("Incidence at age 60-65")) by(SOC) /*
*/ legend(r(2) bm(tiny) region(margin(tiny)) symxsize(8)) yline(0, lcolor(red))
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\HealthStats_Occ.eps", as(eps) preview(on) replace
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\HealthStats_Occ.pdf", as(pdf) replace	

*----------
*O*NET Graph
*----------	
label variable PhysPC1 "Physical"
label variable KsaPC1 "Knowledge Skill #1"
label variable KsaPC2 "Knowledge Skill #2"

graph bar (asis) PhysPC1 KsaPC1 KsaPC2, by(, title("Occupation Tasks") subtitle("Relative to Standardized Mean")) by(SOC)	/*
*/ legend(r(1) bm(tiny) region(margin(tiny)) symxsize(8)) ysc(r(-11 13)) yla(-10(10)10) yline(0, lcolor(red))
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\OnetStats_Occ.eps", as(eps) preview(on) replace
	graph export "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Text\DataFigures\OnetStats_Occ.pdf", as(pdf) replace	
	

	format %2.3f navEU-KsaPC2
	
	*export excel SOC PhysPC1 KsaPC1 KsaPC2 D0 D2 navEU nstdEU navUE nstdUE av_wage avD10_wage  using $OUT_dir\OccCharacteristics.xlsx, firstrow(varlabels) replace
	*clear

	*import excel using $OUT_dir\OccCharacteristics.xlsx, ///
	*	sheet("Sheet1") cellrange(A1:L17) firstrow clear	

tostring *, replace usedisplayformat force
			  
		label variable navEU "Average EU"
		label variable navUE "Average UE"
		label variable nstdEU "Std. Dev. EU"
		label variable nstdUE "Std. Dev. UE"
		label variable PhysPC1 "Physical"
		label variable KsaPC1 "Knowledge Skill #1"
		label variable KsaPC2 "Knowledge Skill #2"
		label variable av_wage "Mean Wage"
		label variable avD10_wage "Mean 10yr Wage Growth"
		label variable D2 "Severe Limitation"
		label variable D0 "Any Limitation"			  

			ssc install texsave
	
	     texsave SOC PhysPC1 KsaPC1 KsaPC2 D0 D2 navEU nstdEU navUE nstdUE av_wage avD10_wage  using $OUT_dir\OccCharacteristics.tex , title(Occupational Characteristics) ///
              align(l|rrr|rr|rrrr|rr) varlabels  replace
			  

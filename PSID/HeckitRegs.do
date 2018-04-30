*HeckitRegs.do
*-------------------v.4-29-2017; @A. Michaud for DIoption w/ DW---------------------------------*
cd $PSID_dir
***************************************************************************************************************
* This code estimates the impact of the following on wages:
*	-Health: Severe and moderate disabilities
*	-Occupation skills: Physical and other
* The selection correction uses changes in national employment in individuals' demographic groups. (several options)
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-calibdata2.dta; created by MainCalib_StartHere.do
*	-CPS_ExclRestr.dta and CPS_ExclRestrByEd.dta; created by "CPS_ExlRestr.do" in folder "CPS"
*	-ONETpca.dta; Occupation tasks principal components from "Risky Occ Paper", see DW.
***************************************************************************************************************
*Section 1: Set up

   use $InputDTAs_dir\calibdata2, clear
	gen nWhite = 1 if Race~=1
	replace nWhite = 0 if Race==1

	gen Female =(Sex==2)
	drop if (x11101ll==. | Age<30 | Age>65)
	
*************************************************************************************************
*Merge Aggregate Employment Data variables from CPS for first step exclusion retriction
*------------------------------------------------------------------------------------------------	
*-------------------------------------------------------------------------------------------------	
merge m:1 LifeOcc2 AgeEdBin wave using $InputDTAs_dir\CPS_ExclRestr.dta
gen AgeEdSelect=(_merge==3)
drop if _merge==2
drop _merge	


*************************************************************************************************
* Generate outcome variable: Employed (this is person level variable)
*------------------------------------------------------------------------------------------------	
*-------------------------------------------------------------------------------------------------	
gen Emp = 1 if (EmpStat==1 | EmpStat==2)
replace Emp = . if (EmpStat==0 | dead==1 | EmpStat==7 | EmpStat==9 | EmpStat==6)
replace Emp = 0 if ((EmpStat>2 & EmpStat<7) | EmpStat==8)

*************************************************************************************************
*Two-step Prep
*------------------------------------------------------------------------------------------------	
*-------------------------------------------------------------------------------------------------	
****Prepare heckit
	*clean wages
		gen crHrlyW= rwage
	*Get rid of really low real wage (<$3 in 1996 dollars) and top codes.
		replace crHrlyW=. if (rwage<3 | HrlyW>9997)
	*Major changes in SSDI, so we drop these years
		drop if (wave<1983)
		gen lrwage = ln(crHrlyW)
		
	*clean labor income
		gen cLabInc = LabInc
		replace cLabInc = . if (LabInc==9999999 | LabInc==0)
		gen lLabInc = ln(cLabInc)

	*Follow L&P: Drop those with outlier wage growth,
	xtset x11101ll wave
	by x11101ll:gen grly=(HrlyW/L.HrlyW)-1
	replace grly=. if grly==-1
	gen suspect=0
	qui su grly,d
	replace suspect=grly<-0.85|(grly>5 & grly!=.)	
	egen ss=sum(suspect),by(x11101ll)				
	
	*Generate year dummies-- NOT IN USE
		*qui tab wave, gen (yd)

	*Merge in Onet data for wage reg 
		gen SOC=Currocc
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

* polynomial in time for wage regressions
	gen time= 0
		forvalues t =1/14 {
		local y=`t'+1983
		replace time = `t' if wave==`y'
	}	
	forvalues p =2/3 {
		gen time`p'= time^`p'
	}
	
	*Age variables (Experience is just age-30 so it is more interpretable)
	gen Exp = Age-30
	gen Exp2=Exp^2	
	gen Age2= Age^2
	gen Exp3 =Exp^3

	*Selection criteria follows time requirements and LP. 
	*-They also include SEO sample, so we will too. <- indeed their results are sensitive to this	
		gen select=(wave>1983 & wave<1998 & dead~=1 & Age<62 & Age>30 & Female==0  & Latino==0 &  ss==0 )
	*We will also include ladies in sum stats. 
	*	They are problematic because not all health vars are self reports, but there is value in knowing their stats too.
		gen selectF=(wave>1983 & wave<1998 & dead~=1 & Age<62 & Age>30 &  Latino==0 &  ss==0 )
		
		gen tobs = .
		bysort x11101ll (wave) : replace tobs =cond((!missing(lrwage) & missing(lrwage[_n-1])), 1, tobs[_n-1] + 1,.) 
			egen max_t = max(tobs), by(x11101ll) 
			
*************************************************************************************************
*Run the Heckits
*------------------------------------------------------------------------------------------------	
*-------------------------------------------------------------------------------------------------	
*Follow L&P structure in estimating wages
*	-Fixed Effects Reg on log-wages with inverse mills from first step
*	-Report results for all three exclusion retriction specifications plus one including ladies.
*-----------------------------------------------------------------------------------

*Spec2: uses ageXeduc FTFY employment changes
dprobit Emp Wlimit1vAM Wlimit2vAM  ageD* nWhite married  Female d5_EtlFTFYemp d1_EtlFTFYemp   if (select==1 ), vce(cluster x11101ll)
mfx
		estimates save $OUT_dir\Prob2, replace	
		estimate store Prob2
*margins, dydx(*)
predict pEmp , xb
gen mills = exp(-.5*(pEmp^2))/(sqrt(2*_pi)*normprob(pEmp))

xtreg lrwage Wlimit2vAM Wlimit1vAM  ageD* mills  ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl   married   time*  if (select==1 ), fe
				estimates save $OUT_dir\Wage2, replace	
		estimate store Wage2
	
	
*Save residuals for AR(1) Estimation

preserve	
	xtreg lrwage Wlimit2vAM Wlimit1vAM  ageD* mills  ONETPhysPC1_jl ONETKsaPC1_jl ONETKsaPC2_jl   married   time*  if (select==1 & max_t>2), fe
	predict HeckitResid2, residuals
	keep x11101ll wave Wlimit2vAM Wlimit1vAM Wlimit0vAM lrwage HeckitResid2 Age  

	export delimited using $OUT_dir\HeckitResid.csv, replace
restore

drop pEmp mills 

*************************************************************************************************
*Write the results
*------------------------------------------------------------------------------------------------	

*-----------------------------------------------------------------------------------
*HeckitWage.tex; "HeckitProbitMargins.tex"; "HeckitProbit.tex" - regression tables for text
*-----------------------------------------------------------------------------------

ssc install estout
esttab  Wage2  ///
                   using $OUT_dir\HeckitWage.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		   nomtitles numbers /// mtitles("(1)" "(2)" "(3)" "(4)") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace

esttab  Prob2   ///
                   using $OUT_dir\HeckitProbitMargins.tex ///
		   , cells(Xmfx_dydx( s  fmt(4)))   stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		   nomtitles numbers /// mtitles("(1)" "(2)" "(3)" "(4)") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace

esttab  Prob2   ///
                   using $OUT_dir\HeckitProbit.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		   nomtitles numbers /// mtitles("(1)" "(2)" "(3)" "(4)") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace			   

*************************************************************************************************
*-----------------------------------------------------------------------------------
*HeckitWage4DW.csv- regression coefficients for DW to use in FORTRAN input
*-----------------------------------------------------------------------------------	


	putexcel set $OUT_dir\HeckitWage4DW, modify
	putexcel A1 = ("Regressor") B1 = ("AgeXEdXOcc") C1 = ("AgeXEd") D1 = ("Ed") E1 = ("Spec 1 with Womn") ///
	A2 = ("Severe Limitation") A3 = ("Moderate Limitation")   ///
	A4 = ("Age>45 & Age<56") A5 = ("Age>55 & Age<61") A6 = ("Age>60 & Age<63")  ///
	A7 = ("Mills") A8 = ("ONET Phys Current Occ") A9 = ("ONET Ksa1 Current Occ") A10 = ("ONET Ksa2 Current Occ") ///
	A11 = ("Married") A12 = ("time") A13 = ("time-squared") A14 = ("time-cubed") ///
	 A15= ("Constant")
	
		estimates use $OUT_dir\Wage2
		matrix b = e(b)'
		putexcel B2 = matrix(b) 
		
		

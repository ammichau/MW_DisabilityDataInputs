*Extras_InsuranceAndExpend.do
*-------------------v.5-1-2017; @A. Michaud for DIoption w/ DW---------------------------------*
cd $PSID_dir
global OUT_dir "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Data\Calibration_May3_2017\Extras"

***************************************************************************************************************
* This code computes statistics comparing insurance and health expenditure outcome dynamics around DI claims
* Step 1) Reads in and cleans relevant additional variables from PSID
* Step 2) Merges with main dataset
* Step 3) Analyze
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-calibdata2.dta; created by MainCalib_StartHere.do
*	-You have to have files set up for psiduse in folder "Mdta", a subdirectory of PSID_dir set in main file
***************************************************************************************************************

*clear all
set more off
ssc install psidtools
*help psid
*psid install using UMICHdata
*psid install using Mdta

psid use || hSSinc  [70]V1212 [71]V1914 [72]V2515 [73]V3068 [74]V3480 [75]V3880 [76]V4395 [77]V5306 [78]V5806 [79]V6417 [80]V7007 [81]V7599 ///
					  [82]V8292 [83]V8900 ///
		|| hSSinc2_   [86]V12832 [87]V13934 [88]V14949 [89]V16449 [90]V17865 [91]V19165 [92]V20465 ///
					  [93]V22027 [05]ER28031 [07]ER41021 [09]ER46929 [11]ER52337 [13]ER58146 ///			 
		|| fSSyn   [94]ER3307 [95]ER6308 [96]ER8425 [97]ER11318 [99]ER14584 [01]ER18746 [03]ER22118 [05]ER26099 [07]ER37117 [09]ER43108 [11]ER48430 [13]ER54108 ///
		|| hSStype   [86]V12833 [87]V13935 [88]V14950 [89]V16450 [90]V17866 [91]V19166 [92]V20466 [93]V22012 ///
		|| pSStype2_ [11]ER34137 [13]ER34244  ///		
		|| pSStype3_ [05]ER27728 [07]ER40703 ///
		|| fSSDI_amt  [84]ER30451 [85]ER30486 [86]ER30521 [87]ER30557 [88]ER30592 ///
				     [89]ER30628 [90]ER30665 [91]ER30713 [92]ER30758 [09]ER34031 [11]ER34143 [13]ER34250 ///		
		|| hMedIns   [68]V158 [69]V740 [70]V1406 [71]V2118 [72]V2715 [80]V7287 ///
		|| hEmpIns   [84]V10470 ///
		|| wEmpIns   [84]V10684 ///
		|| fInsPremium   [99]ER15780 [01]ER19841 [03]ER23278 [05]ER27238 [07]ER40410 [09]ER46383 [11]ER51744 ///
		|| pMoInsLstYr   [99]ER33523 [01]ER33623 [03]ER33723 [05]ER33825 [07]ER33925 [09]ER34028 [11]ER34127 ///
		|| pMoIns2YrsAgo [99]ER33522 [01]ER33622 [03]ER33722 [05]ER33824 [07]ER33924 [09]ER34027 [11]ER34126 ///
		|| pMoUNInsLstYr   [13]ER34234  ///
		|| pMoUNIns2YrsAgo [13]ER34233  ///	
		|| pMedicaid  [86]ER30526 [87]ER30562 [88]ER30597 [89]ER30633 [90]ER30670 [91]ER30718 [92]ER30763 [93]ER30826 [94]ER33116 [95]ER33216 [96]ER33316 [97]ER33416 ///
		|| pTypeInsNow1_ [11]ER34129 [13]ER34236  ///
		|| pTypeInsNow2_ [11]ER34130 [13]ER34237  ///
		|| pTypeInsNow3_ [11]ER34131 [13]ER34238  ///
		|| pTypeInsLst2Yr1_ [99]ER33518 [01]ER33618 [03]ER33718 [05]ER33819 [07]ER33919 [09]ER34022 [11]ER34121 ///
		|| pTypeInsLst2Yr2_ [99]ER33519 [01]ER33619 [03]ER33719 [05]ER33820 [07]ER33920 [09]ER34023 [11]ER34122 ///
		|| pTypeInsLst2Yr3_ [99]ER33520 [01]ER33620 [03]ER33720 [05]ER33821 [07]ER33921 [09]ER34024 [11]ER34123 ///		
		|| fTotMedExp 	[99]ER15799 [01]ER19860 [03]ER23297 [05]ER27257 [07]ER40432 [09]ER46404 [11]ER51765 ///
		|| fTotPrescrpExp [99]ER15793 [01]ER19854 [03]ER23291 [05]ER27251 [07]ER40426 [09]ER46399 [11]ER51760 [13]ER57503  ///
		|| fMedDebt 		[11]ER48949 [13]ER54702  ///
		|| hHsptl 		[81]V7977 [83]V9293 [84]V10882 [85]V11996 [86]V13436 [87]V14519 [03]ER23090 [05]ER27057 [07]ER38268 [09]ER44241 [11]ER49579 [13]ER55327  ///
		|| wHsptl		[81]V7985 [83]V9298 [84]V10889 [85]V12349 [86]V13471 [87]V14530 [03]ER23217 [05]ER27180 [07]ER39365 [09]ER45338 [11]ER50697 [13]ER56443  ///
		|| hDrugAlc 	[07]ER38642 [09]ER44615 [11]ER49955 [13]ER55703 ///
		|| wDrugAlc		[07]ER39739 [09]ER45712 [11]ER51073 [13]ER56819 ///
		|| hDpressn 	[07]ER38623 [09]ER44596 [11]ER49936 [13]ER55684 ///
		|| wDpressn		[07]ER39720 [09]ER45693 [11]ER51054 [13]ER56800 ///		
		|| hYouthHealth [07]ER38323 [09]ER44296 [11]ER49636 [13]ER55384 ///
		|| wYouthHealth [07]ER39420 [09]ER45393 [11]ER50754 [13]ER56500 ///
		|| hHeartCond   [99]ER15488 [01]ER19653 [03]ER23053 [05]ER27006 [07]ER38217 [09]ER44190 [11]ER49513 [13]ER55263 ///
		|| wHeartCond   [99]ER15596 [01]ER19761 [03]ER23180 [05]ER27129 [07]ER39314 [09]ER45287 [11]ER50631 [13]ER56379 ///
		|| hHighBP      [99]ER15458 [01]ER19623 [03]ER23023 [05]ER27010 [07]ER38221 [09]ER44194 [11]ER49518 [13]ER55268 ///
		|| wHighBP      [99]ER15566 [01]ER19731 [03]ER23150 [05]ER27133 [07]ER39318 [09]ER45291 [11]ER50636 [13]ER56384 ///
		|| hMntlEmo		[07]ER38661 [09]ER44634 [11]ER49974 [13]ER55722 ///
		|| wMntlEmo		[07]ER39758 [09]ER45731 [11]ER51092 [13]ER56838 ///
		|| hDiabetes	[99]ER15464 [01]ER19629 [03]ER23029 [05]ER27022 [07]ER38233 [09]ER44206 [11]ER49533 [13]ER55283 ///
		|| wDiabetes	[99]ER15572 [01]ER19737 [03]ER23156 [05]ER27145 [07]ER39330 [09]ER45303 [11]ER50651 [13]ER56399 ///
		|| hCancer		[99]ER15470 [01]ER19635 [03]ER23035 [05]ER27038 [07]ER38249 [09]ER44222 [11]ER49553 [13]ER55303 ///
		|| wCancer		[99]ER15578 [01]ER19743 [03]ER23162 [05]ER27161 [07]ER39346 [09]ER45319 [11]ER50671 [13]ER56419 ///
		|| hStroke		[99]ER15452 [01]ER19617 [03]ER23017 [05]ER26998 [07]ER38209 [09]ER44182 [11]ER49501 [13]ER55251 ///
		|| wStroke		[99]ER15560 [01]ER19725 [03]ER23144 [05]ER27121 [07]ER39306 [09]ER45279 [11]ER50619 [13]ER56367 ///
		|| fFdStmpLstYr  [69]V634 [76]V4366 [77]V5537 [94]ER3059 [95]ER6058 [96]ER8155 [97]ER11049 [99]ER14255 [01]ER18386 [03]ER21652 [05]ER25654 [07]ER36672 [09]ER42691 [11]ER48007 [13]ER53704 ///
		|| pTransfLstYr [74]ER30151 [75]ER30172 [76]ER30208 [77]ER30237 [78]ER30274 [79]ER30304 [80]ER30334 [81]ER30364 [82]ER30390 [83]ER30419 ///
					    [84]ER30449 [85]ER30484 [86]ER30519 [87]ER30555 [88]ER30590 [89]ER30626 [90]ER30663 [91]ER30711 [92]ER30756 [93]ER30824 ///
		|| fCash 		[99]ER15020 [01]ER19216 [03]ER22596 [05]ER26577 [07]ER37595 [09]ER43586 [11]ER48911 [13]ER54661 ///
        using Mdta , clear design(3)
		
	psid long
	xtset x11101ll wave
	
	merge 1:1 x11101ll wave using $InputDTAs_dir\calibdata2.dta
	drop _merge
 save $InputDTAs_dir\Extras, replace	
*************************************************************************************************
*Some definitions
*------------------------------------------------------------------------------------------------
*FamSSyn - Did anybody receive SS income? 1=Y; 5=No; 8=DK; 9=refused
*hwSSinc - head and wife SS inc, top coded at 99999	
*SStype = type of SS income; 1==Disability
*************************************************************************************************

*------------------------
*Assign head/wife vars and harmonize ones needing it
*------------------------
local vrs EmpIns Hsptl DrugAlc Dpressn YouthHealth HeartCond HighBP MntlEmo Diabetes Cancer Stroke 
foreach v of local vrs {
	gen `v'= h`v' if HH==1
	replace `v'=w`v' if HW==1
	drop h`v' w`v'
	}
local vrs SSinc SSinc2_ SStype MedIns
	foreach v of local vrs {
	gen `v'= h`v' if HH==1
	drop h`v' 
	}
gen disab=Hdisab if HH==1
replace disab=Wdisab if HW==1	

*Fill in correct years	
replace SStype= pSStype2_ if SStype==.
replace SStype= pSStype3_ if SStype==.
replace SStype=. if (wave==2009 | (wave>1993 & wave<2005) |  wave<1986 )
	*drop SStype pSStype2_ pSStype3_

	replace SSinc = SSinc2_ if SSinc==.

*------------------------
*Adjust Timing to appropriate reference year
*------------------------
xtset x11101ll wave
	
*One year back
local vrs pMoInsLstYr pMoUNInsLstYr Hsptl fFdStmpLstYr pTransfLstYr
	foreach v of local vrs {
		gen `v'1 = F.`v'
		replace `v' = `v'1
		drop `v'1
	}
*Answered for either of last 2 years	
local vrs fInsPremium pTypeInsLst2Yr2_ pTypeInsLst2Yr3_ fTotMedExp fTotPrescrpExp
	foreach v of local vrs {
		gen `v'1 = F.`v'
		gen `v'2 = F2.`v'
		replace `v' = `v'1
		replace `v' = `v'2 if `v'==.
		drop `v'1 `v'2
	}

*Two years back
local vrs  pMoIns2YrsAgo pMoUNIns2YrsAgo
	foreach v of local vrs {
		gen `v'2 = F2.`v'
		replace `v' = `v'2
		drop `v'2
	}	

*************************************************************************************************
*Coding Chunk 3: DI & SSI receipt
*------------------------------------------------------------------------------------------------
*LP measure
	gen SSDI_LP=(SStype==1)

	egen lastyear=max(wave),by(x11101ll)
	sort x11101ll wave
	
	* The assumption is that a sequence DI=1,DI=0, DI=1 with typen=4 when DI reverts to 0 just means that in that year the person was receiving DI *and* something else */ 
		by x11101ll:replace SSDI_LP=1 if SSDI_LP==0 & SStype==4

	egen ndi=sum(SSDI_LP), by(x11101ll)
	egen nDS=sum(WlimitLPvAM==0),by(x11101ll)
	egen nDI=sum(WlimitLP==0),by(x11101ll)
	replace SSDI_LP=0 if SSDI_LP==1 & wave<lastyear & ndi==1 & (nDS-nDI)==1				
	drop lastyear ndi nDS nDI
	
	gen SSDI = SSDI_LP
	replace SSDI_LP =. if (wave>1993 | wave<1986)
	
* There are also guys who list employment status as "permanently disabled" (EmpStat==5)
*	-> This one looks pretty good!
	gen SSDIv2 = SSDI_LP if (wave>1983 & wave<1994) 
	replace SSDIv2 = SSDI if ( wave==2005 | wave==2007 | wave==2011) 
	replace SSDIv2 = 1 if (fSSyn==1 & EmpStat==5 &  wave>1993)
	replace SSDIv2 = 1 if (SSinc>0 & SSinc<99999 & EmpStat==5)
	replace SSDIv2 = 0 if (SSDIv2==. & wave>1983 & (fSSyn==5 | SSinc==0))
	
*Something  for the later years
	gen SSDI_2000 =  SSDI if ( wave==2005 | wave==2007 | wave==2011 | wave==2013) 
	
*************************************************************************************************
*Coding Chunk 4: Insurance Stats
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------		
*Insurance Status
*Private
	*This year
	gen PrivIns= 1 if (MedIns==1 | MedIns==2 | MedIns==7 | EmpIns==1 | pTypeInsNow1_==1 | pTypeInsNow1_==2 )
	replace PrivIns=0 if ((MedIns>2 & MedIns<7) | EmpIns==5 | (pTypeInsNow1_>2 & pTypeInsNow1_<98) )
	replace PrivIns=1 if (pTypeInsNow2_==1 | pTypeInsNow2_==2 | pTypeInsNow3_==1 | pTypeInsNow3_==2 )
	*Past 2 Years	
	replace PrivIns=1 if (pTypeInsLst2Yr1_==1 | pTypeInsLst2Yr1_==2 )
	replace PrivIns=0 if (pTypeInsLst2Yr1_>2 & pTypeInsLst2Yr1_<98) 
	replace PrivIns=1 if (pTypeInsLst2Yr2_==1 | pTypeInsLst2Yr2_==2 | pTypeInsLst2Yr3_==1 | pTypeInsLst2Yr3_==2 )
	
*Public
	*This year
	gen PubIns= 1 if (MedIns==3 | pMedicaid==1 | (pTypeInsNow1_>2 & pTypeInsNow1_<6) | (pTypeInsNow1_>6 & pTypeInsNow1_<97))
	replace PubIns=0 if ((MedIns<3 | ( MedIns>4 & MedIns<9)) | pMedicaid==5 | (pTypeInsNow1_>0 & pTypeInsNow1_<3) | pTypeInsNow1_==6 )
	replace PubIns=1 if ((pTypeInsNow2_>2 & pTypeInsNow2_<6) | (pTypeInsNow2_>6 & pTypeInsNow2_<97) | (pTypeInsNow3_>2 & pTypeInsNow3_<6) | (pTypeInsNow3_>6 & pTypeInsNow3_<97))
	*Past 2 Years	
	replace PubIns=1 if ((pTypeInsLst2Yr1_>2 & pTypeInsLst2Yr1_<6) | (pTypeInsLst2Yr1_>6 & pTypeInsLst2Yr1_<97))
	replace PubIns=0 if ((pTypeInsLst2Yr1_>0 & pTypeInsLst2Yr1_<3) | pTypeInsLst2Yr1_==6 )
	replace PubIns=1 if ((pTypeInsLst2Yr2_>2 & pTypeInsLst2Yr2_<6) | (pTypeInsLst2Yr2_>6 & pTypeInsLst2Yr2_<97) | (pTypeInsLst2Yr3_>2 & pTypeInsLst2Yr3_<6) | (pTypeInsLst2Yr3_>6 & pTypeInsLst2Yr3_<97))

*Employer	
	gen EmplyIns =(EmpIns==1)
	replace EmplyIns=. if EmpIns==.
	*This year
	replace EmplyIns = 1 if (pTypeInsNow1_==1 | pTypeInsNow1_==6)
	replace EmplyIns = 0 if ((pTypeInsNow1_>1 & pTypeInsNow1_<6) | (pTypeInsNow1_>6 & pTypeInsNow1_<98))
	replace EmplyIns = 1 if (pTypeInsNow2_==1 | pTypeInsNow2_==6 | pTypeInsNow3_==1 | pTypeInsNow3_==6)
	*Past 2 Years
	replace EmplyIns = 1 if (pTypeInsLst2Yr1_==1 | pTypeInsLst2Yr1_==6)
	replace EmplyIns = 0 if ((pTypeInsLst2Yr1_>1 & pTypeInsLst2Yr1_<6) | (pTypeInsLst2Yr1_>6 & pTypeInsLst2Yr1_<98))
	replace EmplyIns = 1 if (pTypeInsLst2Yr2_==1 | pTypeInsLst2Yr2_==6 | pTypeInsLst2Yr3_==1 | pTypeInsLst2Yr3_==6)

*Gaps
	gen unInsGap = 12-pMoInsLstYr if (pMoInsLstYr>0 & pMoInsLstYr<13)
	replace unInsGap = 12-pMoIns2YrsAgo if (pMoIns2YrsAgo>0 & pMoIns2YrsAgo<13 & unInsGap==.)
	replace unInsGap = pMoUNInsLstYr if (pMoUNInsLstYr>0 & pMoUNInsLstYr<13)
	replace unInsGap = pMoUNIns2YrsAgo if (pMoUNIns2YrsAgo>0 & pMoUNIns2YrsAgo<13 & unInsGap==.)

*************************************************************************************************
*Coding Chunk 5: Medical Expenditures
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------		
*Insurance Premium (Family Total)
	replace fInsPremium = . if (fInsPremium>999996 | fInsPremium<1)
	
*Medical Care (Family Total)
	replace fTotMedExp = . if fTotMedExp>9999996

*Percription Costs (Family Total)
	replace fTotPrescrpExp = . if fTotPrescrpExp>9999996
	
* Total current medical bills
	replace fMedDebt=. if (fMedDebt> 9999997 )

*Food stamps
	gen FoodStamp = 1 if (fFdStmpLstYr==1 | pTransfLstYr==1 | pTransfLstYr==5)
	replace FoodStamp = 0 if (fFdStmpLstYr==5 | (pTransfLstYr>1 & pTransfLstYr<15) | pTransfLstYr==0)
	
*Savings
	gen Savngs =  fCash
	replace Savngs = . if fCash>999999997
*************************************************************************************************
*Coding Chunk 6: Medical Conditions
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------		
***TO BE ADDED***
*****************

*******************************************************************************************
*******************************************************************************************
*Analysis
*******************************************************************************************
*Sample select
xtset x11101ll wave
gen lSSDI_LP = L1.SSDI_LP
gen newSSDI=(SSDI_LP==1 & lSSDI_LP~=1 )
gen newSSDIv2=(SSDIv2==1 & L.SSDIv2~=1 )

	xtset x11101ll wave
	by x11101ll:gen grly=(HrlyW/L.HrlyW)-1
	replace grly=. if grly==-1
	gen suspect=0
	qui su grly,d
	replace suspect=grly<-0.85|(grly>5 & grly!=.)	
	egen ss=sum(suspect),by(x11101ll)

gen selectDIstats=(  Age>30 & Age<63 & Sex==1  & Latino==0 )

*******************************************************************************************
*Continuous Variables- calc average and those > 80th percentile
*	- Insurance Premium
*	- Medical Exp
*	- Prescription Exp
*	- Medical Debt
*	- Savings
************
*Percentiles >80th
local vrs fInsPremium fTotMedExp fTotPrescrpExp fMedDebt 
	foreach v of local vrs {
	by wave, sort: egen `v'80 = pctile(`v') if (Age>40 & Age<63 & selectDIstats==1 & Col~=1), p(80)
	*=1 if wage< 20th percentile prior year
	gen `v'Gr80= 1 if (`v'>`v'80 &  Age>40 & Age<63 & selectDIstats==1)
	replace `v'Gr80= 0 if (`v'<`v'80 & `v'~=. & Age>40 & Age<63 & selectDIstats==1)
	*=1 if >80th percentile any of prior 5 years
	xtset x11101ll wave
	gen y5`v'Gr80= `v'Gr80
		replace y5`v'Gr80=0 if (L1.`v'Gr80==0 | L2.`v'Gr80==0 | L3.`v'Gr80==0 | L4.`v'Gr80==0 )
		replace y5`v'Gr80=1 if L1.`v'Gr80==1 
		replace y5`v'Gr80=1 if L2.`v'Gr80==1 
		replace y5`v'Gr80=1 if L3.`v'Gr80==1 
		replace y5`v'Gr80=1 if L4.`v'Gr80==1 
		replace y5`v'Gr80 = . if (Age<40 | Age>62 | selectDIstats==0)
}

*Percentiles < 20th
local vrs fCash
	foreach v of local vrs {
	by wave, sort: egen `v'20 = pctile(`v') if (Age>40 & Age<63 & selectDIstats==1 & Col~=1), p(20)
	*=1 if wage< 20th percentile prior year
	gen `v'Less20= 1 if (`v'<`v'20 &  Age>40 & Age<63 & selectDIstats==1)
	replace `v'Less20= 0 if (`v'>`v'20 & `v'~=. & Age>40 & Age<63 & selectDIstats==1)
	*=1 if < 20th percentile any of prior 5 years
	xtset x11101ll wave
	gen y5`v'Less20= `v'Less20
		replace y5`v'Less20=0 if (L1.`v'Less20==0 | L2.`v'Less20==0 | L3.`v'Less20==0 | L4.`v'Less20==0 )
		replace y5`v'Less20=1 if L1.`v'Less20==1 
		replace y5`v'Less20=1 if L2.`v'Less20==1 
		replace y5`v'Less20=1 if L3.`v'Less20==1 
		replace y5`v'Less20=1 if L4.`v'Less20==1 
		replace y5`v'Less20 = . if (Age<40 | Age>62 | selectDIstats==0)
}

*******************************************************************************************
*Discrete Variables Set Up- calc % of prior 5 years with each
*	- Private Insurance
*	- Employer Insurance
*	- Public Insurance
*	- No Insurance
************
local vrs PrivIns PubIns EmplyIns 
	foreach v of local vrs {
		gen y5`v'= 1 if (`v'==1 &  Age>40 & Age<63 & selectDIstats==1)
		replace y5`v'=0 if (`v'==0 &  Age>40 & Age<63 & selectDIstats==1)
	xtset x11101ll wave		
	forvalues l = 1(1)4 {
		replace y5`v'= y5`v'+1 if (L`l'.`v'==1 &  Age>40 & Age<63 & selectDIstats==1) 
		replace y5`v'=0 if (L`l'.`v'==0 & `v'==. &  Age>40 & Age<63 & selectDIstats==1)
	}
}

gen noIns = 1 if (PrivIns==0 & PubIns==0 & EmplyIns==0 )
	replace noIns= 0 if (PrivIns==1 | PubIns==1 | EmplyIns==1 )
	gen y5noIns = noIns
	xtset x11101ll wave		
	forvalues l = 1(1)4 {
		replace y5noIns= y5noIns+1 if (L`l'.noIns==1 &  Age>40 & Age<63 & selectDIstats==1) 
		replace y5noIns=0 if (L`l'.noIns==0 & noIns==. &  Age>40 & Age<63 & selectDIstats==1)
	}
	
*******************************************************************************************
*Summary Statistics Averages
*		
************			
ssc install estout, replace
*****Tab for DI receipients and general population
	**** EXPENDITURES *****
	svyset [pweight=wpts]
local vrs fInsPremiumGr80 fTotMedExpGr80 fTotPrescrpExpGr80 fMedDebtGr80 fCashLess20
	foreach v of local vrs {	
	svy: tab y5`v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store y5`v'_DI	
	svy: tab y5`v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store y5`v'_Pop			
	svy: tab y5`v' if (Age>40 & Age<63 & SSDIv2==0 & selectDIstats==1 & wave>1997 & Col~=1)
			estimate store y5`v'_NC	
	svy: tab `v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store `v'_DI	
	svy: tab `v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store `v'_Pop			
	svy: tab `v' if (Age>40 & Age<63 & SSDIv2==0 & selectDIstats==1 & wave>1997 & Col~=1)
			estimate store `v'_NCpop
}
			
esttab y5fInsPremiumGr80_DIrate y5fTotMedExpGr80_DIrate y5fTotPrescrpExpGr80_DI y5fInsPremiumGr80_NCpoprate y5fTotMedExpGr80_NCpoprate y5fTotPrescrpExpGr80_NC ///
                   using SumStatsDI_MedExp.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		    title(Medical Expenses exceeding 80th percentile in any of past 5 years; DI receipients and reference pop.)       ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("DI- Premiums" "DI-OOP Total" "DI- Precrip" "Pop- Premiums" "Pop-OOP Total" "Pop- Precrip") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) 	replace

esttab y5fMedDebtGr80_DI y5fCashLess20_DI y5fMedDebtGr80_NC y5fCashLess20_NC ///
                   using SumStatsDI_DebtAsset.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		    title(Medical Debt exceeding 80th percentile and Cash less than 20th in any of past 5 years; DI receipients and reference pop.)       ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("DI- Med Debt$>$80th" "DI- Cash$<$20th" "Pop- Med Debt$>$80th" "Pop- Cash$<$20th") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace				   

drop _est*
			   
	**** INSURANCE COVERAGE *****
	svyset [pweight=wpts]
local vrs PrivIns PubIns EmplyIns noIns unInsGap
	foreach v of local vrs {	
	svy: mean y5`v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store y5`v'_DI	
	svy: mean y5`v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store y5`v'_Pop			
	svy: mean y5`v' if (Age>40 & Age<63 & SSDIv2==0 & selectDIstats==1 & wave>1997 & Col~=1)
			estimate store y5`v'_NC	
	svy: mean `v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store `v'_DI	
	svy: mean `v' if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1997)
			estimate store `v'_Pop			
	svy: mean `v' if (Age>40 & Age<63 & SSDIv2==0 & selectDIstats==1 & wave>1997 & Col~=1)
			estimate store `v'_NCpop
}
			
esttab y5PrivIns_DI y5PubIns_DI y5EmplyIns_DI  y5PrivIns_NC y5PubIns_NC y5EmplyIns_NC  ///
                   using SumStatsDI_InsType.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		    title(Medical Expenses exceeding 80th percentile in any of past 5 years; DI receipients and reference pop.)       ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("DI- Private" "DI- Public" "DI- Employer" "Pop- Private" "Pop- Public" "Pop- Employer") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
			
esttab y5noIns_DI y5unInsGap_DI y5noIns_NC y5unInsGap_NC ///
                   using SumStatsDI_UnIns.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		    title(Medical Expenses exceeding 80th percentile in any of past 5 years; DI receipients and reference pop.)       ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("DI- Coverage Gap" "DI- Months No Cov" "Pop-  Coverage Gap" "DI- Months No Cov") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace				   

drop _est*			   
			   
			   
			  			   
************
*Separations:
*		Want to figure out if SSDI claimaints were involuntary or voluntary separated
************
*Total inv. u spells
gen InvUprime=(InvU==1 & (Age>44 & Age<63) & selectDIstats==1)

	egen InvUTot = sum(InvUprime), by( x11101ll )
	gen InvU0 = InvU
	replace InvU0 = 0 if InvU0==.
	gen InvU5yr = InvU0
	xtset x11101ll wave
	replace InvU5yr = 1 if (L1.InvU0==1)
	replace InvU5yr = 1 if (L2.InvU0==1)
	replace InvU5yr = 1 if (L3.InvU0==1)
	replace InvU5yr = 1 if (L4.InvU0==1)

	*By DI
	svy: tab InvU5yr if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1985)
		estimate store InvU5_imp
	svy: tab InvU5yr if (Age>40 & Age<63 & SSDI_LP==1 & wave>1985 & wave<1994 & selectDIstats==1)
		estimate store InvU5_early
	svy: tab InvU5yr if (Age>40 & Age<63 & SSDIv2==1  & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvU5_late		
	svy: tab InvU5yr if (Age>40 & Age<63 & wave>1985 & wave<1994 & selectDIstats==1 & Col~=1)
		estimate store InvU5c_early
	svy: tab InvU5yr if (Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvU5c_late
	
	*By Health
	svy: tab InvU5yr if (Age>40 & Age<63 & WlimitLP==1 & selectDIstats==1 & wave>1985 & wave<1994)
		estimate store InvU5_early_mod
	svy: tab InvU5yr if (Age>40 & Age<63 & WlimitLP==2 & wave>1985 & wave<1994 & selectDIstats==1)
		estimate store InvU5_early_severe
	svy: tab InvU5yr if (Age>40 & Age<63 & WlimitLP==1 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvU5_late_mod
	svy: tab InvU5yr if (Age>40 & Age<63 & WlimitLP==2 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvU5_late_severe
	
esttab InvU5_imp InvU5_early InvU5_late InvU5c_early InvU5c_late ///
                   using $OUT_dir\SumStatsDI_InvolU.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Involuntary Unemployed in any of past 5 years.)       ///		   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("Total Imputed 1986-2013" "1986-1993" "2005, 2007, 2011" "1986-1993; Pop" "2005, 2007, 2011; Pop") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
			   
esttab InvU5_early_mod InvU5_early_severe InvU5_late_mod InvU5_late_severe ///
                   using $OUT_dir\SumStatsWlim_InvolU.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Involuntary Unemployed in any of past 5 years.)       ///		   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles( "1986-1993; moderate" "2005, 2007, 2011; moderate" "1986-1993; severe" "2005, 2007, 2011; severe") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
			   
*Total inv. separations
gen InvSprime=(InvSep==1 & (Age>44 & Age<63) & selectDIstats==1)

	egen InvSTot = sum(InvSprime), by( x11101ll )
	gen InvS0=(InvSep==1)
	replace InvS0 = 0 if InvS0==.
	gen InvS5yr = InvS0
	xtset x11101ll wave
	replace InvS5yr = 1 if (L1.InvS0==1)
	replace InvS5yr = 1 if (L2.InvS0==1)
	replace InvS5yr = 1 if (L3.InvS0==1)
	replace InvS5yr = 1 if (L4.InvS0==1)
	
	svy: tab InvS5yr if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1985)
		estimate store InvS5_imp
	svy: tab InvS5yr if (Age>40 & Age<63 & SSDI_LP==1 & wave>1985 & wave<1994 & selectDIstats==1)
		estimate store InvS5_early
	svy: tab InvS5yr if (SSDIv2==1 & Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1)
		estimate store InvS5_late
	svy: tab InvS5yr if (Age>40 & Age<63 & wave>1985 & wave<1994 & selectDIstats==1 & Col~=1)
		estimate store InvS5c_early
	svy: tab InvS5yr if (Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvS5c_late

	*By Health
	svy: tab InvS5yr if (Age>40 & Age<63 & WlimitLP==1 & selectDIstats==1 & wave>1985 & wave<1994)
		estimate store InvS5_early_mod
	svy: tab InvS5yr if (Age>40 & Age<63 & WlimitLP==2 & wave>1985 & wave<1994 & selectDIstats==1)
		estimate store InvS5_early_severe
	svy: tab InvS5yr if (Age>40 & Age<63 & WlimitLP==1 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvS5_late_mod
	svy: tab InvS5yr if (Age>40 & Age<63 & WlimitLP==2 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
		estimate store InvS5_late_severe		
		

			
esttab InvS5_imp InvS5_early InvS5_late InvS5c_early InvS5c_late ///
                   using $OUT_dir\SumStatsDI_InvolSep.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Involuntary Separation in any of past 5 years.)       ///			   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("Total Imputed 1986-2013" "1986-1993" "2005, 2007, 2011" "1986-1993; Pop" "2005, 2007, 2011; Pop") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	

			   
			   
esttab InvS5_early_mod InvS5_early_severe InvS5_late_mod InvS5_late_severe ///
                   using $OUT_dir\SumStatsWlim_InvolSep.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Involuntary Separation in any of past 5 years.)       ///			   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		   nonumbers mtitles( "1986-1993; moderate" "2005, 2007, 2011; moderate" "1986-1993; severe" "2005, 2007, 2011; severe") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	

			   
			   
			   
			   
************
*Percent Employed- 10 years leading to DI claim + 10 years prior to first limitation status
************
gen Emp=(EmpStat==1 | EmpStat==2)
replace Emp=. if (EmpStat==. | EmpStat==0)
xtset x11101ll wave

*Find first limitation switch
	    by x11101ll: egen firstWL1w = min(cond(WlimitLP==1, wave, .))
		gen firstWL1 = 1 if wave==firstWL1w
	    by x11101ll: egen firstWL2w = min(cond(WlimitLP==2, wave, .))
		gen firstWL2 = 1 if wave==firstWL2w
	    by x11101ll: egen firstSSDIw = min(cond(SSDIv2==1, wave, .))
		gen firstSSDI = 1 if wave==firstSSDIw
		
		drop firstWL1w firstWL2w firstSSDIw

*10 year prior
	forvalues L =1/10{	
		*Employment Stats
		gen EmpDI_`L'= 1 if (L`L'.Emp==1 & SSDIv2==1 & selectDIstats==1)
		replace EmpDI_`L' = 0  if (L`L'.Emp==0 & SSDIv2==1 & selectDIstats==1)
		
		gen EmpWL1_`L'= 1 if (L`L'.Emp==1 & firstWL1==1 & selectDIstats==1)
		replace EmpWL1_`L' = 0  if (L`L'.Emp==0 & firstWL1==1 & selectDIstats==1)	
		
		gen EmpWL2_`L'= 1 if (L`L'.Emp==1 & firstWL2==1 & selectDIstats==1)
		replace EmpWL2_`L' = 0  if (L`L'.Emp==0 & firstWL2==1 & selectDIstats==1)	
		
		*Health Stats	
		gen Wlim1DI_`L'= 1 if (L`L'.WlimitLP==1 & SSDIv2==1 & selectDIstats==1)
		replace Wlim1DI_`L' = 0 if ((L`L'.WlimitLP==2 | L`L'.WlimitLP==0)  & SSDIv2==1 & selectDIstats==1)
		gen Wlim2DI_`L'= 1 if (L`L'.WlimitLP==2 & SSDIv2==1 & selectDIstats==1)
		replace Wlim2DI_`L' = 0 if ((L`L'.WlimitLP==1 | L`L'.WlimitLP==0)  & SSDIv2==1 & selectDIstats==1)	
	}
*Year of
		*Employment Stats
		gen EmpDI_0= 1 if (Emp==1 & SSDIv2==1 & selectDIstats==1)
		replace EmpDI_0 = 0  if (Emp==0 & SSDIv2==1 & selectDIstats==1)
		
		gen EmpWL1_0= 1 if (Emp==1 & firstWL1==1 & selectDIstats==1)
		replace EmpWL1_0 = 0  if (Emp==0 & firstWL1==1 & selectDIstats==1)	
		
		gen EmpWL2_0= 1 if (Emp==1 & firstWL2==1 & selectDIstats==1)
		replace EmpWL2_0 = 0  if (Emp==0 & firstWL2==1 & selectDIstats==1)

		gen EmpWL1stay_0= 1 if (Emp==1 & firstWL1==1 & selectDIstats==1 & WlimitLP==1)
		replace EmpWL1stay_0 = 0  if (Emp==0 & firstWL1==1 & selectDIstats==1 & WlimitLP==1)	
		
		gen EmpWL2stay_0= 1 if (Emp==1 & firstWL2==1 & selectDIstats==1 & WlimitLP==2)
		replace EmpWL2stay_0 = 0  if (Emp==0 & firstWL2==1 & selectDIstats==1 & WlimitLP==2)

		gen Wlim1DI_0= 1 if (WlimitLP==1 & SSDIv2==1 & selectDIstats==1)
		replace Wlim1DI_0 = 0 if ((WlimitLP==2 | WlimitLP==0)  & SSDIv2==1 & selectDIstats==1)
		gen Wlim2DI_0= 1 if (WlimitLP==2 & SSDIv2==1 & selectDIstats==1)
		replace Wlim2DI_0 = 0 if ((WlimitLP==1 | WlimitLP==0)  & SSDIv2==1 & selectDIstats==1)	
		
*5 years post
	forvalues L =1/5{	
		*Employment Stats
		gen EmpWL1_F`L'= 1 if (F`L'.Emp==1 & firstWL1==1 & selectDIstats==1)
		replace EmpWL1_F`L' = 0  if (F`L'.Emp==0 & firstWL1==1 & selectDIstats==1)	
		
		gen EmpWL2_F`L'= 1 if (F`L'.Emp==1 & firstWL2==1 & selectDIstats==1)
		replace EmpWL2_F`L' = 0  if (F`L'.Emp==0 & firstWL2==1 & selectDIstats==1)
	
		gen EmpWL1stay_F`L'= 1 if (F`L'.Emp==1 & firstWL1==1 & selectDIstats==1 & F`L'.WlimitLP==1)
		replace EmpWL1stay_F`L' = 0  if (F`L'.Emp==0 & firstWL1==1 & selectDIstats==1 & F`L'.WlimitLP==1)	
		
		gen EmpWL2stay_F`L'= 1 if (F`L'.Emp==1 & firstWL2==1 & selectDIstats==1 & F`L'.WlimitLP==2)
		replace EmpWL2stay_F`L' = 0  if (F`L'.Emp==0 & firstWL2==1 & selectDIstats==1 & F`L'.WlimitLP==2)	
		
	}
	
	
	*Check av population employment rate
		gen Emp_all= 1 if (Emp==1 & Col~=1 & selectDIstats==1 & Age>40 & Age<63 )
		replace Emp_all = 0  if (Emp==0 & Col~=1 & selectDIstats==1 & Age>40 & Age<63)		
		by wave, sort: egen Emp_allr = mean(Emp_all	)
	*Check av population work limitations
		gen Wlim1_all= 1 if (WlimitLP==1 & Col~=1 & selectDIstats==1 & Age>40 & Age<63 )
		replace Wlim1_all = 0  if ((WlimitLP==0 | WlimitLP==2) & Col~=1 & selectDIstats==1 & Age>40 & Age<63)		
		gen Wlim2_all= 1 if (WlimitLP==2 & Col~=1 & selectDIstats==1 & Age>40 & Age<63 )
		replace Wlim2_all = 0  if ((WlimitLP==0 | WlimitLP==1) & Col~=1 & selectDIstats==1 & Age>40 & Age<63)	
		by wave, sort: egen Wlim1_allr = mean(Wlim1_all	)
		by wave, sort: egen Wlim2_allr = mean(Wlim2_all	)
		
gen early = 1 if (wave>1985 & wave<1994)
replace early = 0 if (wave==2005 | wave==2007 | wave==2011) 	

	
preserve
	keep EmpDI_* Wlim1DI_* Wlim2DI_* Emp_allr Wlim1_allr Wlim2_allr early	
	collapse (mean) Emp* Wlim* ,by(early)
	reshape long EmpDI_ Wlim1DI_ Wlim2DI_, i(early) j(yrs2Event)	
	replace yrs2Event=-yrs2Event	
	drop if early==.	
	save $InputDTAs_dir\EmpPlotDI, replace


	sort early yrs2Event
	twoway (line Wlim1DI_ yrs2Event if early==1 & yrs2Event>-9, lwidth(thick)  lcolor(red)  ) (line  Wlim2DI_ yrs2Event if early==1 & yrs2Event>-9, lwidth(thick)  lcolor(blue)  ) ,/*
	*/ title("Work Limitation Prior to DI acceptance") subtitle("1986-1993") xtitle("Years Prior to Acceptance") ytitle("Fraction with Work Limitation") /*
	*/ legend(lab(1 "Moderate Work Limitation") lab(2 "Severe Work Limitation") )/*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) tline(0, lc(red))
	graph export "$OUT_dir\Wlim_early.eps", replace
	graph export "$OUT_dir\Wlim_early.pdf", replace
	graph save Graph "H:\disability\SumStatsOUT\Wlim_early.gph", replace

	
	twoway (line Wlim1DI_ yrs2Event if early==0 & yrs2Event>-9, lwidth(thick)  lcolor(red)  ) (line  Wlim2DI_ yrs2Event if early==0 & yrs2Event>-9, lwidth(thick)  lcolor(blue)  ), /*
	*/ title("Work Limitation Prior to DI acceptance") subtitle("2005, 2007, 2011") xtitle("Years Prior to Acceptance") ytitle("Fraction with Work Limitation") /*
	*/ legend(lab(1 "Moderate Work Limitation") lab(2 "Severe Work Limitation") ) /*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) tline(0, lc(red))
	graph export "$OUT_dir\Wlim_late.eps", replace
	graph export "$OUT_dir\Wlim_late.pdf", replace
	graph save Graph "H:\disability\SumStatsOUT\Wlim_late.gph", replace	
	
restore

preserve
	keep EmpWL1_*  early
	drop EmpWL1_F*
	collapse (mean) Emp* ,by(early)
	reshape long EmpWL1_ , i(early) j(yrs2Event)	
	replace yrs2Event=-yrs2Event	
	drop if early==.	
	save $InputDTAs_dir\EmpPlotWL1, replace
restore

preserve
	keep EmpWL2_*  early
	drop EmpWL2_F*
	collapse (mean) Emp* ,by(early)
	reshape long EmpWL2_, i(early) j(yrs2Event)	
	replace yrs2Event=-yrs2Event	
	drop if early==.	
	save $InputDTAs_dir\EmpPlotWL2, replace
restore

preserve
	keep EmpWL1_F* EmpWL1stay_F*  early	
	collapse (mean) Emp* ,by(early)
	reshape long EmpWL1_F EmpWL1stay_F , i(early) j(yrs2Event)	
	drop if early==.	
	drop if yrs2Event>5
	rename EmpWL1_F EmpWL1_
	append using $InputDTAs_dir\EmpPlotWL1
	save $InputDTAs_dir\EmpPlotWL1, replace
restore
	
preserve
	keep EmpWL2_F* EmpWL2stay_F*  early	
	collapse (mean) Emp* ,by(early)
	reshape long EmpWL2_F EmpWL2stay_F, i(early) j(yrs2Event)	
	drop if early==.	
	drop if yrs2Event>5
	rename EmpWL2_F EmpWL2_	
	append using $InputDTAs_dir\EmpPlotWL2
	
	merge 1:1 yrs2Event early using $InputDTAs_dir\EmpPlotDI
	drop _merge
	merge 1:m yrs2Event early using $InputDTAs_dir\EmpPlotWL1
	drop _merge	
	
	twoway (line  Emp_allr yrs2Event if early==1 , lcolor(gray) ) (line  EmpDI_ yrs2Event if early==1 , lwidth(thick)  lcolor(black) ) /*
	*/ (line EmpWL1_ yrs2Event if early==1 , lwidth(thick) lcolor(blue) ) (line  EmpWL2_ yrs2Event if early==1 , lwidth(thick) lcolor(red) )  /*
	*/(line EmpWL1stay_ yrs2Event if early==1 , lwidth(thick) lpattern(dash) lcolor(blue) ) (line  EmpWL2stay_ yrs2Event if early==1 , lwidth(thick) lpattern(dash) lcolor(red)) , /* 
	*/ title("Employment Rates Before and After Event") subtitle("1986-1993") xtitle("Years before/after Onset") ytitle("Fraction Employed") /*
	*/ legend(lab(1 "Reference Group") lab(2 "DI Enroll") lab(3 "Moderate Work Limitation") lab(4 "Severe Work Limitation") lab(5 "Still Moderate Limitation") lab(6 "Still Severe Limitation"))/*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) tline(0, lc(red))
	*graph export "$OUT_dir\Emp_early.eps", replace
	*graph export "$OUT_dir\Emp_early.pdf", replace
	*graph save Graph "H:\disability\SumStatsOUT\Emp_early.gph", replace

	twoway (line  Emp_allr yrs2Event if early==0 , lcolor(gray) ) (line  EmpDI_ yrs2Event if early==0 , lwidth(thick) lcolor(black)  ) /*
	*/ (line EmpWL1_ yrs2Event if early==0 , lwidth(thick) lcolor(blue) ) (line  EmpWL2_ yrs2Event if early==0 , lwidth(thick) lcolor(red) )  /*
	*/(line EmpWL1stay_ yrs2Event if early==0 , lwidth(thick) lpattern(dash) lcolor(blue) ) (line  EmpWL2stay_ yrs2Event if early==0 , lwidth(thick) lpattern(dash) lcolor(red)) , /* 
	*/ title("Employment Rates Before and After Event") subtitle("2005, 2007, 2011") xtitle("Years before/after Onset") ytitle("Fraction Employed") /*
	*/ legend(lab(1 "Reference Group") lab(2 "DI Enroll") lab(3 "Moderate Work Limitation") lab(4 "Severe Work Limitation") lab(5 "Still Moderate Limitation") lab(6 "Still Severe Limitation"))/*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) tline(0, lc(red))
	*graph export "$OUT_dir\Emp_late.eps", replace
	*graph export "$OUT_dir\Emp_late.pdf", replace
	*graph save Graph "H:\disability\SumStatsOUT\Emp_late.gph", replace
restore
	

	
		by x11101ll, sort: egen EverDI = max(SSDI_LP)
		by x11101ll, sort: egen EverWL = max(WlimitLP)
		
preserve

	collapse (median) LifeOcc2 EverDI EverWL wpts if (Age>50 & Age<65 & selectDIstats==1 & wave>1985 & wave<1994), by(x11101ll)
	drop if LifeOcc2==.
	gen EverWL1=(EverWL==1 | EverWL==2)
	gen EverWL2=(EverWL==2)
	
	collapse (mean) EverDI EverWL1 EverWL2 , by(LifeOcc2)	

	by LifeOcc2, sort: sum EverDI EverWL1 EverWL2	 
	
restore	



************
*Employment and Health Status of DI recipients by age
************
*use no college as the reference group
drop Emp_all
gen Emp_all=1 if (Emp==1 & Col~=1 & selectDIstats==1 )
replace Emp_all=0 if (Emp==0 & Col~=1 & selectDIstats==1 ) 
gen WlimitLP2_all=1 if (WlimitLP==2 & Col~=1 & selectDIstats==1 )
replace WlimitLP2_all=0 if (WlimitLP==0 & Col~=1 & selectDIstats==1 )
gen WlimitLP1_all=1 if (WlimitLP==1 & Col~=1 & selectDIstats==1 )
replace WlimitLP1_all=0 if (WlimitLP==0 & Col~=1 & selectDIstats==1 )


gen avEmpDI_L1to3 = (EmpDI_1+EmpDI_2+EmpDI_3)/3
gen avWlim1_L1to3 = (Wlim1DI_1+Wlim1DI_2+Wlim1DI_3)/3
gen avWlim2_L1to3 = (Wlim2DI_1+Wlim2DI_2+Wlim2DI_3)/3

preserve
collapse (mean) Emp_all WlimitLP2_all WlimitLP1_all EmpDI_1 Wlim1DI_1 Wlim2DI_1 avEmpDI_L1to3 avWlim1_L1to3 avWlim2_L1to3 if (selectDIstats==1 & wave>1985 & wave<1994) [pw=wpts], by(AgeBin)

export delimited using "$OUT_dir\EmpWlim_byAge.csv", replace

restore

preserve
collapse (mean) Emp_all WlimitLP2_all WlimitLP1_all EmpDI_1 Wlim1DI_1 Wlim2DI_1 avEmpDI_L1to3 avWlim1_L1to3 avWlim2_L1to3 if (selectDIstats==1 & wave>1985 & wave<1994) [pw=wpts]

export delimited using "$OUT_dir\EmpWlim_all.csv", replace

restore

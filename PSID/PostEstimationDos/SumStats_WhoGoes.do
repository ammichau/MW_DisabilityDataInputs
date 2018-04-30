*SumStats_WhoGoes.do
*-------------------v.7-24-2017; @A. Michaud for DIoption w/ DW---------------------------------*
global SSOUT_dir $root_dir\SumStatsOUT
cd $PSID_dir
***************************************************************************************************************
* This code computes statistics about DI claims
* Step 1) Reads in and cleans variables from PSID
* Step 2) Merges with main dataset
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-calibdata2.dta; created by MainCalib_StartHere.do
*	-You have to have files set up for psiduse in folder "Mdta", a subdirectory of PSID_dir set in main file
*-------------------------------------------------------------------------------------------------
* Updates
* 	-7-24-2017: Changed output folder
***************************************************************************************************************

clear all
set more off


psid use || hwSSinc  [70]V1212 [71]V1914 [72]V2515 [73]V3068 [74]V3480 ///
					 [75]V3880 [76]V4395 [77]V5306 [78]V5806 [79]V6417 [80]V7007 [81]V7599 ///
					 [82]V8292 [83]V8900 ///
		|| hSSinc    [86]V12832 [87]V13934 [88]V14949 [89]V16449 [90]V17865 [91]V19165 [92]V20465 ///
					 [93]V22027 [05]ER28031 [07]ER41021 [09]ER46929 [11]ER52337 [13]ER58146 ///			 
		|| FamSSyn   [94]ER3307 [95]ER6308 [96]ER8425 [97]ER11318 [99]ER14584 [01]ER18746 [03]ER22118 [05]ER26099 [07]ER37117 [09]ER43108 [11]ER48430 ///
        || hwSStype  [84]ER30450 [85]ER30485 ///
		|| hSStype   [86]V12833 [87]V13935 [88]V14950 [89]V16450 [90]V17866 [91]V19166 [92]V20466 [93]V22012 ///
		|| wSStype   [86]V12854 [87]V13956 [88]V14971 [89]V16471 [90]V17887 [91]V19187 [92]V20487 [93]V22286 ///
		|| pSStype2_ [11]ER34137 ///
		|| pSStype3_ [05]ER27728 [07]ER40703 ///
		|| SSDI_amt  [84]ER30451 [85]ER30486 [86]ER30521 [87]ER30557 [88]ER30592 ///
				     [89]ER30628 [90]ER30665 [91]ER30713 [92]ER30758 [09]ER34031 [11]ER34143 ///			
        || hWksU     [69]V672 [70]V1336 [71]V2042 [72]V2642 [73]V3159 [74]V3575 [75]V4030 ///
		|| hHrsU     [76]V4338 [77]V5240 [78]V5739 [79]V6344 [80]V6942 [81]V7538 [82]V8236 [83]V8838 ///
					 [84]V10045 [85]V11153 [86]V12552 [87]V13752 [88]V14842 [89]V16342 [90]V17751 [91]V19051 ///
					 [92]V20351 [93]V21638 ///
		|| wHrsU     [76]V4727 [77]V5252 [78]V5751 [79]V6356 [80]V6954 [81]V7548 [82]V8246 [83]V8848 [84]V10139 ///
					 [85]V11265 [86]V12664 [87]V13816 [88]V14872 [89]V16372 [90]V17781 [91]V19081 [92]V20381 [93]V21674 ///
		|| hWksU	 [94]ER2191 [95]ER5190 [96]ER7286 [97]ER10201 [99]ER13332 [01]ER17356 ///
		|| hWksU_E   [03]ER21320 [05]ER25309 [07]ER36314 [09]ER42341 [11]ER47654 ///
		|| hWksU_O   [09]ER46666 [11]ER52067 ///
		|| wWksU_E   [03]ER21570 [05]ER25567 [07]ER36572 [09]ER42593 [11]ER47911 ///
		|| wWksU_O   [09]ER46677 [11]ER52078 ///		
		|| hWksE 	 [68]V223 [69]V658 [70]V1292 [71]V1998 [72]V2596 [73]V3129 [74]V3544 [75]V3998 [76]V4507 [77]V5417 ///
					 [78]V5904 [79]V6515 [80]V7118 [81]V7741 [82]V8403 [83]V9034 [84]V10561 [85]V11705 [86]V13105 ///
					 [87]V14203 [88]V15257 [89]V16758 [90]V18196 [91]V19496 [92]V20796 [93]V22575 [94]ER4092 [95]ER6932 ///
					 [96]ER9183 [97]ER12170 [99]ER16467 [01]ER20395 [03]ER24077 [05]ER27883 [07]ER40873 [09]ER46761 [11]ER52169 ///
		|| wWksE     [68]V244 [69]V610 [70]V1368 [71]V2076 [72]V2674 [73]V3185 [74]V3603 [75]V4057 [76]V4607 [77]V5522 ///
				     [78]V6051 [79]V6611 [80]V7213 [81]V7904 [82]V8562 [83]V9212 [84]V10775 [85]V12068 [86]V13282 [87]V14376 ///
					 [88]V15559 [89]V17077 [90]V18498 [91]V19798 [92]V21098 [93]V22928 [94]ER4103 [95]ER6943 [96]ER9194 [97]ER12181 ///
					 [99]ER16478 [01]ER20406 [03]ER24088 [05]ER27894 [07]ER40884 [09]ER46782 [11]ER52190 ///
		|| hInvU     [69]V651 [70]V1332 [71]V2038 [72]V2638 [73]V3155 [74]V3571 [75]V4026 [76]V4556 [77]V5458 ///
					 [78]V5986 [79]V6559 [80]V7161 [81]V7809 [82]V8470 [83]V9107 [84]V10609 [85]V11764 ///
					 [86]V13160 [87]V14256 [88]V15328 [89]V16843 [90]V18267 [91]V19567 [92]V20867 [93]V22655 ///
					 [94]ER4034 [95]ER6874 [96]ER9125 [97]ER12102 [99]ER13498 [01]ER17538 [03]ER21184 ///
					 [05]ER25173 [07]ER36178 [09]ER42211 [11]ER47524 ///
		|| hInvSep   [68]V201 [69]V643 [70]V1282 [71]V1988 [72]V2586 [73]V3119 [74]V3534 [75]V3986 ///
					 [76]V4490 [77]V5399 [78]V5890 [79]V6501 [80]V7104 [81]V7727 [82]V8391 [83]V9022 [84]V10539 ///
					 [85]V11679 [86]V13079 [87]V14177 [88]V15240 [89]V16741 [90]V18179 [91]V19479 [92]V20779 ///
					 [93]V22551 [94]ER4023 [95]ER6863 [96]ER9114 [97]ER12091 [99]ER13310 [01]ER17321 [03]ER21216 ///
					 [05]ER25205 [07]ER36210 [09]ER42241 [11]ER47554 ///
        using Mdta , clear design(3)
		
	psid long
	xtset x11101ll wave
	
cd "C:\Users\ammichau\Google Drive\Disability\DisabilityOption\Data\Calibration_May3_2017"
	merge 1:1 x11101ll wave using $InputDTAs_dir\calibdata2.dta
	drop _merge
 save $InputDTAs_dir\who, replace	
*************************************************************************************************
*Some definitions
*------------------------------------------------------------------------------------------------
*FamSSyn - Did anybody receive SS income? 1=Y; 5=No; 8=DK; 9=refused
*hwSSinc - head and wife SS inc, top coded at 99999	
*hSStype = type of SS income; 1==Disability
*************************************************************************************************

*------------------------
*Assign head/wife vars and harmonize ones needing it
*------------------------
local vrs  SStype HrsU WksU_E WksU_O WksE 
foreach v of local vrs {
	gen `v'= h`v' if HH==1
	replace `v'=w`v' if HW==1
	drop h`v' w`v'
	}
local vrs SSinc WksU InvU InvSep
	foreach v of local vrs {
	gen `v'= h`v' if HH==1
	drop h`v' 
	}
gen disab=Hdisab if HH==1
replace disab=Wdisab if HW==1	
	
gen SSDI=(hwSStype==1 | pSStype2_==1 | pSStype3_==1)	
	replace SSDI=1 if (SStype==1)
	replace SSDI=. if (wave==2013 | wave==2009 | (wave>1993 & wave<2005) |  wave<1984 )
	*drop hwSStype pSStype2_ pSStype3_

replace WksU = WksU_E if WksU==.
replace WksU = WksU_O if WksU==.
drop WksU_*

*************************************************************************************************
*Coding Chunk 3: DI & SSI receipt
*------------------------------------------------------------------------------------------------
* EmpStat: working=1, temp u =2, u =3, retired = 4, disb=5, housewife = 6
*------------------------------------------------------------------------------------------------		

*Construct SSDI receipt variable (for head only)
*!!!!!This does not appear to be very consistent with the self-report years. Don't use.!!!!!

	*1) 1970-1983: If head reports SSI income & is less than 62 y/old or reports being disabled & not working
		*gen SSDI_impute=(SSinc>0 & SSinc<99999 & disab==1  & Age<62 )	
	*2) 1984-1983: SSDI receipt
		*replace SSDI_impute = 1 if (SSDI==1)
	*3) 1994-2003 : Family SSDI receipt & reports being disabled & not working
		*replace SSDI_impute = 1 if (FamSSyn==1 & disab==1  & Age<62)
		*replace SSDI_impute=. if (wave==2013 | wave<1984)

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
	
	replace SSDI_LP =. if (wave>1993 | wave<1986)
	
* There are also guys who list employment status as "permanently disabled" (EmpStat==5)
*	-> This one looks pretty good!
	gen SSDIv2 = SSDI_LP if (wave>1983 & wave<1994) 
	replace SSDIv2 = SSDI if ( wave==2005 | wave==2007 | wave==2011) 
	replace SSDIv2 = 1 if (FamSSyn==1 & EmpStat==5 & (wave==2009 | (wave<2005 & wave>1993) ))
	replace SSDIv2 = 1 if (SSinc>0 & SSinc<99999 & EmpStat==5)
	replace SSDIv2 = 0 if (SSDIv2==. & wave>1983 & (FamSSyn==5 | SSinc==0))
	
*Something  for the later years
	gen SSDI_2000 =  SSDI if ( wave==2005 | wave==2007 | wave==2011) 
	
*************************************************************************************************
*Coding Chunk 4: Weeks unemployed & employed prior year
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------		
* Weeks unemployed
	*1) 1969-1975
	replace WksU = . if (WksU>52 & wave>1968 & wave<1976)
	*2) 1976-1993; hours 
	replace WksU = HrsU/40 if (wave>1975 & wave<1994)
	*3) 1994-2001; 
	replace WksU = . if (WksU>52 & wave>1993)
    *4) 2002- Even and odd years

* Weeks employed
	replace WksE=. if WksE>52
	gen Emp20 = 1 if (WksE>20 & WksE<53)
	replace Emp20 = 0 if (WksE<21)
*************************************************************************************************
*Coding Chunk 5: Job Loss reason
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------		
	*Involuntary unemployment- company folded, laid off, or fired
	replace InvU = 1 if (InvU == 3)
	replace InvU = 0 if (InvU~=1)
	replace InvU=. if HH==0
	
	replace InvSep = 1 if (InvU == 1 | InvSep==3)
	replace InvSep = 0 if (InvSep~=1)
	replace InvU=. if HH==0
	
************
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
save $InputDTAs_dir\who, replace	
*********************************************************************************
*------------------------------------------------------
*Cleaning Done. Analysis Starts Here.
*------------------------------------------------------
********************************************************************************

************
*Income:
*		Want to figure out where SSDI claimaints are in the income distribution. Prime Age only
************	
*Total Labor income	
	replace LabInc=. if (LabInc<100 | LabInc>220000 )
	by wave, sort: egen LabIp20 = pctile(LabInc) if (Age>30 & Age<63 & selectDIstats==1 & Col~=1), p(20)
	*=1 if wage< 20th percentile prior year
	gen LabIncLess20= 1 if (LabInc<LabIp20 &  Age>30 & Age<63 & selectDIstats==1)
	replace LabIncLess20= 0 if (LabInc>LabIp20 & LabInc~=. & Age>30 & Age<63 & selectDIstats==1)
	*=1 if wage< 20th percentile any of prior 5 years
	xtset x11101ll wave
	gen y5LabIncLess20= LabIncLess20
		replace y5LabIncLess20=1 if L1.LabIncLess20==1 
		replace y5LabIncLess20=1 if L2.LabIncLess20==1 
		replace y5LabIncLess20=1 if L3.LabIncLess20==1 
		replace y5LabIncLess20=1 if L4.LabIncLess20==1 
		replace y5LabIncLess20 = 0 if (LabIncLess20<1 & Age>40 & Age<63 & selectDIstats==1)
	*drop if (wave<1983 | wave>1997)

*****Tab for DI receipients and general population
	svyset [pweight=wpts]
	svy: tab y5LabIncLess20 if (Age>40 & Age<63 & SSDIv2==1 & selectDIstats==1 & wave>1985)
			estimate store DILabInc5_imp	
	svy: tab y5LabIncLess20 if (Age>40 & Age<63 & SSDI_LP==1 & wave>1985 & wave<1994 & selectDIstats==1)
			estimate store DILabInc5_early	
	svy: tab y5LabIncLess20 if (SSDIv2==1 & Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1)
			estimate store DILabInc5_late	
	svy: tab y5LabIncLess20 if (Age>40 & Age<63 & wave>1985 & wave<1994 & selectDIstats==1 & Col~=1)
			estimate store DILabInc5c_early	
	svy: tab y5LabIncLess20 if (Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1 & Col~=1)
			estimate store DILabInc5c_late
			
esttab DILabInc5_imp DILabInc5_early DILabInc5_late DILabInc5c_early DILabInc5c_late ///
                   using $SSOUT_dir\SumStatsDI_labInc.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		    title(Labor income less than 20th percentile in any of past 5 years; DI receipients and reference pop.)       ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("Total Imputed 1986-2013" "1986-1993" "2005, 2007, 2011" "Pop 1986-1993" "Pop 2005, 2007, 2011") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
			   
*****Tab by health
	svyset [pweight=wpts]
	svy: tab y5LabIncLess20 if (Age>40 & Age<63 & WlimitLP==1 & selectDIstats==1 & wave>1985 & wave<1994)
			estimate store DILabInc5_early_mod	
	svy: tab y5LabIncLess20 if (Age>40 & Age<63 & WlimitLP==2 & selectDIstats==1 & wave>1985 & wave<1994)
			estimate store DILabInc5_early_severe	
	svy: tab y5LabIncLess20 if (WlimitLP==1 & Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1)
			estimate store DILabInc5_late_mod	
	svy: tab y5LabIncLess20 if (WlimitLP==2 & Age>40 & Age<63 & (wave==2005 | wave==2007 | wave==2011) & selectDIstats==1)
			estimate store DILabInc5_late_severe	

			
esttab DILabInc5_early_mod DILabInc5_early_severe DILabInc5_late_mod DILabInc5_late_severe ///
                   using $SSOUT_dir\SumStatsWlim_labInc.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		    title(Labor income less than 20th percentile in any of past 5 years; by work limitation.)       ///
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles( "1986-1993; moderate" "2005, 2007, 2011; moderate" "1986-1993; severe" "2005, 2007, 2011; severe") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
			   
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
                   using $SSOUT_dir\SumStatsDI_InvolU.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Involuntary Unemployed in any of past 5 years.)       ///		   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("Total Imputed 1986-2013" "1986-1993" "2005, 2007, 2011" "1986-1993; Pop" "2005, 2007, 2011; Pop") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	
			   
esttab InvU5_early_mod InvU5_early_severe InvU5_late_mod InvU5_late_severe ///
                   using $SSOUT_dir\SumStatsWlim_InvolU.tex ///
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
                   using $SSOUT_dir\SumStatsDI_InvolSep.tex ///
		   , se ar2 b(4) stat(N , fmt(0 4 4) labels("Observations" ) ) ///
		   title(Involuntary Separation in any of past 5 years.)       ///			   
		   nodepvars gaps label substitute(\hline\hline \hline \hline "\hline  "  ///
                   "\sym{\sym{\dagger}}" " $^{\dagger}$" "\sym{\sym{*}}" " $^{*}$" "\sym{\sym{**}}" " $^{**}$") ///
		     nonumbers mtitles("Total Imputed 1986-2013" "1986-1993" "2005, 2007, 2011" "1986-1993; Pop" "2005, 2007, 2011; Pop") ///
	           star(\sym{\dagger} 0.10 \sym{*} 0.05 \sym{**} 0.01) replace	

			   
			   
esttab InvS5_early_mod InvS5_early_severe InvS5_late_mod InvS5_late_severe ///
                   using $SSOUT_dir\SumStatsWlim_InvolSep.tex ///
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
	graph export $SSOUT_dir\Wlim_early.eps, replace
	graph export $SSOUT_dir\Wlim_early.pdf, replace
	graph save Graph $SSOUT_dir\Wlim_early.gph, replace

	
	twoway (line Wlim1DI_ yrs2Event if early==0 & yrs2Event>-9, lwidth(thick)  lcolor(red)  ) (line  Wlim2DI_ yrs2Event if early==0 & yrs2Event>-9, lwidth(thick)  lcolor(blue)  ), /*
	*/ title("Work Limitation Prior to DI acceptance") subtitle("2005, 2007, 2011") xtitle("Years Prior to Acceptance") ytitle("Fraction with Work Limitation") /*
	*/ legend(lab(1 "Moderate Work Limitation") lab(2 "Severe Work Limitation") ) /*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) tline(0, lc(red))
	graph export $SSOUT_dir\Wlim_late.eps, replace
	graph export $SSOUT_dir\Wlim_late.pdf, replace
	graph save Graph $SSOUT_dir\Wlim_late.gph, replace	
	
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
	*graph export $SSOUT_dir\Emp_early.eps, replace
	*graph export $SSOUT_dir\Emp_early.pdf, replace
	*graph save Graph $SSOUT_dir\Emp_early.gph, replace

	twoway (line  Emp_allr yrs2Event if early==0 , lcolor(gray) ) (line  EmpDI_ yrs2Event if early==0 , lwidth(thick) lcolor(black)  ) /*
	*/ (line EmpWL1_ yrs2Event if early==0 , lwidth(thick) lcolor(blue) ) (line  EmpWL2_ yrs2Event if early==0 , lwidth(thick) lcolor(red) )  /*
	*/(line EmpWL1stay_ yrs2Event if early==0 , lwidth(thick) lpattern(dash) lcolor(blue) ) (line  EmpWL2stay_ yrs2Event if early==0 , lwidth(thick) lpattern(dash) lcolor(red)) , /* 
	*/ title("Employment Rates Before and After Event") subtitle("2005, 2007, 2011") xtitle("Years before/after Onset") ytitle("Fraction Employed") /*
	*/ legend(lab(1 "Reference Group") lab(2 "DI Enroll") lab(3 "Moderate Work Limitation") lab(4 "Severe Work Limitation") lab(5 "Still Moderate Limitation") lab(6 "Still Severe Limitation"))/*
	*/ graphregion(color(white)) xlabel(,grid gstyle(dot)) ylabel(,grid gstyle(dot)) tline(0, lc(red))
	*graph export $SSOUT_dir\Emp_late.eps, replace
	*graph export $SSOUT_dir\Emp_late.pdf, replace
	*graph save Graph $SSOUT_dir\Emp_late.gph, replace
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

export delimited using $SSOUT_dir\EmpWlim_byAge.csv, replace

restore

preserve
collapse (mean) Emp_all WlimitLP2_all WlimitLP1_all EmpDI_1 Wlim1DI_1 Wlim2DI_1 avEmpDI_L1to3 avWlim1_L1to3 avWlim2_L1to3 if (selectDIstats==1 & wave>1985 & wave<1994) [pw=wpts]

export delimited using $SSOUT_dir\EmpWlim_all.csv, replace

restore

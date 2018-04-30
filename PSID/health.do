*health.do
*-------------------v.4-29-2017; @A. Michaud for DIoption w/ DW---------------------------------*
cd $PSID_dir
***************************************************************************************************************
* This code reads in and cleans health realted (and other) variables from PSID
* Variables in use:
*	-3 questions about work limiting disability
*	-Death Year
*	-Sex
*	-Age
*	-Employment Status
* Variables created
*	- 3-value work limitation varaible following LP's AER
*	-
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-You have to have files set up for psiduse in folder "Mdta", a subdirectory of PSID_dir set in main file
***************************************************************************************************************

*clear all
set more off
*ssc install psidtools
*help psid
*psid install using UMICHdata
*psid install using Mdta


psid use || Hdisab [72]V2718 [73]V3244 [74]V3666 [75]V4145 [76]V4625 [77]V5560 [78]V6102 [79]V6710 ///
				   [80]V7343 [81]V7974 [82]V8616 [83]V9290 [84]V10879 [85]V11993 [86]V13427 [87]V14515 ///
				   [88]V15994 [89]V17391 [90]V18722 [91]V20022 [92]V21322 [93]V23181 [94]ER3854 [95]ER6724 ///
				   [96]ER8970 [97]ER11724 [99]ER15449 [01]ER19614 [03]ER23014 [05]ER26995 [07]ER38206 [09]ER44179 [11]ER49498 [13]ER55248 ///
		|| Wdisab  [76]V4766 [81]V7982 [82]V8619 [83]V9295 [84]V10886 [85]V12346 [86]V13462 [87]V14526 ///
				   [88]V16000 [89]V17397 [90]V18728 [91]V20028 [92]V21329 [93]V23188 [94]ER3859 [95]ER6729 ///
				   [96]ER8975 [97]ER11728 [99]ER15557 [01]ER19722 [03]ER23141 [05]ER27118 [07]ER39303 [09]ER45276 [11]ER50616 [13]ER56364 ///
	    || Hwlimit01_ [86]V13428 [87]V14516 [88]V15995 [89]V17392 [90]V18723 [91]V20023 [92]V21323 [93]V23182 ///
					[94]ER3855 [95]ER6725 [96]ER8971 [97]ER11725 [99]ER15450 [01]ER19615 [03]ER23015 ///
					[05]ER26996 [07]ER38207 [09]ER44180 [11]ER49499 [13]ER55249 ///
		|| Wwlimit01_ [86]V13463 [87]V14527 [88]V16001 [89]V17398 [90]V18729 [91]V20029 [92]V21330 [93]V23189 [94]ER3860 ///
					[95]ER6730 [96]ER8976 [97]ER11729 [99]ER15558 [01]ER19723 [03]ER23142 [05]ER27119 [07]ER39304 [09]ER45277 [11]ER50617 [13]ER56365 ///
		|| Hwlimit [68]V216 [72]V2719 [73]V3245 [74]V3667 [75]V4146 [76]V4626 ///
				   [77]V5561 [78]V6103 [79]V6711 [80]V7344 [81]V7975 [82]V8617 [83]V9291 ///
				   [84]V10880 [85]V11994 [86]V13429 [87]V14517 [88]V15996 [89]V17393 ///
				   [90]V18724 [91]V20024 [92]V21324 [93]V23183 [94]ER3856 [95]ER6726 ///
				   [96]ER8972 [97]ER11726 [99]ER15451 [01]ER19616 [03]ER23016 [05]ER26997 ///
				   [07]ER38208 [09]ER44181 [11]ER49500 [13]ER55250 ///			 
	    || Wwlimit [76]V4767 [81]V7983 [82]V8620 [83]V9296 [84]V10887 [85]V12347 [86]V13464 [87]V14528 ///
				   [88]V16002 [89]V17399 [90]V18730 [91]V20030 [92]V21331 [93]V23190 [94]ER3861 [95]ER6731 ///
				   [96]ER8977 [97]ER11730 [99]ER15559 [01]ER19724 [03]ER23143 [05]ER27120 [07]ER39305 [09]ER45278 [11]ER50618 [13]ER56366 ///
		|| DeathYr  [68]ER32050 ///
		|| Sex		[68]ER32000 ///
		|| Age		 [68]ER30004 [69]ER30023 [70]ER30046 [71]ER30070 [72]ER30094 [73]ER30120 [74]ER30141 ///
					 [75]ER30163 [76]ER30191 [77]ER30220 [78]ER30249 [79]ER30286 [80]ER30316 [81]ER30346 ///
					 [82]ER30376 [83]ER30402 [84]ER30432 [85]ER30466 [86]ER30501 [87]ER30538 [88]ER30573 ///
					 [89]ER30609 [90]ER30645 [91]ER30692 [92]ER30736 [93]ER30809 [94]ER33104 [95]ER33204 ///
					 [96]ER33304 [97]ER33404 [99]ER33504 [01]ER33604 [03]ER33704 [05]ER33804 [07]ER33904 ///
					 [09]ER34004 [11]ER34104 [13]ER34204 ///
        || EmpStat   [79]ER30293 [80]ER30323 [81]ER30353 [82]ER30382 [83]ER30411 [84]ER30441 [85]ER30474 ///
					 [86]ER30509 [87]ER30545 [88]ER30580 [89]ER30616 [90]ER30653 [91]ER30699 [92]ER30744 ///
					 [93]ER30816 [94]ER33111 [95]ER33211 [96]ER33311 [97]ER33411 [99]ER33512 [01]ER33612 ///
					 [03]ER33712 [05]ER33813 [07]ER33913 [09]ER34016 [11]ER34116 [13]ER34216 ///					 
        using Mdta , clear design(3)
		save $InputDTAs_dir\health, replace
		


***************************************************************************************************************************		
*Not currently in use:
*|| HeadSSinc2 [93]V22013 ///
*|| TimeHSSinc2 [93]V22014 ///
*|| SSDI        [86]ER30520 [87]ER30556 [88]ER30591 [89]ER30627 [90]ER30664 [91]ER30712 [92]ER30757 [09]ER34030 ///
*|| HcareFac  [85]V12415 [86]V13655 [87]V14702 [88]V16176 [89]V17558 [90]V18912 [91]V20212 [92]V21518 ///
*|| Medicare  [99]ER33518 [01]ER33618 [03]ER33718 [05]ER33819 [07]ER33919 [09]ER34022 [11]ER34121 ///
*|| ADLmeal	[92]ER30780 [93]ER30838 [94]ER33139 [95]ER33294A [96]ER33337 ///  *individuals 55+
*|| ADLshop  [92]ER30782 [93]ER30840 [94]ER33141 [95]ER33295A [96]ER33339 ///
*|| ADLhwrk  [92]ER30788 [93]ER30846 [94]ER33147 [95]ER33298A [96]ER33345 ///
*___________________________________________________________________________________________________________________________
*Notes:
*	-"In 1973, 1974, and 1975, the PSID did not ask the work limitation question of those who were in the sample in 1972, assuming that the answer
*		would not change. For new entrants, the question was asked only at entry into the sample. "

rename Sex1968 Sex
rename DeathYr1968 DeathYr

* Go long
	psid long
	xtset x11101ll wave
	
* Assign vars to appropriate person	
gen HH=(xsqnr==1)
gen HW=(xsqnr==2)
	
*Little Cleaning
	replace Age=. if (Age==0 | Age>106)


*************************************************************************************************
*Coding Chunk 2: Work Limiting D
*------------------------------------------------------------------------------------------------
* Two Q's: Do you have a physical or nervous condition that limits the type of work or the amount of work you can do? 
*	-> 123 Variable says by how much: 1=complete/can't work, 2= severe, 3= moderate, 5=little, 7=no, 9=missing
*		-I recode to 0=none, 1= somewhat, 2=severe, and eventually 3=dead
*	-> 01 Variable says yes=1 or no=5, 9=missing
*-------------------------------------------------------------------------------------------------	
*L&P measure
gen disab = Hdisab if HH==1
replace disab = Wdisab if HW==1
gen twdisab = Hwlimit01_ if HH==1
replace twdisab = Wwlimit01_ if HW==1
gen hmdisab = Hwlimit if HH==1
replace hmdisab = Wwlimit if HW==1

	*Direct from their code.
	gen  WlimitLP=2 if 		((disab==1 & twdisab==7)|(disab==1 & twdisab==1 & hmdisab==1)|(disab==1 & twdisab==5 & hmdisab==1)| ///
						    (disab==1 & twdisab==8 & hmdisab==1))
	replace WlimitLP=1 if 	((disab==1 & twdisab==1 & hmdisab==3)|(disab==1 & twdisab==8 & hmdisab==3)|(disab==1 & twdisab==5 & hmdisab==3)| ///
						     (disab==1 & twdisab==1 & hmdisab==5)|(disab==1 & twdisab==8 & hmdisab==5)|(disab==1 & twdisab==5 & hmdisab==5))
	replace WlimitLP=0 if 		WlimitLP==.

	*My interpretation from reading their paper. This only changes a few observations
	gen     WlimitLPvAM=WlimitLP 
	replace WlimitLPvAM=. if 		(WlimitLPvAM<1)
	replace WlimitLPvAM=0 if 		(disab==5 | twdisab==5)

drop disab twdisab hmdisab
*************************************************************************************************
*Coding Chunk 6: Dead, Yrs to Death
*------------------------------------------------------------------------------------------------
* I thought this might be useful.
* Dead=1 if, well... dead. 
* Yrs to death >0 if observe death, 0 in death year, -1 if dead, and 99 if not dead yet
*------------------------------------------------------------------------------------------------	
replace DeathYr=1971 if DeathYr==7071
replace DeathYr=1972 if DeathYr==7172
replace DeathYr=1973 if DeathYr==7273
replace DeathYr=1974 if DeathYr==7374
replace DeathYr=1975 if DeathYr==7475
replace DeathYr=1976 if DeathYr==7576
replace DeathYr=1977 if DeathYr==7677
replace DeathYr=1978 if DeathYr==7778
replace DeathYr=1979 if DeathYr==7879
replace DeathYr=1980 if DeathYr==7980
replace DeathYr=1981 if DeathYr==8081
replace DeathYr=1982 if DeathYr==8182
replace DeathYr=1983 if DeathYr==8283
replace DeathYr=1984 if DeathYr==8384
replace DeathYr=1985 if DeathYr==8485
replace DeathYr=1986 if DeathYr==8586
replace DeathYr=1987 if DeathYr==8687
replace DeathYr=1988 if DeathYr==8788
replace DeathYr=1989 if DeathYr==8889
replace DeathYr=1990 if DeathYr==8990
replace DeathYr=1991 if DeathYr==9091
replace DeathYr=1992 if DeathYr==9192
replace DeathYr=1993 if DeathYr==9293
replace DeathYr=1994 if DeathYr==9394
replace DeathYr=1995 if DeathYr==9495
replace DeathYr=1996 if DeathYr==9596
replace DeathYr=1997 if DeathYr==9697
replace DeathYr=1998 if DeathYr==9798
replace DeathYr=1999 if DeathYr==9899
replace DeathYr=1999 if DeathYr==9999
replace DeathYr=2009 if DeathYr==709

gen Yrs2Death = 99
gen dead = 0
forvalues x = 1997(-1)1967 {
	replace dead= 1 if (DeathYr==`x' & wave==`x' )	
	forvalues z = `x'(1)1997 {
		replace dead = 1 if (DeathYr==`x' & wave==`z')
	}		
	forvalues y = `x'(-1)1967 {
		replace Yrs2Death = `x'-`y' if (DeathYr==`x' & wave==`y')
	}
	forvalues zz = 1999(2)2011 {
		replace dead = 1 if (DeathYr==`x' & wave==`zz')
	}	
}

*2 year gap
forvalues x = 2011(-2)1999 {
	replace dead= 1 if (DeathYr==`x' & wave==`x' )	
	forvalues z = `x'(2)2011 {
		replace dead = 1 if (DeathYr==`x' & wave==`z')
	}		
	forvalues y = `x'(-2)1999 {
		replace Yrs2Death = `x'-`y' if (DeathYr==`x' & wave==`y')
	}
	forvalues yy = 1997(-1)1968 {
		replace Yrs2Death = `x'-`yy' if (DeathYr==`x' & wave==`yy')
	}	
}

replace Yrs2Death = -1 if (Yrs2Death==99 & dead==1)

save $InputDTAs_dir\health, replace

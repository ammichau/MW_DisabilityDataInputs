*work.do
*-------------------v.5-1-2017; @A. Michaud for DIoption w/ DW---------------------------------*
cd $PSID_dir
***************************************************************************************************************
* This code reads in and cleans work realted (and other) variables from PSID
* Variables in use:
*	-CPI adjusted Hourly Wages
*	-Education
*	-Race
*	-Marital Status
*	-Person Weight
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-You have to have files set up for psiduse in folder "Mdta", a subdirectory of PSID_dir set in main file
***************************************************************************************************************

clear all
set more off


psid use || HnyrsFT  [74]V3621 [75]V4142 [76]V4631 [77]V5605 [78]V6154 [79]V6751 [80]V7384 [81]V8036 [82]V8660 [83]V9346 ///
					 [84]V10993 [85]V11740 [86]V13606 [87]V14653 [88]V16127 [89]V17524 [90]V18855 [91]V20155 [92]V21461  ///
					 [93]V23317 [94]ER3986 [95]ER6856 [96]ER9102 [97]ER11898 [99]ER15980 [01]ER20041 [03]ER23477 [05]ER27445 ///
					 [07]ER40617 [09]ER46595 [11]ER51956 ///
		 || WnyrsFT  [74]V3611 [75]V4111 [76]V4990 [77]V5575 [78]V6124 [79]V6721 [80]V7354 [81]V8006 [82]V8630 [83]V9316 ///
					 [84]V10963 [85]V12103 [86]V13532 [87]V14579 [88]V16053 [89]V17450 [90]V18781 [91]V20081 [92]V21387 ///
					 [93]V23244 [94]ER3916 [95]ER6786 [96]ER9032 [97]ER11810 [99]ER15887 [01]ER19948 [03]ER23385 [05]ER27349 ///
					 [07]ER40524 [09]ER46501 [11]ER51862 /// 
		 || hHrsYr   [68]V47 [69]V465 [70]V1138 [71]V1839 [72]V2439 [73]V3027 [74]V3423 [75]V3823 [76]V4332 [77]V5232 ///
				     [78]V5731 [79]V6336 [80]V6934 [81]V7530 [82]V8228 [83]V8830 [84]V10037 [85]V11146 [86]V12545 [87]V13745 ///
					 [88]V14835 [89]V16335 [90]V17744 [91]V19044 [92]V20344 [93]V21634 [94]ER4096 [95]ER6936 [96]ER9187 ///
					 [97]ER12174 [99]ER16471 [01]ER20399 [03]ER24080 [05]ER27886 [07]ER40876 [09]ER46767 [11]ER52175 ///
		 || wHrsYr   [68]V53 [69]V475 [70]V1148 [71]V1849 [72]V2449 [73]V3035 [74]V3431 [75]V3831 [76]V4344 [77]V5244 ///
					 [78]V5743 [79]V6348 [80]V6946 [81]V7540 [82]V8238 [83]V8840 [84]V10131 [85]V11258 [86]V12657 [87]V13809 ///
					 [88]V14865 [89]V16365 [90]V17774 [91]V19074 [92]V20374 [93]V21670 [94]ER4107 [95]ER6947 [96]ER9198 ///
					 [97]ER12185 [99]ER16482 [01]ER20410 [03]ER24091 [05]ER27897 [07]ER40887 [09]ER46788 [11]ER52196 ///
		 || hHrWage  [68]V337 [69]V871 [70]V1567 [71]V2279 [72]V2906 [73]V3275 [74]V3695 [75]V4174 [76]V5050 [77]V5631 [78]V6178 ///
					 [79]V6771 [80]V7417 [81]V8069 [82]V8693 [83]V9379 [84]V11026 [85]V12377 [86]V13629 [87]V14676 [88]V16150 ///
					 [89]V17536 [90]V18887 [91]V20187 [92]V21493 [94]ER4148 [95]ER6988 [96]ER9239 [97]ER12217 [99]ER16514 [01]ER20451 ///
					 [03]ER24137 [05]ER28003 [07]ER40993 [09]ER46901 [11]ER52309 [13]ER58118 ///
		 || wHrWage  [68]V338 [69]V873 [70]V1569 [71]V2281 [72]V2908 [73]V3277 [74]V3697 [75]V4176 [76]V5052 [77]V5632 [78]V6179 [79]V6772 ///
					 [80]V7418 [81]V8070 [82]V8694 [83]V9380 [84]V11027 [85]V12378 [86]V13630 [87]V14677 [88]V16151 [89]V17537 [90]V18888 ///
					 [91]V20188 [92]V21494 [94]ER4149 [95]ER6989 [96]ER9240 [97]ER12218 [99]ER16515 [01]ER20452 [03]ER24138 [05]ER28004 [07]ER40994 [09]ER46902 [11]ER52310 [13]ER58119 ///
		 || hLabInc	 [68]V74 [69]V514 [70]V1196 [71]V1897 [72]V2498 [73]V3051 [74]V3463 [75]V3863 [76]V5031 [77]V5627 [78]V6174 [79]V6767 [80]V7413 ///
					 [81]V8066 [82]V8690 [83]V9376 [84]V11023 [85]V12372 [86]V13624 [87]V14671 [88]V16145 [89]V17534 [90]V18878 [91]V20178 [92]V21484 ///
					 [93]V23323 [94]ER4140 [95]ER6980 [96]ER9231 [97]ER12080 [99]ER16463 [01]ER20443 [03]ER24116 [05]ER27931 [07]ER40921 [09]ER46829 [11]ER52237 [13]ER58038 ///
		 || wLabInc  [68]V75 [69]V516 [70]V1198 [71]V1899 [72]V2500 [73]V3053 [74]V3465 [75]V3865 [76]V4379 [77]V5289 [78]V5788 [79]V6398 [80]V6988 [81]V7580 ///
					 [82]V8273 [83]V8881 [84]V10263 [85]V11404 [86]V12803 [87]V13905 [88]V14920 [89]V16420 [90]V17836 [91]V19136 [92]V20436 [93]V23324 ///
					 [94]ER4144 [95]ER6984 [96]ER9235 [97]ER12082 [99]ER16465 [01]ER20447 [03]ER24135 [05]ER27943 [07]ER40933 [09]ER46841 [11]ER52249 [13]ER58050 ///
		 || tFamInc  [68]V81 [69]V529 [70]V1514 [71]V2226 [72]V2852 [73]V3256 [74]V3676 [75]V4154 [76]V5029 [77]V5626 [78]V6173 [79]V6766 ///
					 [80]V7412 [81]V8065 [82]V8689 [83]V9375 [84]V11022 [85]V12371 [86]V13623 [87]V14670 [88]V16144 [89]V17533 [90]V18875 ///
					 [91]V20175 [92]V21481 [93]V23322 [94]ER4153 [95]ER6993 [96]ER9244 [97]ER12079 [99]ER16462 [01]ER20456 [03]ER24099 ///
					 [05]ER28037 [07]ER41027 [09]ER46935 [11]ER52343 ///
		 || wEduc    [68]V246 [72]V2687 [73]V3216 [74]V3638 [75]V4199 [76]V5075 [77]V5648 [78]V6195 [79]V6788 [80]V7434 [81]V8086 [82]V8710 ///
				     [83]V9396 [84]V11043 [85]V12401 [86]V13641 [87]V14688 [88]V16162 [89]V17546 [90]V18899 ///
		 || hEduc    [68]V313 [69]V794 [70]V1485 [71]V2197 [72]V2823 [73]V3241 [74]V3663 [75]V4198 [76]V5074 [77]V5647 [78]V6194 [79]V6787 ///
					 [80]V7433 [81]V8085 [82]V8709 [83]V9395 [84]V11042 [85]V12400 [86]V13640 [87]V14687 [88]V16161 [89]V17545 [90]V18898 ///
		 || hHS		 [85]V11945 [86]V13568 [87]V14615 [88]V16089 [89]V17486 [90]V18817 [91]V20117 [92]V21423 [93]V23279 [94]ER3948 [95]ER6818 ///
					 [96]ER9064 [97]ER11854 [99]ER15937 [01]ER19998 [03]ER23435 [05]ER27402 [07]ER40574 [09]ER46552 [11]ER51913 [13]ER57669 ///
		 || wHS		 [85]V12300 [86]V13503 [87]V14550 [88]V16024 [89]V17421 [90]V18752 [91]V20052 [92]V21358 [93]V23215 [94]ER3887 [95]ER6757 ///
					 [96]ER9003 [97]ER11766 [99]ER15845 [01]ER19906 [03]ER23343 [05]ER27306 [07]ER40481 [09]ER46458 [11]ER51819 [13]ER57559 ///
		 || hCol     [75]V4099 [76]V4690 [77]V5614 [78]V6163 [79]V6760 [80]V7393 [81]V8045 [82]V8669 [83]V9355 [84]V11002 [85]V11960 ///
					 [86]V13583 [87]V14630 [88]V16104 [89]V17501 [90]V18832 [91]V20132 [92]V21438 [93]V23294 [94]ER3963 [95]ER6833 ///
				 	 [96]ER9079 [97]ER11869 [99]ER15952 [01]ER20013 [03]ER23450 [05]ER27417 [07]ER40589 [09]ER46567 [11]ER51928 [13]ER57684 ///
		 || wCol	 [75]V4105 [76]V4698 [77]V5570 [78]V6119 [79]V6716 [80]V7349 [81]V8001 [82]V8625 [83]V9311 [84]V10958 [85]V12315 ///
					 [86]V13513 [87]V14560 [88]V16034 [89]V17431 [90]V18762 [91]V20062 [92]V21368 [93]V23225 [94]ER3897 [95]ER6767 ///
					 [96]ER9013 [97]ER11781 [99]ER15860 [01]ER19921 [03]ER23358 [05]ER27321 [07]ER40496 [09]ER46473 [11]ER51834 [13]ER57574 ///
		 || hEducC	 [75]V4093 [76]V4684 [77]V5608 [78]V6157 [79]V6754 [80]V7387 [81]V8039 [82]V8663 [83]V9349 [84]V10996 [91]V20198 [92]V21504 ///
					 [93]V23333 [94]ER4158 [95]ER6998 [96]ER9249 [97]ER12222 [99]ER16516 [01]ER20457 [03]ER24148 [05]ER28047 [07]ER41037 [09]ER46981 [11]ER52405 [13]ER58223 ///
		 || wEducC	 [75]V4102 [76]V4695 [77]V5567 [78]V6116 [79]V6713 [80]V7346 [81]V7998 [82]V8622 [83]V9308 [84]V10955 [91]V20199 [92]V21505 [93]V23334 [94]ER4159 [95]ER6999 ///
				     [96]ER9250 [97]ER12223 [99]ER16517 [01]ER20458 [03]ER24149 [05]ER28048 [07]ER41038 [09]ER46982 [11]ER52406 [13]ER58224 ///						 
		 || hrace    [68]V181 [69]V801 [70]V1490 [71]V2202 [72]V2828 [73]V3300 [74]V3720 [75]V4204 [76]V5096 [77]V5662 [78]V6209 [79]V6802 /// 
					 [80]V7447 [81]V8099 [82]V8723 [83]V9408 [84]V11055 [85]V11938 [86]V13565 [87]V14612 [88]V16086 [89]V17483 [90]V18814 ///
					 [91]V20114 [92]V21420 [93]V23276 [94]ER3944 [95]ER6814 [96]ER9060 [97]ER11848 [99]ER15928 [01]ER19989 [03]ER23426 ///
					 [05]ER27393 [07]ER40565 [09]ER46543 [11]ER51904 [13]ER57659 ///
		 || wrace    [85]V12293 [86]V13500 [87]V14547 [88]V16021 [89]V17418 [90]V18749 [91]V20049 [92]V21355 [93]V23212 [94]ER3883 [95]ER6753 ///
					 [96]ER8999 [97]ER11760 [99]ER15836 [01]ER19897 [03]ER23334 [05]ER27297 [07]ER40472 [09]ER46449 [11]ER51810 [13]ER57549 ///
		 || hMarried [68]V239 [69]V607 [70]V1365 [71]V2072 [72]V2670 [73]V3181 [74]V3598 [75]V4053 [76]V4603 [77]V5650 [78]V6197 [79]V6790 [80]V7435 [81]V8087 ///
					 [82]V8711 [83]V9419 [84]V11065 [85]V12426 [86]V13665 [87]V14712 [88]V16187 [89]V17565 [90]V18916 [91]V20216 [92]V21522 [93]V23336 [94]ER4159A ///
					 [95]ER6999A [96]ER9250A [97]ER12223A [99]ER16423 [01]ER20369 [03]ER24150 [05]ER28049 [07]ER41039 [09]ER46983 [11]ER52407 [13]ER58225 ///			 
		 || wpts     [68]ER30019 [69]ER30042 [70]ER30066 [71]ER30090 [72]ER30116 [73]ER30137 [74]ER30159 [75]ER30187 [76]ER30216 [77]ER30245 [78]ER30282 ///
					 [79]ER30312 [80]ER30342 [81]ER30372 [82]ER30398 [83]ER30428 [84]ER30462 [85]ER30497 [86]ER30534 [87]ER30569 [88]ER30605 [89]ER30641 ///
					 [90]ER30686 [91]ER30730 [92]ER30803 [93]ER30864 [94]ER33119 [95]ER33275 [96]ER33318 [97]ER33438 [99]ER33547 [01]ER33639 [03]ER33742 [05]ER33849 [07]ER33951 [09]ER34046 [11]ER34155 ///					 
		 using Mdta , clear design(3)
		 

	   

 
***************************************************************************************************************************		
*Notes:
*   -wnyrsFT only asked of new heads and wives. Can be useful for wife who becomes head.
*   -hHS and wHS = year of graduation, supposed to not include GED
*   -weduc & heduc = 4 if completed HS, 7 =BA, 8 =PhD
* 	-wCol and hCol = 1 if completed college degree
*	-race=1 if white, =2 if black
*	-IF WE WANT STATE OF RESIDENCE, I can get it from the CNEF stuff later. Sneaky.


* Go long
	psid long
	xtset x11101ll wave
	
* Assign vars to appropriate person	

gen HH=(xsqnr==1)
gen HW=(xsqnr==2)


*************************************************************************************************
*Coding Chunk 1: Education
* Codes pre-1975 differ
*------------------------------------------------------------------------------------------------
gen educ = hEducC if HH==1
replace educ =wEducC if (HW==1 & educ==.)
replace educ = . if educ==99

replace educ = wEduc if (HW==1 & wave<1975)
replace educ = hEduc if (HH==1 & wave<1975)

	gen     EdBin=1 if educ<=3 & wave<1975                  		/*0-11  grades*/
	replace EdBin=2 if (educ==4|educ==5) & wave<1975		      	/*High school or 12 grades+nonacademic training*/
	replace EdBin=3 if educ>=6 & educ<=8 & wave<1975            	/*College dropout, BA degree, or college & adv./prof. degree*/
	replace EdBin=. if educ>8 & wave<1975                   		/*Missing, NA, DK*/
	replace EdBin=1 if educ>=0  & educ<=11 & wave>1974            	/*0-11  grades*/
	replace EdBin=2 if educ==12 & wave>1974                         			/*High school or 12 grades+nonacademic training*/
	replace EdBin=3 if educ>=13 & educ<=17 & wave>1974            	/*College dropout, BA degree, or college & adv./prof. degree*/
	replace EdBin=. if educ>17 & wave>1974 	                   		/*Missing, NA, DK*/

	gen lsHS=(EdBin==1)
	gen HS=(EdBin==2)
	gen Col=(EdBin==3)
	
	replace lsHS=. if EdBin==.
	replace HS=. if EdBin==.
	replace Col=. if EdBin==.

by  x11101ll, sort: egen EdBin2 =  mode(EdBin), maxmode	

*************************************************************************************************
*Coding Chunk 2: Job "intensity"; ie yearly hours
*------------------------------------------------------------------------------------------------
gen HrsYr=hHrsYr if HH==1
replace HrsYr=wHrsYr if HW==1
replace HrsYr=. if HrsYr>5840
	
*************************************************************************************************
*Coding Chunk 3: Race
*   -Let Full-time be >30hrs, 50weeks = 1500 annual
*------------------------------------------------------------------------------------------------
*
	gen Racet = hrace if HH==1
	replace Racet = wrace if HW==1
	
	by  x11101ll, sort: egen Race =  mode(Racet), minmode
	
	drop Racet hrace wrace
*************************************************************************************************
*Coding Chunk 4: Labor Income and Wage
*------------------------------------------------------------------------------------------------
*
	gen HrlyW =  hHrWage if HH==1
	replace HrlyW = wHrWage if HW==1
	
	gen LabInc =  hLabInc if HH==1
	replace LabInc = wLabInc if HW==1	
	
	gen CPI=.
	replace CPI=1.445 if wave==1993
	replace CPI=1.482 if wave==1994
	replace CPI=1.524 if wave==1995
	replace CPI=1.569 if wave==1996
	replace CPI=1.605 if wave==1997
	replace CPI=1.630 if wave==1998
	replace CPI=1.666 if wave==1999
	replace CPI=1.722 if wave==2000
	replace CPI=1.771 if wave==2001
	replace CPI=1.799 if wave==2002
	replace CPI=1.840 if wave==2003
	replace CPI=1.889 if wave==2004
	replace CPI=1.953 if wave==2005
	replace CPI=2.016 if wave==2006
	replace CPI=2.153 if wave==2008
	replace CPI=1.403 if wave==1992
	replace CPI=1.362 if wave==1991
	replace CPI=1.307 if wave==1990
	replace CPI=1.240 if wave==1989
	replace CPI=1.183 if wave==1988
	replace CPI=1.136 if wave==1987
	replace CPI=1.096 if wave==1986
	replace CPI=1.076 if wave==1985
	replace CPI=1.039 if wave==1984
	replace CPI=0.996 if wave==1983
	replace CPI=0.965 if wave==1982
	replace CPI=0.909 if wave==1981
	replace CPI=0.824 if wave==1980
	replace CPI=0.726 if wave==1979
	replace CPI=0.652 if wave==1978
	replace CPI=0.606 if wave==1977
	replace CPI=0.569 if wave==1976
	replace CPI=0.538 if wave==1975
	replace CPI=0.493 if wave==1974
	replace CPI=0.444 if wave==1973
	replace CPI=0.418 if wave==1972
	replace CPI=0.405 if wave==1971
	replace CPI=0.388 if wave==1970
	replace CPI=0.367 if wave==1969
	replace CPI=0.348 if wave==1968
	replace CPI=0.334 if wave==1967
	replace CPI=CPI/1.666
	replace CPI=1.245 if wave==2007
	replace CPI=1.287 if wave==2009
	replace CPI=1.309 if wave==2010
	replace CPI=1.350 if wave==2011
	replace CPI=1.377 if wave==2012
	replace CPI=1.399 if wave==2013
	
	gen CPI2=1.630 if wave==1999
	replace CPI2=1.722 if wave==2001
	replace CPI2=1.799 if wave==2003
	replace CPI2=1.889 if wave==2005
	replace CPI2=2.016 if wave==2007
	replace CPI2=2.153 if wave==2009
	replace CPI2=CPI2/1.666
	replace CPI2=1.309 if wave==2011
	replace CPI2=1.399 if wave==2013
	
	*Wages are retrospective one year
	replace HrlyW=. if HrlyW>9990
	xtset x11101ll wave
	qby x11101ll:gen wage= F.HrlyW
	replace wage=. if wage>9990
	
	gen rwage= wage/CPI
	gen r2wage= HrlyW/CPI	
	*The biannual period:
		replace rwage = HrlyW/CPI2 if wave>1998
	

*************************************************************************************************
*Coding Chunk 5: Maritial Status
*------------------------------------------------------------------------------------------------
*
gen married = 1 if (hMarried==1 & HH==1)
replace married = 0 if (hMarried~=1 & HH==1)

*in use
keep x11101ll wave x11102 xsqnr HS Col lsHS EdBin EdBin2 Race wage rwage r2wage HrlyW LabInc married wpts HrsYr


save $InputDTAs_dir\work, replace

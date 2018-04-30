*occhistory2000.do
*-------------------v.4-29-2017; @A. Michaud for DIoption w/ DW---------------------------------*
cd $PSID_dir
***************************************************************************************************************
* This code reads in and cleans occupation variables from PSID
* 	-We need a separate code for after 2001 because the occupation codes change
* 	-Occupation with highest earnings will be coded as the year's occupation
*-------------------------------------------------------------------------------------------------
* Requirements:
*	-You have to have files set up for psiduse in folder "Mdta", a subdirectory of PSID_dir set in main file
*	-"occ2000_occ1990dd.dta"; David Dorn's crosswalk from 2000 to 1990 codes.
***************************************************************************************************************

*This file computes the same stuff as occhistory except for later variables using different occupational coding
ssc install psidtools

psid use || HoccCurJ1 [03]ER21145 [05]ER25127 [07]ER36132 [09]ER42167 [11]ER47479 [13]ER53179 ///
		 || HoccCurJ2 [03]ER21201 [05]ER25190 [07]ER36195 [09]ER42228 [11]ER47541 [13]ER53241 ///
		 || HoccCurJ3 [03]ER21233 [05]ER25222 [07]ER36227 [09]ER42258 [11]ER47571 [13]ER53271 ///
		 || WoccCurJ1 [03]ER21395 [05]ER25385 [07]ER36390 [09]ER42419 [11]ER47736 [13]ER53442 ///
		 || WoccCurJ2 [03]ER21451 [05]ER25448 [07]ER36453 [09]ER42480 [11]ER47798 [13]ER53504 ///
		 || WoccCurJ3 [03]ER21483 [05]ER25480 [07]ER36485 [09]ER42510 [11]ER47828 [13]ER53534 ///
		 || HearnJ1	  [03]ER21182 [05]ER25171 [07]ER36176 [09]ER42209 [11]ER47522 [13]ER53222 ///		
		 || HearnJ2   [03]ER21214 [05]ER25203 [07]ER36208 [09]ER42239 [11]ER47552 [13]ER53252 ///
		 || HearnJ3   [03]ER21246 [05]ER25235 [07]ER36240 [09]ER42269 [11]ER47582 [13]ER53282 ///
		 || WearnJ1	  [03]ER21432 [05]ER25429 [07]ER36434 [09]ER42461 [11]ER47779 [13]ER53485 ///		
		 || WearnJ2   [03]ER21464 [05]ER25461 [07]ER36466 [09]ER42491 [11]ER47809 [13]ER53515 ///
		 || WearnJ3   [03]ER21496 [05]ER25493 [07]ER36498 [09]ER42521 [11]ER47839 [13]ER53545 ///	
		 using Mdta , clear 

		
***************************************************************************************************************************		
*Notes:
*	-After 2001 start asking about several jobs, need to figure out which to use. Choose highest earnings	
*	-Occupations after 1999 coded in 2000 codes

* Go long
	psid long
	xtset x11101ll wave
	
* Assign occs to appropriate person	
	gen HH =(xsqnr==1)
	gen HW=(xsqnr==2)
	
* Find Main Job	
	*Classify main occupation as the one with the highest earnings
    gen Mocc= HearnJ1	
	replace Mocc =. if (Mocc>35000000 | Mocc<1000)
	gen Hocc = HoccCurJ1
	
    gen Mocc2= HearnJ2
	replace Mocc2 =. if (Mocc2>35000000 | Mocc2<1000)
	replace Hocc = HoccCurJ2 if (Mocc2>Mocc & Mocc2~=.)
	replace Mocc = Mocc2 if (Mocc2>Mocc & Mocc2~=.)
	
	replace Mocc2 = HearnJ3 
	replace Mocc2 =. if (Mocc2>35000000 | Mocc2<1000)
	replace Hocc = HoccCurJ3 if (Mocc2>Mocc & Mocc2~=.)
	
	drop Mocc* 
	
	*Same for Wifey
    gen Mocc= WearnJ1	
	replace Mocc =. if (Mocc>35000000 | Mocc<1000)
	gen Wocc = WoccCurJ1
	
    gen Mocc2= WearnJ2
	replace Mocc2 =. if (Mocc2>35000000 | Mocc2<1000)
	replace Wocc = WoccCurJ2 if (Mocc2>Mocc & Mocc2~=.)
	replace Mocc = Mocc2 if (Mocc2>Mocc & Mocc2~=.)
	
	replace Mocc2 = WearnJ3 
	replace Mocc2 =. if (Mocc2>35000000 | Mocc2<1000)
	replace Wocc = WoccCurJ3 if (Mocc2>Mocc & Mocc2~=.)
	
	drop Mocc* 

	gen occ = Hocc if HH==1	
	replace occ = Wocc if HW==1
	replace occ=. if occ==0
	
	drop Hocc* Wocc* Hearn* Wearn*

	
* Merge with David Dorn's nice stuff to go 2000>1990, later to HRS
	*Current Occ
    merge m:1 occ using $InputDTAs_dir/occ2000_occ1990dd.dta
	drop occ 
	rename occ1990dd occ
	drop if _merge==2
	drop _merge 
	
save $InputDTAs_dir/occHist2000, replace





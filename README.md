# MW_DisabilityDataInputs
******************************************************
Crunching on data to calibrate and validate our model
******************************************************

This repository contains only the files for the calculations used in the main text and calibration. Additional robustness code available by request. (AM: you've archived them on IUbox and hard storage)

## Where to start?
The main file is: /PSID/MainCalib_StartHere.do
  - You set directories in the main file and it calls all other files sequentially.
  - Each other .do file has extensive details on what is going on.
  - So: read the .do files!
  
## You need to do a bit of work on getting files we don't own the right to redistribute!
  I know it makes replication a pain, but we try to give credit where credit is due and not steal things. (Please reciprocate, thx)
### Current Population Survey (CPS)
  -Download some data from our friends at UMN through cps.ipums.org
  -Full list of variables and samples listed in /CPS/CPSdata_needed.txt
### Panel Study of Income Dynamics (PSID)
  -We are using PSIDuse (https://ideas.repec.org/c/boc/bocode/s457951.html)
  -Its great! You can do the same. You just have to set it up following the installation instructions.
   -If you prefer to download the data directly, that's cool, but you need to open all of the .do files under \PSID and check the variables we use. They are specified exactly.
### Occupation Crosswalks
  -We downloaded our occupation crosswalks from David Autor and David Dorn. "The Growth of Low Skill Service Jobs and the Polarization of the U.S. Labor Market." American Economic Review, 103(5), 1553-1597, 2013. 
  -They were available on David Dorn's website. 

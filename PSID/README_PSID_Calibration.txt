Main do file is MainCalib_StartHere.do: lots of comments, please start there.

To put everything together, YOU WILL NEED TO INSTALL PSID USE and unzip the Mdta folder.

IF YOU DON'T WANT TO INSTALL PSIDUSE:
 you can start from MainCalib_StartHere.do using calibdata1.dta which contains all of the pulled and cleaned variables from PSID

NOTE: for either of the two options you will need to also unzip InputDTAs to current folder.

Note: a couple of the inputdta's are computed from CPS data in the CPS folder in the immediate above directory.

/PostEstimationDos : contains Do files unrelated to the calibration.

11/14 Note: I added separate estimations for women where necessary. They all start with the prefix "Lady_"
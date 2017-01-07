**Data workshop 10/15/2016
 


**************************************************
***A. How to integrate data of different levels***
**************************************************

***1. Individual data***

clear
cd"C:\Users\Liang Sun\Documents\My work\DataWorkshop_IntegrateData_20161015"
use IND2013ER
*individual file
*75,252 observations in all, 1968-2013
 

*1968 interview number and person number combined identify a person

*take 2009,2011,and 2013 data for example

*1.1 Cross-year variables: constant
*take a few variables for example
rename ER30001 ID1968  //family interview number 1968
rename ER30002 PERNUM68  //person number 1968
rename ER32000 GENDER   

*1.2 Single-year variables: time-variant 

*yearly family interview ID (unique within each year)
rename ER34201 ID2013
rename ER34101 ID2011
rename ER34001 ID2009

*yearly sequence number of person (unique within each year)
rename ER34202 SEQ2013
rename ER34102 SEQ2011
rename ER34002 SEQ2009

*relation to head  (unique within each year)
rename ER34203 REL2013
rename ER34103 REL2011
rename ER34003 REL2009

keep ID1968 PERNUM68 GENDER ID* SEQ* REL*


*select those who were heads or wives or "wives"(cohabitors) in any of the three years
*because family files only include head/wife's information
*SEQ 01-head 02-wife
*REL 10-head 20-wife 22-"wife" 
keep if ( SEQ2013 == 01 & REL2013 == 10)|( SEQ2013 == 02 & ( REL2013 == 20 | REL2013 == 22))| ///
( SEQ2011 == 01 & REL2011 == 10) |( SEQ2011 == 02 & ( REL2011 == 20 | REL2011 == 22)) | ///
( SEQ2009 == 01 & REL2009 == 10) |( SEQ2009 == 02 & ( REL2009 == 20 | REL2009 == 22)) 

sort ID1968 PERNUM68
duplicates report ID1968 PERNUM68
*should be unique

save data_ind,replace


***2. Family files***

*family files are separate by year

clear
use FAM2013
rename ER53002 ID2013 
rename ER58223 HDEDU2013
rename ER58224 WFEDU2013
sort ID2013
keep ID2013 HDEDU2013 WFEDU2013
save FAM2013_short,replace

clear 
use FAM2011
rename ER47302 ID2011
rename ER52405 HDEDU2011
rename ER52406 WFEDU2011
sort ID2011
keep ID2011 HDEDU2011 WFEDU2011
save FAM2011_short,replace

clear 
use FAM2009
rename ER42002 ID2009
rename ER46981 HDEDU2009
rename ER46982 WFEDU2009
sort ID2009
keep ID2009 HDEDU2009 WFEDU2009
save FAM2009_short,replace


***3. merge FAM with IND file***

*merge FAM2013 with ID2013 by family ID2013
clear
use FAM2013_short
merge 1:m ID2013 using data_ind,keep(using matched)
* keep observations in using and matched 

tab _merge
drop _merge
save FAM_IND,replace

*merge with more family files
clear 
use FAM2011_short
merge 1:m ID2011 using FAM_IND,keep(using matched)
drop _merge
save FAM_IND,replace

clear 
use FAM2009_short
merge 1:m ID2009 using FAM_IND,keep(using matched)
drop _merge
save FAM_IND,replace



*check the data 
*should be individual level now

*family ID1968 and person number combined can identify a person
duplicates report ID1968 PERNUM68 

*we can even generate a new personal ID for individuals
egen NEWID= group(ID1968 PERNUM68),label
sort NEWID
*or 
gen PERID=1000*ID1968+PERNUM68
duplicates report PERID
*as long as it is unique

save FAM_IND,replace



*****************************************************
***B. How to integrate data from different sources***
*****************************************************

***1.PSID+NCDB***

*for practice, I truncated PSID data into a small file with much fewer obs
*which also already includes geographic indicator "cbsa"
* file name: "PSID_cbsa.dta"

*notice that PSID data and NCDB data have different structures
*PSID now is individual-level in wide format
*NCDB is neighborhood-level and in long format 

*it will be easier to reshape NCDB data because PSID is our master data 
*and we want to perform our analysis on individual level
clear
use NCDB

reshape wide pct_edscoll i_pct_age30_64, i(cbsa)j(year)

save NCDB_wide,replace
*You can check now if cbsa is unique in this file

clear 
use PSID_cbsa
*cbsa is not unique in master data

merge m:1 cbsa using NCDB_wide


drop if _merge==2
*you can drop those non-matched from using, because they exist only in NCDB data

drop _merge 

save PSID_NCDB,replace
*Then you can conduct analysis using this individual-level data



***2.PSID+IPEDS***

* Practice: merge PSID data with IPEDS data
*PSID data file name: "PSID_unitid.dta", which has IPEDS institution ID included
*IPEDS data files: "IPEDS2009.dta, IPEDS2011.dta, IPEDS2013.dta"
*Hint: you will need to append IPEDS data files first before reshaping and merging

 
 
 
 
 *You can try by yourself before scrolling down
 
 
 
 
 
 *Codes are provided below
 
 
 
 
 
 
 
 
 

 
 

*IPEDS-public data are by year
*append data of 2009,2011,2013
clear
use ipeds2009
append using ipeds2011
append using ipeds2013

reshape wide instnm control satvr25 satvr75 satmt25 satmt75,i(unitid)j(year)

save ipeds_0913,replace


*then merge PSID with IPEDS_public data
clear 
use PSID_unitid

duplicates report unitid

drop _merge

merge m:1 unitid using ipeds_0913

keep if _merge==3

drop _merge

save PSID_IPEDS_0913,replace


*do some descriptive analysis
clear
use PSID_IPEDS_0913


*use 2013 information for example
gen educ=.
replace educ=HDEDU2013 if REL2013==10
replace educ=WFEDU2013 if REL2013==20|REL2013==22
replace educ=. if educ==99

*partner's education
gen peduc=.
replace peduc=WFEDU2013 if REL2013==10
replace peduc=HDEDU2013 if REL2013==20|REL2013==22
replace peduc=. if peduc==99

corr educ peduc

*you can also convert educ from quantitative into categorical 
gen educ_cat=0
replace educ_cat=1 if educ<=12
replace educ_cat=2 if educ>12&educ<16
replace educ_cat=3 if educ>=16

gen peduc_cat=0
replace peduc_cat=1 if peduc<=12
replace peduc_cat=2 if peduc>12&peduc<16
replace peduc_cat=3 if peduc>=16

tab educ_cat peduc_cat


*run a simple regression

gen female=(GENDER==2)

gen avgsat=(satvr252013+satvr752013+satmt252013+satmt752013)/4

reg peduc female educ avgsat 
*too few observations, don't show anything significant
*but this gives an idea of how we can do further analysis with the data


***3.use crosswalk file***

*PSID file: "PSID_fips.dta"
*crosswalk file: "fips_cbsa.dta"
*NCDB file (which NCDB file will you use?)



*you can write your own codes here








*my codes are provided below






*first,we can take a look at this crosswalk file
clear
use fips_cbsa
duplicates report fipstate fipscnty
*unique


*then merge PSID_fips data with crosswalk file
clear
use PSID_fips

duplicates report fipstate fipscnty

merge m:1 fipstate fipscnty using fips_cbsa

drop _merge

*then we can merge PSID_fips_cbsa with NCDB by cbsa

merge m:1 cbsa using NCDB_wide     

save PSID_fips_cbsa_NCDB,replace
 
use "120_country_sample.dta", clear

//Panel setting and basic stats
sort iso3
merge iso3 using "idcountry.dta"
tab _merge
keep if _merge==3
drop _merge

label var idcountry "country id"

order iso3 idcountry 
sort cname idtime

xtset idcountry idtime
su

////////////////////////////////////////////////////////////////////////////////
//Validation of distancing using stingency index and mobility

//Table 2 with dist

quietly xtreg dist a_driving, robust
outreg2 using "table_2_dist", excel tex replace ctitle(Driving) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist a_walking, robust
outreg2 using "table_2_dist", excel tex append ctitle(Walking) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_retailrecreation, robust
outreg2 using "table_2_dist", excel tex append ctitle(Retail) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_grocerypharmacy, robust
outreg2 using "table_2_dist", excel tex append ctitle(Grocery/Pharmacy) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_parks, robust
outreg2 using "table_2_dist", excel tex append ctitle(Parks) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_transitstations, robust
outreg2 using "table_2_dist", excel tex append ctitle(Transit Stations) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_workplace, robust
outreg2 using "table_2_dist", excel tex append ctitle(Workplace) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_residential, robust
outreg2 using "table_2_dist", excel tex append ctitle(Residential) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

//Table 2 with dist (high income sample)
quietly xtreg dist a_driving if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex replace ctitle(Driving) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist a_walking if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Walking) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_retailrecreation if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Retail) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_grocerypharmacy if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Grocery/Pharmacy) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_parks if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Parks) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_transitstations if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Transit Stations) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_workplace if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Workplace) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist g_residential if gdpc>25000, robust
outreg2 using "table_2_dist_h", excel tex append ctitle(Residential) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

////////////////////////////////////////////////////////////////////////////////
//Cross Country Variation in MIDIS

//Merging time passed since the first case
sort cname idtime
merge cname idtime using "time_passed.dta"
tab _merge
drop _merge

rename time_passed tp
gen tp1=tp+idtime-1

label var tp "days passed between 1st and 500th cases"
label var tp1 "days passed since the first case"

//Generate variables (logs and interactions) and some scaling

g lgdpc=log(gdpc)

replace dec=dec/1000

xtset idcountry idtime
su  

////////////////////////////////////////////////////////////////////////////////
// Table 3 with SI
 
quietly xtreg dist L.strindex tp1, robust
outreg2 using "table_3_str_tp1", excel tex replace ctitle(Governmental) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.strindex L.dec tp1, robust
outreg2 using "table_3_str_tp1", excel tex append ctitle(Governmental & Behavioral) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.strindex L.dec tp1 lgdpc, robust
outreg2 using "table_3_str_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.strindex L.dec tp1 hc, robust
outreg2 using "table_3_str_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.strindex L.dec tp1 spi, robust
outreg2 using "table_3_str_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.strindex L.dec tp1 ethnofrac, robust
outreg2 using "table_3_str_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.strindex L.dec tp1 EAP ECA LAC MENA SA SSA, robust
outreg2 using "table_3_str_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly reghdfe dist L.strindex L.dec tp1, absorb(idcountry) vce(robust)
outreg2 using "table_3_str_tp1", excel tex append ctitle(Fixed Effects) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

// Table 4 with OGRI

quietly xtreg dist L.govresindex tp1, robust
outreg2 using "table_4_gov_tp1", excel tex replace ctitle(Governmental) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.govresindex L.dec tp1, robust
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Governmental & Behavioral) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.govresindex L.dec tp1 hc, robust
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.govresindex L.dec tp1 spi, robust
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.govresindex L.dec tp1 lgdpc, robust
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.govresindex L.dec tp1 ethnofrac, robust
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.govresindex L.dec tp1 EAP ECA LAC MENA SA SSA, robust
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly reghdfe dist L.govresindex L.dec tp1, absorb(idcountry) vce(robust)
outreg2 using "table_4_gov_tp1", excel tex append ctitle(Fixed Effects) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

// Table 4 with CHI

quietly xtreg dist L.conthealindex tp1, robust
outreg2 using "table_4_cont_tp1", excel tex replace ctitle(Governmental) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.conthealindex L.dec tp1, robust
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Governmental & Behavioral) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.conthealindex L.dec tp1 hc, robust
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.conthealindex L.dec tp1 spi, robust
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.conthealindex L.dec tp1 lgdpc, robust
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.conthealindex L.dec tp1 ethnofrac, robust
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.conthealindex L.dec tp1 EAP ECA LAC MENA SA SSA, robust
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly reghdfe dist L.conthealindex L.dec tp1, absorb(idcountry) vce(robust)
outreg2 using "table_4_cont_tp1", excel tex append ctitle(Fixed Effects) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

// Table 4 with ESI

quietly xtreg dist L.econsuppindex tp1, robust
outreg2 using "table_4_econ_tp1", excel tex replace ctitle(Governmental) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.econsuppindex L.dec tp1, robust
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Governmental & Behavioral) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.econsuppindex L.dec tp1 hc, robust
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.econsuppindex L.dec tp1 spi, robust
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.econsuppindex L.dec tp1 lgdpc, robust
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly xtreg dist L.econsuppindex L.dec tp1 ethnofrac, robust
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) 

quietly xtreg dist L.econsuppindex L.dec tp1 EAP ECA LAC MENA SA SSA, robust
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Comparative Development) label addstat(Overall R2, e(r2_o), #countries, e(N_g), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  

quietly reghdfe dist L.econsuppindex L.dec tp1, absorb(idcountry) vce(robust)
outreg2 using "table_4_econ_tp1", excel tex append ctitle(Fixed Effects) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3)  


////////////////////////////////////////////////////////////////////////////////
//Output Loss Analysis
use "30_country_sample.dta", clear

//Panel setting and basic stats
sort iso3
merge iso3 using "idcountry.dta"
tab _merge
keep if _merge==3
drop _merge

label var idcountry "country id"

order iso3 idcountry 
sort cname idtime

xtset idcountry idtime
su

//Table 5

gen temp=1

quietly reghdfe output_loss dist, absorb(temp) vce(robust)
outreg2 using "table_5", excel tex replace ctitle(Weekends Excluded) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) addtext(Country FE, No, Time FE, No)

quietly reghdfe output_loss dist, absorb(idcountry) vce(robust)
outreg2 using "table_5", excel tex append ctitle(Weekends Excluded) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) addtext(Country FE, Yes, Time FE, No)

quietly reghdfe output_loss dist, absorb(idcountry idtime) vce(robust)
outreg2 using "table_5", excel tex append ctitle(Weekends Excluded) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) addtext(Country FE, Yes, Time FE, Yes)

quietly reghdfe output_loss dist if holiday==0, absorb(temp) vce(robust)
outreg2 using "table_5", excel tex append ctitle(Weekends and Holidays Excluded) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) addtext(Country FE, No, Time FE, No)

quietly reghdfe output_loss dist if holiday==0, absorb(idcountry) vce(robust)
outreg2 using "table_5", excel tex append ctitle(Weekends and Holidays Excluded) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) addtext(Country FE, Yes, Time FE, No)

quietly reghdfe output_loss dist if holiday==0, absorb(idcountry idtime) vce(robust)
outreg2 using "table_5", excel tex append ctitle(Weekends and Holidays Excluded) label addstat(R2, e(r2), #obs, e(N))  noni noobs nocons bdec(3) sdec(3) addtext(Country FE, Yes, Time FE, Yes)

// END OF FILE /////////////////////////////////////////////////////////////////

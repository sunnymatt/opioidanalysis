*************************************************************************
*
* PUBLPOL 104 Final Project
* Matthew Sun, Lanting Lu, Kent Mendoza
* 
*************************************************************************

* Preliminaries
clear all
set mem 100m
set more off

// matthew's directory
cd "C:\Users\matth\OneDrive - Leland Stanford Junior University\Senior Year\Winter Quarter\PUBLPOL 104\opioidanalysis\"
use "opioid_death_statevar.dta"


*** DATA CLEANING **************************************************************
drop year_code // duplicate of year
drop gender // duplicate o fgender_code
label define gender 0 "F"
encode gender_code, gen(gender)
drop gender_code

drop race_code 
rename race race_code
label define race 0 "American Indian or Alaska Native"
encode race_code, gen(race)
drop race_code

drop state_code
rename state state_code 
label define state 0 "Alabama"
encode state_code, gen(state)
drop state_code

drop hispanic_origin_code
rename hispanic_origin hispanic_origin_code 
label define hispanic_origin 0 "Not Hispanic or Latino"
encode hispanic_origin_code, gen(hispanic_origin)
drop hispanic_origin_code

destring population, replace force // convert from string to long
// 45 missing values for people who had a missing value for hispanic origin, 
// so we just drop those
drop if hispanic_origin == 2

// might need these two later!
drop crude_rate
drop age_adjusted_rate 

// helpful commands:
// label list [encoded variable]

*** EDA ************************************************************************

// graph total opioid deaths
preserve 
collapse (sum) deaths population, by(year)
twoway (connected deaths year), ///
	xtitle("Year") ///
	ytitle("Total Opioid-Related Deaths") ///
	title("Opioid-Related Deaths in the USA, 1999-2018") ///
	name(total_deaths, replace)

gen death_rate = 1000 * deaths / population
twoway (connected death_rate year), ///
	xtitle("Year") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	title("Opioid-Related Death Rate in the USA, 1999-2018") ///
	name(death_rate, replace)
restore

// graph opioid death rate by gender
preserve 
collapse (sum) deaths population, by(year gender)
gen death_rate = 1000 * deaths / population
twoway (connected death_rate year if gender==0) (connected death_rate year if gender==1), ///
	xtitle("Year") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	yscale(titlegap(5)) ///
	title("Opioid-Related Death Rates by Gender in the USA, 1999-2018", size(medium)) ///
	legend(label(1 "Female") label(2 "Male")) ///
	name(death_rate_gender, replace)
restore

// graph opioid death rate by race
preserve 
collapse (sum) deaths population, by(year race)
gen death_rate = 1000 * deaths / population
twoway (connected death_rate year if race==0) ///
	(connected death_rate year if race==1) ///
	(connected death_rate year if race==2) ///
	(connected death_rate year if race==3), ///
	xtitle("Year") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	yscale(titlegap(5)) ///
	legend(label(1 "Native American") label(2 "API") label(3 "Black") label(4 "White")) ///
	title("Opioid-Related Death Rate by Race in the USA, 1999-2018", size(medium)) ///
	name(death_rate_race, replace)
// interestingly, death rates are highest for native americans and have 
// risen faster than for any other racial group!
// https://www.pewtrusts.org/en/research-and-analysis/blogs/stateline/2019/09/09/in-cherokee-country-opioid-crisis-seen-as-existential-threat
restore

// trends for states that expanded versus didn't expand
preserve
collapse (sum) deaths population (mean) expanded, by(year state)
gen death_rate = 1000 * deaths / population
collapse (mean) death_rate, by(year expanded)
twoway (connected death_rate year if expanded==0) ///
	(connected death_rate year if expanded==1), ///
	xtitle("Year") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	yscale(titlegap(5)) ///
	legend(label(1 "Non-expansion") label(2 "Expansion")) ///
	title("Opioid-Related Death Rate by Medicaid Expansion Status in the USA, 1999-2018", size(medium)) ///
	name(death_rate_expansion, replace)
restore
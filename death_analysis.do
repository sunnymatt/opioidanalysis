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
collapse (sum) deaths population (mean) expanded state_med_inc-state_blk_pct, by(year state)
gen death_rate = 1000 * deaths / population
collapse (mean) death_rate state_med_inc-state_blk_pct, by(year expanded)
twoway (connected death_rate year if expanded==0) ///
	(connected death_rate year if expanded==1), ///
	xtitle("Year") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	yscale(titlegap(5)) ///
	legend(label(1 "Non-expansion") label(2 "Expansion")) ///
	xline(2014, lc(538g)) ///
	title("Opioid-Related Death Rate by Medicaid Expansion Status in the USA, 1999-2018", size(medium)) ///
	name(death_rate_expansion, replace)

// median incomes seem different in expansion vs non-expansion states;
// surprisingly, hgiher in expansion states
twoway (connected state_med_inc year if expanded==0) ///
	(connected state_med_inc year if expanded==1), ///
	xtitle("Year") ///
	ytitle("Income ($)") ///
	yscale(titlegap(5)) ///
	legend(label(1 "Non-expansion") label(2 "Expansion")) ///
	title("Average Median Income in Expansion vs Non-Expansion States, 1999-2018", size(medium)) ///
	name(income_time, replace)
restore 

preserve
drop if year < 2010
collapse (mean) expanded state_wh_pct state_blk_pct, by(year state)
collapse (mean) state_wh_pct state_blk_pct, by(year expanded)
twoway (connected state_wh_pct year if expanded==0, lc(538b) mc(none) lw(medthick)) ///
	(connected state_blk_pct year if expanded==0, lp(dash) lc(538b) mc(none) lw(medthick)) ///
	(connected state_wh_pct year if expanded==1,  lc(538r) mc(none) lw(medthick)) ///
	(connected state_blk_pct year if expanded==1, lp(dash) lc(538r) mc(none) lw(medthick)), ///
	xtitle("Year") ///
	ytitle("% of population") ///
	yscale(titlegap(5) r(0 1)) ///
	legend(label(1 "Non-expansion, white") label(2 "Non-expansion, black") label(3 "Expansion, white") label(4 "Expansion, black")) ///
	title("Racial Composition of Expansion vs Non-Expansion States, 1999-2018", size(medium)) ///
	name(race_time, replace)
restore

// utilization 
preserve 
collapse (mean) state_mc_units expanded (sum) population, by(state year)

egen ymin = min(year), by(state)
egen ymax = max(year), by(state)
gsort -ymin -ymax state year

// line plot
twoway (line state_mc_units year, c(L) lc(538r)), ///
	xtitle("Years After Expansion") ///
	ytitle("Total Number of Opioid Units Reimbursed") ///
	yscale(titlegap(5)) ///
	title("Units of Opioids Reimbursed Over Time, 1999-2018", size(medium)) ///
	name(opioid_prescriptions, replace)

collapse (sum) state_mc_units, by(year expanded)

twoway (connected state_mc_units year if expanded==0, lc(538b) mc(none) lw(medthick)) ///
	(connected state_mc_units year if expanded==1, lc(538r) mc(none) lw(medthick)), ///
	xtitle("Year") ///
	ytitle("Total number of units of opioids reimbursed per capita") ///
	yscale(titlegap(5) r(0 1)) ///
	xline(2014, lc(538g)) ///
	legend(label(1 "Non-expansion") label(2 "Expansion")) ///
	title("Total Units of Opioids Reimbursed Per Capita in Expansion and Non-Expansion States, 1999-2018", size(small)) ///
	name(race_time, replace)

restore

// average units reimbursed per person by expansion status
preserve
collapse (sum) population (mean) expanded state_mc_units, by(year state)
gen util_rate = state_mc_units / population
collapse (mean) util_rate state_mc_units, by(year expanded)

twoway (connected util_rate year if expanded==0, lc(538b) mc(none) lw(medthick)) ///
	(connected util_rate year if expanded==1, lc(538r) mc(none) lw(medthick)), ///
	xtitle("Year") ///
	ytitle("Average number of units of opioids reimbursed per capita") ///
	yscale(titlegap(5) r(0 1)) ///
	xline(2014, lc(538g)) ///
	legend(label(1 "Non-expansion") label(2 "Expansion")) ///
	title("Average Units of Opioids Reimbursed Per Capita in Expansion and Non-Expansion States, 1999-2018", size(small)) ///
	name(race_time, replace)
restore

preserve
// per-state opioid death rate trends
collapse (sum) deaths population (mean) expanded state_med_inc-state_blk_pct state_exp_yr, by(year state)
gen death_rate = 1000 * deaths / population

// in order to generate pretty graphs
egen xmin = min(year), by(state)
egen xmax = max(year), by(state)
gsort -xmin -xmax state year


// line plot
twoway (line death_rate year if expanded==0, c(L)), ///
	xtitle("Year") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	yscale(titlegap(5)) ///
	xline(2014, lc(538g)) ///
	title("Opioid-Related Death Rate for Non-Expansion States, 1999-2018", size(medium)) ///
	name(nonexpansion_state_death_rate, replace)	
	

gen year_c = year - state_exp_yr
// in order to generate pretty graphs
egen ymin = min(year_c), by(state)
egen ymax = max(year_c), by(state)
gsort -ymin -ymax state year_c

// line plot
twoway (line death_rate year_c if expanded==1, c(L) lc(538r)), ///
	xtitle("Years After Expansion") ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	yscale(titlegap(5)) ///
	xscale(r(-18 4)) ///
	xlabel(-18[2]4) ///
	xline(0, lc(538g)) ///
	title("Opioid-Related Death Rate for Expansion States, Centered by Expansion Year", size(medium)) ///
	name(expansion_state_death_rate, replace)	
	
restore 

// what years did states expand?
preserve	
collapse (mean) expanded state_exp_yr, by(state)
tab state_exp_yr if expanded == 1
// 25 states expanded on January 1, 2014 
// 7 states expanded at later dates
// expansions happened until July of 2016
restore


// regressions!

// restricted sample with non-equivalent comparison group: expansion in 
// 2014
preserve
collapse (sum) deaths population (mean) expanded state_exp_yr state_med_inc-state_blk_pct, by(year state)
gen death_rate = 1000 * deaths / population

drop if expanded != 0 & state_exp_yr != 2014 // restrict sample to never-expanders and expanded in 2014

collapse (mean) death_rate state_exp_yr, by(year expanded)
twoway (scatter death_rate year if expanded == 0, mc(538b)) (scatter death_rate year if expanded == 1, mc(538r)), ///
	title("Opioid Death Rates in Non-Expansion vs 2014 Expansion States", size(medium)) ///
	legend(label(1 "Non-Expansion") label(2 "Expanded in 2014")) ///
	ytitle("Opioid-Related Deaths per 100,000") ///
	xtitle("Year") ///
	yscale(range(0 .23)) ///
	yscale(titlegap(5)) ///
	xline(2014, lp(dash) lc(538g)) ///
	ylabel(,format(%9.2f)) ///
	name(comparison_scatter, replace)
	

// generate centered year variable
replace year = year - 2014 // center year 
gen d = year >= 0 // dummy for before / after 2014
gen d_yr = year * d 
gen e_yr = year * expanded 
gen d_e = d * expanded 
gen d_e_yr = expanded * d_yr 

reg death_rate year d d_yr expanded e_yr d_e d_e_yr 
outreg2 using figures/reg/reg_2014_linear.rtf, replace

loc pret0 "function y = `=_b[_cons]' + `=_b[year]'*x, ran(-15 0) "	// comparison control group, pre-policy
loc post0 "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[d_yr]'*x + `=_b[d]', ran(0 4) "	// comparison control group, post policy
loc pret1 "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[expanded]' + `=_b[e_yr]'*x, ran(-15 0) "	 // expanded in 2014, pre-policy
loc post1 "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[d]' + `=_b[d_yr]'*x + `=_b[e_yr]'*x + `=_b[expanded]' + `=_b[d_e]' + `=_b[d_e_yr]'*x, ran(0 4) "	 // expanded in 2014, post-policy


twoway (scatter death_rate year if expanded==0, mc(538b)) (scatter death_rate year if expanded==1, mc(538r)) ///
		(`pret0' lc(538b) ) ///
		(`pret1' lc(538r) ) ///
		(`post0' lc(538b) ) ///
		(`post1' lc(538r) ), ///
		title("Opioid Death Rates in Non-Expansion vs 2014 Expansion States", margin(b=5)) ///
		ytitle("Opioid-Related Deaths per 100,000") ///
		ylab(, angle(hori) labsize(small)) ///
		xlab(, angle(hori) labsize(small)) ///
		xtitle("Years after 2014") ///
		xline(0, lp(dash) lc(538g)) ///
		leg(ring(0) pos(4) cols(1) order(3 "Non-Expansion" 4 "Expanded in 2014")) ///
		name(reg_comp_2014, replace)

restore



// parametric simple interrupted time series with non-equivalent comparison group
preserve
collapse (sum) deaths population (mean) expanded state_exp_yr state_med_inc-state_blk_pct, by(year state)
gen death_rate = 1000 * deaths / population

// generate centered year variable
gen t_c = year 
replace t_c = t_c - state_exp_yr if state_exp_yr != .

// generate treatment vs control group
gen expansion_state = 1
replace expansion_state = 0 if state_exp_yr == .

// generate year-by-year treatment variable
gen under = 0
replace under = 1 if t_c >= 0 & expansion_state == 1

gen t_d = t_c * expansion_state
gen t_e = t_c * under 
gen y_sq = year * year
gen t_sq_d = t_c * t_c * expansion_state
gen t_sq_e= t_c * t_c * under 

// fully parametric linear
reg death_rate year expansion_state t_d under t_e 
est sto m1

xtset state // fixed effect by state
xtreg death_rate year expansion_state t_d under t_e , fe
est sto m2

// quadratic model
xtset state 
xtreg death_rate year y_sq expansion_state t_d t_sq_d under t_e t_sq_e, fe
est sto m3


loc mprenon "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[y_sq]'*x*x, ran(1999 2018) " // untreated prediction
loc mpredis "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[y_sq]'*x*x + `=_b[t_d]' * (x - 2014) + `=_b[t_sq_d]' * (x - 2014) * (x - 2014), ran(1999 2014) "	// treated before dismissal
loc mpostdis "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[y_sq]'*x*x + `=_b[t_d]' * (x - 2014) + `=_b[t_sq_d]' * (x - 2014) * (x - 2014) + `=_b[under]' + `=_b[t_e]'* (x - 2014) + `=_b[t_sq_e]' * (x - 2014) * (x - 2014), ran(2014 2018) " // treated after dismissal

twoway (`mprenon' lc(538r) ) ///
		(`mpredis' lc(538b) ) ///
		(`mpostdis' lc(538b) ) ///
		, ///
		title("Predicted Trends for Non-Expansion and Expansion States", size(medium)) ///
		ytitle("Opioid-Related Deaths per 100,000") ///
		ylab(, angle(hori) labsize(small)) ///
		xlab(, angle(hori) labsize(small)) ///
		xtitle("Year") ///
		xline(2014, lp(dash) lc(538g)) ///
		leg(ring(0) pos(4) cols(1) order(1 "Control" 2 "Treatment (Expanded in 2014)")) ///
		name(quadratic_trend, replace)

// robustness check: keep analysis but drop states that expanded in 2014 
drop if state_exp_yr == 2014
reg death_rate year expansion_state t_d under t_e 

xtset state // fixed effect by state
xtreg death_rate year expansion_state t_d under t_e , fe
outreg2 using figures/reg/reg_post2014_linear.rtf, replace

loc mprenon "function y = `=_b[_cons]' + `=_b[year]'*x , ran(1999 2018) " // untreated prediction
loc mpredis "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[t_d]' * (x - 2015), ran(1999 2015) "	// treated before dismissal
loc mpostdis "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[t_d]' * (x - 2015) + `=_b[under]' + `=_b[t_e]'* (x - 2015), ran(2015 2018) " // treated after dismissal

twoway (`mprenon' lc(538r) ) ///
		(`mpredis' lc(538b) ) ///
		(`mpostdis' lc(538b) ) ///
		, ///
		title("Predicted Trends for Non-Expansion and Post-2014 Expansion States", size(medium)) ///
		ytitle("Opioid-Related Deaths per 100,000") ///
		ylab(, angle(hori) labsize(small)) ///
		xlab(, angle(hori) labsize(small)) ///
		xtitle("Year") ///
		xline(2015, lp(dash) lc(538g)) ///
		leg(ring(0) pos(4) cols(1) order(1 "Control" 2 "Treatment (Expanded in 2014)")) ///
		name(post_2014_trend, replace)

// esttab m? using figures/reg/reg_all_dd.rtf, replace ///
// 	cells(b(star fmt(%4.3f)) se(par fmt(%4.3f))) ///
// 	stats(r2, lab("R-sq" "p(F) comp. to m1")) ///
// 	varwidth(20)

// upshot: fully parametric linear + fixed effect by state regressions both still have
// statistically significant regression coefficients, quadratic no longer has 
// stat. significant coefs
restore


// robustness check: run regressions with different years before expansion
// favorite model: state fixed effects
// 1 yr - anticipatory effects?
// https://www.journals.uchicago.edu/doi/full/10.1162/ajhe_a_00088?mobileUi=0&
// CA increased payments to insurers in anticipation of Medicaid rollout: https://www.latimes.com/business/la-fi-medicaid-insurance-profits-20171101-story.html
preserve

collapse (sum) deaths population (mean) expanded state_exp_yr state_med_inc-state_blk_pct, by(year state)
gen death_rate = 1000 * deaths / population
	
// generate centered year variable
gen t_c = year 

// generate treatment vs control group
gen expansion_state = 1
replace expansion_state = 0 if state_exp_yr == .

// generate year-by-year treatment variable
gen under = 0
replace under = 1 if t_c >= 0 & expansion_state == 1

gen t_d = t_c * expansion_state
gen t_e = t_c * under 
gen y_sq = year * year
gen t_sq_d = t_c * t_c * expansion_state
gen t_sq_e= t_c * t_c * under 
	
	
foreach x of numlist 0/3 {
	// replace all vars that are time-dependent
	replace t_c = year 
	replace t_c = t_c - state_exp_yr - `x' if state_exp_yr != .
	
	replace under = 0
	replace under = 1 if t_c >= 0 & expansion_state == 1
	
	replace t_d = t_c * expansion_state
	replace t_e = t_c * under 

	xtset state // fixed effect by state
	xtreg death_rate year expansion_state t_d under t_e , fe
	estimates store mnlag`x'

}
// esttab mnlag? using figures/reg/falsification_check.rtf, replace ///
// 	mtitles("Original" "-1 yr" "-2 yr" "-3 yr") ///
// 	cells(b(star fmt(%4.3f)) se(par fmt(%4.3f))) ///
// 	stats(r2, lab("R-sq" "p(F) comp. to m1")) ///
// 	varwidth(20)

// event study specification
// reset centered year to t_c = 0
gen state_exp_yr_rnd = round(state_exp_yr) // have to round year b/c event study
replace t_c = 0 
replace t_c = year - state_exp_yr_rnd if state_exp_yr_rnd != .
// now we add so there are no negative years, which we need to run the regression
gen t_c_pos = t_c + 18

// for relabeling when we generate the coeflist graph
local map = ""
foreach x of numlist 1/22 {
	local num = `x' - 18
	local map = "`map' `x'.t_c_pos=`num'"
}
di `map'

xtset state // fixed effect by state
// regress with year fixed effect, omitting year 18 (treatment year)
xtreg death_rate io18.t_c_pos i.year t_c, fe
coefplot, ///
	drop(_cons *.year t_c) ///
	vertical ///
	xlabel(, angle(vertical)) ///
	ytitle("Value of coefficient estimate (+95% CI)") ///
	xtitle("{&beta}{subscript:i} (in {&beta}{subscript:i} D{superscript:t*=i})") ///
	yline(0) ///
	rename(`map') ///
	title("Event Study Robustness Check")
	
restore

// cool other methods to check out: synthetic controls
// http://econweb.umd.edu/~galiani/files/synth_runner.pdf

preserve

collapse (sum) deaths population (mean) expanded state_exp_yr state_med_inc-state_blk_pct, by(year state)
gen death_rate = 1000 * deaths / population
	
// keep balanced panel of race data
// bysort state (death_rate) : drop if _N != 20 // must have all 20 years
drop if year < 2010
drop if state == 34 | state == 41 // drop ND, SD

// generate year-by-year treatment variable
gen t_c = year 
replace t_c = t_c - state_exp_yr - 1 if state_exp_yr != .
gen under = 0
replace under = 1 if t_c >= 0 & expanded == 1

tsset state year
// synth_runner death_rate state_med_inc(1999(1)2013) state_wh_pct(2010(1)2013) state_wh_pct(2010(1)2013), d(under)
synth_runner death_rate state_med_inc(2010(1)2013) state_wh_pct(2010(1)2013) state_wh_pct(2010(1)2013), d(under)
effect_graphs, tc_gname("Expansion") sc_name("Synthetic non-expansion") tc_ytitle("Opioid-Related Deaths per 100,000") tc_options(title("Opioid Death Rate Trends for Expansion and Synthetic Control States") yscale(titlegap(5))) effect_options(legend(ring(0) pos(4) cols(1) order(1 "Difference between expansion/synthetic non-expansion")) title("Difference in Opioid Death Rate for Expansion and Synthetic Control States"))
restore

// ITS regression for utilization data
// parametric simple interrupted time series with non-equivalent comparison group
preserve
collapse (mean) expanded state_exp_yr state_med_inc state_mc_units, by(year state)

// generate centered year variable
gen t_c = year 
replace t_c = t_c - state_exp_yr if state_exp_yr != .

// generate year-by-year treatment variable
gen under = 0
replace under = 1 if t_c >= 0 & expanded == 1

gen t_d = t_c * expanded
gen t_e = t_c * under 
gen y_sq = year * year
gen t_sq_d = t_c * t_c * expanded
gen t_sq_e= t_c * t_c * under 

// fully parametric linear
reg state_mc_units year expanded t_d under t_e

xtset state // fixed effect by state
xtreg state_mc_units year expanded t_d under t_e , fe
outreg2 using figures/reg/prescr_reg.rtf, replace

loc mprenon "function y = `=_b[_cons]' + `=_b[year]'*x , ran(1999 2018) " // untreated prediction
loc mpredis "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[t_d]' * (x - 2014), ran(1999 2014) "	// treated before dismissal
loc mpostdis "function y = `=_b[_cons]' + `=_b[year]'*x + `=_b[t_d]' * (x - 2014) + `=_b[under]' + `=_b[t_e]'* (x - 2014), ran(2014 2018) " // treated after dismissal

twoway (`mprenon' lc(538b) ) ///
		(`mpredis' lc(538r) ) ///
		(`mpostdis' lc(538r) ) ///
		, ///
		title("Predicted Trends in Opioid Prescriptions for Non-Expansion and Post-2014 Expansion States", size(small)) ///
		ytitle("Number of units of opioids reimbursed by Medicaid") ///
		ylab(, angle(hori) labsize(small)) ///
		xlab(, angle(hori) labsize(small)) ///
		yscale(titlegap(7)) ///
		xtitle("Year") ///
		xline(2014, lp(dash) lc(538g)) ///
		leg(ring(0) pos(4) cols(1) order(1 "Control" 2 "Treatment (Expanded in 2014)")) ///
		name(opioid_prescr_prediction, replace)
	
restore 


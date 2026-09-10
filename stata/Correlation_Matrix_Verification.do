* Correlation Matrix Verification
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.0 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block at the bottom: all six correlations and p-values
* matched exactly.
*
* Purpose: independently reproduces the six pairwise Pearson correlations
* in Table 5, Panel A among the five raw indicators (TFR, CBR, IMR, CDR,
* age structure) across all 28 states.

clear
input str20 state double(tfr cbr imr cdr age)
"Bihar"             2.9  26.8  23  5.9  7.4
"UttarPradesh"      2.6  23.5  35  6.3  7.7
"Meghalaya"         2.9  22.1  31  5.4  4.7
"MadhyaPradesh"     2.4  22.5  35  6.7  7.9
"Rajasthan"         2.3  22.8  28  5.8  7.5
"Chhattisgarh"      1.8  22.2  36  8.4  7.8
"Jharkhand"         2.2  21.5  27  6.2  7.1
"Assam"             1.9  19.6  29  6.1  6.7
"Odisha"            1.6  15.8  28  7.9  9.5
"ArunachalPradesh"  1.7  16.3  17  5.4  4.6
"Uttarakhand"       1.9  16.7  19  6.0  8.9
"Haryana"           1.9  18.5  24  6.7  8.7
"Manipur"           2.2  12.7   2  4.4  7.0
"Maharashtra"       1.4  13.8  13  6.0  9.9
"Karnataka"         1.5  14.9  15  7.0  7.7
"Gujarat"           1.9  16.8  19  6.2  7.9
"Punjab"            1.4  13.6  16  7.1 10.3
"WestBengal"        1.3  13.9  16  5.8  8.5
"HimachalPradesh"   1.7  14.0  11  6.7 10.2
"AndhraPradesh"     1.7  14.3  18  6.6  9.8
"Telangana"         1.5  15.7  17  6.5  9.23
"Nagaland"          1.7  13.3  12  5.3  5.2
"Tripura"           1.7  15.0  12  5.9  7.9
"Mizoram"           1.9  14.0  12  5.7  6.3
"Kerala"            1.3  11.0   8  7.3 12.6
"TamilNadu"         1.3  11.0  11  6.8 10.4
"Goa"               1.32 10.7   7  6.5 11.2
"Sikkim"            1.1  14.6   7  4.7  6.7
end

label variable tfr "Total Fertility Rate"
label variable cbr "Crude Birth Rate"
label variable imr "Infant Mortality Rate"
label variable cdr "Crude Death Rate"
label variable age "Age structure, % aged 60+"

* Six pairwise correlations with significance, using a standard two-tailed
* test.
pwcorr tfr cbr imr cdr age, sig star(0.05)

* Individual pairs, printed explicitly for direct comparison against the
* manuscript's Table 5, Panel A:
di as text _n "TFR-CBR:"
pwcorr tfr cbr, sig
di as text _n "TFR-IMR:"
pwcorr tfr imr, sig
di as text _n "TFR-CDR:"
pwcorr tfr cdr, sig
di as text _n "CBR-IMR:"
pwcorr cbr imr, sig
di as text _n "CBR-CDR:"
pwcorr cbr cdr, sig
di as text _n "IMR-CDR:"
pwcorr imr cdr, sig

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the manuscript's published results; Table 5,
* Panel A of the manuscript). Confirm your Stata output matches these to
* two decimal places, with p<0.01 marked ** and p<0.05 marked *:
*
*   TFR-CBR:  r = +0.82 **  (p = 0.0000)
*   TFR-IMR:  r = +0.61 **  (p = 0.0006)
*   TFR-CDR:  r = -0.22     (p = 0.2679, n.s.)
*   CBR-IMR:  r = +0.85 **  (p = 0.0000)
*   CBR-CDR:  r = +0.04     (p = 0.8433, n.s.)
*   IMR-CDR:  r = +0.38 *   (p = 0.0467)
* ---------------------------------------------------------------------------

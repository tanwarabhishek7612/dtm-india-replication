* Discriminating-Power Verification
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.0 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block at the bottom: all 5 percentages matched exactly
* (the RESOLVED version of the underlying method).
*
* Purpose: reproduces Section 4.2's discriminating-power figures using
* Method A (the manuscript's actual method): for each indicator, does its
* own single-indicator vote (Section 4.3 threshold bands) equal the
* state's published composite stage, across all 28 states?

clear
input str20 state double(tfr cbr imr cdr age) str2 published
"Bihar"             2.9  26.8  23  5.9  7.4  "S2"
"UttarPradesh"      2.6  23.5  35  6.3  7.7  "S3"
"Meghalaya"         2.9  22.1  31  5.4  4.7  "S3"
"MadhyaPradesh"     2.4  22.5  35  6.7  7.9  "S3"
"Rajasthan"         2.3  22.8  28  5.8  7.5  "S3"
"Chhattisgarh"      1.8  22.2  36  8.4  7.8  "S3"
"Jharkhand"         2.2  21.5  27  6.2  7.1  "S3"
"Assam"             1.9  19.6  29  6.1  6.7  "S3"
"Odisha"            1.6  15.8  28  7.9  9.5  "S3"
"Manipur"           2.2  12.7   2  4.4  7.0  "S3"
"Maharashtra"       1.4  13.8  13  6.0  9.9  "S4"
"ArunachalPradesh"  1.7  16.3  17  5.4  4.6  "S4"
"Uttarakhand"       1.9  16.7  19  6.0  8.9  "S4"
"Haryana"           1.9  18.5  24  6.7  8.7  "S4"
"Karnataka"         1.5  14.9  15  7.0  7.7  "S4"
"Gujarat"           1.9  16.8  19  6.2  7.9  "S4"
"Punjab"            1.4  13.6  16  7.1 10.3  "S4"
"WestBengal"        1.3  13.9  16  5.8  8.5  "S4"
"HimachalPradesh"   1.7  14.0  11  6.7 10.2  "S4"
"AndhraPradesh"     1.7  14.3  18  6.6  9.8  "S4"
"Telangana"         1.5  15.7  17  6.5  9.23 "S4"
"Nagaland"          1.7  13.3  12  5.3  5.2  "S4"
"Tripura"           1.7  15.0  12  5.9  7.9  "S4"
"Mizoram"           1.9  14.0  12  5.7  6.3  "S4"
"Kerala"            1.3  11.0   8  7.3 12.6  "S5"
"TamilNadu"         1.3  11.0  11  6.8 10.4  "S5"
"Goa"               1.32 10.7   7  6.5 11.2  "S5"
"Sikkim"            1.1  14.6   7  4.7  6.7  "S5"
end

* Single-indicator votes, each using its own Section 4.3 threshold bands.
gen tfr_vote = "S2" if tfr>=2.9
replace tfr_vote = "S3" if tfr>=2.1 & tfr<2.9
replace tfr_vote = "S4" if tfr>=1.7 & tfr<2.1
replace tfr_vote = "S5" if tfr<1.7

gen cbr_vote = "S2" if cbr>23
replace cbr_vote = "S3" if cbr>=17 & cbr<=23
replace cbr_vote = "S4" if cbr>=13 & cbr<17
replace cbr_vote = "S5" if cbr<13

gen imr_vote = "S2" if imr>=35
replace imr_vote = "S3" if imr>=25 & imr<35
replace imr_vote = "S4" if imr>=10 & imr<25
replace imr_vote = "S5" if imr<10

gen cdr_vote = "S2" if tfr>=2.1 & cdr>=8
replace cdr_vote = "S3" if (tfr>=2.1 & cdr<8) | (tfr<2.1 & cdr>=7 & cdr<=9)
replace cdr_vote = "S4" if tfr<2.1 & cdr<7
replace cdr_vote = "S5" if tfr<2.1 & cdr>9

gen age_vote = "S2" if age<7
replace age_vote = "S3" if age>=7 & age<10
replace age_vote = "S4" if age>=10 & age<14
replace age_vote = "S5" if age>=14

gen byte tfr_match = (tfr_vote==published)
gen byte cbr_match = (cbr_vote==published)
gen byte imr_match = (imr_vote==published)
gen byte cdr_match = (cdr_vote==published)
gen byte age_match = (age_vote==published)

di as text _n "Discriminating power (% of 28 states where indicator's own vote == published stage):"
foreach v in tfr cbr imr cdr age {
    qui sum `v'_match
    di as text "  `v': " %5.1f (r(mean)*100) "%"
}

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the manuscript's published results; Section 4.2):
*
*   CBR: 82.1%   (reproduces the composite stage most often)
*   IMR: 78.6%
*   CDR: 71.4%
*   TFR: 67.9%
*   Age: 32.1%   (lags well behind the other four)
* ---------------------------------------------------------------------------

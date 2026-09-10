* Meghalaya Influence Verification
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.0 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block at the bottom: Cook's D and both Model II
* coefficients matched exactly.
*
* Purpose: independently verifies two Section 5.7 claims:
*   1. Meghalaya is a case-influence outlier with Cook's distance D = 0.54
*      in the primary OLS model (n=27, Telangana excluded).
*   2. Re-estimating with Meghalaya also excluded (n=26) strengthens the
*      literacy effect (beta=1.15, P=0.001) and the income effect
*      (beta=17.87, P=0.007), with % Christian remaining non-significant.
*      (Note: the manuscript's income coefficient was corrected from an
*      earlier draft value of 18.03/0.006 to 17.87/0.007, matching what
*      this script computes.)

clear
input str20 state double(dtm literacy christian ln_nsdp)
"AndhraPradesh"    66.485125441481   59.1  1.38  12.379820049104
"ArunachalPradesh" 56.4696504688832  57.7 30.26  12.3023323743701
"Assam"            41.5277474830512  66.3  3.74  11.8478464990987
"Bihar"            12.3732352941176  51.5  0.12  11.005095350184
"Chhattisgarh"     36.1550793650794  60.2  1.92  11.911177957926
"Goa"              90.0383496732026  84.7 25.1   13.2809948605644
"Gujarat"          54.5569418564527  69.7  0.52  12.6039154441726
"Haryana"          49.4668322473917  65.9  0.2   12.6740836658487
"HimachalPradesh"  72.1287260991353  75.9  0.18  12.3664127030094
"Jharkhand"        33.6245511610441  55.4  4.3   11.5643217540536
"Karnataka"        68.8163963483944  68.1  1.87  12.7361507452869
"Kerala"           91.242118296594   92.1 18.38  12.541655200788
"MadhyaPradesh"    23.462091452523   59.2  0.29  11.8473455974653
"Maharashtra"      77.2352686944343  75.9  0.96  12.5378230374827
"Manipur"          65.0043616287095  70.3 41.29  11.7669861189192
"Meghalaya"        11.5189838326635  72.9 74.59  11.8273565707146
"Mizoram"          61.7423127004425  89.3 87.16  12.370836802617
"Nagaland"         65.7469805748386  76.1 87.93  11.9749599245663
"Odisha"           59.1105126760849  64.0  2.77  12.0141127891962
"Punjab"           76.1767867799294  70.7  1.26  12.1809137992698
"Rajasthan"        29.120778376568   52.1  0.14  12.0236330817737
"Sikkim"           81.8148826269638  76.4  9.91  13.2840450565058
"TamilNadu"        86.2307947671823  73.4  6.12  12.6610260867295
"Tripura"          66.5578268481306  82.7  4.35  12.0835829257936
"UttarPradesh"     17.1356611557667  57.2  0.18  11.4448821425189
"Uttarakhand"      56.1171126639062  70.0  0.37  12.4138101304945
"WestBengal"       75.3223854686802  70.5  0.72  11.9151520012279
end

* Step 1: full model (n=27, Telangana already excluded from this dataset),
* then Cook's distance for every observation.
regress dtm literacy christian ln_nsdp
predict cooksd, cooksd
gsort -cooksd
list state cooksd in 1/5, clean noobs

sum cooksd if state == "Meghalaya"
di as text "Meghalaya Cook's D (expect ~0.54): " r(mean)

* Step 2: re-estimate with Meghalaya also excluded (n=26)
regress dtm literacy christian ln_nsdp if state != "Meghalaya"

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the manuscript's published results):
*
*   Step 1: Meghalaya Cook's D = 0.5408 (manuscript: 0.54)   MATCH
*
*   Step 2 (n=26):
*     Female_Literacy_pct   beta = 1.1527   p = 0.0014  (manuscript: 1.15, 0.001)
*     Pct_Christian         beta = -0.0549  p = 0.6370  n.s.
*     ln_NSDP_per_capita    beta = 17.8656  p = 0.0066  (manuscript: 17.87, 0.007)
*     Adjusted R-squared = 0.7074
* ---------------------------------------------------------------------------

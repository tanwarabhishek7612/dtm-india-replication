* Primary Model I Verification
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* BUG FOUND, FIXED, AND RE-VERIFIED IN STATA 18.0 (SE). The first
* version of this file mistakenly named the ln(NSDP) column "nsdp" and
* then applied gen ln_nsdp = ln(nsdp) -- taking the log a second time of
* a variable that was already log-transformed in the source data (same
* values as Meghalaya_Influence_Verification.do's ln_nsdp column, which
* was named correctly and did NOT have this bug). That produced
* ln_nsdp beta = 237.47 instead of the expected 19.21. Fixed here by
* naming the input column ln_nsdp directly and removing the extra ln().
* The corrected version has been re-run in Stata 18.0 (SE) and confirmed:
* ln_nsdp beta = 19.214, matching the EXPECTED OUTPUT block below exactly.
*
* Purpose: independently verifies Section 5.7's PRIMARY model (Model I,
* n=27, Telangana excluded, Meghalaya INCLUDED): Composite DTM Score ~
* Female Literacy + % Christian + ln(NSDP per capita).

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

* Note: this is the FULL n=27 sample -- unlike
* Meghalaya_Influence_Verification.do, Meghalaya is NOT dropped here.
* ln_nsdp is already log-transformed in the source data (same values as
* Meghalaya_Influence_Verification.do's ln_nsdp column) -- do NOT take
* ln() of it again.
count
di as text "n = " r(N) " (expect 27, Meghalaya included, Telangana already absent from this dataset)"

label variable ln_nsdp "ln(NSDP per capita)"

regress dtm literacy christian ln_nsdp

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the manuscript's published Section 5.7, Model I
* results):
*
*   Female literacy:  beta = 1.22,  P = 0.003  **
*   % Christian:      beta = -0.20, P = 0.116  n.s.
*   ln(NSDP):         beta = 19.21, P = 0.010  *
*   Adjusted R-squared = 0.654
*
* Together with Meghalaya_Influence_Verification.do (Cook's D + Model II)
* and Migration_Model_Verification.do (Model III), this covers all three
* specifications in Table 4.
* ---------------------------------------------------------------------------

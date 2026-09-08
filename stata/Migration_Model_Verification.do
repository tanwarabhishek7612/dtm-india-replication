* 16-State Migration Model Verification (Stata translation)
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.0 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block at the bottom: all coefficients matched exactly.
*
* Purpose: independently reproduces the secondary OLS model in Table 4 /
* Section 5.7: Composite DTM Score ~ Female Literacy + % Christian +
* ln(NSDP per capita) + Net Migration, restricted to the 16 states with
* available Census-based net migration estimates (Mistri, 2015).
* Also checks that none of the 16 states is a Northeast Cluster state.

clear
input str20 state double(dtm literacy christian nsdp migration)
"Bihar"           12.3732352941176 51.5  0.12  60180  -3.39
"UttarPradesh"    17.1356611557667 57.2  0.18  93422  -1.94
"MadhyaPradesh"   23.462091452523  59.2  0.29 139713   0.48
"Rajasthan"       29.120778376568  52.1  0.14 166647  -1.34
"Assam"           41.5277474830512 66.3  3.74 139783  -2.21
"Odisha"          59.1105126760849 64.0  2.77 165068  -0.55
"Haryana"         49.4668322473917 65.9  0.20 319363   2.01
"Maharashtra"     77.2352686944343 75.9  0.96 278681   2.70
"Karnataka"       68.8163963483944 68.1  1.87 339813   1.68
"Gujarat"         54.5569418564527 69.7  0.52 297722   1.64
"Punjab"          76.1767867799294 70.7  1.26 195031   0.77
"WestBengal"      75.3223854686802 70.5  0.72 149515  -0.50
"HimachalPradesh" 72.1287260991353 75.9  0.18 234782  -0.40
"AndhraPradesh"   66.485125441481  59.1  1.38 237951  -2.02
"Kerala"          91.242118296594  92.1 18.38 279751  -5.41
"TamilNadu"       86.2307947671823 73.4  6.12 315220   4.92
end

* Sanity check: confirm none of these 16 states is a Northeast Cluster
* state (Arunachal Pradesh, Manipur, Meghalaya, Mizoram, Nagaland, Sikkim,
* Tripura). If this list ever prints a name, the manuscript's claim that
* migration data exclude the Northeast Cluster entirely would need revision.
gen byte ne_cluster = inlist(state, "ArunachalPradesh", "Manipur", ///
    "Meghalaya", "Mizoram", "Nagaland", "Sikkim", "Tripura")
count if ne_cluster
di as text "Northeast Cluster states found in migration sample: " r(N) " (should be 0)"

gen ln_nsdp = ln(nsdp)
label variable ln_nsdp "ln(NSDP per capita)"

regress dtm literacy christian ln_nsdp migration

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the independently-verified Python run; Table 4,
* secondary model, n=16):
*
*   Female literacy:  beta = 1.63,  P = 0.024  *
*   % Christian:      beta = -0.24, n.s. (P = 0.87)
*   ln(NSDP):         beta = 16.30, n.s. (P = 0.20)
*   Net migration:    beta = 0.53,  n.s. (P = 0.81)
*   Adjusted R-squared = 0.713
* ---------------------------------------------------------------------------

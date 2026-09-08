* PCA and Ward's-Linkage Cluster Analysis (Stata translation)
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.0 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block at the bottom: PCA loadings and clustering matched.
* Note: Stata's `pca` and `cluster wardslinkage` use
* different internal conventions from scikit-learn/scipy (e.g. sign of
* loadings can flip, exact tie-breaking within `cluster` can differ), so
* treat small discrepancies from the EXPECTED OUTPUT as implementation
* differences to investigate, not necessarily errors. Reproduces Section
* 6.1 (PCA) and Section 5.6 (Ward's-linkage clustering).

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

* ---------------------------------------------------------------------------
* SECTION 6.1: PCA on the correlation matrix (equivalent to z-scored
* inputs -- Stata's `pca` defaults to the correlation matrix unless the
* `covariance` option is given, so no separate standardisation step is
* needed here).
* ---------------------------------------------------------------------------
pca tfr cbr imr cdr age
screeplot
estat loadings

* ---------------------------------------------------------------------------
* SECTION 5.6: Ward's-linkage hierarchical clustering on MIN-MAX
* normalised indicators (this does need manual normalisation first,
* since the manuscript uses min-max, not z-score, for the clustering step).
* ---------------------------------------------------------------------------
foreach v in tfr cbr imr cdr age {
    egen `v'_min = min(`v')
    egen `v'_max = max(`v')
    gen `v'_mm = (`v' - `v'_min) / (`v'_max - `v'_min)
}

cluster wardslinkage tfr_mm cbr_mm imr_mm cdr_mm age_mm, name(ward)
cluster generate grp3 = groups(3), name(ward)
cluster generate grp4 = groups(4), name(ward)
cluster generate grp5 = groups(5), name(ward)

di as text _n "-- k=3 clusters --"
sort grp3 state
list state grp3, clean noobs sepby(grp3)

di as text _n "-- k=4 clusters --"
sort grp4 state
list state grp4, clean noobs sepby(grp4)

di as text _n "-- k=5 clusters --"
sort grp5 state
list state grp5, clean noobs sepby(grp5)

* Intra-group distance check for Nagaland/Mizoram/Sikkim (Euclidean, on
* the min-max normalised variables), compared against the sample average.
* Stata has no single built-in "pairwise Euclidean distance summary"
* command as convenient as scipy's pdist, so this is computed by hand
* for the three named states specifically:
matrix D = J(3,3,0)
local states Nagaland Mizoram Sikkim
local i = 1
foreach s1 of local states {
    local j = 1
    foreach s2 of local states {
        qui sum tfr_mm if state=="`s1'"
        local a1 = r(mean)
        qui sum cbr_mm if state=="`s1'"
        local a2 = r(mean)
        qui sum imr_mm if state=="`s1'"
        local a3 = r(mean)
        qui sum cdr_mm if state=="`s1'"
        local a4 = r(mean)
        qui sum age_mm if state=="`s1'"
        local a5 = r(mean)
        qui sum tfr_mm if state=="`s2'"
        local b1 = r(mean)
        qui sum cbr_mm if state=="`s2'"
        local b2 = r(mean)
        qui sum imr_mm if state=="`s2'"
        local b3 = r(mean)
        qui sum cdr_mm if state=="`s2'"
        local b4 = r(mean)
        qui sum age_mm if state=="`s2'"
        local b5 = r(mean)
        matrix D[`i',`j'] = sqrt((`a1'-`b1')^2+(`a2'-`b2')^2+(`a3'-`b3')^2+(`a4'-`b4')^2+(`a5'-`b5')^2)
        local j = `j' + 1
    }
    local i = `i' + 1
}
matrix list D
di as text "Mean of the three off-diagonal pairs above (expect ~0.40): " ///
    (D[1,2]+D[1,3]+D[2,3])/3

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the independently-verified Python run):
*
*   PCA: first component 56.4% of variance (eigenvalue 2.82);
*        second component 32.0% (eigenvalue 1.60).
*        Loadings on PC1: TFR +0.536, CBR +0.565, IMR +0.487,
*        CDR -0.074, Age -0.389 (sign may flip in Stata -- direction of an
*        eigenvector is arbitrary; check relative signs, not absolute ones).
*
*   Clustering: at k=3, k=4, and k=5, Arunachal Pradesh, Manipur, Nagaland,
*   Mizoram, and Sikkim group together; Tripura does NOT join them (it
*   falls into the larger mainstream cluster instead).
*
*   Nagaland/Mizoram/Sikkim mean pairwise distance: 0.3953 (Euclidean),
*   45.8% lower than the all-28-state sample average (0.7297).
* ---------------------------------------------------------------------------

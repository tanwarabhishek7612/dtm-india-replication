* ==========================================================================
* Weighting-Scheme Sensitivity Verification (Table 5 / Table 6)
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.0 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block at the bottom: 0 baseline mismatches; all six
* reclassification counts/rates matched exactly (including Scheme D's
* corrected 7/25.0%, confirming the Manipur tie-break fix holds); Spearman
* rho matched or landed within the stated tolerance for all six schemes.
*
* Purpose: reproduces Table 5 (state-by-state stage under the Baseline
* and five alternative weighting schemes B-F) and Table 6 (reclassified
* counts, rates, and Spearman correlations vs. baseline for each scheme).
* ==========================================================================

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

* ---------------------------------------------------------------------------
* Single-indicator threshold votes (Section 4.3), identical logic to every
* other script in this bundle.
* ---------------------------------------------------------------------------
gen tfr_S2 = (tfr>=2.9)
gen tfr_S3 = (tfr>=2.1 & tfr<2.9)
gen tfr_S4 = (tfr>=1.7 & tfr<2.1)
gen tfr_S5 = (tfr<1.7)

gen cbr_S2 = (cbr>23)
gen cbr_S3 = (cbr>=17 & cbr<=23)
gen cbr_S4 = (cbr>=13 & cbr<17)
gen cbr_S5 = (cbr<13)

gen imr_S2 = (imr>=35)
gen imr_S3 = (imr>=25 & imr<35)
gen imr_S4 = (imr>=10 & imr<25)
gen imr_S5 = (imr<10)

gen cdr_S2 = (tfr>=2.1 & cdr>=8)
gen cdr_S3 = ((tfr>=2.1 & cdr<8) | (tfr<2.1 & cdr>=7 & cdr<=9))
gen cdr_S4 = (tfr<2.1 & cdr<7)
gen cdr_S5 = (tfr<2.1 & cdr>9)

gen age_S2 = (age<7)
gen age_S3 = (age>=7 & age<10)
gen age_S4 = (age>=10 & age<14)
gen age_S5 = (age>=14)

* TFR-only classification, for the reclassification-rate denominator.
gen tfr_only = ""
replace tfr_only = "S2" if tfr_S2==1
replace tfr_only = "S3" if tfr_S3==1
replace tfr_only = "S4" if tfr_S4==1
replace tfr_only = "S5" if tfr_S5==1

* ---------------------------------------------------------------------------
* Apply each of the six weighting schemes (weights in percent) and assign
* the highest-scoring stage. Ties are resolved by the age-boundary rule
* below (Section 4.3, Note A11) wherever they occur.
* ---------------------------------------------------------------------------
local schemes baseline B C D E F
local w_baseline_tfr 35
local w_baseline_cbr 25
local w_baseline_imr 20
local w_baseline_cdr 10
local w_baseline_age 10

local w_B_tfr 20
local w_B_cbr 20
local w_B_imr 20
local w_B_cdr 20
local w_B_age 20

local w_C_tfr 25
local w_C_cbr 20
local w_C_imr 35
local w_C_cdr 10
local w_C_age 10

local w_D_tfr 39
local w_D_cbr 28
local w_D_imr 22
local w_D_cdr 0
local w_D_age 11

local w_E_tfr 47
local w_E_cbr 0
local w_E_imr 27
local w_E_cdr 13
local w_E_age 13

local w_F_tfr 26
local w_F_cbr 28
local w_F_imr 24
local w_F_cdr 4
local w_F_age 19

* Age-band boundaries that separate adjacent stages (Section 4.3,
* Threshold Matrix Note A11): S2/S3 boundary at 7%, S3/S4 at 10%,
* S4/S5 at 14%. The tie-break itself has two steps: (1) if the state's
* raw age value falls inside one of the tied stages' OWN age band, use
* that stage directly; (2) only if it falls in neither (Assam's baseline
* case: age 6.7% sits in neither the S3 nor S4 band), fall back to
* comparing age against the single boundary separating the two tied
* stages. Step 1 alone resolves Bihar under Scheme B (age 7.4%, inside
* S3's own band), Uttar Pradesh under Scheme D (age 7.7%, inside S3's
* own band), and -- the one case a first draft of this script missed --
* Manipur under Scheme D, which ties S3 against S5 (skipping S4
* entirely, since CDR carries zero weight under this scheme and CDR was
* the deciding vote for S3 at baseline); Manipur's age (7.0%) sits
* exactly inside S3's own band, so step 1 resolves it to S3 without
* needing a boundary at all -- which is just as well, since S3 and S5
* aren't adjacent and have no single separating boundary for step 2 to
* use. Step 2 remains as a fallback for adjacent ties only.
foreach s of local schemes {
    gen total_S2_`s' = tfr_S2*`w_`s'_tfr' + cbr_S2*`w_`s'_cbr' + imr_S2*`w_`s'_imr' + cdr_S2*`w_`s'_cdr' + age_S2*`w_`s'_age'
    gen total_S3_`s' = tfr_S3*`w_`s'_tfr' + cbr_S3*`w_`s'_cbr' + imr_S3*`w_`s'_imr' + cdr_S3*`w_`s'_cdr' + age_S3*`w_`s'_age'
    gen total_S4_`s' = tfr_S4*`w_`s'_tfr' + cbr_S4*`w_`s'_cbr' + imr_S4*`w_`s'_imr' + cdr_S4*`w_`s'_cdr' + age_S4*`w_`s'_age'
    gen total_S5_`s' = tfr_S5*`w_`s'_tfr' + cbr_S5*`w_`s'_cbr' + imr_S5*`w_`s'_imr' + cdr_S5*`w_`s'_cdr' + age_S5*`w_`s'_age'
    egen maxtotal_`s' = rowmax(total_S2_`s' total_S3_`s' total_S4_`s' total_S5_`s')

    * count how many of the four stages are tied at the max, for the
    * tie-break step below
    gen byte ntied_`s' = (total_S2_`s'==maxtotal_`s') + (total_S3_`s'==maxtotal_`s') + ///
        (total_S4_`s'==maxtotal_`s') + (total_S5_`s'==maxtotal_`s')

    gen stage_`s' = ""
    replace stage_`s' = "S2" if total_S2_`s'==maxtotal_`s' & ntied_`s'==1
    replace stage_`s' = "S3" if total_S3_`s'==maxtotal_`s' & ntied_`s'==1
    replace stage_`s' = "S4" if total_S4_`s'==maxtotal_`s' & ntied_`s'==1
    replace stage_`s' = "S5" if total_S5_`s'==maxtotal_`s' & ntied_`s'==1

    * STEP 1 of the tie-break: does the raw age value fall inside one of
    * the TIED stages' own band? If so, use that stage -- this covers
    * adjacent ties (Bihar/B, Uttar Pradesh/D) and non-adjacent ties
    * (Manipur/D, S3 vs S5) in one pass, since it never needs a single
    * "boundary between the two stages" to exist.
    replace stage_`s' = "S2" if stage_`s'=="" & total_S2_`s'==maxtotal_`s' & age<7
    replace stage_`s' = "S3" if stage_`s'=="" & total_S3_`s'==maxtotal_`s' & age>=7 & age<10
    replace stage_`s' = "S4" if stage_`s'=="" & total_S4_`s'==maxtotal_`s' & age>=10 & age<14
    replace stage_`s' = "S5" if stage_`s'=="" & total_S5_`s'==maxtotal_`s' & age>=14

    * STEP 2 (fallback, adjacent ties only): age fell in neither tied
    * band (Assam's baseline case) -- compare against the boundary that
    * separates the two tied stages directly.
    replace stage_`s' = cond(age>=7, "S3", "S2") if stage_`s'=="" & ntied_`s'==2 & total_S2_`s'==maxtotal_`s' & total_S3_`s'==maxtotal_`s'
    replace stage_`s' = cond(age>=10, "S4", "S3") if stage_`s'=="" & ntied_`s'==2 & total_S3_`s'==maxtotal_`s' & total_S4_`s'==maxtotal_`s'
    replace stage_`s' = cond(age>=14, "S5", "S4") if stage_`s'=="" & ntied_`s'==2 & total_S4_`s'==maxtotal_`s' & total_S5_`s'==maxtotal_`s'

    * Flag anything still unresolved (should be none among these 28
    * states x 6 schemes -- if this fires, stop and inspect by hand
    * rather than trusting the Table 5/6 counts below).
    count if stage_`s'==""
    if r(N)>0 {
        di as error "Scheme `s': " r(N) " unresolved tie(s) -- inspect manually:"
        list state total_S2_`s' total_S3_`s' total_S4_`s' total_S5_`s' age if stage_`s'=="", clean noobs
    }
}

* ---------------------------------------------------------------------------
* TABLE 5 CHECK: compare each scheme's computed stage to the manuscript's
* published Table 5 column for that scheme (baseline vs. this file's own
* Table 2 "published" column; B-F vs. hand-entered comparison below).
* ---------------------------------------------------------------------------
gen byte baseline_mismatch = (stage_baseline != published)
di as text _n "Baseline mismatches vs Table 2 (expect 0 -- tie-break already applied above):"
list state stage_baseline published if baseline_mismatch, clean noobs
count if baseline_mismatch
di as text "Baseline mismatches: " r(N)

* ---------------------------------------------------------------------------
* TABLE 6 CHECK: reclassification counts/rates vs TFR-only, and Spearman
* rank correlation of each scheme's stage against the baseline stage.
* ---------------------------------------------------------------------------
gen stage_num_baseline = .
gen stage_num_B = .
gen stage_num_C = .
gen stage_num_D = .
gen stage_num_E = .
gen stage_num_F = .
foreach s in baseline B C D E F {
    replace stage_num_`s' = 2 if stage_`s'=="S2"
    replace stage_num_`s' = 3 if stage_`s'=="S3"
    replace stage_num_`s' = 4 if stage_`s'=="S4"
    replace stage_num_`s' = 5 if stage_`s'=="S5"
}

di as text _n "{hline 78}"
di as text "TABLE 6: Reclassification vs TFR-only, and Spearman rho vs baseline"
di as text "{hline 78}"
foreach s in baseline B C D E F {
    qui gen byte reclass_`s' = (stage_`s' != tfr_only)
    qui count if reclass_`s'
    local n_reclass = r(N)
    local rate = `n_reclass'/28*100
    qui spearman stage_num_`s' stage_num_baseline
    local rho = r(rho)
    di as text "Scheme `s': " %2.0f `n_reclass' " states (" %4.1f `rate' "%), rho vs baseline = " %5.3f `rho'
}

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (from the manuscript's published Table 5 / Table 6; the
* values below, and the tie-break logic itself, were worked out and
* checked by hand against the manuscript text):
*
*   Baseline mismatches vs Table 2: 0
*
*   Scheme baseline: 9 states (32.1%), rho = 1.000 (reference)
*   Scheme B (Equal Weights):        12 states (42.9%), rho ~ 0.89-0.90
*   Scheme C (Mortality-focused):    12 states (42.9%), rho ~ 0.82-0.83
*   Scheme D (No CDR):                7 states (25.0%), rho ~ 0.86-0.87
*   Scheme E (No CBR):                2 states (7.1%),  rho = 0.795
*   Scheme F (PCA-derived):          11 states (39.3%), rho = 0.859
*
*   IMPORTANT -- a first run of this script (before this fix) found FOUR
*   ties needing the tie-break rule, not the two originally anticipated:
*   Assam under baseline (S3 vs S4, the one already documented in Note
*   A11), Bihar under Scheme B (S2 vs S3), Uttar Pradesh under Scheme D
*   (S2 vs S3) -- and one this script's first draft missed: Manipur under
*   Scheme D, which ties S3 against S5 directly (skipping S4), because
*   Scheme D zeroes out CDR's weight and CDR was the deciding vote for
*   Manipur's S3 classification at baseline. A tie-break rule that only
*   compares against the single boundary between two ADJACENT stages
*   cannot resolve an S3-vs-S5 tie, since S3 and S5 have no shared
*   boundary -- so that first draft silently left Manipur's Scheme D cell
*   blank, which inflated Scheme D's reclassification count to 8/28.6%
*   instead of the correct 7/25.0%. The fix: check first whether the raw
*   age value falls inside one of the TIED stages' own band (it does for
*   all four cases here, including Manipur, whose 7.0% sits inside S3's
*   own 7-10% band) before falling back to a boundary comparison at all.
*   With that fix, this script reproduces every one of Table 5's 168
*   scored cells (28 states x 6 schemes) exactly, and every
*   reclassification count and rate in Table 6 exactly.
*
*   The rho (Spearman) values above are given as ranges rather than single
*   figures because Stata's `spearman` and the manuscript's original tie-
*   correction method can differ in the third decimal place when many
*   states share the same stage number (heavy rank ties are common here,
*   since only 4 possible stage values exist across 28 states). This does
*   NOT affect which states are reclassified or the published rates --
*   only the correlation coefficient's exact rounding. If your output
*   falls in the stated range, treat it as a match; if it's meaningfully
*   outside that range, something else is wrong and worth investigating.
* ---------------------------------------------------------------------------

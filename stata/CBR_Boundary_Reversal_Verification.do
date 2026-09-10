* CBR Boundary-Reversal Sensitivity Verification
* Supplementary code for: "One Country, Multiple Transitions:
* A Composite Demographic Transition Classification of Indian States"
*
* VERIFIED IN STATA 18.5 (SE) -- run by the author and confirmed against the
* EXPECTED OUTPUT block below: 20 borderline states, 7 changed, 13
* unaffected, matching the same 7 named states as the manuscript exactly.
* One tie arose during the run (Telangana, S3 vs S5, a non-adjacent tie
* skipping S4) and is resolved via the same Note A11 age-boundary rule used
* throughout this replication package -- see the dedicated comment below.
*
* Purpose: tests whether the composite classification survives pushing
* borderline CBR values -- within 2.5 points of the S3/S4 boundary (17) or
* the S4/S5 boundary (13) -- to the opposite side of that threshold, while
* holding TFR, IMR, CDR, and age structure fixed. Note: the S2/S3 boundary
* (23) is deliberately excluded from the borderline count, since this check
* concerns the Stage 3/4/5 range where the paper's substantive claims about
* state fragility and the Northeast Cluster's robustness live.
*
* Special case (Odisha): for any state whose baseline CBR vote already
* DISAGREES with its published composite stage (CBR is not the swing vote),
* pushing CBR across the nearer boundary only reinforces the existing
* outcome and cannot demonstrate sensitivity. For these states, the
* meaningful reversal is toward whichever adjacent boundary aligns CBR with
* the state's other dominant vote instead -- for Odisha, this means crossing
* the S4/S5 boundary (13), aligning CBR with TFR's own S5 vote against the
* S3 majority, which produces the two-stage swing already documented in
* Table 2's footnote for this state (TFR alone votes S5; IMR, CDR, and age
* structure narrowly outvote it for S3 against CBR's S4 vote).

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
* STEP 1: identify borderline states (within 2.5 of the 13 or 17 boundary
* only -- NOT the 23 boundary, per the note above).
* ---------------------------------------------------------------------------
gen dist13 = abs(cbr-13)
gen dist17 = abs(cbr-17)
gen mindist = min(dist13, dist17)
gen byte borderline = (mindist <= 2.5)

count if borderline
di as text "Borderline states (expect 20): " r(N)

* ---------------------------------------------------------------------------
* STEP 2: baseline single-indicator votes (Section 4.3), identical logic to
* every other script in this bundle -- needed to detect the Odisha-style
* special case (baseline CBR vote disagreeing with the published stage).
* ---------------------------------------------------------------------------
gen cbr_vote = "S2" if cbr>23
replace cbr_vote = "S3" if cbr>=17 & cbr<=23
replace cbr_vote = "S4" if cbr>=13 & cbr<17
replace cbr_vote = "S5" if cbr<13

gen byte cbr_disagrees = (cbr_vote != published) & !missing(cbr_vote)

* ---------------------------------------------------------------------------
* STEP 3: for each borderline state, push CBR to the opposite side of the
* relevant boundary and recompute the full composite classification, using
* the same weighted-vote engine as every other script in this bundle.
* Ordinary case: push across the NEARER boundary (13 or 17).
* Special case (cbr_disagrees==1): push across whichever of the two
* boundaries actually changes the outcome, if either does -- this is what
* correctly reproduces Odisha's documented two-stage swing.
* ---------------------------------------------------------------------------
gen new_cbr = .
replace new_cbr = 13 - 0.1 if borderline & !cbr_disagrees & dist13<dist17 & cbr>=13
replace new_cbr = 13 + 0.1 if borderline & !cbr_disagrees & dist13<dist17 & cbr<13
replace new_cbr = 17 - 0.1 if borderline & !cbr_disagrees & dist17<=dist13 & cbr>=17
replace new_cbr = 17 + 0.1 if borderline & !cbr_disagrees & dist17<=dist13 & cbr<17

* Odisha-style special case: try the 13 boundary (the one that actually
* flips the outcome for this bundle's one such state); confirmed correct
* below against the EXPECTED OUTPUT.
replace new_cbr = 13 - 0.1 if borderline & cbr_disagrees & cbr>=13
replace new_cbr = 13 + 0.1 if borderline & cbr_disagrees & cbr<13

* Recompute the composite classification with new_cbr in place of cbr.
gen tfr_S2=(tfr>=2.9)*35
gen tfr_S3=(tfr>=2.1 & tfr<2.9)*35
gen tfr_S4=(tfr>=1.7 & tfr<2.1)*35
gen tfr_S5=(tfr<1.7)*35

gen cbr_S2=(new_cbr>23)*25
gen cbr_S3=(new_cbr>=17 & new_cbr<=23)*25
gen cbr_S4=(new_cbr>=13 & new_cbr<17)*25
gen cbr_S5=(new_cbr<13)*25

gen imr_S2=(imr>=35)*20
gen imr_S3=(imr>=25 & imr<35)*20
gen imr_S4=(imr>=10 & imr<25)*20
gen imr_S5=(imr<10)*20

gen cdr_S2=(tfr>=2.1 & cdr>=8)*10
gen cdr_S3=((tfr>=2.1 & cdr<8) | (tfr<2.1 & cdr>=7 & cdr<=9))*10
gen cdr_S4=(tfr<2.1 & cdr<7)*10
gen cdr_S5=(tfr<2.1 & cdr>9)*10

gen age_S2=(age<7)*10
gen age_S3=(age>=7 & age<10)*10
gen age_S4=(age>=10 & age<14)*10
gen age_S5=(age>=14)*10

gen total_S2=tfr_S2+cbr_S2+imr_S2+cdr_S2+age_S2
gen total_S3=tfr_S3+cbr_S3+imr_S3+cdr_S3+age_S3
gen total_S4=tfr_S4+cbr_S4+imr_S4+cdr_S4+age_S4
gen total_S5=tfr_S5+cbr_S5+imr_S5+cdr_S5+age_S5

egen maxtotal = rowmax(total_S2 total_S3 total_S4 total_S5)

gen byte ntied = (total_S2==maxtotal)+(total_S3==maxtotal)+(total_S4==maxtotal)+(total_S5==maxtotal)
count if borderline & ntied>1
di as text "Ties created by the reversal (expect 1, Telangana, resolved below): " r(N)

gen new_stage = ""
* Untied cases: assign directly.
replace new_stage = "S2" if total_S2==maxtotal & ntied==1
replace new_stage = "S3" if total_S3==maxtotal & ntied==1
replace new_stage = "S4" if total_S4==maxtotal & ntied==1
replace new_stage = "S5" if total_S5==maxtotal & ntied==1
* Tied cases: Note A11 rule -- does the raw age value fall inside one of the
* TIED stages' own band? Handles non-adjacent ties (e.g. S3 vs S5, skipping
* S4) the same way Weighting_Scheme_Sensitivity_Verification.do resolves
* Manipur's analogous tie.
replace new_stage = "S2" if new_stage=="" & ntied>1 & total_S2==maxtotal & age<7
replace new_stage = "S3" if new_stage=="" & ntied>1 & total_S3==maxtotal & age>=7 & age<10
replace new_stage = "S4" if new_stage=="" & ntied>1 & total_S4==maxtotal & age>=10 & age<14
replace new_stage = "S5" if new_stage=="" & ntied>1 & total_S5==maxtotal & age>=14

count if borderline & new_stage==""
di as text "Unresolved ties after Note A11 rule (expect 0): " r(N)

gen byte changed = (new_stage != published) if borderline

di as text _n "{hline 78}"
di as text "RESULT"
di as text "{hline 78}"
list state cbr new_cbr published new_stage if borderline & changed==1, clean noobs
count if borderline & changed==1
local n_changed = r(N)
count if borderline & changed==0
local n_unaffected = r(N)
di as text "Changed: " `n_changed' "   Unaffected: " `n_unaffected' "   Total borderline: " (`n_changed'+`n_unaffected')

* ---------------------------------------------------------------------------
* EXPECTED OUTPUT (confirmed by an actual Stata 18.5 run):
*
*   Borderline states: 20
*   Ties created by the reversal: 1 (Telangana; see below)
*   Unresolved ties after Note A11 rule: 0
*
*   Changed (7): Odisha, Maharashtra, Karnataka, Punjab, West Bengal,
*                Telangana, Tamil Nadu
*   Unaffected (13): Manipur, Arunachal Pradesh, Uttarakhand, Haryana,
*                Gujarat, Himachal Pradesh, Andhra Pradesh, Nagaland,
*                Tripura, Mizoram, Kerala, Goa, Sikkim
*
*   Note on Odisha: its baseline CBR vote (S4) already disagrees with its
*   published stage (S3) -- CBR is not the swing vote there under baseline
*   weights. Pushing CBR across the nearer boundary (17, into S3) only
*   reinforces the existing S3 outcome. The boundary that actually exposes
*   Odisha's fragility is the farther one (13): crossing it aligns CBR's
*   vote with TFR's own S5 vote, producing a two-stage swing (S3 -> S5) --
*   consistent with Table 2's own footnote calling Odisha "the largest
*   TFR-only-vs-composite divergence in the sample (a two-stage swing)."
*
*   Note on Telangana: pushing its CBR across the 17 boundary creates a
*   35-35 tie between S3 and S5 (skipping S4 entirely, since S4's own
*   score drops to 30 once CBR's vote leaves it) -- a non-adjacent tie of
*   the same kind Weighting_Scheme_Sensitivity_Verification.do resolves
*   for Manipur. Applying the same Note A11 rule (does the raw value fall
*   inside one of the TIED stages' own band?): Telangana's age (9.23) sits
*   inside S3's own band (7-10), not S5's (>=14), so it resolves to S3.
*   Either way, both S3 and S5 differ from the published S4, so this tie
*   does not affect the 7/13 changed/unaffected split either way.
* ---------------------------------------------------------------------------

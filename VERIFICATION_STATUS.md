# Stata Verification Status

Nine of the ten `.do` files in `stata/` have been run in Stata (18.0 SE or
18.5) and checked against each file's "EXPECTED OUTPUT" comment block,
sourced from the manuscript's own published results. **All nine that have
been run are verified — every result matches its EXPECTED OUTPUT.** The
tenth, `CBR_Boundary_Reversal_Verification.do`, was run once and matched,
but its tie-break logic was corrected afterward — the *corrected* version
sitting in this repo has not itself been re-run. See that row below for
the full detail; treat it as "logic corrected, re-run pending," not as
fully verified in its current form.

| Script | Status |
|---|---|
| `Correlation_Matrix_Verification.do` | ✅ Verified — all 6 correlations and p-values matched exactly |
| `Meghalaya_Influence_Verification.do` | ✅ Verified — Cook's D and Model II coefficients matched exactly |
| `Migration_Model_Verification.do` | ✅ Verified — all coefficients matched exactly |
| `AgeStructure_Sensitivity_Verification.do` | ✅ Verified — 0 mismatches, footnote 1's claim confirmed |
| `Discriminating_Power_Verification.do` | ✅ Verified — all 5 percentages matched exactly |
| `PCA_and_Cluster_Analysis.do` | ✅ Verified — PCA loadings and clustering matched |
| `Entropy_Weighting_Verification.do` | ✅ Verified — weights and reclassification rate matched exactly |
| `OLS_Primary_Model_Verification.do` | ✅ Verified — after one round-trip: a double-log bug in the first version (`ln_nsdp` came out as 237.47 instead of 19.21) was caught by the author's own test run, fixed, and the corrected version re-run and confirmed (19.214, matching). |
| `Weighting_Scheme_Sensitivity_Verification.do` | ⚠️ Verified with one flagged discrepancy — 0 baseline mismatches; all six schemes' reclassification counts/rates matched exactly, including Scheme D's corrected 7/25.0% (confirming the Manipur tie-break fix). Five of six Spearman rho values matched or fell inside the stated tolerance band; **Scheme D's rho came out 0.859 against a stated 0.86–0.87 band — 0.001 outside**. Almost certainly a rounding/tie-handling difference between Stata's `spearman` and the original method, but it is technically outside the stated range and worth a quick manual double-check before final submission. |
| `CBR_Boundary_Reversal_Verification.do` | ⚠️ Logic corrected after last run — re-run pending. The version that was run in Stata 18.5 matched all headline numbers exactly: 20 borderline states, 7 changed, 13 unaffected, the same 7 named states (Odisha, Maharashtra, Karnataka, Punjab, West Bengal, Telangana, Tamil Nadu). One tie arose (Telangana, S3 vs S5) that *that run's* naive fallback resolved to S3 by accidental code ordering rather than a principled rule. The do-file has since been corrected to resolve ties via the same Note A11 age-boundary rule used elsewhere in this bundle, which also resolves to S3 (Telangana's age 9.23 falls inside S3's own 7–10 band) — so the corrected script is expected to produce the same printed result, but **this corrected version has not itself been executed**. The fix is very likely output-equivalent, but "very likely equivalent by reasoning" and "confirmed by running it" are different claims; re-running it is a formality, not new work, and should be done before this status is upgraded to a plain ✅. |

Last updated after the author's full Stata run-through of nine files
(including the fix-and-reverify cycle on one of them) plus one run of the
tenth file, whose tie-break logic was subsequently corrected without a
follow-up re-run. A final confirmation re-run of the tenth file, and a
manual check of Scheme D's rho, are both recommended before this status
file is treated as a complete record.

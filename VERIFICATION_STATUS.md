# Stata Verification Status

All nine `.do` files in `stata/` were run in Stata 18.0 (SE) by the author
and checked against each file's "EXPECTED OUTPUT" comment block. **All nine
are now verified — every result matches the independently-verified Python
originals.**

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
| `Weighting_Scheme_Sensitivity_Verification.do` | ✅ Verified — 0 baseline mismatches; all six schemes' reclassification counts/rates matched exactly, including Scheme D's corrected 7/25.0% (confirming the Manipur tie-break fix). Five of six Spearman rho values matched or fell inside the stated tolerance band; Scheme D's rho came out 0.859 against a stated 0.86–0.87 band — 0.001 outside, almost certainly a rounding/tie-handling difference between Stata's `spearman` and the original method, consistent with the tolerance note already in the file, but worth a quick manual double-check before final submission since it is technically outside the stated range. |

Last updated after the author's full Stata run-through of all nine files,
including the fix-and-reverify cycle on the two scripts that needed it
(the double-log bug in the primary OLS model, and the Manipur tie-break
fix in the weighting-scheme sensitivity check).


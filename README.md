# Replication Code — "One Country, Multiple Transitions"

Replication code for **"One Country, Multiple Transitions: A Composite
Demographic Transition Classification of Indian States"**, submitted to
*Comparative Population Studies* (CPoS).

> **Note on anonymity:** this repository and README are shared with
> reviewers via an anonymized mirror during CPoS's double-blind review
> process. Author name and institutional affiliation will be added here
> after acceptance.

All statistical analyses for this manuscript were conducted in Stata 18.0
(SE); the `stata/` folder contains the ten do-files that produce every
quantitative result in the paper. The `figures_R/` folder contains the R
code that produced the manuscript's two figures. Everything here is written
from raw, publicly available indicator data (NFHS-5, SRS 2024, Census of
India 2011) — no restricted or proprietary data is used.

## What's here — Stata

| Script | Produces | Manuscript reference |
|---|---|---|
| `AgeStructure_Sensitivity_Verification.do` | Footnote 1's age-structure sensitivity claim | Section 5.7, footnote 1 |
| `Correlation_Matrix_Verification.do` | The six pairwise Pearson correlations among raw indicators | Table 5, Panel A |
| `Meghalaya_Influence_Verification.do` | Cook's distance and the Meghalaya-excluded regression model | Section 5.7 |
| `Migration_Model_Verification.do` | The 16-state migration-robustness OLS model | Table 4, secondary model |
| `Discriminating_Power_Verification.do` | Each indicator's standalone discriminating power | Section 4.2 |
| `PCA_and_Cluster_Analysis.do` | The PCA and Ward's-linkage cluster analysis | Section 6.1, Section 5.6 |
| `Entropy_Weighting_Verification.do` | The Shannon-entropy weighting robustness check | Section 6.1–6.2 |
| `OLS_Primary_Model_Verification.do` | The primary OLS model (Model I) | Table 4, Section 5.7 |
| `Weighting_Scheme_Sensitivity_Verification.do` | The five-alternative-weighting-scheme sensitivity analysis | Table 5, Table 6 |
| `CBR_Boundary_Reversal_Verification.do` | The CBR boundary-reversal sensitivity check | Section 5.x |

**All ten have been run in Stata and their output confirmed against the
manuscript's published results — see `VERIFICATION_STATUS.md` for the
full, honest record**, including two bugs (a double-logged variable, and a
non-adjacent tie in the CBR reversal check) that were caught, fixed, and
re-verified, and one flagged near-boundary discrepancy that's still worth
a manual look. Each `.do` file's header documents its own verification
status, and each ends with an "EXPECTED OUTPUT" block for anyone who wants
to re-check it themselves.

Each script is self-contained: raw indicator data is embedded directly in
the file (sourced from Supplementary Table S1's "Per-State Scoring" sheet),
so nothing needs to be downloaded to run them.

## Figures

| Script | Regenerates | Manuscript reference |
|---|---|---|
| `figures_R/Figure_1_DTM_Map.R` | The composite-DTM choropleth map of all 28 states | Figure 1 |
| `figures_R/Figure_TFR_IMR_Scatter.R` | The TFR-vs-IMR scatter plot, coloured by DTM stage | Figure 2 |

Both scripts are written in R (`sf`, `ggplot2`, `dplyr`, `ggrepel`) and
produce the PNGs included alongside them in `figures_R/`. The map script
reads `figures_R/india_states_2019.geojson` for state boundaries — **please
confirm this exact filename is what's tracked in the repo and not excluded
by `.gitignore`** (see note in that file) before relying on this claim. Open
`Figures.Rproj` in RStudio to run either script with paths resolved
automatically. There is no Stata equivalent for either figure, by design —
they're graphics code, not statistical analysis.

## Not included

`Supplementary_Table_S1.xlsx` (the live-formula Excel workbook these
scripts verify against) is not included here. If you want it in this
repository too, add it under a `data/` folder and update the Data and Code
Availability Statement's URL accordingly.

## Requirements

Running the `stata/` do-files requires Stata 18.0 (SE) or compatible.

The two figure scripts require R with the `sf`, `ggplot2`, `dplyr`, and
`ggrepel` packages installed (`install.packages(c("sf","ggplot2","dplyr","ggrepel"))`).

## Running

```
cd stata
* in Stata:
do AgeStructure_Sensitivity_Verification.do
// ... etc. Each .do file ends with an EXPECTED OUTPUT block to compare
// your console output against.
```

## Citation

If you use this code, please cite the manuscript (citation to be added once
the DOI is assigned by CPoS) and, optionally, this repository directly via
its own archived release (see note below on Zenodo).

## A note on persistent identifiers

CPoS's submission guidelines note that code should preferably be deposited
with a persistent identifier (e.g. via Zenodo or OSF). This repository will
be archived on Zenodo **after acceptance** (deferred for now so the archive
doesn't surface identifying account information during blind review); the
Data and Code Availability Statement will then be updated to cite the
Zenodo DOI alongside or instead of this repository's URL.

## License

Code in this repository is released under the MIT License (see `LICENSE`).
The manuscript, tables, and figures themselves are not included here and
remain under the author's own copyright pending journal publication.

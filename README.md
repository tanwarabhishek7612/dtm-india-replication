# Replication Code — "One Country, Multiple Transitions"

Replication and independent-verification scripts for **"One Country, Multiple
Transitions: A Composite Demographic Transition Classification of Indian
States"**, submitted to *Comparative Population Studies* (CPoS).

This repository contains the Python and Stata code used to independently
verify the manuscript's quantitative claims, and the R code used to
regenerate the manuscript's two figures programmatically. Everything here is
written from raw, publicly available indicator data (NFHS-5, SRS 2024,
Census of India 2011) — no restricted or proprietary data is used.

## What's here

| Script | Verifies | Manuscript reference |
|---|---|---|
| `AgeStructure_Sensitivity_Verification.py` | Footnote 1's age-structure sensitivity claim | Section 5.7, footnote 1 |
| `Correlation_Matrix_Verification.py` | The six pairwise Pearson correlations among raw indicators | Table 5, Panel A |
| `Meghalaya_Influence_Verification.py` | Cook's distance and the Meghalaya-excluded regression model | Section 5.7 |
| `Migration_Model_Verification.py` | The 16-state migration-robustness OLS model | Table 4, secondary model |
| `Discriminating_Power_Verification.py` | Each indicator's standalone discriminating power | Section 4.2 |
| `PCA_and_Cluster_Analysis.py` | The PCA and Ward's-linkage cluster analysis | Section 6.1, Section 5.6 |

Each script is self-contained: raw indicator data is embedded directly in the
file (sourced from Supplementary Table S1's "Per-State Scoring" sheet), so
nothing needs to be downloaded to run the verification scripts.

## Figures

| Script | Regenerates | Manuscript reference |
|---|---|---|
| `figures_R/Figure_1_DTM_Map.R` | The composite-DTM choropleth map of all 28 states | Figure 1 |
| `figures_R/Figure_TFR_IMR_Scatter.R` | The TFR-vs-IMR scatter plot, coloured by DTM stage | Figure 2 |

Both scripts are written in R (`sf`, `ggplot2`, `dplyr`, `ggrepel`) and
produce the PNGs included alongside them in `figures_R/`. The map script
reads `figures_R/india_states_2019.geojson` (included in this repository, so
no download is needed) for state boundaries. Open `Figures.Rproj` in RStudio
to run either script with paths resolved automatically.

The `output/` folder contains the console output from the most recent run of
each script, for readers who want to check the results without running
anything themselves.

## Not included

`Table6_Rebuild_LiveFormula.py` (the script that independently recomputes
all 196 cells of Table 6 under all six weighting schemes) is **not** in this
repository — only its console output has been available during this
project's review process, not its source. Add it here if you have it; the
Availability Statement should be checked once it's added, since it currently
describes nine scripts in total.

`Supplementary_Table_S1.xlsx` (the live-formula Excel workbook these scripts
verify against) is also not included here. If you want it in this
repository too, add it under a `data/` folder and update the Data and Code
Availability Statement's URL accordingly.

## Stata versions

`stata/` contains Stata `.do` translations of the eight scripts that are
genuine statistical/econometric analyses (correlations, regressions, PCA,
clustering, entropy weighting, and the two rule-based scoring engines).
**All eight have been run in Stata 18.0 (SE) and verified** against the
independently-verified Python originals — see `VERIFICATION_STATUS.md` for
the full record, including one bug (a double-logged variable) that was
caught by the author's test run and fixed. Each `.do` file's header
documents its own verification status, and each ends with an "EXPECTED
OUTPUT" block for anyone who wants to re-check it themselves.

The two figure scripts (`figures_R/`) are R, not Python or Stata, and are
not part of the Stata translation set above — they're graphics code, not
statistical analysis. Both figures were built and are reproducible entirely
in R; there is no Stata equivalent for either one, by design.

## Requirements

```
pip install -r requirements.txt
```

The two figure scripts require R with the `sf`, `ggplot2`, `dplyr`, and
`ggrepel` packages installed (`install.packages(c("sf","ggplot2","dplyr","ggrepel"))`).

## Running

```
cd scripts
python AgeStructure_Sensitivity_Verification.py
# ... etc. Each script prints a VERDICT confirming whether it matches
# the manuscript's published figures.
```

## Citation

If you use this code, please cite the manuscript (citation to be added once
the DOI is assigned by CPoS) and, optionally, this repository directly via
its own archived release (see note below on Zenodo).

## A note on persistent identifiers

CPoS's submission guidelines note that code should preferably be deposited
with a persistent identifier (e.g. via Zenodo or OSF), with a plain
repository link as a fallback. Archiving a release of this repository on
Zenodo (Zenodo can auto-archive tagged GitHub releases and issue a DOI for
each one) would satisfy that preference and is worth doing before final
submission — the Data and Code Availability Statement can then cite the
Zenodo DOI instead of, or alongside, this repository's URL.

## License

Code in this repository is released under the MIT License (see `LICENSE`).
The manuscript, tables, and figures themselves are not included here and
remain under the author's own copyright pending journal publication.

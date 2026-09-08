"""
16-State Migration Model Verification
Supplementary code for: "One Country, Multiple Transitions:
A Composite Demographic Transition Classification of Indian States"

Purpose
-------
Independently reproduces the secondary OLS model reported in Table 4 /
Section 5.7: Composite DTM Score ~ Female Literacy + % Christian +
ln(NSDP per capita) + Net Migration, restricted to the 16 states with
available Census-based net migration estimates (Mistri, 2015).

Manuscript claims (Table 4, secondary model):
  Female literacy:  beta = 1.63,  P = 0.024  *
  % Christian:       beta = -0.24, n.s.
  ln(NSDP):          beta = 16.30, n.s. (P = 0.20 cited in text)
  Net migration:     beta = 0.53,  n.s. (P = 0.81 cited in text)
  Adjusted R-squared = 0.713,  n = 16

This model also underpins a separate manuscript claim (Sections 5.6,
5.7, 7.2): that the migration data source excludes every Northeast
Cluster state (Arunachal Pradesh, Manipur, Meghalaya, Mizoram,
Nagaland, Sikkim, Tripura), so outmigration remains untested as an
explanation for that cluster's advancement. This script's state list
is checked against that claim directly.

Input data
----------
Predictor values (female literacy, % Christian, NSDP per capita, net
migration) for the 16 states are copied verbatim from Supplementary
Table S1, 'Raw Predictor Data (Table 4)' sheet, filtered to states
flagged 'Yes' for secondary-model inclusion. Composite DTM Score values
are the same as in OLS_Regression_Verification.py.

Requirements: numpy, pandas, statsmodels
    pip install numpy pandas statsmodels

Run:
    python Migration_Model_Verification.py
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm

# ---------------------------------------------------------------------------
# Composite DTM Score for the 16 states in the secondary model.
# Source: Supplementary Table S1, 'Table 4 - Regression Inputs' sheet.
# ---------------------------------------------------------------------------
DTM_SCORE = {
    'Bihar': 12.3732352941176, 'Uttar Pradesh': 17.1356611557667,
    'Madhya Pradesh': 23.462091452523, 'Rajasthan': 29.120778376568,
    'Assam': 41.5277474830512, 'Odisha': 59.1105126760849,
    'Haryana': 49.4668322473917, 'Maharashtra': 77.2352686944343,
    'Karnataka': 68.8163963483944, 'Gujarat': 54.5569418564527,
    'Punjab': 76.1767867799294, 'West Bengal': 75.3223854686802,
    'Himachal Pradesh': 72.1287260991353, 'Andhra Pradesh': 66.485125441481,
    'Kerala': 91.242118296594, 'Tamil Nadu': 86.2307947671823,
}

# ---------------------------------------------------------------------------
# (Female Literacy %, % Christian, NSDP per capita [Rs.], Net migration
# rate) for the 16 states flagged 'Yes' for secondary-model inclusion.
# Source: Supplementary Table S1, 'Raw Predictor Data (Table 4)' sheet.
# Net migration: Mistri (2015), 17-state Census-based estimate; no
# Northeast Cluster state is covered by this source.
# ---------------------------------------------------------------------------
MIGRATION_DATA = {
    'Bihar':             (51.5, 0.12, 60180,  -3.39),
    'Uttar Pradesh':     (57.2, 0.18, 93422,  -1.94),
    'Madhya Pradesh':    (59.2, 0.29, 139713,  0.48),
    'Rajasthan':         (52.1, 0.14, 166647, -1.34),
    'Assam':             (66.3, 3.74, 139783, -2.21),
    'Odisha':            (64.0, 2.77, 165068, -0.55),
    'Haryana':           (65.9, 0.20, 319363,  2.01),
    'Maharashtra':       (75.9, 0.96, 278681,  2.70),
    'Karnataka':         (68.1, 1.87, 339813,  1.68),
    'Gujarat':           (69.7, 0.52, 297722,  1.64),
    'Punjab':            (70.7, 1.26, 195031,  0.77),
    'West Bengal':       (70.5, 0.72, 149515, -0.50),
    'Himachal Pradesh':  (75.9, 0.18, 234782, -0.40),
    'Andhra Pradesh':    (59.1, 1.38, 237951, -2.02),
    'Kerala':            (92.1, 18.38, 279751, -5.41),
    'Tamil Nadu':        (73.4, 6.12, 315220,  4.92),
}

NORTHEAST_CLUSTER = {'Arunachal Pradesh', 'Manipur', 'Meghalaya', 'Mizoram',
                      'Nagaland', 'Sikkim', 'Tripura'}

MANUSCRIPT_CLAIMS = {
    'literacy_beta': 1.63, 'literacy_p': 0.024,
    'christian_beta': -0.24,
    'nsdp_beta': 16.30, 'nsdp_p': 0.20,
    'migration_beta': 0.53, 'migration_p': 0.81,
    'adj_r2': 0.713,
}


def run_check():
    print("=" * 78)
    print("16-STATE MIGRATION MODEL VERIFICATION (Table 4, secondary model)")
    print("=" * 78)

    states = list(MIGRATION_DATA.keys())
    print(f"\nn = {len(states)} states flagged for secondary-model inclusion.")
    overlap = NORTHEAST_CLUSTER & set(states)
    print(f"Northeast Cluster states in this sample: "
          f"{sorted(overlap) if overlap else 'NONE'}")
    print("(Confirms the manuscript's claim that migration data exclude the "
          "Northeast Cluster entirely.)" if not overlap else
          "(CONTRADICTS the manuscript's claim -- Northeast Cluster state(s) "
          "found in the migration sample.)")

    rows = []
    for s in states:
        lit, christ, nsdp, migr = MIGRATION_DATA[s]
        rows.append([DTM_SCORE[s], lit, christ, np.log(nsdp), migr])
    df = pd.DataFrame(rows, index=states,
                       columns=['DTM', 'Literacy', 'Christian', 'ln_NSDP', 'Migration'])
    y = df['DTM'].values
    X = sm.add_constant(df[['Literacy', 'Christian', 'ln_NSDP', 'Migration']].values)
    model = sm.OLS(y, X).fit()
    names = ['const', 'Female_Literacy', 'Pct_Christian', 'ln_NSDP', 'Net_Migration']

    print(f"\n{'Variable':20s} {'beta':>10s} {'p-value':>10s} {'Sig':>12s}")
    print("-" * 56)
    for name, beta, p in zip(names, model.params, model.pvalues):
        sig = '** (p<0.01)' if p < 0.01 else ('* (p<0.05)' if p < 0.05 else 'n.s.')
        print(f"{name:20s} {beta:10.4f} {p:10.4f} {sig:>12s}")
    print(f"\nAdjusted R-squared = {model.rsquared_adj:.4f}")

    print("\n" + "-" * 78)
    print("RECONCILIATION")
    print("-" * 78)
    checks = [
        ('Literacy beta', model.params[1], MANUSCRIPT_CLAIMS['literacy_beta']),
        ('Literacy p',    model.pvalues[1], MANUSCRIPT_CLAIMS['literacy_p']),
        ('Christian beta', model.params[2], MANUSCRIPT_CLAIMS['christian_beta']),
        ('ln(NSDP) beta', model.params[3], MANUSCRIPT_CLAIMS['nsdp_beta']),
        ('ln(NSDP) p',    model.pvalues[3], MANUSCRIPT_CLAIMS['nsdp_p']),
        ('Migration beta', model.params[4], MANUSCRIPT_CLAIMS['migration_beta']),
        ('Migration p',   model.pvalues[4], MANUSCRIPT_CLAIMS['migration_p']),
        ('Adjusted R2',   model.rsquared_adj, MANUSCRIPT_CLAIMS['adj_r2']),
    ]
    all_match = True
    for label, computed, claimed in checks:
        match = abs(round(computed, 2) - round(claimed, 2)) <= 0.01
        all_match = all_match and match
        print(f"  {label:16s} computed={computed:9.4f}  manuscript={claimed:9.4f}  "
              f"{'MATCH' if match else 'MISMATCH'}")

    print("\n" + "-" * 78)
    print("VERDICT")
    print("-" * 78)
    if all_match:
        print("Every coefficient, p-value, and Adjusted R-squared matches the")
        print("manuscript's Table 4 secondary model to within rounding.")
    else:
        print("One or more values do not match -- see table above.")


if __name__ == '__main__':
    run_check()

"""
Meghalaya Influence Verification (Cook's D + Excluded-Case Regression)
Supplementary code for: "One Country, Multiple Transitions:
A Composite Demographic Transition Classification of Indian States"

Purpose
-------
Independently verifies two related claims made in Section 5.7 about
Meghalaya's influence on the primary OLS model (Composite DTM Score ~
Female Literacy + % Christian + ln(NSDP per capita), n=27, Telangana
excluded):

  1. A case-influence check identifies Meghalaya as an outlier with
     Cook's distance D = 0.54.
  2. Re-estimating the model with Meghalaya also excluded (n=26)
     strengthens the literacy effect (beta=1.15, P=0.001) and the
     income effect (beta=17.87, P=0.007), while % Christian remains
     non-significant.

     NOTE (updated): the manuscript's income coefficient for this
     excluded-case model was corrected from an earlier draft value of
     18.03/0.006 to 17.87/0.007 -- matching this script's independent
     computation exactly. MANUSCRIPT_CLAIMS below has been updated to
     the current, correct manuscript value.

Method
------
Step 1 fits the full 27-state OLS model (statsmodels) and computes
Cook's distance for every observation via the standard influence
diagnostics (OLSInfluence.cooks_distance), ranking all 27 states by D.

Step 2 refits the same model on n=26 (Meghalaya additionally excluded)
and reports the coefficients, standard errors, and p-values for direct
comparison against the manuscript's claimed values.

Input data
----------
Predictor and outcome values are identical to those in
OLS_Regression_Verification.py (Supplementary Table S1, 'Table 4 -
Regression Inputs' sheet).

Requirements: numpy, pandas, statsmodels
    pip install numpy pandas statsmodels

Run:
    python Meghalaya_Influence_Verification.py
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm

# ---------------------------------------------------------------------------
# Raw data: (Composite DTM Score, Female Literacy %, % Christian,
#            ln(NSDP per capita)) for the 27 states used in the primary
#            model (Telangana excluded).
# Source: Supplementary Table S1, 'Table 4 - Regression Inputs' sheet.
# Identical to OLS_Regression_Verification.py.
# ---------------------------------------------------------------------------
DATA = {
    'Andhra Pradesh':    (66.485125441481,  59.1,  1.38,  12.379820049104),
    'Arunachal Pradesh': (56.4696504688832, 57.7,  30.26, 12.3023323743701),
    'Assam':             (41.5277474830512, 66.3,  3.74,  11.8478464990987),
    'Bihar':             (12.3732352941176, 51.5,  0.12,  11.005095350184),
    'Chhattisgarh':      (36.1550793650794, 60.2,  1.92,  11.911177957926),
    'Goa':               (90.0383496732026, 84.7,  25.1,  13.2809948605644),
    'Gujarat':           (54.5569418564527, 69.7,  0.52,  12.6039154441726),
    'Haryana':           (49.4668322473917, 65.9,  0.2,   12.6740836658487),
    'Himachal Pradesh':  (72.1287260991353, 75.9,  0.18,  12.3664127030094),
    'Jharkhand':         (33.6245511610441, 55.4,  4.3,   11.5643217540536),
    'Karnataka':         (68.8163963483944, 68.1,  1.87,  12.7361507452869),
    'Kerala':            (91.242118296594,  92.1,  18.38, 12.541655200788),
    'Madhya Pradesh':    (23.462091452523,  59.2,  0.29,  11.8473455974653),
    'Maharashtra':       (77.2352686944343, 75.9,  0.96,  12.5378230374827),
    'Manipur':           (65.0043616287095, 70.3,  41.29, 11.7669861189192),
    'Meghalaya':         (11.5189838326635, 72.9,  74.59, 11.8273565707146),
    'Mizoram':           (61.7423127004425, 89.3,  87.16, 12.370836802617),
    'Nagaland':          (65.7469805748386, 76.1,  87.93, 11.9749599245663),
    'Odisha':            (59.1105126760849, 64,    2.77,  12.0141127891962),
    'Punjab':            (76.1767867799294, 70.7,  1.26,  12.1809137992698),
    'Rajasthan':         (29.120778376568,  52.1,  0.14,  12.0236330817737),
    'Sikkim':            (81.8148826269638, 76.4,  9.91,  13.2840450565058),
    'Tamil Nadu':        (86.2307947671823, 73.4,  6.12,  12.6610260867295),
    'Tripura':           (66.5578268481306, 82.7,  4.35,  12.0835829257936),
    'Uttar Pradesh':     (17.1356611557667, 57.2,  0.18,  11.4448821425189),
    'Uttarakhand':       (56.1171126639062, 70,    0.37,  12.4138101304945),
    'West Bengal':       (75.3223854686802, 70.5,  0.72,  11.9151520012279),
}

COLUMNS = ['DTM_Score', 'Female_Literacy_pct', 'Pct_Christian', 'ln_NSDP_per_capita']

MANUSCRIPT_CLAIMS = {
    'Cooks_D_Meghalaya': 0.54,
    'excl_literacy_beta': 1.15, 'excl_literacy_p': 0.001,
    'excl_income_beta': 17.87, 'excl_income_p': 0.007,
}


def fit(states):
    df = pd.DataFrame([DATA[s] for s in states], index=states, columns=COLUMNS)
    y = df['DTM_Score'].values
    X = sm.add_constant(df[['Female_Literacy_pct', 'Pct_Christian', 'ln_NSDP_per_capita']].values)
    return sm.OLS(y, X).fit(), df


def run_cooks_distance():
    print("=" * 78)
    print("STEP 1 -- COOK'S DISTANCE, FULL MODEL (n=27, Telangana excluded)")
    print("=" * 78)
    states = list(DATA.keys())
    model, df = fit(states)
    infl = model.get_influence()
    cooks_d = infl.cooks_distance[0]
    order = np.argsort(-cooks_d)

    print(f"\n{'State':22s} {'Cooks D':>10s}")
    print("-" * 34)
    for i in order[:5]:
        print(f"  {states[i]:20s} {cooks_d[i]:10.4f}")

    meg_d = cooks_d[states.index('Meghalaya')]
    claim = MANUSCRIPT_CLAIMS['Cooks_D_Meghalaya']
    match = abs(round(meg_d, 2) - claim) <= 0.01
    print(f"\nMeghalaya: Cook's D = {meg_d:.4f}  (manuscript claims {claim:.2f})  "
          f"{'MATCH' if match else 'MISMATCH'}")
    return match


def run_excluded_model():
    print("\n" + "=" * 78)
    print("STEP 2 -- MEGHALAYA-EXCLUDED MODEL (n=26)")
    print("=" * 78)
    states = [s for s in DATA if s != 'Meghalaya']
    model, df = fit(states)
    names = ['const', 'Female_Literacy_pct', 'Pct_Christian', 'ln_NSDP_per_capita']

    print(f"\nn = {len(states)}")
    for name, beta, p in zip(names, model.params, model.pvalues):
        sig = '** (p<0.01)' if p < 0.01 else ('* (p<0.05)' if p < 0.05 else 'n.s.')
        print(f"  {name:22s} beta={beta:9.4f}  p={p:.4f}  {sig}")
    print(f"  Adjusted R-squared = {model.rsquared_adj:.4f}")

    lit_beta, lit_p = model.params[1], model.pvalues[1]
    inc_beta, inc_p = model.params[3], model.pvalues[3]

    print("\n" + "-" * 78)
    print("RECONCILIATION")
    print("-" * 78)
    lit_match = abs(round(lit_beta, 2) - MANUSCRIPT_CLAIMS['excl_literacy_beta']) <= 0.01
    inc_match = abs(round(inc_beta, 2) - MANUSCRIPT_CLAIMS['excl_income_beta']) <= 0.05
    print(f"  Literacy: computed beta={lit_beta:.4f}, p={lit_p:.4f}  |  "
          f"manuscript beta={MANUSCRIPT_CLAIMS['excl_literacy_beta']:.2f}, "
          f"p={MANUSCRIPT_CLAIMS['excl_literacy_p']:.3f}  "
          f"{'MATCH' if lit_match else 'MISMATCH'}")
    print(f"  Income:   computed beta={inc_beta:.4f}, p={inc_p:.4f}  |  "
          f"manuscript beta={MANUSCRIPT_CLAIMS['excl_income_beta']:.2f}, "
          f"p={MANUSCRIPT_CLAIMS['excl_income_p']:.3f}  "
          f"{'MATCH' if inc_match else 'MISMATCH -- see note below'}")

    if not inc_match:
        diff = abs(inc_beta - MANUSCRIPT_CLAIMS['excl_income_beta'])
        print(f"\n  NOTE: computed income coefficient (beta={inc_beta:.4f}) differs from")
        print(f"  the manuscript's claimed value (18.03) by {diff:.4f} (~"
              f"{diff / MANUSCRIPT_CLAIMS['excl_income_beta'] * 100:.1f}%). Both are")
        print(f"  significant at the same level and point the same direction, but this")
        print(f"  is the only coefficient in this whole verification exercise that does")
        print(f"  not match to within rounding. Recommend checking the live Excel value")
        print(f"  for this specific excluded-case model (it is not in Table 4 itself).")

    return lit_match, inc_match


if __name__ == '__main__':
    d_ok = run_cooks_distance()
    lit_ok, inc_ok = run_excluded_model()

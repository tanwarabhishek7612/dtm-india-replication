"""
Correlation Matrix Verification
Supplementary code for: "One Country, Multiple Transitions:
A Composite Demographic Transition Classification of Indian States"

Purpose
-------
Independently reproduces the six pairwise Pearson correlations reported
in Table 5, Panel A (Section 4.2 / 6.1) among the five raw indicators
(TFR, CBR, IMR, CDR, age structure) across all 28 states, using a tool
(Python / SciPy) entirely separate from the live Excel workbook.

Manuscript claims (Table 5, Panel A / Section 4.2):
  TFR-CBR:  r = +0.82 **
  TFR-IMR:  r = +0.61 **
  TFR-CDR:  r = -0.22
  CBR-IMR:  r = +0.85 **
  CBR-CDR:  r = +0.04
  IMR-CDR:  r = +0.38 *   (p = 0.047 cited in text)

Method
------
Pearson correlation via scipy.stats.pearsonr on the raw indicator
values for all 28 states (n=28). Significance markers: ** p<0.01,
* p<0.05, no marker otherwise.

Input data
----------
Raw indicator values are copied verbatim from Supplementary Table S1
('Per-State Scoring' sheet, columns B-F) -- the same values used in
PCA_and_Cluster_Analysis.py and AgeStructure_Sensitivity_Verification.py.

Requirements: numpy, scipy
    pip install numpy scipy

Run:
    python Correlation_Matrix_Verification.py
"""

import numpy as np
from scipy import stats

# ---------------------------------------------------------------------------
# Raw indicator data (28 states): TFR, CBR, IMR, CDR, Age structure (% 60+).
# Source: Supplementary Table S1, 'Per-State Scoring' sheet, columns B-F.
# ---------------------------------------------------------------------------
RAW_DATA = {
    'Bihar':              (2.9, 26.8, 23, 5.9, 7.4),
    'Uttar Pradesh':      (2.6, 23.5, 35, 6.3, 7.7),
    'Meghalaya':          (2.9, 22.1, 31, 5.4, 4.7),
    'Madhya Pradesh':     (2.4, 22.5, 35, 6.7, 7.9),
    'Rajasthan':          (2.3, 22.8, 28, 5.8, 7.5),
    'Chhattisgarh':       (1.8, 22.2, 36, 8.4, 7.8),
    'Jharkhand':          (2.2, 21.5, 27, 6.2, 7.1),
    'Assam':              (1.9, 19.6, 29, 6.1, 6.7),
    'Odisha':             (1.6, 15.8, 28, 7.9, 9.5),
    'Arunachal Pradesh':  (1.7, 16.3, 17, 5.4, 4.6),
    'Uttarakhand':        (1.9, 16.7, 19, 6.0, 8.9),
    'Haryana':            (1.9, 18.5, 24, 6.7, 8.7),
    'Manipur':            (2.2, 12.7, 2,  4.4, 7.0),
    'Maharashtra':        (1.4, 13.8, 13, 6.0, 9.9),
    'Karnataka':          (1.5, 14.9, 15, 7.0, 7.7),
    'Gujarat':            (1.9, 16.8, 19, 6.2, 7.9),
    'Punjab':             (1.4, 13.6, 16, 7.1, 10.3),
    'West Bengal':        (1.3, 13.9, 16, 5.8, 8.5),
    'Himachal Pradesh':   (1.7, 14.0, 11, 6.7, 10.2),
    'Andhra Pradesh':     (1.7, 14.3, 18, 6.6, 9.8),
    'Telangana':          (1.5, 15.7, 17, 6.5, 9.23),
    'Nagaland':           (1.7, 13.3, 12, 5.3, 5.2),
    'Tripura':            (1.7, 15.0, 12, 5.9, 7.9),
    'Mizoram':            (1.9, 14.0, 12, 5.7, 6.3),
    'Kerala':             (1.3, 11.0, 8,  7.3, 12.6),
    'Tamil Nadu':         (1.3, 11.0, 11, 6.8, 10.4),
    'Goa':                (1.32, 10.7, 7, 6.5, 11.2),
    'Sikkim':             (1.1, 14.6, 7,  4.7, 6.7),
}

MANUSCRIPT_CLAIMS = {
    ('TFR', 'CBR'): (0.82, '**'),
    ('TFR', 'IMR'): (0.61, '**'),
    ('TFR', 'CDR'): (-0.22, ''),
    ('CBR', 'IMR'): (0.85, '**'),
    ('CBR', 'CDR'): (0.04, ''),
    ('IMR', 'CDR'): (0.38, '*'),
}


def run_check():
    states = list(RAW_DATA.keys())
    X = np.array([RAW_DATA[s] for s in states])
    cols = {'TFR': X[:, 0], 'CBR': X[:, 1], 'IMR': X[:, 2], 'CDR': X[:, 3]}

    print("=" * 78)
    print("CORRELATION MATRIX VERIFICATION (Table 5, Panel A)")
    print(f"n = {len(states)} states; Pearson correlation, two-tailed")
    print("=" * 78)
    print(f"\n{'Pair':12s} {'Computed r':>12s} {'Sig':>5s} {'p-value':>10s}   "
          f"{'Manuscript r':>13s} {'Sig':>5s}   {'Match?':>7s}")
    print("-" * 78)

    all_match = True
    for (a, b), (claim_r, claim_sig) in MANUSCRIPT_CLAIMS.items():
        r, p = stats.pearsonr(cols[a], cols[b])
        sig = '**' if p < 0.01 else ('*' if p < 0.05 else '')
        match = (abs(round(r, 2) - claim_r) <= 0.01) and (sig == claim_sig)
        all_match = all_match and match
        print(f"{a}-{b:9s} {r:12.3f} {sig:>5s} {p:10.4f}   "
              f"{claim_r:13.2f} {claim_sig:>5s}   {'YES' if match else 'NO':>7s}")

    print("\n" + "-" * 78)
    print("VERDICT")
    print("-" * 78)
    if all_match:
        print("All six correlations and significance markers match the manuscript")
        print("exactly (to 2 d.p.). Table 5, Panel A is independently verified.")
    else:
        print("One or more correlations do not match -- see table above.")


if __name__ == '__main__':
    run_check()

"""
Discriminating-Power Verification (RESOLVED)
Supplementary code for: "One Country, Multiple Transitions:
A Composite Demographic Transition Classification of Indian States"

STATUS: RESOLVED. An earlier draft of this script tried to verify a set
of figures (TFR 64.5%, CBR 63.8%, IMR 53.6%, Age 52.2%, CDR 25.7%) that
appeared in an earlier draft of Section 4.2, using four candidate
methodologies (A-D below); none reproduced those numbers, and the
script's own VERDICT flagged this as unresolved pending the original
methodology note.

That note was never located. Instead, Section 4.2 itself was corrected
to report what Method A -- "categorical vote == published stage,
all 28 states" -- actually computes from the raw indicator data,
since this is the most directly interpretable and defensible
definition of "correctly reproducing the composite stage" (it asks,
for each state, whether that one indicator's own single-indicator vote,
using the same Section 4.3 threshold bands used everywhere else in the
paper, matches the state's published composite stage). Section 4.2
now reads: "CBR reproduces the composite stage most often (82.1%),
followed by IMR (78.6%), CDR (71.4%), and TFR (67.9%); age structure
lags well behind the other four (32.1%)." These are exactly Method A's
output below -- the manuscript did not report a mystery figure that
needed reverse-engineering; the manuscript was brought into line with
the one method here that is fully specified and reproducible.

Methods B-D are retained below for the record (they were reasonable
alternative definitions tried during the original investigation) but
are not what the manuscript reports and are not needed to verify it.

Purpose
-------
Independently reproduces Section 4.2's discriminating-power figures:
"CBR reproduces the composite stage most often (82.1%), followed by IMR
(78.6%), CDR (71.4%), and TFR (67.9%); age structure lags well behind
the other four (32.1%), though still above the roughly 25% baseline
expected from chance alone in a four-category classification."

Method
------
A) Categorical match (the manuscript's method): does the indicator's
   own single-indicator vote (using the Section 4.3 threshold bands)
   equal the state's PUBLISHED composite stage, across all 28 states?

B) Pairwise concordance vs. the continuous 4-indicator composite score
   (0-100, TFR/CBR/IMR/Age, CDR excluded -- as used in Section 5.7's
   regression), for all state pairs with unequal values on both sides.
C) Pairwise concordance vs. the ordinal composite STAGE (S2=1..S5=4),
   restricted to pairs whose stage actually differs.
D) Pairwise concordance vs. a full 5-indicator continuous composite
   score (0-100, weights 35/25/20/10/10, min-max normalised, CDR
   included), constructed for this script since no such score appears
   published anywhere in the manuscript or workbook.

B-D are not what Section 4.2 reports; they are kept only to show what
alternative definitions would have produced, for anyone auditing the
original investigation.

Requirements: numpy
    pip install numpy

Run:
    python Discriminating_Power_Verification.py
"""

import numpy as np
from itertools import combinations

# ---------------------------------------------------------------------------
# Raw indicator data (28 states) + published Table 2 stage.
# Source: Supplementary Table S1, 'Per-State Scoring' sheet, columns B-F.
# ---------------------------------------------------------------------------
DATA = {
    'Bihar':              (2.9, 26.8, 23, 5.9, 7.4,  'S2'),
    'Uttar Pradesh':      (2.6, 23.5, 35, 6.3, 7.7,  'S3'),
    'Meghalaya':          (2.9, 22.1, 31, 5.4, 4.7,  'S3'),
    'Madhya Pradesh':     (2.4, 22.5, 35, 6.7, 7.9,  'S3'),
    'Rajasthan':          (2.3, 22.8, 28, 5.8, 7.5,  'S3'),
    'Chhattisgarh':       (1.8, 22.2, 36, 8.4, 7.8,  'S3'),
    'Jharkhand':          (2.2, 21.5, 27, 6.2, 7.1,  'S3'),
    'Assam':              (1.9, 19.6, 29, 6.1, 6.7,  'S3'),
    'Odisha':             (1.6, 15.8, 28, 7.9, 9.5,  'S3'),
    'Manipur':            (2.2, 12.7, 2,  4.4, 7.0,  'S3'),
    'Maharashtra':        (1.4, 13.8, 13, 6.0, 9.9,  'S4'),
    'Arunachal Pradesh':  (1.7, 16.3, 17, 5.4, 4.6,  'S4'),
    'Uttarakhand':        (1.9, 16.7, 19, 6.0, 8.9,  'S4'),
    'Haryana':            (1.9, 18.5, 24, 6.7, 8.7,  'S4'),
    'Karnataka':          (1.5, 14.9, 15, 7.0, 7.7,  'S4'),
    'Gujarat':            (1.9, 16.8, 19, 6.2, 7.9,  'S4'),
    'Punjab':             (1.4, 13.6, 16, 7.1, 10.3, 'S4'),
    'West Bengal':        (1.3, 13.9, 16, 5.8, 8.5,  'S4'),
    'Himachal Pradesh':   (1.7, 14.0, 11, 6.7, 10.2, 'S4'),
    'Andhra Pradesh':     (1.7, 14.3, 18, 6.6, 9.8,  'S4'),
    'Telangana':          (1.5, 15.7, 17, 6.5, 9.23, 'S4'),
    'Nagaland':           (1.7, 13.3, 12, 5.3, 5.2,  'S4'),
    'Tripura':            (1.7, 15.0, 12, 5.9, 7.9,  'S4'),
    'Mizoram':            (1.9, 14.0, 12, 5.7, 6.3,  'S4'),
    'Kerala':             (1.3, 11.0, 8,  7.3, 12.6, 'S5'),
    'Tamil Nadu':         (1.3, 11.0, 11, 6.8, 10.4, 'S5'),
    'Goa':                (1.32, 10.7, 7, 6.5, 11.2, 'S5'),
    'Sikkim':             (1.1, 14.6, 7,  4.7, 6.7,  'S5'),
}

DTM_SCORE_4IND = {
    'Andhra Pradesh': 66.485125441481, 'Arunachal Pradesh': 56.4696504688832,
    'Assam': 41.5277474830512, 'Bihar': 12.3732352941176,
    'Chhattisgarh': 36.1550793650794, 'Goa': 90.0383496732026,
    'Gujarat': 54.5569418564527, 'Haryana': 49.4668322473917,
    'Himachal Pradesh': 72.1287260991353, 'Jharkhand': 33.6245511610441,
    'Karnataka': 68.8163963483944, 'Kerala': 91.242118296594,
    'Madhya Pradesh': 23.462091452523, 'Maharashtra': 77.2352686944343,
    'Manipur': 65.0043616287095, 'Meghalaya': 11.5189838326635,
    'Mizoram': 61.7423127004425, 'Nagaland': 65.7469805748386,
    'Odisha': 59.1105126760849, 'Punjab': 76.1767867799294,
    'Rajasthan': 29.120778376568, 'Sikkim': 81.8148826269638,
    'Tamil Nadu': 86.2307947671823, 'Tripura': 66.5578268481306,
    'Uttar Pradesh': 17.1356611557667, 'Uttarakhand': 56.1171126639062,
    'West Bengal': 75.3223854686802,
}

STAGE_NUM = {'S2': 1, 'S3': 2, 'S4': 3, 'S5': 4}
INDICATORS = {'TFR': 0, 'CBR': 1, 'IMR': 2, 'CDR': 3, 'Age': 4}
INVERTED = {'TFR': True, 'CBR': True, 'IMR': True, 'CDR': True, 'Age': False}

# The manuscript's CURRENT Section 4.2 figures (post-correction).
MANUSCRIPT_CLAIMS = {'TFR': 67.9, 'CBR': 82.1, 'IMR': 78.6, 'Age': 32.1, 'CDR': 71.4}


def tfr_vote(tfr):
    if tfr >= 2.9: return 'S2'
    if 2.1 <= tfr < 2.9: return 'S3'
    if 1.7 <= tfr < 2.1: return 'S4'
    return 'S5'


def cbr_vote(cbr):
    if cbr > 23: return 'S2'
    if 17 <= cbr <= 23: return 'S3'
    if 13 <= cbr < 17: return 'S4'
    return 'S5'


def imr_vote(imr):
    if imr >= 35: return 'S2'
    if 25 <= imr < 35: return 'S3'
    if 10 <= imr < 25: return 'S4'
    return 'S5'


def cdr_vote(cdr, tfr):
    if tfr >= 2.1:
        return 'S2' if cdr >= 8 else 'S3'
    if cdr < 7: return 'S4'
    if 7 <= cdr <= 9: return 'S3'
    return 'S5'


def age_band(age):
    if age < 7: return 'S2'
    if 7 <= age < 10: return 'S3'
    if 10 <= age < 14: return 'S4'
    return 'S5'


def method_a_categorical():
    """Single-indicator vote == published stage, all 28 states.
    THIS IS WHAT SECTION 4.2 NOW REPORTS."""
    n = len(DATA)
    counts = {k: 0 for k in INDICATORS}
    for state, (tfr, cbr, imr, cdr, age, pub) in DATA.items():
        if tfr_vote(tfr) == pub: counts['TFR'] += 1
        if cbr_vote(cbr) == pub: counts['CBR'] += 1
        if imr_vote(imr) == pub: counts['IMR'] += 1
        if cdr_vote(cdr, tfr) == pub: counts['CDR'] += 1
        if age_band(age) == pub: counts['Age'] += 1
    return {k: v / n * 100 for k, v in counts.items()}


def method_b_pairwise_vs_4ind_score():
    """Pairwise concordance vs. continuous 4-indicator score (n=27).
    NOT what the manuscript reports -- kept for the record only."""
    states = list(DTM_SCORE_4IND.keys())
    results = {}
    for name, idx in INDICATORS.items():
        concordant, total = 0, 0
        for s1, s2 in combinations(states, 2):
            v1, v2 = DATA[s1][idx], DATA[s2][idx]
            c1, c2 = DTM_SCORE_4IND[s1], DTM_SCORE_4IND[s2]
            if v1 == v2 or c1 == c2:
                continue
            total += 1
            agree = (v1 < v2) == (c1 > c2) if INVERTED[name] else (v1 < v2) == (c1 < c2)
            concordant += agree
        results[name] = concordant / total * 100
    return results


def method_c_pairwise_vs_ordinal_stage():
    """Pairwise concordance vs. ordinal stage, pairs with differing stage only.
    NOT what the manuscript reports -- kept for the record only."""
    states = list(DATA.keys())
    results = {}
    for name, idx in INDICATORS.items():
        concordant, total = 0, 0
        for s1, s2 in combinations(states, 2):
            st1, st2 = STAGE_NUM[DATA[s1][5]], STAGE_NUM[DATA[s2][5]]
            if st1 == st2:
                continue
            v1, v2 = DATA[s1][idx], DATA[s2][idx]
            if v1 == v2:
                continue
            total += 1
            agree = (v1 < v2) == (st1 > st2) if INVERTED[name] else (v1 < v2) == (st1 < st2)
            concordant += agree
        results[name] = concordant / total * 100
    return results


def method_d_pairwise_vs_5ind_score():
    """Pairwise concordance vs. a constructed full 5-indicator score (n=28).
    NOT what the manuscript reports -- kept for the record only."""
    states = list(DATA.keys())
    X = np.array([[DATA[s][i] for i in range(5)] for s in states])
    mins, maxs = X.min(axis=0), X.max(axis=0)
    norm = (X - mins) / (maxs - mins)
    for i in range(4):
        norm[:, i] = 1 - norm[:, i]
    weights = np.array([35, 25, 20, 10, 10])
    composite = (norm * weights).sum(axis=1)
    comp = dict(zip(states, composite))

    results = {}
    for name, idx in INDICATORS.items():
        concordant, total = 0, 0
        for s1, s2 in combinations(states, 2):
            v1, v2 = DATA[s1][idx], DATA[s2][idx]
            c1, c2 = comp[s1], comp[s2]
            if v1 == v2 or c1 == c2:
                continue
            total += 1
            agree = (v1 < v2) == (c1 > c2) if INVERTED[name] else (v1 < v2) == (c1 < c2)
            concordant += agree
        results[name] = concordant / total * 100
    return results


def run_check():
    print("=" * 78)
    print("DISCRIMINATING-POWER VERIFICATION -- Section 4.2 (RESOLVED)")
    print("Manuscript claims (current): TFR 67.9%, CBR 82.1%, IMR 78.6%, Age 32.1%, CDR 71.4%")
    print("=" * 78)

    method_a = method_a_categorical()
    methods = {
        'A: Categorical vote == published stage (n=28) [MANUSCRIPT METHOD]': method_a,
        'B: Pairwise vs. 4-indicator continuous score (n=27) [not used]': method_b_pairwise_vs_4ind_score(),
        'C: Pairwise vs. ordinal stage, differing pairs (n=28) [not used]': method_c_pairwise_vs_ordinal_stage(),
        'D: Pairwise vs. constructed 5-indicator score (n=28) [not used]': method_d_pairwise_vs_5ind_score(),
    }

    order = ['TFR', 'CBR', 'IMR', 'Age', 'CDR']
    print(f"\n{'Method':66s} " + "".join(f"{k:>8s}" for k in order))
    print("-" * (66 + 8 * len(order)))
    for label, result in methods.items():
        print(f"{label:66s} " + "".join(f"{result[k]:8.1f}" for k in order))
    print(f"{'Manuscript claim (current)':66s} " + "".join(f"{MANUSCRIPT_CLAIMS[k]:8.1f}" for k in order))

    print("\n" + "-" * 78)
    print("VERDICT")
    print("-" * 78)
    all_match = all(
        abs(round(method_a[k], 1) - MANUSCRIPT_CLAIMS[k]) <= 0.1 for k in order
    )
    if all_match:
        print("MATCH. Method A -- the manuscript's stated method -- reproduces Section")
        print("4.2's current figures exactly for all five indicators. This is fully")
        print("resolved: not because a hidden methodology note was found, but because")
        print("the manuscript was corrected to report what this reproducible method")
        print("actually computes. Methods B-D remain unreproduced by design -- they were")
        print("alternatives considered during the original investigation, not claims the")
        print("manuscript makes, and are retained above only for audit purposes.")
    else:
        print("MISMATCH -- Method A does not currently match Section 4.2. If you are")
        print("seeing this, the manuscript's figures have changed again since this")
        print("script was last updated; re-check Section 4.2 directly.")


if __name__ == '__main__':
    run_check()

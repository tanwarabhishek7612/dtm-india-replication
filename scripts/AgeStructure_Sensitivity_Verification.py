"""
Age-Structure Sensitivity Verification
Supplementary working file for: "One Country, Multiple Transitions:
A Composite Demographic Transition Classification of Indian States"

Purpose
-------
Verifies the claim in manuscript footnote 1 (Section 5.7): that shifting
the age-structure classification of the four states named as most exposed
to the 2011-vs-2024 Census staleness problem -- Kerala, Tamil Nadu,
Andhra Pradesh, and Telangana -- up one age-structure band (simulating
understated population ageing in the stale 2011 data) does not change
any of their composite DTM stage classifications.

This replaces an earlier draft of the footnote, which described a
sensitivity test on a different set of states (Haryana, Manipur,
Uttarakhand) that was not actually a test of the claim the footnote was
making. This script runs the correct test, on the four states the
footnote itself identifies as most exposed.

Method
------
Independently reimplements the exact scoring rules from Supplementary
Table S1 ('Per-State Scoring' sheet, live formulas) in Python: each of
the five indicators (TFR, CBR, IMR, CDR, age structure) casts a
35/25/20/10/10-weighted vote for a DTM stage based on fixed thresholds;
the stage with the highest weighted total wins. The engine is first
validated against all 28 published Table 2 stages, then age structure's
vote is shifted up one band for the four target states only, holding
TFR, CBR, IMR, and CDR fixed at their reported values.

Requirements: none (pure Python)

Run:
    python AgeStructure_Sensitivity_Verification.py
"""

# ---------------------------------------------------------------------------
# Raw indicator data for all 28 states (TFR, CBR, IMR, CDR, Age 60+ %),
# plus the published Table 2 stage, for validating the scoring engine.
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

# The four states footnote 1 identifies as most exposed to stale
# 2011-vs-2024 age-structure data.
TARGET_STATES = ['Kerala', 'Tamil Nadu', 'Andhra Pradesh', 'Telangana']

WEIGHTS = {'TFR': 35, 'CBR': 25, 'IMR': 20, 'CDR': 10, 'Age': 10}


def tfr_vote(tfr):
    if tfr >= 2.9:
        return 'S2'
    if 2.1 <= tfr < 2.9:
        return 'S3'
    if 1.7 <= tfr < 2.1:
        return 'S4'
    return 'S5'


def cbr_vote(cbr):
    if cbr > 23:
        return 'S2'
    if 17 <= cbr <= 23:
        return 'S3'
    if 13 <= cbr < 17:
        return 'S4'
    return 'S5'


def imr_vote(imr):
    if imr >= 35:
        return 'S2'
    if 25 <= imr < 35:
        return 'S3'
    if 10 <= imr < 25:
        return 'S4'
    return 'S5'


def cdr_vote(cdr, tfr):
    if tfr >= 2.1:
        return 'S2' if cdr >= 8 else 'S3'
    else:
        if cdr < 7:
            return 'S4'
        if 7 <= cdr <= 9:
            return 'S3'
        return 'S5'


def age_band(age):
    if age < 7:
        return 'S2'
    if 7 <= age < 10:
        return 'S3'
    if 10 <= age < 14:
        return 'S4'
    return 'S5'


NEXT_BAND = {'S2': 'S3', 'S3': 'S4', 'S4': 'S5', 'S5': 'S5'}


def score(tfr, cbr, imr, cdr, age_vote_override):
    votes = {
        'TFR': tfr_vote(tfr),
        'CBR': cbr_vote(cbr),
        'IMR': imr_vote(imr),
        'CDR': cdr_vote(cdr, tfr),
        'Age': age_vote_override,
    }
    totals = {'S2': 0, 'S3': 0, 'S4': 0, 'S5': 0}
    for ind, v in votes.items():
        totals[v] += WEIGHTS[ind]
    winner = max(totals, key=totals.get)
    return winner, totals


def run_validation():
    print("=" * 78)
    print("STEP 1 -- VALIDATE SCORING ENGINE AGAINST ALL 28 PUBLISHED STAGES")
    print("=" * 78)
    mismatches = []
    for state, (tfr, cbr, imr, cdr, age, published) in DATA.items():
        computed, _ = score(tfr, cbr, imr, cdr, age_band(age))
        if computed != published:
            mismatches.append((state, computed, published))
    if not mismatches:
        print("All 28 states: computed stage == published Table 2 stage. Engine trusted.\n")
    else:
        print(f"WARNING: {len(mismatches)} mismatch(es) found -- engine NOT trusted:")
        for m in mismatches:
            print(" ", m)
        print()
    return len(mismatches) == 0


def run_sensitivity():
    print("=" * 78)
    print("STEP 2 -- SENSITIVITY TEST: shift age-structure band up one tier")
    print("for Kerala, Tamil Nadu, Andhra Pradesh, Telangana")
    print("=" * 78)
    any_change = False
    for state in TARGET_STATES:
        tfr, cbr, imr, cdr, age, published = DATA[state]
        band0 = age_band(age)
        band1 = NEXT_BAND[band0]
        w0, t0 = score(tfr, cbr, imr, cdr, band0)
        w1, t1 = score(tfr, cbr, imr, cdr, band1)
        changed = w1 != w0
        any_change = any_change or changed
        print(f"\n{state} (age={age}%, band={band0}->{band1}, published={published})")
        print(f"  Baseline (age->{band0}): composite = {w0}   totals = {t0}")
        print(f"  Shifted  (age->{band1}): composite = {w1}   totals = {t1}")
        print(f"  {'RECLASSIFIED' if changed else 'No reclassification'}")

    print("\n" + "-" * 78)
    print("VERDICT")
    print("-" * 78)
    if not any_change:
        print("None of the four states reclassify when their age-structure band is")
        print("shifted up one tier. This confirms footnote 1's claim: even if the")
        print("stale 2011 Census data understates current ageing in these states,")
        print("age structure's 10% weight is too small on its own to move any of")
        print("them to a different composite stage; TFR, CBR, IMR, and CDR remain")
        print("the decisive signals.")
    else:
        print("At least one state reclassifies under the shifted age-structure band")
        print("-- footnote 1's claim would need revision.")


if __name__ == '__main__':
    ok = run_validation()
    run_sensitivity()

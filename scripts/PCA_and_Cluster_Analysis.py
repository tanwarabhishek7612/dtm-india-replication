"""
PCA and Ward's-Linkage Cluster Analysis
Supplementary code for: "One Country, Multiple Transitions:
A Composite Demographic Transition Classification of Indian States"

Reproduces the results reported in Section 6.1 (Principal Components Analysis)
and Section 5.6 (Hierarchical Cluster Analysis) of the manuscript.

Requirements: numpy, scikit-learn (>=1.0), scipy (>=1.7)
    pip install numpy scikit-learn scipy

Input: raw state-level indicator values for TFR, CBR, IMR, CDR, and Age
structure (% aged 60+), for all 28 Indian states classified in this study.
These are the same values published in Supplementary Table S1
('Per-State Scoring' sheet, columns B-F).

Run:
    python PCA_and_Cluster_Analysis.py
"""

import numpy as np
from sklearn.decomposition import PCA
from scipy.cluster.hierarchy import linkage, fcluster
from scipy.spatial.distance import pdist, squareform

# ---------------------------------------------------------------------------
# 1. Raw indicator data (28 states): TFR, CBR, CDR is per 1,000; IMR per
#    1,000 live births; Age = % of population aged 60 years and above.
#    Source: NFHS-5 (2019-21) and SRS (2024) — see Section 4.1 of the
#    manuscript and Supplementary Table S1 for full sourcing.
# ---------------------------------------------------------------------------
raw_data = {
    'Bihar':              (2.9, 26.8, 23, 5.9, 7.4),
    'Uttar Pradesh':       (2.6, 23.5, 35, 6.3, 7.7),
    'Meghalaya':           (2.9, 22.1, 31, 5.4, 4.7),
    'Madhya Pradesh':      (2.4, 22.5, 35, 6.7, 7.9),
    'Rajasthan':           (2.3, 22.8, 28, 5.8, 7.5),
    'Chhattisgarh':        (1.8, 22.2, 36, 8.4, 7.8),
    'Jharkhand':           (2.2, 21.5, 27, 6.2, 7.1),
    'Assam':               (1.9, 19.6, 29, 6.1, 6.7),
    'Odisha':              (1.6, 15.8, 28, 7.9, 9.5),
    'Arunachal Pradesh':   (1.7, 16.3, 17, 5.4, 4.6),
    'Uttarakhand':         (1.9, 16.7, 19, 6.0, 8.9),
    'Haryana':             (1.9, 18.5, 24, 6.7, 8.7),
    'Manipur':             (2.2, 12.7, 2,  4.4, 7.0),
    'Maharashtra':         (1.4, 13.8, 13, 6.0, 9.9),
    'Karnataka':           (1.5, 14.9, 15, 7.0, 7.7),
    'Gujarat':             (1.9, 16.8, 19, 6.2, 7.9),
    'Punjab':              (1.4, 13.6, 16, 7.1, 10.3),
    'West Bengal':         (1.3, 13.9, 16, 5.8, 8.5),
    'Himachal Pradesh':    (1.7, 14.0, 11, 6.7, 10.2),
    'Andhra Pradesh':      (1.7, 14.3, 18, 6.6, 9.8),
    'Telangana':           (1.5, 15.7, 17, 6.5, 9.23),
    'Nagaland':            (1.7, 13.3, 12, 5.3, 5.2),
    'Tripura':             (1.7, 15.0, 12, 5.9, 7.9),
    'Mizoram':             (1.9, 14.0, 12, 5.7, 6.3),
    'Kerala':              (1.3, 11.0, 8,  7.3, 12.6),
    'Tamil Nadu':          (1.3, 11.0, 11, 6.8, 10.4),
    'Goa':                 (1.32, 10.7, 7, 6.5, 11.2),
    'Sikkim':              (1.1, 14.6, 7,  4.7, 6.7),
}

states = list(raw_data.keys())
X = np.array([raw_data[s] for s in states])          # shape (28, 5)
indicator_names = ['TFR', 'CBR', 'IMR', 'CDR', 'Age structure (60+)']


def run_pca(X, labels):
    """Section 6.1: PCA on standardised (z-scored) indicators."""
    print("=" * 70)
    print("PRINCIPAL COMPONENTS ANALYSIS (Section 6.1)")
    print("=" * 70)

    # Standardise: PCA is run on the correlation matrix (z-scored inputs),
    # consistent with Nardo et al. (2005) composite-indicator practice.
    Xz = (X - X.mean(axis=0)) / X.std(axis=0, ddof=1)

    pca = PCA()
    pca.fit(Xz)

    var_pct = pca.explained_variance_ratio_ * 100
    eigenvalues = pca.explained_variance_
    loadings = pca.components_.T  # rows = indicators, cols = components

    print(f"\nFirst component:  {var_pct[0]:.1f}% of variance "
          f"(eigenvalue = {eigenvalues[0]:.2f})")
    print(f"Second component: {var_pct[1]:.1f}% of variance "
          f"(eigenvalue = {eigenvalues[1]:.2f})")

    print("\nLoadings on PC1 / PC2:")
    for name, row in zip(labels, loadings):
        l1, l2 = row[0], row[1]
        print(f"  {name:22s}  PC1={l1:+.3f}   PC2={l2:+.3f}")

    return pca, loadings


def run_clustering(X, labels):
    """Section 5.6: Ward's-linkage hierarchical clustering on
    min-max normalised indicators."""
    print("\n" + "=" * 70)
    print("WARD'S-LINKAGE HIERARCHICAL CLUSTER ANALYSIS (Section 5.6)")
    print("=" * 70)

    Xmm = (X - X.min(axis=0)) / (X.max(axis=0) - X.min(axis=0))

    Z = linkage(Xmm, method='ward')

    for k in (3, 4, 5):
        clusters = fcluster(Z, k, criterion='maxclust')
        groups = {}
        for state, c in zip(labels, clusters):
            groups.setdefault(c, []).append(state)
        print(f"\n-- k={k} clusters --")
        for c, members in groups.items():
            print(f"  Cluster {c}: {members}")

    # Intra-group distance check for the Nagaland / Mizoram / Sikkim grouping
    Xmm_named = dict(zip(labels, Xmm))
    D_full = squareform(pdist(Xmm))
    idx = {s: i for i, s in enumerate(labels)}

    target = ['Nagaland', 'Mizoram', 'Sikkim']
    pairs = [(a, b) for i, a in enumerate(target) for b in target[i + 1:]]
    within = np.mean([D_full[idx[a], idx[b]] for a, b in pairs])
    overall_euclidean = np.mean(pdist(Xmm))
    overall_manhattan = np.mean(pdist(Xmm, metric='cityblock'))
    within_manhattan = np.mean(
        [squareform(pdist(Xmm, metric='cityblock'))[idx[a], idx[b]] for a, b in pairs]
    )

    print(f"\nMean pairwise distance, Nagaland/Mizoram/Sikkim "
          f"(Euclidean): {within:.4f}")
    print(f"Mean pairwise distance, all 28 states (Euclidean): "
          f"{overall_euclidean:.4f}")
    print(f"  -> {(1 - within / overall_euclidean) * 100:.1f}% lower "
          f"than sample average (Euclidean)")
    print(f"  -> {(1 - within_manhattan / overall_manhattan) * 100:.1f}% "
          f"lower than sample average (Manhattan)")

    return Z


if __name__ == '__main__':
    run_pca(X, indicator_names)
    run_clustering(X, states)

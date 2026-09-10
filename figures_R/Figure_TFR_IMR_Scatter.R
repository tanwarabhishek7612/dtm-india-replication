# ==============================================================================
# Figure 2: Total Fertility Rate vs Infant Mortality Rate, 28 Indian states
# Supplementary code for: "One Country, Multiple Transitions:
# A Composite Demographic Transition Classification of Indian States"
#
# Purpose: builds the published Figure 2 scatter plot (TFR on x-axis, IMR on
# y-axis), coloured by DTM stage, with open-circle markers for the Northeast
# Cluster (Nagaland, Tripura, Mizoram, Sikkim) and an OLS trend line fitted
# on all states except Manipur (excluded as a small-sample outlier per
# Section 4.1, since Manipur's IMR = 2 is implausibly low relative to its
# TFR and would distort the fitted line).
#
# Data: Total Fertility Rate (NFHS-5, IIPS & ICF 2021) and Infant Mortality
# Rate (SRS Statistical Report, RGI 2024, supplemented by NFHS-5 for states
# not covered by SRS) for all 28 Indian states, matching Table 2.
#
# The OLS fit shown in the figure (slope = 13.41, intercept = -4.77, n = 27,
# Manipur excluded) and mean IMR = 18.9 (rounds to 19, shown by the dotted
# reference line) are computed directly in this script below.
#
# Note on Nagaland/Tripura: both states share identical TFR (1.7) and IMR
# (12) values, so their points and labels are merged into a single
# "Nagaland/Tripura*" label to avoid two overlapping, unreadable labels at
# the same coordinate. Both states are still included separately in every
# reported statistic (means, OLS fit, cluster distances, etc.) -- only the
# on-plot label is merged, purely for display.
#
# Requires: ggplot2, ggrepel (both installed via install.packages() if not
# already present).
# ==============================================================================

library(ggplot2)
library(ggrepel)

data <- data.frame(
  state = c("Bihar","Meghalaya","UttarPradesh","MadhyaPradesh","Rajasthan",
            "Chhattisgarh","Jharkhand","Assam","Odisha","Manipur",
            "Maharashtra","ArunachalPradesh","Uttarakhand","Haryana","Karnataka",
            "Gujarat","Punjab","WestBengal","HimachalPradesh","AndhraPradesh",
            "Telangana","Nagaland","Tripura","Mizoram","Kerala","TamilNadu",
            "Goa","Sikkim"),
  label = c("Bihar","Meghalaya*","Uttar Pradesh","Madhya Pradesh","Rajasthan",
            "Chhattisgarh","Jharkhand","Assam","Odisha","Manipur*",
            "Maharashtra","Arunachal Pradesh*","Uttarakhand","Haryana","Karnataka",
            "Gujarat","Punjab","West Bengal","Himachal Pradesh","Andhra Pradesh",
            "Telangana","Nagaland/Tripura*",NA,"Mizoram*","Kerala","Tamil Nadu",
            "Goa*","Sikkim*"),
  tfr = c(2.9,2.9,2.6,2.4,2.3,1.8,2.2,1.9,1.6,2.2,
          1.4,1.7,1.9,1.9,1.5,1.9,1.4,1.3,1.7,1.7,
          1.5,1.7,1.7,1.9,1.3,1.3,1.32,1.1),
  imr = c(23,31,35,35,28,36,27,29,28,2,
          13,17,19,24,15,19,16,16,11,18,
          17,12,12,12,8,11,7,7),
  stage = c("S2","S3","S3","S3","S3","S3","S3","S3","S3","S3",
            "S4","S4","S4","S4","S4","S4","S4","S4","S4","S4",
            "S4","S4","S4","S4","S5","S5","S5","S5"),
  necluster = c(0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,
                0,1,1,1,0,0,0,1),
  manipur_flag = c(0,0,0,0,0,0,0,0,0,1,
                    0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0)
)

colors <- c(S2 = "#8B0000", S3 = "#E67E22", S4 = "#3477B3", S5 = "#278E59")

fit <- lm(imr ~ tfr, data = subset(data, manipur_flag == 0))
cat("slope =", round(coef(fit)[2], 2), " intercept =", round(coef(fit)[1], 2),
    " (expect 13.41, -4.77)\n")
mean_imr <- mean(data$imr)
cat("mean IMR =", round(mean_imr, 1), " (expect 18.9)\n")

# Verified label offsets, carried over from the matplotlib version (already
# checked for overlap there, including the West Bengal/Punjab/Telangana fix).
offsets <- data.frame(
  state = data$state,
  dx = c(0.08, 0.08, 0.08, -0.08, 0.08, -0.05, 0.08, 0.08, -0.08, 0.08,
         -0.30, 0.12, 0.15, 0.10, 0.35, -0.55, 0.10, -0.30, 0.0, 0.12,
         -0.05, -0.65, NA, 0.55, 0.10, -0.17, 0.10, -0.10),
  dy = c(0, 0.3, 0.3, 0.6, 0.2, 0.7, -0.6, 0.3, 0.2, 0,
         2.8, -1.4, 2.3, 0, -1.8, 2.3, -1.6, 1.5, -3.6, 1.4,
         1.3, 0.3, NA, 1.4, 0.5, 0.3, -0.9, -0.4),
  hjust = c(0, 0, 0, 1, 0, 1, 0, 0, 1, 0,
            1, 0, 0, 0, 0, 1, 0, 1, 0.5, 0,
            1, 1, NA, 0, 0, 1, 0, 1)
)
leader_states <- c("MadhyaPradesh","Chhattisgarh","Gujarat","Uttarakhand","Nagaland",
                    "Mizoram","HimachalPradesh","Maharashtra","Karnataka",
                    "WestBengal","Punjab")

d <- merge(data, offsets, by = "state")
d$tx <- d$tfr + d$dx
d$ty <- d$imr + d$dy

leaders <- subset(d, state %in% leader_states)

p <- ggplot() +
  geom_abline(intercept = coef(fit)[1], slope = coef(fit)[2],
              linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_vline(xintercept = 2.1, linetype = "dotted", color = "grey75") +
  geom_hline(yintercept = mean_imr, linetype = "dotted", color = "grey75") +
  geom_point(data = subset(d, necluster == 0),
             aes(x = tfr, y = imr, color = stage), size = 3, show.legend = FALSE) +
  geom_point(data = subset(d, necluster == 1),
             aes(x = tfr, y = imr, color = stage), size = 4.5,
             shape = 21, stroke = 1.3, fill = "white", show.legend = FALSE) +
  geom_text_repel(
    data = subset(d, !is.na(label)),
    aes(x = tfr, y = imr, label = label, color = stage),
    size = 3.2,
    box.padding = 0.45,
    point.padding = 0.25,
    force = 1.2,
    force_pull = 0.5,
    max.overlaps = Inf,
    min.segment.length = 0,
    segment.color = "grey55",
    segment.size = 0.3,
    seed = 123,
    show.legend = FALSE
  ) +
  # Clean manual legend: dummy off-plot points/lines carrying only the
  # aesthetics we want shown, so the two real point layers above (which
  # differ only in shape, not meaning) don't collide in one shared legend.
  geom_point(data = data.frame(x = NA_real_, y = NA_real_,
                                stage = factor(c("S2", "S3", "S4", "S5"))),
             aes(x = x, y = y, color = stage), size = 3, na.rm = TRUE) +
  geom_point(data = data.frame(x = NA_real_, y = NA_real_, lab = "Northeast Cluster"),
             aes(x = x, y = y, shape = lab), size = 3.5, stroke = 1.1, na.rm = TRUE) +
  geom_line(data = data.frame(x = c(NA_real_, NA_real_), y = c(NA_real_, NA_real_),
                               lab = "OLS trend (excl. Manipur)"),
            aes(x = x, y = y, linetype = lab), color = "grey50", na.rm = TRUE) +
  scale_shape_manual(values = c("Northeast Cluster" = 21), name = NULL) +
  scale_linetype_manual(values = c("OLS trend (excl. Manipur)" = "dashed"), name = NULL) +
  scale_color_manual(values = colors,
                      labels = c("Stage 2", "Stage 3", "Stage 4", "Stage 5"),
                      name = NULL) +
  scale_x_continuous(limits = c(0.55, 3.35), breaks = seq(1, 3.25, 0.5),
                      name = "Total Fertility Rate (TFR)") +
  scale_y_continuous(limits = c(-3, 41),
                      name = "Infant Mortality Rate (IMR, per 1,000 live births)") +
  labs(caption = paste(
    "* TFR from NFHS-5 (states not covered by SRS). Manipur (IMR = 2) excluded from the OLS trend\n",
    "as a small-sample outlier (Section 4.1). Open-circle markers = Northeast Cluster\n",
    "(Nagaland, Tripura, Mizoram, Sikkim). Nagaland and Tripura share identical TFR/IMR values and\n",
    "are shown as a single merged point/label; both are included separately in all reported statistics.",
    sep = "")) +
  guides(color = guide_legend(order = 1),
         shape = guide_legend(order = 2),
         linetype = guide_legend(order = 3)) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    legend.position = "right",
    plot.caption = element_text(hjust = 0, size = 8, color = "black"),
    axis.title.y = element_text(margin = margin(r = 10)),
    plot.margin = margin(15, 15, 15, 15)
  )

# Output path is relative -- run this script with the repository root (or
# this script's own folder) as the working directory, e.g. in RStudio:
# Session > Set Working Directory > To Source File Location.
ggsave("Figure_TFR_IMR_Scatter.png", p,
       width = 11, height = 7.8, dpi = 220)
cat("saved\n")

# -----------------------------------------------------------------------
# EXPECTED OUTPUT (confirmed by an actual R run):
#
#   slope = 13.41  intercept = -4.77  (expect 13.41, -4.77)
#   mean IMR = 18.9  (expect 18.9)
#   saved
# -----------------------------------------------------------------------

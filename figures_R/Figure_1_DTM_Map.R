# ==============================================================================
# Figure 1: Composite DTM Stage Classification, 28 Indian states (choropleth)
# Supplementary code for: "One Country, Multiple Transitions:
# A Composite Demographic Transition Classification of Indian States"
#
# This version reproduces the manuscript figure exactly:
#   - All 28 classified states shown in their DTM stage colour
#   - Jammu & Kashmir / Ladakh / other UTs shown in grey ("Not classified")
#   - Every state labelled by name
#   - Nagaland, Tripura, Mizoram, Sikkim labels in BOLD (Northeast Cluster)
#   - Small states (Meghalaya, Manipur, Goa, Nagaland, Tripura, Mizoram)
#     get leader-line labels so the text doesn't overlap their tiny shapes
#   - High-resolution, crisp (non-blurry) text via the cairo PNG device
#
# Requires: sf, ggplot2, dplyr
# ==============================================================================

library(sf)
library(ggplot2)
library(dplyr)

# Use the classic (GEOS) geometry engine instead of the newer spherical (s2)
# engine. s2 is strict about tiny topology glitches (duplicate vertices,
# etc.) that are common in public boundary files; GEOS tolerates them.
sf_use_s2(FALSE)

# ---- 1. Boundary file -------------------------------------------------------
SHAPEFILE_PATH <- "india_states_2019.geojson"   # <-- update this path if needed
india_states <- st_read(SHAPEFILE_PATH, quiet = TRUE) %>%
  st_make_valid()   # repairs any invalid/self-intersecting geometry

# ---- 2. Composite DTM stage classification, from Table 2 (28 states) -------
dtm <- data.frame(
  state_label = c("Bihar","Uttar Pradesh","Meghalaya","Madhya Pradesh","Rajasthan",
                  "Chhattisgarh","Jharkhand","Assam","Odisha","Manipur",
                  "Maharashtra","Arunachal Pradesh","Uttarakhand","Haryana","Karnataka",
                  "Gujarat","Punjab","West Bengal","Himachal Pradesh","Andhra Pradesh",
                  "Telangana","Nagaland","Tripura","Mizoram","Kerala","Tamil Nadu",
                  "Goa","Sikkim"),
  stage = c("S2","S3","S3","S3","S3","S3","S3","S3","S3","S3",
            "S4","S4","S4","S4","S4","S4","S4","S4","S4","S4",
            "S4","S4","S4","S4","S5","S5","S5","S5")
)

# States whose labels should render in BOLD (the paper's "Northeast Cluster")
ne_cluster <- c("Nagaland", "Tripura", "Mizoram", "Sikkim")

# ---- 3. Match state names between the boundary file and dtm$state_label ----
name_fixes <- c(
  "Orissa" = "Odisha",
  "Uttaranchal" = "Uttarakhand",
  "Pondicherry" = "Puducherry"
)
india_states <- india_states %>%
  mutate(state_label = recode(ST_NM, !!!name_fixes, .default = ST_NM))

map_data <- india_states %>%
  left_join(dtm, by = "state_label") %>%
  mutate(stage = ifelse(is.na(stage), "Unclassified", stage))

cat("Total features plotted:", nrow(map_data), "\n")
cat("States matched to a DTM stage:", sum(map_data$stage != "Unclassified"), "\n")

# ---- 4. Colour palette ------------------------------------------------------
colors <- c(S2 = "#8B0000", S3 = "#E67E22", S4 = "#3477B3", S5 = "#278E59",
            Unclassified = "grey80")

# ---- 5. Build one label point per state (dissolve multi-part states first) -
# Some states are split into several map fragments (islands/exclaves) in the
# boundary file; dissolve them into a single shape per state before finding
# a label point, so the label lands in a sensible spot rather than on a
# stray sliver.
state_shapes <- map_data %>%
  filter(stage != "Unclassified") %>%
  group_by(state_label) %>%
  summarise(.groups = "drop")

# st_point_on_surface guarantees the point falls inside the polygon
# (unlike a centroid, which can fall outside for oddly-shaped states)
label_pts_sf <- st_point_on_surface(state_shapes)
label_coords <- st_coordinates(label_pts_sf)

label_points <- state_shapes %>%
  st_drop_geometry() %>%
  mutate(
    lon = label_coords[, "X"],
    lat = label_coords[, "Y"],
    is_ne = state_label %in% ne_cluster
  )

# The Northeast is a tight cluster of small states, so automatic label
# placement tends to tangle arrows and overlap text there. Instead we give
# those labels fixed, hand-tuned offsets (in degrees) from each state's
# point, and draw the leader line explicitly. hjust points the text away
# from the arrow (0 = text grows rightward from the point, 1 = text ends
# at the point, growing leftward).
leader_offsets <- data.frame(
  state_label = c("Meghalaya", "Nagaland", "Manipur", "Tripura", "Mizoram", "Goa"),
  dx          = c( 1.6,         1.7,         1.7,       -1.3,      -0.6,     -0.7),
  dy          = c( 0.9,         0.7,        -0.3,        0.2,      -1.0,      0.0),
  hjust       = c( 0,           0,           0,           1,         1,        1)
)

# Assam and Sikkim just need a small nudge (no arrow) to clear the extra
# space now used by the repositioned Meghalaya/Nagaland labels above.
nudge_offsets <- data.frame(
  state_label = c("Assam", "Sikkim"),
  dx          = c(-1.0,      0.0),
  dy          = c( 0.5,      0.7)
)

leader_states <- leader_offsets$state_label

label_points <- label_points %>%
  left_join(leader_offsets, by = "state_label") %>%
  left_join(nudge_offsets, by = "state_label", suffix = c("", "_n")) %>%
  mutate(
    dx = coalesce(dx, dx_n, 0),
    dy = coalesce(dy, dy_n, 0),
    hjust = ifelse(is.na(hjust), 0.5, hjust),
    label_lon = lon + dx,
    label_lat = lat + dy
  )

leader_labels <- label_points %>% filter(state_label %in% leader_states)
direct_labels <- label_points %>% filter(!state_label %in% leader_states)

# ---- 6. Build the map -------------------------------------------------------
p <- ggplot(map_data) +
  geom_sf(aes(fill = stage), color = "white", linewidth = 0.2) +
  scale_fill_manual(
    values = colors,
    labels = c("Stage 2", "Stage 3", "Stage 4", "Stage 5", "Not classified (UT / no data)"),
    name = "Composite DTM"
  ) +
  # Thin leader lines from each small state to its offset label
  geom_segment(
    data = leader_labels,
    aes(x = lon, y = lat, xend = label_lon, yend = label_lat),
    color = "black", linewidth = 0.3
  ) +
  # State names that fit directly on their own polygon (plus Assam/Sikkim,
  # which get a small nudge but no visible arrow)
  geom_text(
    data = direct_labels,
    aes(x = label_lon, y = label_lat, label = state_label,
        fontface = ifelse(is_ne, "bold", "plain")),
    size = 3.1, color = "black"
  ) +
  # Small states: label pulled off to the side, aligned away from its arrow
  geom_text(
    data = leader_labels,
    aes(x = label_lon, y = label_lat, label = state_label,
        fontface = ifelse(is_ne, "bold", "plain"), hjust = hjust),
    size = 3.1, color = "black"
  ) +
  labs(caption = "Bold labels = Northeast Cluster (Nagaland, Mizoram, Tripura, Sikkim).") +
  theme_void(base_size = 12) +
  theme(
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0.5, size = 10, face = "italic", color = "black"),
    plot.margin = margin(10, 10, 10, 10),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

# ---- 7. Save at high resolution with crisp (non-blurry) text ---------------
# The "cairo" PNG type produces much sharper anti-aliased text than the
# default Windows PNG device, which is usually why exported text looks blurry.
ggsave(
  "Figure_1_DTM_Map.png", p,
  width = 11, height = 9.5, dpi = 320,
  type = "cairo"
)
cat("saved\n")

# Load required packages
if (!requireNamespace("circlize", quietly = TRUE)) {
  install.packages("circlize")
}
library(circlize)
library(readxl)
library(tidyverse)

# --------------------------------------------------------------
# 1. Data Loading and Preprocessing
# --------------------------------------------------------------

# Load the dataset
data <- read_excel("W.xlsx")

# Remove unnecessary columns (adjust as needed)
d1 <- data[, -c(2, 3)]

# Transform data for chord diagram
links <- d1 %>%
  pivot_longer(cols = 2:5, names_to = "from", values_to = "value") %>%
  filter(value == 1) %>%
  select(from, to = Gene, value)

# Filter attendance data (adjust as needed)
attendance <- data[, -c(4, 5, 6, 7)]

# --------------------------------------------------------------
# 2. Dynamic Gap and Sector Calculation
# --------------------------------------------------------------

# Calculate unique sectors based on 'from' and 'to' columns
sectors <- unique(c(links$from, links$to))  # Unique sectors from links

# Define dynamic gap degrees for the chord diagram
gap.degree <- c(rep(2, length(sectors) - 1), 10)  # Small gaps between sectors, larger gap for heatmap

# --------------------------------------------------------------
# 2.1 Color Assignments for Sectors
# --------------------------------------------------------------

# Assign custom colors to sectors based on gene names
sector_colors <- setNames(c(
  "#1E90FF",  # Dodger blue for HY5
  "#000000",  # Near black for WRKY33
  "#FF4500",  # Orange red for PIF
  "#32CD32",  # Lime green for CRY
  colorRampPalette(c("#FFD700", "#FF69B4", "#00FA9A", "#BA55D3", "#FF6347"))(length(sectors) - 4)  # Custom bright palette for others
), sectors)

# --------------------------------------------------------------
# 3. Circos Plot Setup
# --------------------------------------------------------------

# Clear any existing plots
circos.clear()

# Set circos parameters
circos.par(
  start.degree = 90,
  gap.degree = gap.degree,  # Adjust gap dynamically
  track.margin = c(0.01, 0.01)  # Set track margins
)

# Save the plot to a high-resolution PNG file
png("circos_plot_with_heatmap_final.png", width = 4000, height = 4000, res = 150)

# --------------------------------------------------------------
# 4. Create Chord Diagram
# --------------------------------------------------------------

# Clear any existing circos plots before starting a new one
circos.clear()

# Set circos parameters with reduced gaps and margins for clarity
circos.par(
  start.degree = 90,
  gap.degree = c(rep(2, length(sectors) - 1), 8),  # Adjusted gap for heatmap separation
  track.margin = c(0.003, 0.005)  # Further reduced margins for better space utilization
)

# Create the chord diagram with links
chordDiagram(
  x = links,
  directional = FALSE,
  annotationTrack = c("grid"),
  grid.col = sector_colors,  # Apply the color mapping
  preAllocateTracks = list(
    list(track.height = 0.1),  # Adjust height for sector labels
    list(track.height = 0.2)    # Adjust heatmap height
  ),
  transparency = 0.5
)

# --------------------------------------------------------------
# 5. Add Sector Labels
# --------------------------------------------------------------

# Adjust sector labels to be closer to the chord diagram with a larger font size
circos.trackPlotRegion(
  track.index = 1,
  panel.fun = function(x, y) {
    circos.text(
      CELL_META$xcenter, CELL_META$ylim[1] + 0.01, CELL_META$sector.index,
      facing = "clockwise",
      niceFacing = TRUE, adj = c(0, 0.5), cex = 2  # Adjusted label size for clarity
    )
  },
  bg.border = NA
)

# --------------------------------------------------------------
# 6. Scaling Function for Heatmap Values
# --------------------------------------------------------------

# Function to scale data from a fixed range (-3 to 4.5) to a new range (-1 to 1)
scale_to_range_fixed <- function(x, min_fixed = -3, max_fixed = 4.5, min_new = -1, max_new = 1) {
  scaled_fixed <- (x - min_fixed) / (max_fixed - min_fixed)
  scaled_fixed * (max_new - min_new) + min_new
}

# Apply the scaling function to Day8 and Day18 attendance data
attendance[, c("Day8", "Day18")] <- apply(
  attendance[, c("Day8", "Day18")], 
  2, 
  scale_to_range_fixed
)

# --------------------------------------------------------------
# 7. Heatmap Color Mapping
# --------------------------------------------------------------

# Define the color palette for heatmap values
heatmap_palette <- colorRampPalette(c("blue", "white", "red"))(100)

# Function to map scaled values to color palette
map_to_colors <- function(value, palette, min_value = -1, max_value = 1) {
  scaled_index <- round((value - min_value) / (max_value - min_value) * (length(palette) - 1)) + 1
  palette[scaled_index]
}

# --------------------------------------------------------------
# 8. Add Heatmap to Chord Diagram
# --------------------------------------------------------------

circos.trackPlotRegion(
  ylim = c(-1, 1),
  track.index = 2,
  panel.fun = function(x, y) {
    gene = CELL_META$sector.index
    if (gene %in% attendance$Gene) {
      idx <- which(attendance$Gene == gene)
      attendance_day8 <- map_to_colors(attendance$Day8[idx], heatmap_palette)
      attendance_day18 <- map_to_colors(attendance$Day18[idx], heatmap_palette)
      
      # Draw heatmap boxes for Day 8 and Day 18
      circos.rect(CELL_META$xlim[1], 0.2, CELL_META$xlim[2], 0.6, col = attendance_day8, border = "black")
      circos.rect(CELL_META$xlim[1], -0.2, CELL_META$xlim[2], -0.6, col = attendance_day18, border = "black")
    }
  },
  bg.border = NA
)

# --------------------------------------------------------------
# 9. Add Day 8 and Day 18 Labels
# --------------------------------------------------------------

# Labels for Day 8 and Day 18 heatmap sections
circos.text(
  x = -1.0, y = 0.8, labels = "Day 8", cex = 2
)
circos.text(
  x = -1.0, y = -0.8, labels = "Day 18", cex = 2
)

# --------------------------------------------------------------
# 10. Add Legend for Heatmap Values
# --------------------------------------------------------------

# Create a horizontal legend for heatmap values
legend(
  "topleft",
  legend = seq(-1, 1, by = 0.5),
  fill = heatmap_palette[seq(1, 100, length.out = 5)],
  title = "Heatmap Values",
  cex = 3,  # Adjusted size of legend text and box
  bty = "n",  # No box around the legend
  horiz = TRUE,  # Legend displayed horizontally
  x.intersp = 0.8,  # Reduced spacing between legend boxes
  text.width = 0.1  # Adjust text spacing to make it compact
)

# --------------------------------------------------------------
# 11. Finalize and Save Plot
# --------------------------------------------------------------

# Clear Circos plot to finalize
circos.clear()

# Close the graphics device to save the plot
dev.off()

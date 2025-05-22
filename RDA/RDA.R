rm(list = ls())

# Load required packages
library(vegan)

# Load the data
df <- read.csv("RDA/coxl_lignin_precursor.csv", row.names = 1)
df <- na.omit(df)
colnames(df)[colnames(df) == "HCA..mg.g."] <- "HCA"
colnames(df)[colnames(df) == "LPA..mg.g."] <- "LPA"
colnames(df)[colnames(df) == "FLA..mg.g."] <- "FLA"
colnames(df)[colnames(df) == "CFA..mg.g."] <- "CFA"
colnames(df)[colnames(df) == "SPLT..mg.g."] <- "SPLT"

# Subset the data
ra <- df[, 1:(ncol(df) - 5)]  # The ra data
lp <- df[, (ncol(df) - 4):ncol(df)]  # The lp data

# Perform RDA
mag.rda <- rda(ra ~ ., lp)
summary(mag.rda)

# Extract site and species scores
site_scores <- scores(mag.rda, display = "sites", scaling = 3)
species_scores <- scores(mag.rda, display = "species", scaling = 3)

# Multiply by 10 to increase spread
site_scores <- site_scores * 10
species_scores <- species_scores * 10

# Create data frame for species
species_df <- as.data.frame(species_scores)
species_df$species <- rownames(species_df)

# Extract biplot scores for lignin precursors
biplot_scores <- scores(mag.rda, display = "bp", scaling = 3)
biplot_df <- as.data.frame(biplot_scores)
biplot_df$variable <- rownames(biplot_df)

# Create the group labels by extracting the unique part of column names (excluding last 11 characters)
group_labels <- substr(colnames(ra), 1, nchar(colnames(ra)) - 11)

# Custom color palette (provided by you)
custom_colors <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", 
                   "#D55E00", "#CC79A7", "#999999", "#882255", "#44AA99")

# Assign the colors to each group (assuming there are exactly 10 unique groups)
group_colors <- setNames(custom_colors, unique(group_labels))

# Save the main plot (ordination plot) with points and arrows

# Open a new device to save the ordination plot
png("RDA/rda_plot.png", width = 50, height = 50, units = "cm", res = 300)

# Create the ordination plot
par(mar = c(6, 6, 4, 5), cex.lab = 2.5, cex.axis = 2, bg = "white") 
model <- ordiplot(mag.rda, type = "none", scaling = 1, cex = 5, ylim = c(-5, 6), xlim = c(0, 8))  # Set y-axis from -2 to +2
# Larger points, thicker border

# Plot species points with colors based on groups, on top of site points
species_colored <- group_colors[substr(rownames(species_df), 1, nchar(rownames(species_df)) - 11)]
points(species_scores, col = species_colored, pch = 1, cex = 3, lwd = 5)  # Larger points, thicker border

# BP axis (arrows) with longer length
arrows(0, 0, biplot_scores[, 1] * 2, biplot_scores[, 2] * 10, col = "#9e1212", length = 0.1, lwd = 3)

# Add labels for BP axis with increased size
text(biplot_scores[, 1] * 2, biplot_scores[, 2] * 12, labels = rownames(biplot_scores), col = "#161616", cex = 2, pos = 3)

# Close the device to save the ordination plot
dev.off()


# Save the legend plot separately without axes

# Open a new device to save the legend
png("RDA/legend_plot.png", width = 1200, height = 1200, res = 150)

# Create an empty plot to hold the legend
plot(0, 0, type = "n", xlab = "", ylab = "", xlim = c(0, 1), ylim = c(0, 1), axes = FALSE)  # Empty plot for legend, no axes

# Create the legend
legend("center",  # Position of the legend
       legend = names(group_colors)[1:10],  # Group names
       fill = group_colors,  # Color corresponding to each group
       title = "Groups",  # Title of the legend
       cex = 1.5,  # Size of the text
       box.lwd = 2)  # Line width of the legend box

# Close the device to save the legend plot
dev.off()

library(tidyverse)
library(scales)
library(ggsignif)
library(ggExtra)
library(grid)


df <- read.csv("data.csv")

# Correction of CDS and genome length by completeness
df$number_of_cds <- df$number_of_cds / (df$completeness * 10^(-2))
df$length <- df$length / (df$completeness * 10^(-2))



# plot

# Modify legend
type_counts <- as.data.frame(table(df$type))
names(type_counts) <- c("type", "count")
type_counts <- type_counts[order(factor(type_counts$type, levels = c("SAG", "MAG", "WGS"))), ]
new_legend <- paste("MHQ", type_counts$type, paste0("(N=", type_counts$count, ")"), sep = " ")

# point plot
p1 <- ggplot(df, aes(x = length, y = number_of_cds, 
                    color = factor(type, levels = c("SAG", "MAG", "WGS")))) +
  geom_point(size = 3, alpha = 0.6) +
  guides(color = guide_legend(override.aes = list(alpha = 1, size = 5))) +
  geom_smooth(method = "lm", color = "red", linetype = "dashed") +
  scale_color_manual(values = c("#1F77B4", "#FF7F0E", "#3F3F3F"),
                     labels = new_legend) +
  xlim(3*10^5, 3*10^7) +
  ylim(400, 15000) +
  scale_x_log10(breaks = c(10^6, 10^7),
                labels = trans_format(log10, math_format(10^.x))) + 
  scale_y_log10(breaks = c(10^3, 10^4),
                labels = trans_format(log10, math_format(10^.x))) +
  labs(x = "Genome total size [bp] (corrected)",
       y = "Number of predicted CDS (corrected)") +
  annotation_logticks(outside = TRUE,
                      short = unit(1.5,"mm"),
                      mid = unit(2,"mm"),
                      long = unit(2.5,"mm")) +
  coord_cartesian(clip = "off") +
  theme_classic(base_size = 20) +
  theme(panel.grid.major = element_line(linetype = "dashed"),
        axis.text = element_text(color = "black", size = 16),
        legend.title = element_blank(),
        legend.margin = margin(3, 15, 3, 10),
        legend.text = element_text(size = 14),
        legend.key.spacing.y = unit(0.2, 'cm'),
        legend.position = c(0.05, 0.95), 
        legend.justification = c(0,1),
        legend.background = element_rect(fill = 'white', colour = '#D6D6D6',
                                         linewidth = 1))
p1

# edge histogram plot
p2 <- ggMarginal(p1, type = "histogram",
           groupColour = T,
           groupFill=T, 
           xparams = list(bins = 60),
           yparams = list(bins = 60),
           alpha = 0.2)
p2

# Prepare data for box plot

# Linear regression on log-log scale, store residuals
fit <- lm(log(number_of_cds)~log(length), data = df)
df$number_of_cds_fit <- exp(predict(fit))
df$residuals_log <- log(df$number_of_cds)-log(df$number_of_cds_fit)

# box plot
my_comparisons <- list(c("WGS","MAG"),
                       c("MAG","SAG"), 
                       c("WGS","SAG"))

p3 <- ggplot(df, aes(x = factor(type, levels = c("SAG", "MAG", "WGS")),
                     y = residuals_log, 
                     fill = factor(type, levels = c("SAG", "MAG", "WGS")))) +
  stat_boxplot(geom = "errorbar", width = 0.4, size = 1, color = "#3F3F3F") +
  geom_boxplot(outlier.fill = "#3F3F3F", outlier.shape = 23, outlier.size = 1, linewidth=0.5) +
  geom_signif(comparisons = my_comparisons,
              test = "wilcox.test", 
              map_signif_level = c("****"=0.0001, "***"=0.001, "**"=0.01, "*"=0.05), 
              textsize = 8,
              size = 1.1,
              color = "#3F3F3F",
              step_increase = 0.2) + 
  scale_fill_manual(values = c("#1F77B4", "#FF7F0E", "#808080")) +
  labs(x = NULL, y = NULL, title = "Residuals (log)") +
  scale_y_continuous(limits = c(NA, 1.3), breaks = c(-0.5, 0.0, 0.5, 1.0)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(color = "#B3B3B3", linewidth = 1.5),
        plot.title = element_text(hjust = 0.5, size = 16),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(color = "black", size = 16),
        legend.position = 'none',
        plot.margin = margin()) +
  coord_flip()


pdf("comprehensive_correlation.pdf", width = 8, height = 8)
p2
vie <- viewport(width=0.41, height=0.23, x=0.63, y=0.24)
print(p3, vp=vie)
dev.off()


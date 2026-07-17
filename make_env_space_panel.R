# make_env_space_panel.R
# Figure 2, panel B: the four study populations positioned in climate
# space. Panel A of Figure 2 is the field-site map (an external raster,
# not reproducible from this repo); this script produces a companion
# scatter panel that is dropped in beside the map in the figure-layout
# tool.
#
# Axis choice: Spring precipitation (x) vs spring temperature (y). These
# are the two most differentiating climate axes for these four sites and,
# because Nemophila menziesii is a spring annual, spring climate is the
# selective environment the plants actually experience. Spring temperature
# also separates AC from BB (10.5 vs 11.7 C), which annual temperature does
# not (12.30 vs 12.43 C). Spring VPD was rejected as an axis: it is
# non-monotonic across the four sites (0.44 / 0.52 / 0.38 / 0.49 kPa) and so
# does not order the populations.
#
# Error bars are +/- 1 interannual SD (as reported in Table 1), i.e. the
# among-year variability of each climate variable, NOT a standard error of
# a mean.

suppressPackageStartupMessages({
  library(ggplot2); library(here)
})

# --- Climate data (Table 1) --------------------------------------------
# mean +/- interannual SD. VPD carried for reference; not plotted.
sites <- data.frame(
  Population    = c("AC", "BB", "BO", "HR"),
  spring_ppt    = c(541.4, 222.7, 185.0, 187.5),   # mm
  spring_ppt_sd = c(255.8, 118.6, 101.7, 100.9),
  spring_temp   = c(10.5, 11.7, 12.4, 12.4),        # deg C
  spring_temp_sd= c(1.1, 0.9, 1.1, 1.0),
  stringsAsFactors = FALSE
)
sites$Population <- factor(sites$Population, levels = c("AC", "BB", "BO", "HR"))

# Direct-label placement. BO (185.0, 12.4) and HR (187.5, 12.4) are almost
# coincident -- the two Central Coast sites really are climatically alike --
# so their labels are pushed apart vertically (BO up, HR down) to keep the
# panel legible instead of looking like three points.
lab <- within(sites, {
  hjust   <- c(AC = 0,   BB = 0,   BO = 0.5, HR = 0.5)[as.character(Population)]
  nudge_x <- c(AC = 14,  BB = 12,  BO = 0,   HR = 0  )[as.character(Population)]
  nudge_y <- c(AC = 0.10,BB = 0.12,BO = 0.24,HR = -0.24)[as.character(Population)]
})

# Population colours: ggplot2 default hue palette on alphabetical
# AC/BB/BO/HR, matching Figure 4 (raw trait means) so the panel reads as
# part of the same study.
pop_cols <- c(AC = "#F8766D", BB = "#7CAE00", BO = "#00BFC4", HR = "#C77CFF")

p <- ggplot(sites, aes(spring_ppt, spring_temp, colour = Population)) +
  geom_errorbar(aes(ymin = spring_temp - spring_temp_sd,
                    ymax = spring_temp + spring_temp_sd),
                width = 0, linewidth = 0.4, alpha = 0.5) +
  geom_errorbar(aes(xmin = spring_ppt - spring_ppt_sd,
                    xmax = spring_ppt + spring_ppt_sd),
                orientation = "y", width = 0, linewidth = 0.4, alpha = 0.5) +
  geom_point(size = 3.4) +
  geom_text(data = lab,
            aes(x = spring_ppt + nudge_x, y = spring_temp + nudge_y,
                label = Population, hjust = hjust),
            fontface = "bold", size = 3.6, show.legend = FALSE) +
  scale_colour_manual(values = pop_cols, guide = "none") +
  labs(x = "Spring precipitation (mm)",
       y = expression("Spring temperature ("*degree*"C)"),
       tag = "B") +
  coord_cartesian(xlim = c(60, 820), ylim = c(9.2, 13.6), clip = "off") +
  theme_classic(base_size = 11) +
  theme(plot.tag = element_text(face = "bold"),
        plot.margin = margin(6, 12, 6, 6))

dir.create(here("figures"), showWarnings = FALSE)
out_png <- here("figures", "env-space-panel.png")
out_pdf <- here("figures", "env-space-panel.pdf")
ggsave(out_png, p, width = 4.3, height = 4.0, dpi = 300, device = ragg::agg_png)
ggsave(out_pdf, p, width = 4.3, height = 4.0, device = "pdf")

cat("Wrote:\n  ", out_png, "\n  ", out_pdf, "\n", sep = "")
print(sites[, c("Population", "spring_ppt", "spring_temp")])

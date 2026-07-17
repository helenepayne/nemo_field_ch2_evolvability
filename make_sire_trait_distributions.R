# make_sire_trait_distributions.R
# Frequency distributions (histograms) of PATERNAL (sire) trait means,
# by population. For each sire we average the raw trait values of its
# F-plant offspring, then plot the distribution of those sire means.
# Trait columns, block exclusions, and Donor-label normalisation mirror
# prep_population() in MCMC_multivariate_animal_model_readable.Rmd.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr)
  library(stringr); library(ggplot2); library(here)
})

POP_CONFIG <- list(
  AC = list(file = "data/AC_compiledsheet_full_2022.csv", exclude_blocks = "W"),
  BB = list(file = "data/BB_compiledsheet_full_2022.csv", exclude_blocks = "W"),
  BO = list(file = "data/BO_compiledsheet_full_2022.csv", exclude_blocks = "W"),
  HR = list(file = "data/HR_compiledsheet_full_2022.csv", exclude_blocks = "W")
)

TRAIT_COLS <- c(corolla = "corolla_diam_mm_SEG",
                SLA     = "SLA_SEG",
                d13C    = "d13C_SEG",
                msm     = "msm_all",
                fec     = "est_fecundity")

read_pop <- function(pop, cfg) {
  raw <- read_csv(here(cfg$file), show_col_types = FALSE)
  if (length(cfg$exclude_blocks) > 0)
    raw <- raw %>% filter(!(Block %in% cfg$exclude_blocks))
  raw %>%
    mutate(
      F_plant = ifelse(is.na(F_plant), 0L, as.integer(F_plant == TRUE)),
      # Normalise sire label exactly as prep_population() does, so one sire
      # is not split into two groups by mixed prefixes.
      sire = paste0("Donor_", pop, "_",
                    str_remove(Donor, paste0("^Donor_", pop, "_|^", pop, "_")))
    ) %>%
    filter(F_plant == 1L) %>%
    transmute(Population = pop, sire,
              corolla = .data[[TRAIT_COLS["corolla"]]],
              SLA     = .data[[TRAIT_COLS["SLA"]]],
              d13C    = .data[[TRAIT_COLS["d13C"]]],
              msm     = .data[[TRAIT_COLS["msm"]]],
              fec     = .data[[TRAIT_COLS["fec"]]])
}

dat <- purrr::imap_dfr(POP_CONFIG, ~ read_pop(.y, .x))

# Sire means: average each sire's offspring for each trait (NA-robust).
sire_means <- dat %>%
  pivot_longer(c(corolla, SLA, d13C, msm, fec),
               names_to = "trait", values_to = "value") %>%
  group_by(Population, sire, trait) %>%
  summarise(sire_mean = mean(value, na.rm = TRUE),
            n_off = sum(!is.na(value)), .groups = "drop") %>%
  filter(n_off > 0)   # drop sire x trait cells with no observed offspring

trait_labels <- c(
  corolla = "Corolla~diameter~(mm)",
  SLA     = "SLA~(mm^2~mg^-1)",
  d13C    = "delta^13*C~('‰')",
  msm     = "Mean~seed~mass~(mg)",
  fec     = "Fecundity~(filled~seeds)"
)

sire_means <- sire_means %>%
  mutate(Population = factor(Population, levels = c("AC", "BB", "BO", "HR")),
         trait      = factor(trait, levels = names(trait_labels)))

# Per-panel sire count (number of sires contributing a mean for that trait).
n_lab <- sire_means %>%
  group_by(Population, trait) %>%
  summarise(n = n(), .groups = "drop")

p <- ggplot(sire_means, aes(sire_mean, fill = Population)) +
  geom_histogram(bins = 18, colour = "grey20", linewidth = 0.15) +
  geom_text(data = n_lab, aes(label = paste0("sires=", n)),
            x = Inf, y = Inf, hjust = 1.1, vjust = 1.4,
            size = 2.7, inherit.aes = FALSE) +
  facet_grid(Population ~ trait, scales = "free",
             labeller = labeller(trait = as_labeller(trait_labels, label_parsed))) +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  labs(x = "Sire (paternal family) mean of raw trait value", y = "Number of sires") +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        strip.text = element_text(size = 9),
        strip.background = element_rect(fill = "grey92"))

dir.create(here("figures"), showWarnings = FALSE)
out_png <- here("figures", "sire-trait-distributions.png")
out_pdf <- here("figures", "sire-trait-distributions.pdf")
ggsave(out_png, p, width = 11, height = 8, dpi = 300, device = ragg::agg_png)
# Base "pdf" device (no cairo dependency); renders ‰ via Adobe Standard Encoding.
ggsave(out_pdf, p, width = 11, height = 8, device = "pdf")

cat("Wrote:\n  ", out_png, "\n  ", out_pdf, "\n", sep = "")
cat("\nSires contributing a mean, per population x trait:\n")
print(n_lab %>% pivot_wider(names_from = trait, values_from = n))
cat("\nTotal distinct sires per population:\n")
print(sire_means %>% distinct(Population, sire) %>% count(Population, name = "n_sires"))

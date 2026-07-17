# make_trait_distributions.R
# Frequency distributions (histograms) of the five raw focal traits,
# by population. Trait columns and block exclusions mirror
# prep_population() in MCMC_multivariate_animal_model_readable.Rmd so the
# values shown are the same raw measurements that enter the animal model
# (F-plants only; the AC watered "W" block is excluded).

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

# Raw (un-standardised) trait columns used by prep_population().
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
    mutate(F_plant = ifelse(is.na(F_plant), 0L, as.integer(F_plant == TRUE))) %>%
    filter(F_plant == 1L) %>%
    transmute(Population = pop,
              corolla = .data[[TRAIT_COLS["corolla"]]],
              SLA     = .data[[TRAIT_COLS["SLA"]]],
              d13C    = .data[[TRAIT_COLS["d13C"]]],
              msm     = .data[[TRAIT_COLS["msm"]]],
              fec     = .data[[TRAIT_COLS["fec"]]])
}

dat <- purrr::imap_dfr(POP_CONFIG, ~ read_pop(.y, .x))

trait_labels <- c(
  corolla = "Corolla~diameter~(mm)",
  SLA     = "SLA~(mm^2~mg^-1)",
  d13C    = "delta^13*C~('‰')",
  msm     = "Mean~seed~mass~(mg)",
  fec     = "Fecundity~(filled~seeds)"
)

long <- dat %>%
  pivot_longer(-Population, names_to = "trait", values_to = "value") %>%
  filter(!is.na(value)) %>%
  mutate(
    Population = factor(Population, levels = c("AC", "BB", "BO", "HR")),
    trait      = factor(trait, levels = names(trait_labels))
  )

# Per-panel n, placed in the top-right of each facet.
n_lab <- long %>%
  group_by(Population, trait) %>%
  summarise(n = n(), .groups = "drop")

p <- ggplot(long, aes(value, fill = Population)) +
  geom_histogram(bins = 25, colour = "grey20", linewidth = 0.15) +
  geom_text(data = n_lab, aes(label = paste0("n=", n)),
            x = Inf, y = Inf, hjust = 1.1, vjust = 1.4,
            size = 2.7, inherit.aes = FALSE) +
  facet_grid(Population ~ trait, scales = "free",
             labeller = labeller(trait = as_labeller(trait_labels, label_parsed))) +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  labs(x = "Raw trait value", y = "Count") +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        strip.text = element_text(size = 9),
        strip.background = element_rect(fill = "grey92"))

dir.create(here("figures"), showWarnings = FALSE)
out_png <- here("figures", "trait-distributions.png")
out_pdf <- here("figures", "trait-distributions.pdf")
ggsave(out_png, p, width = 11, height = 8, dpi = 300, device = ragg::agg_png)
# Base "pdf" device (no cairo dependency); renders ‰ via Adobe Standard Encoding.
ggsave(out_pdf, p, width = 11, height = 8, device = "pdf")

cat("Wrote:\n  ", out_png, "\n  ", out_pdf, "\n", sep = "")
print(n_lab %>% tidyr::pivot_wider(names_from = trait, values_from = n))

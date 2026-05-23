# nemo_field_ch2_evolvability

Chapter 2 analysis code for a pedigreed breeding design in four distinct populations of the annual wildflower, *Nemophila menziesii*, across a latitudinal gradient in California to estimate additive genetic variance, genetic correlations, selection gradients, and evolvability for five traits (corolla diameter, specific leaf area, δ¹³C, mean seed mass, and fecundity).

The repository contains:

- **MCMC_multivariate_animal_model.Rmd** — the multivariate animal model (Bayesian, MCMCglmm)
  that produces V_A, h², r_A, evolvability, β_P and β_G.
- **fetch_dryad.R** — downloads data from Dryad on first run.

## Data

Raw data CSVs (`*_compiledsheet_full_2022.csv`, `*_compiledsheet_full_2023.csv`)
live in the Dryad data package
[10.5061/dryad.pvmcvdp1p](https://doi.org/10.5061/dryad.pvmcvdp1p) and are
fetched on first run by `fetch_dryad.R`. If the package is still
private/embargoed, populate `data/` manually:

```
data/
├── AC_compiledsheet_full_2022.csv
├── AC_compiledsheet_full_2023.csv
├── BB_compiledsheet_full_2022.csv
├── BB_compiledsheet_full_2023.csv
├── BO_compiledsheet_full_2022.csv
├── BO_compiledsheet_full_2023.csv
├── HR_compiledsheet_full_2022.csv
└── HR_compiledsheet_full_2023.csv
```

## Provenance

This repo was split from
[helenepayne/nemo_field](https://github.com/helenepayne/nemo_field) (now
archived). Per-file commit history pre-split lives in that monorepo.

## Sister repositories

- [nemo_field_ch1_adaptive_capacity](https://github.com/helenepayne/nemo_field_ch1_adaptive_capacity)
- [nemo_field_ch3_phenotypic_plasticity](https://github.com/helenepayne/nemo_field_ch3_phenotypic_plasticity)

## Running the analysis

```r
# In RStudio, open MCMC_multivariate_animal_model.Rmd
# Set TEST_RUN <- TRUE for a 1-2 minute smoke test, FALSE for the full fit.
# Knit to HTML. The first run will source fetch_dryad.R and populate data/.
```

## Authors

Helen E. Payne. See `git log` for per-file attribution in the parent monorepo.

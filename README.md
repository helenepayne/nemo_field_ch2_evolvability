# nemo_field_ch2_evolvability

Chapter 2 analysis code for a pedigreed breeding design in four distinct populations of the annual wildflower, *Nemophila menziesii*, across a latitudinal gradient in California to estimate additive genetic variance, genetic correlations, selection gradients, and evolvability for five traits (corolla diameter, specific leaf area, δ¹³C, mean seed mass, and fecundity).

## Quick start

```sh
Rscript build.R
```

[build.R](build.R) does the whole pipeline:

1. Sources [fetch_dryad.R](fetch_dryad.R) and downloads the 4 input CSVs this repo needs from Dryad into `data/` (skipping anything already cached).
2. Knits [MCMC_multivariate_animal_model.Rmd](MCMC_multivariate_animal_model.Rmd) to `MCMC_multivariate_animal_model.html`.

The Rmd has a `TEST_RUN` flag at the top of the `config` chunk: leave it `TRUE` for a ~1–2 min smoke test, set it to `FALSE` for the publication-quality fit (much longer).

While the Dryad package is still in pre-publication review, the automatic fetch will fail gracefully — see [Data dependencies](#data-dependencies) below.

## Data dependencies

The analysis reads four site×year datasheets, one per population for the 2022 cohort:

```
data/
├── AC_compiledsheet_full_2022.csv
├── BB_compiledsheet_full_2022.csv
├── BO_compiledsheet_full_2022.csv
└── HR_compiledsheet_full_2022.csv
```

All four are part of the Dryad package [10.5061/dryad.pvmcvdp1p](https://doi.org/10.5061/dryad.pvmcvdp1p). Once that DOI is public, `fetch_dryad()` resolves it through `rdryad` and downloads the files automatically on the first run.

### While Dryad is in pre-publication review

The public `rdryad` API cannot enumerate a private dataset, and Dryad's *pre-publication share URLs* are gated by AWS WAF (a browser CAPTCHA / JS challenge), so they cannot be scripted from R or `curl` either. Until the package is published, populate `data/` manually:

1. Open the share URL in a browser (stored in `$DRYAD_REVIEW_URL`, not committed to this repo).
2. Download the four CSVs listed above into `data/`.

`build.R` will then skip the fetch (files are cached) and proceed to the knit.

## Outputs

- `MCMC_multivariate_animal_model.html` — full knitted report (posterior summaries, R̂ diagnostics, genetic correlations, evolvability, β_P and β_G, Random Skewers).

## Provenance

This repo was split from [helenepayne/nemo_field](https://github.com/helenepayne/nemo_field) (now archived). Per-file commit history pre-split lives in that monorepo.

## Sister repositories

- [nemo_field_ch1_adaptive_capacity](https://github.com/helenepayne/nemo_field_ch1_adaptive_capacity)
- [nemo_field_ch3_phenotypic_plasticity](https://github.com/helenepayne/nemo_field_ch3_phenotypic_plasticity)

## Authors

Helen E. Payne. See `git log` in the parent monorepo for per-file attribution.

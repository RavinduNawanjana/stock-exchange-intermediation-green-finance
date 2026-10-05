# Market Intermediaries and the Green Transition

**Evidence on Stock Exchanges and Bank Green Finance Adoption in Emerging Markets**

R-first reproducible research companion based **only on the Figshare supplementary data package** associated with the study. The repository does **not** include, edit, rewrite, or numerically benchmark against the SSRN manuscript PDF.

## Reproducibility design

The source of truth is the Figshare package:

- `Dataset_S1_Raw_Survey_Data.xlsx`: 103 respondents × 30 five-point Likert items plus the item codebook.
- `Dataset_S2_SPSS_Data_File.sav`: the same 30 items plus source composite scores and SPSS-generated diagnostics.
- `Dataset_S3_SPSS_Output.spv`: preserved original IBM SPSS output viewer file.
- `FIGSHARE_README.txt`: source documentation supplied with the data package.

The analytical architecture is deliberately layered:

1. **R** is the primary statistical implementation: validation, scoring, reliability, descriptives, Pearson/Spearman correlations, OLS, VIF and influence diagnostics, deterministic bootstrap, KMO/Bartlett diagnostics, exploratory factor analysis, EFA-derived CR/AVE diagnostics, chi-square sensitivity analyses, SPSS `.sav` reconciliation, and all analytical figures.
2. **Quarto** presents the methods, results, robustness checks, factor-validity diagnostics, SPSS reconciliation, and interpretation limits as a reproducible research companion.
3. **Python/Jupyter** provides an independent audit of the XLSX source, range/missingness checks, construct scoring, headline statistics, and direct XLSX-to-SPSS `.sav` reconciliation when `pyreadstat` is available.
4. **SPSS** is preserved as source evidence. The repository never rewrites the `.sav` or `.spv` files.
5. **GitHub Actions** executes the Python/Jupyter and R/Quarto workflows in clean environments and uploads run artifacts.

## Construct map

| Code | Construct | Items |
| --- | --- | --- |
| PRA | Policy and Regulatory Alignment | V1–V7 |
| MM | Market Mechanisms | V8–V14 |
| MA | Market Awareness | V15–V21 |
| MI | Market Incentives | V22–V28 |
| GFA | Green Finance Adoption | V29–V30 |

Composite scores are the **unweighted respondent-level mean of the documented items**. No undocumented reverse scoring or manuscript-driven adjustment is applied.

## What is intentionally absent

- No SSRN PDF or DOCX.
- No manuscript-reported numerical targets.
- No manuscript-reconciliation page or scripts.
- No screenshots or externally sourced figures from IPCC, stock exchanges, rating agencies, UN bodies, or other third parties.
- No CFA, SEM, mediation, moderation, causal model, or country-level inference invented for portfolio appearance.

Every figure produced by this repository is generated from the Figshare data package during the R workflow.

## Run locally

Install R 4.4+ and Quarto. From the repository root:

```r
install.packages(c(
  "readxl", "haven", "ggplot2", "psych", "GPArotation",
  "boot", "knitr", "rmarkdown"
))
```

Then:

```bash
Rscript analysis/master.R
quarto render
```

For the independent Python audit:

```bash
python -m pip install -r requirements.txt
python python/run_audit.py
pytest -q
jupyter nbconvert --to notebook --execute notebooks/independent_python_audit.ipynb   --output independent_python_audit_executed.ipynb
```

## Statistical interpretation

This is a cross-sectional survey of 103 financial practitioners. The repository quantifies associations among perception-based composite scores. It does **not** identify causal effects of stock exchanges, regulations, market mechanisms, awareness, or incentives on realised bank finance flows or environmental outcomes.

## Start here

- [`index.qmd`](index.qmd) — research companion overview
- [`methods.qmd`](methods.qmd) — data, scoring, estimation and reproducibility boundaries
- [`empirical-results.qmd`](empirical-results.qmd) — descriptive, reliability, correlation and regression outputs
- [`factor-validity.qmd`](factor-validity.qmd) — KMO/Bartlett, EFA and EFA-derived CR/AVE diagnostics
- [`robustness.qmd`](robustness.qmd) — bootstrap, influence and chi-square sensitivity
- [`spss-reconciliation.qmd`](spss-reconciliation.qmd) — direct XLSX/SAV consistency checks
- [`notebooks/independent_python_audit.ipynb`](notebooks/independent_python_audit.ipynb) — independent audit layer
- [`docs/data_provenance.md`](docs/data_provenance.md) — source lineage

## Publication note

The repository is a computational companion, not a replacement for the associated paper. The paper itself is not redistributed here, and its text has not been edited or modified in preparing this repository.

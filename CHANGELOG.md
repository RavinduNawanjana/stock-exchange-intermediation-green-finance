# Changelog

## v2.0.0 — 2026-10-06

- Rebuilt repository around the Figshare supplementary package as the sole quantitative evidence base.
- Removed the SSRN manuscript PDF and all manuscript-number reconciliation files.
- Removed all externally sourced manuscript figures.
- Kept R as the primary statistical implementation and Quarto as the reporting layer.
- Retained Python/Jupyter only as an independent audit layer.
- Preserved the original XLSX, SAV, SPV and Figshare README byte-for-byte.
- Added direct XLSX/SAV item and composite reconciliation.
- Added R-generated data-only figures, bootstrap, EFA, EFA-derived CR/AVE and transparent chi-square sensitivity analysis.
- Added separate GitHub Actions jobs for Python/Jupyter and R/Quarto reproduction.

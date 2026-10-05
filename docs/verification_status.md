# Verification status

## Completed locally during packaging

- Source Excel inspected with spreadsheet-aware tooling: `Codebook` contains 30 documented items and `Raw_Data` contains 103 respondents × 30 items.
- Independent Python audit executed successfully from the source XLSX.
- Python validation confirms zero missing item cells and a response range of 1–5.
- Frozen Figshare-data benchmark checks passed locally.
- Jupyter audit notebook executed successfully from a clean source notebook.
- Local Python test status: **2 passed, 1 skipped**. The skipped test is direct SAV reconciliation because `pyreadstat` is not installed in the offline packaging environment.

## Verified after GitHub upload

GitHub Actions installs `pyreadstat`, R and Quarto, then performs:

- direct XLSX ↔ SPSS `.sav` raw-item reconciliation;
- direct reconstructed composite ↔ SPSS composite reconciliation;
- full R analysis and cross-language benchmark tests;
- bootstrap, EFA, CR/AVE diagnostics and chi-square sensitivity;
- R-generated figures from Figshare data only;
- Quarto site rendering;
- run-specific tracked-file checksums.

Both GitHub Actions jobs should be green before the repository is described as fully reproduced.

The repository deliberately contains no manuscript numerical benchmark table and no paper PDF.

# Repository audit

## Scope

Version 2.0.0 is intentionally **Figshare-only**. The associated SSRN PDF is not bundled, edited, or used as a numerical target. The manuscript's externally sourced figures are not bundled.

## Local checks completed during packaging

- Figshare ZIP structure inspected and the four source files copied byte-for-byte.
- XLSX inspected with spreadsheet-aware tooling: `Codebook` has 30 items and `Raw_Data` has 103 respondents × 30 items.
- The raw matrix contains no missing cells and all responses are integers from 1 to 5.
- Derived CSV snapshots are included for inspectability and R validates them against the XLSX.
- `python python/run_audit.py` completed successfully.
- `pytest -q` completed with **2 passed, 1 skipped**; the skip is SAV reconciliation because the offline packaging environment lacks `pyreadstat`.
- The clean Jupyter notebook executed successfully locally; SAV reconciliation is deferred in that local run for the same dependency reason.
- GitHub Actions is configured to install `pyreadstat` and must pass the full SAV reconciliation.
- R/Quarto are unavailable in the packaging environment; their complete execution is delegated to the included GitHub Actions workflow.

## Claims boundary

No paper-reported numerical value is treated as ground truth in this repository. All analytical tables and figures are recomputed from the Figshare data package. No CFA/SEM or causal model is introduced.

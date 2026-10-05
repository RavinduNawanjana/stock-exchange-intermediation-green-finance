# Upload and verification

This repository is already hosted at `RavinduNawanjana/stock-exchange-intermediation-green-finance`.

## Verification workflow

1. Push changes to `main` or run **Reproduce Figshare survey analysis** manually from the Actions tab.
2. Confirm that both jobs finish successfully:
   - `Independent Python and Jupyter audit`
   - `R statistical reproduction and Quarto render`
3. The workflow first verifies the SHA-256 checksums of the four preserved Figshare source files.
4. Download the workflow artifacts when needed:
   - the executed independent Jupyter audit and resolved Python environment;
   - the rendered Quarto site, R-generated tables and figures, R session information, and run-specific integrity manifest.
5. Treat the repository as fully reproduced only after both jobs are green.

The workflow has read-only repository permissions. It does not rewrite source files or commit generated outputs back to the repository.

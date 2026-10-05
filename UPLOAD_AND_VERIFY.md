# Upload and verification

1. Create a GitHub repository named `stock-exchanges-green-finance-adoption`.
2. Keep it **private** for the first verification run.
3. Copy the **contents of this folder** to the repository root. Do not upload the ZIP itself.
4. Commit and push to `main`.
5. Open **Actions** and wait for both jobs in `Reproduce Figshare survey analysis`:
   - `Independent Python and Jupyter audit`
   - `R statistical reproduction and Quarto render`
6. Both jobs should finish with a green check before treating the repository as fully reproduced.
7. Download the workflow artifacts if you want the executed notebook, rendered Quarto site, generated figures, output tables, R session information, and run-specific integrity manifest.

The workflow has read-only repository permissions. It does not rewrite source files or commit generated outputs back to the repository.

source("R/functions.R")
if (!file.exists("data/original/Dataset_S1_Raw_Survey_Data.xlsx")) stop("Run from repository root.")
ensure_dirs()
steps <- c(
  "analysis/01_validate_inputs.R",
  "analysis/02_scores_reliability.R",
  "analysis/03_associations_regression.R",
  "analysis/04_bootstrap.R",
  "analysis/05_factor_validity.R",
  "analysis/06_chi_square_sensitivity.R",
  "analysis/07_spss_reconciliation.R",
  "analysis/08_figures.R",
  "tests/run_tests.R"
)
for (s in steps) {
  cat("\n=== ", s, " ===\n", sep = "")
  sys.source(s, envir = new.env(parent = globalenv()))
}
writeLines(capture.output(sessionInfo()), "outputs/session_info.txt")
cat("\nComplete: Figshare-only R analysis, SPSS reconciliation, tests and figures.\n")

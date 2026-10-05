source("R/functions.R")
ensure_dirs()
raw <- read_source_xlsx(); scores <- score_constructs(raw)

# The Figshare package does not document the exact SPSS crosstab definitions.
# These chi-square tests are therefore a transparent sensitivity analysis only.
out <- lapply(predictors, function(k) {
  a <- factor(round_likert(scores[[k]]))
  b <- factor(round_likert(scores$GFA))
  tab <- table(a, b)
  tst <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))
  data.frame(construct = k, chi_square = unname(tst$statistic), df = unname(tst$parameter), p_value = tst$p.value,
             min_expected = min(tst$expected), cells_expected_lt5 = sum(tst$expected < 5),
             definition = "rounded construct mean (1-5) by rounded GFA mean (1-5); sensitivity only")
})
write_csv_safe(do.call(rbind, out), "outputs/tables/chi_square_construct_sensitivity.csv")

item_rows <- lapply(paste0("V", 1:28), function(item) {
  tab <- table(factor(raw[[item]]), factor(round_likert(scores$GFA)))
  tst <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))
  data.frame(item = item, chi_square = unname(tst$statistic), df = unname(tst$parameter),
             p_value = tst$p.value, min_expected = min(tst$expected), cells_expected_lt5 = sum(tst$expected < 5))
})
item_out <- do.call(rbind, item_rows)
item_out$p_fdr_bh <- stats::p.adjust(item_out$p_value, method = "BH")
write_csv_safe(item_out, "outputs/tables/chi_square_item_sensitivity.csv")
cat("Transparent chi-square sensitivity analyses complete.\n")

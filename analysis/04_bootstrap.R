source("R/functions.R")
ensure_dirs()
if (!requireNamespace("boot", quietly = TRUE)) stop("Package 'boot' is required.")
raw <- read_source_xlsx(); scores <- score_constructs(raw)
set.seed(7318958)
stat_fun <- function(data, idx) {
  d <- data[idx, , drop = FALSE]
  stats::coef(stats::lm(GFA ~ PRA + MM + MA + MI, data = d))
}
b <- boot::boot(scores, statistic = stat_fun, R = 2000)
term_names <- names(stats::coef(stats::lm(GFA ~ PRA + MM + MA + MI, data = scores)))
rows <- lapply(seq_along(b$t0), function(i) {
  vals <- b$t[, i]
  qs <- stats::quantile(vals, c(0.025, 0.975), na.rm = TRUE, names = FALSE)
  data.frame(term = term_names[[i]], original = b$t0[[i]], bootstrap_mean = mean(vals, na.rm = TRUE),
             bootstrap_se = stats::sd(vals, na.rm = TRUE),
             percentile_ci_low = qs[[1]], percentile_ci_high = qs[[2]])
})
write_csv_safe(do.call(rbind, rows), "outputs/tables/bootstrap_ols_2000.csv")
cat("Deterministic 2,000-resample OLS bootstrap complete.\n")

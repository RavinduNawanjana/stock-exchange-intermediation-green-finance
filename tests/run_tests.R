source("R/functions.R")
raw <- read_source_xlsx(); validate_raw(raw); scores <- score_constructs(raw)
bench <- utils::read.csv("data/reference/independent_python_benchmarks.csv", stringsAsFactors = FALSE)
getb <- function(metric, target) {
  x <- bench[bench$metric == metric & bench$target == target, "value"]
  if (length(x) != 1L) stop("benchmark lookup failed: ", metric, " / ", target)
  as.numeric(x)
}
assert_close <- function(actual, expected, tol=1e-9, label="value") {
  if (!is.finite(actual) || abs(actual-expected) > tol) stop(sprintf("%s mismatch: R=%.12g expected=%.12g", label, actual, expected))
}
for (k in names(construct_items)) {
  assert_close(mean(scores[[k]]), getb("construct_mean", k), 1e-10, paste("mean", k))
  assert_close(stats::sd(scores[[k]]), getb("construct_sd", k), 1e-10, paste("sd", k))
  assert_close(cronbach_alpha_raw(raw[, construct_items[[k]], drop=FALSE]), getb("cronbach_alpha", k), 1e-10, paste("alpha", k))
}
assert_close(cronbach_alpha_raw(raw), getb("cronbach_alpha", "all_30_items"), 1e-10, "alpha all30")
for (k in predictors) {
  p <- stats::cor.test(scores[[k]], scores$GFA, method="pearson")
  assert_close(unname(p$estimate), getb("pearson_r", k), 1e-10, paste("pearson", k))
  assert_close(p$p.value, getb("pearson_p", k), 1e-9, paste("pearson p", k))
  s <- suppressWarnings(stats::cor.test(scores[[k]], scores$GFA, method="spearman", exact=FALSE))
  assert_close(unname(s$estimate), getb("spearman_rho", k), 1e-10, paste("spearman", k))
}
fit <- stats::lm(GFA ~ PRA + MM + MA + MI, data=scores)
for (term in names(stats::coef(fit))) {
  target <- if (term == "(Intercept)") "const" else term
  assert_close(stats::coef(fit)[[term]], getb("ols_b", target), 1e-10, paste("OLS", term))
}
std <- standardized_coefficients(fit, scores)
for (term in predictors) assert_close(std$standardized_beta[std$term==term], getb("ols_standardized_beta", term), 1e-10, paste("std beta", term))
assert_close(summary(fit)$r.squared, getb("model_r_squared", "full"), 1e-10, "R2")
assert_close(summary(fit)$adj.r.squared, getb("model_adjusted_r_squared", "full"), 1e-10, "adj R2")
cat("All R core-data/statistical tests match independent Python calculations from the Figshare XLSX.\n")

source("R/functions.R")
ensure_dirs()
raw <- read_source_xlsx(); scores <- score_constructs(raw)

corr <- do.call(rbind, lapply(predictors, function(k) {
  p <- stats::cor.test(scores[[k]], scores$GFA, method = "pearson")
  s <- suppressWarnings(stats::cor.test(scores[[k]], scores$GFA, method = "spearman", exact = FALSE))
  data.frame(construct = k, label = construct_labels[[k]],
             pearson_r = unname(p$estimate), pearson_p = p$p.value,
             spearman_rho = unname(s$estimate), spearman_p = s$p.value)
}))
write_csv_safe(corr, "outputs/tables/correlations.csv")

full_cor <- stats::cor(scores, method = "pearson")
full_cor_out <- cbind(construct = rownames(full_cor), as.data.frame(full_cor, check.names = FALSE))
write_csv_safe(full_cor_out, "outputs/tables/construct_correlation_matrix.csv")

fit <- stats::lm(GFA ~ PRA + MM + MA + MI, data = scores)
sm <- summary(fit)
co <- as.data.frame(sm$coefficients)
co$term <- rownames(co); rownames(co) <- NULL
names(co)[1:4] <- c("estimate", "std_error", "t_value", "p_value")
std <- standardized_coefficients(fit, scores)
co <- merge(co, std[, c("term", "standardized_beta")], by = "term", all.x = TRUE, sort = FALSE)
ci <- stats::confint(fit)
co$ci_low <- ci[match(co$term, rownames(ci)), 1]
co$ci_high <- ci[match(co$term, rownames(ci)), 2]
write_csv_safe(co, "outputs/tables/ols_coefficients.csv")

model_summary <- data.frame(
  n = stats::nobs(fit), residual_df = stats::df.residual(fit),
  r_squared = sm$r.squared, adjusted_r_squared = sm$adj.r.squared,
  f_statistic = unname(sm$fstatistic[[1]]), f_df1 = unname(sm$fstatistic[[2]]),
  f_df2 = unname(sm$fstatistic[[3]]),
  f_p_value = stats::pf(sm$fstatistic[[1]], sm$fstatistic[[2]], sm$fstatistic[[3]], lower.tail = FALSE)
)
write_csv_safe(model_summary, "outputs/tables/model_summary.csv")
write_csv_safe(vif_base(fit), "outputs/tables/vif.csv")

influence <- data.frame(
  row_index = seq_len(nrow(scores)), fitted = stats::fitted(fit), residual = stats::residuals(fit),
  standardized_residual = stats::rstandard(fit), studentized_residual = stats::rstudent(fit),
  cooks_distance = stats::cooks.distance(fit), leverage = stats::hatvalues(fit)
)
write_csv_safe(influence, "outputs/restricted/influence_diagnostics.csv")
write_csv_safe(data.frame(
  diagnostic = c("cooks_gt_4_over_n", "leverage_gt_2p_over_n", "abs_studentized_gt_2"),
  count = c(sum(influence$cooks_distance > 4 / nrow(scores)),
            sum(influence$leverage > 2 * length(stats::coef(fit)) / nrow(scores)),
            sum(abs(influence$studentized_residual) > 2))
), "outputs/tables/influence_summary.csv")
cat("Correlations, OLS, VIF and influence diagnostics complete.\n")

source("R/functions.R")
ensure_dirs()
if (!requireNamespace("psych", quietly = TRUE)) stop("Package 'psych' is required.")
if (!requireNamespace("GPArotation", quietly = TRUE)) stop("Package 'GPArotation' is required.")
raw <- read_source_xlsx(); R <- stats::cor(raw)

kmo <- psych::KMO(R)
bart <- psych::cortest.bartlett(R, n = nrow(raw))
write_csv_safe(data.frame(overall_MSA = unname(kmo$MSA), bartlett_chisq = unname(bart$chisq),
                          bartlett_df = unname(bart$df), bartlett_p = unname(bart$p.value)),
               "outputs/tables/efa_prechecks.csv")
write_csv_safe(data.frame(item = names(kmo$MSAi), MSA = as.numeric(kmo$MSAi)),
               "outputs/tables/item_kmo.csv")

eigen <- eigen(R, symmetric = TRUE)$values
write_csv_safe(data.frame(component = seq_along(eigen), eigenvalue = eigen), "outputs/tables/correlation_eigenvalues.csv")

set.seed(7318958)
efa <- suppressWarnings(psych::fa(R, nfactors = 5, n.obs = nrow(raw), fm = "pa", rotate = "oblimin"))
L <- unclass(efa$loadings)
loadings <- data.frame(item = rownames(L), L, check.names = FALSE, row.names = NULL)
write_csv_safe(loadings, "outputs/tables/efa_5factor_pattern_loadings.csv")
if (!is.null(efa$Phi)) {
  phi <- as.data.frame(efa$Phi); phi$factor <- rownames(phi); rownames(phi) <- NULL
  write_csv_safe(phi, "outputs/tables/efa_factor_correlations.csv")
}

# EFA-derived descriptive CR/AVE. These are not CFA/SEM estimates.
validity_rows <- lapply(names(construct_items), function(k) {
  dat <- raw[, construct_items[[k]], drop = FALSE]
  if (ncol(dat) == 2L) {
    r <- stats::cor(dat[[1]], dat[[2]])
    lambda <- rep(sqrt(max(r, 0)), 2)
    method <- "two_item_equal_loading_approximation"
  } else {
    f <- suppressWarnings(psych::fa(stats::cor(dat), nfactors = 1, n.obs = nrow(dat), fm = "pa", rotate = "none"))
    lambda <- as.numeric(unclass(f$loadings)[, 1])
    method <- "one_factor_principal_axis"
  }
  theta <- pmax(0, 1 - lambda^2)
  cr <- (sum(lambda)^2) / ((sum(lambda)^2) + sum(theta))
  ave <- sum(lambda^2) / (sum(lambda^2) + sum(theta))
  data.frame(construct = k, label = construct_labels[[k]], method = method,
             composite_reliability = cr, average_variance_extracted = ave,
             min_abs_loading = min(abs(lambda)), max_abs_loading = max(abs(lambda)))
})
write_csv_safe(do.call(rbind, validity_rows), "outputs/tables/efa_derived_cr_ave.csv")
cat("KMO/Bartlett, 5-factor PAF EFA and EFA-derived CR/AVE diagnostics complete.\n")

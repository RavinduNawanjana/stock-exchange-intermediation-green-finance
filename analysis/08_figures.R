source("R/functions.R")
ensure_dirs()
if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Package 'ggplot2' is required.")
raw <- read_source_xlsx(); scores <- score_constructs(raw)

# 1. Construct distributions.
long <- stack(scores)
names(long) <- c("score", "construct")
long$construct <- factor(long$construct, levels = names(construct_labels), labels = unname(construct_labels))
p1 <- ggplot2::ggplot(long, ggplot2::aes(x = construct, y = score)) +
  ggplot2::geom_boxplot(width = 0.55, outlier.alpha = 0.35) +
  ggplot2::coord_cartesian(ylim = c(1, 5)) +
  ggplot2::labs(title = "Observed construct-score distributions",
                subtitle = "103 respondents; unweighted means of documented Likert items",
                x = NULL, y = "Composite mean (1 to 5)",
                caption = "Generated only from the Figshare raw survey matrix") +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 25, hjust = 1))
ggplot2::ggsave("figures/construct_distributions.png", p1, width = 9.6, height = 5.8, dpi = 220)

# 2. Construct means with normal-approximation 95% CI for sample mean (descriptive only).
d <- data.frame(construct = names(scores), mean = vapply(scores, mean, numeric(1)),
                sd = vapply(scores, stats::sd, numeric(1)), n = nrow(scores))
d$se <- d$sd / sqrt(d$n); d$low <- d$mean - 1.96*d$se; d$high <- d$mean + 1.96*d$se
d$label <- factor(unname(construct_labels[d$construct]), levels = rev(unname(construct_labels[d$construct])))
p2 <- ggplot2::ggplot(d, ggplot2::aes(x = label, y = mean, ymin = low, ymax = high)) +
  ggplot2::geom_pointrange() + ggplot2::coord_flip(ylim = c(1,5)) +
  ggplot2::labs(title = "Construct means in the observed sample", subtitle = "Points are sample means; bars are 95% normal-approximation intervals",
                x = NULL, y = "Mean score", caption = "Descriptive intervals; not population-generalizability claims") +
  ggplot2::theme_minimal(base_size = 11)
ggplot2::ggsave("figures/construct_means.png", p2, width = 8.8, height = 5.0, dpi = 220)

# 3. Correlation heatmap.
cm <- stats::cor(scores)
cor_long <- as.data.frame(as.table(cm)); names(cor_long) <- c("x","y","r")
cor_long$x <- factor(cor_long$x, levels = names(construct_labels), labels = unname(construct_labels))
cor_long$y <- factor(cor_long$y, levels = names(construct_labels), labels = unname(construct_labels))
p3 <- ggplot2::ggplot(cor_long, ggplot2::aes(x = x, y = y, fill = r)) +
  ggplot2::geom_tile() + ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", r)), size = 3) +
  ggplot2::scale_fill_gradient2(limits = c(-1,1), midpoint = 0) +
  ggplot2::labs(title = "Pearson correlation matrix of composite scores", x = NULL, y = NULL, fill = "r",
                caption = "Cross-sectional associations; no causal interpretation") +
  ggplot2::theme_minimal(base_size = 10) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
ggplot2::ggsave("figures/correlation_heatmap.png", p3, width = 8.8, height = 7.1, dpi = 220)

# 4. Standardized OLS coefficients and approximate transformed CI.
fit <- stats::lm(GFA ~ PRA + MM + MA + MI, data = scores)
co <- as.data.frame(summary(fit)$coefficients); co$term <- rownames(co); rownames(co) <- NULL
co <- co[co$term %in% predictors, , drop = FALSE]
sy <- stats::sd(scores$GFA)
co$beta <- vapply(co$term, function(k) stats::coef(fit)[[k]] * stats::sd(scores[[k]]) / sy, numeric(1))
ci <- stats::confint(fit)[co$term, , drop = FALSE]
co$low <- vapply(seq_len(nrow(co)), function(i) ci[i,1] * stats::sd(scores[[co$term[i]]]) / sy, numeric(1))
co$high <- vapply(seq_len(nrow(co)), function(i) ci[i,2] * stats::sd(scores[[co$term[i]]]) / sy, numeric(1))
co$label <- factor(unname(construct_labels[co$term]), levels = rev(unname(construct_labels[co$term])))
p4 <- ggplot2::ggplot(co, ggplot2::aes(x = label, y = beta, ymin = low, ymax = high)) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed") + ggplot2::geom_pointrange() + ggplot2::coord_flip() +
  ggplot2::labs(title = "Standardized partial associations with Green Finance Adoption",
                subtitle = "Four-predictor OLS using Figshare composite scores", x = NULL, y = "Standardized coefficient",
                caption = "Associational model; intervals inherit conventional OLS assumptions") + ggplot2::theme_minimal(base_size = 11)
ggplot2::ggsave("figures/standardized_ols.png", p4, width = 9.0, height = 5.2, dpi = 220)

# 5. Reliability.
rel <- do.call(rbind, lapply(names(construct_items), function(k) data.frame(construct=k, alpha=cronbach_alpha_raw(raw[, construct_items[[k]], drop=FALSE]))))
rel$label <- factor(unname(construct_labels[rel$construct]), levels = rev(unname(construct_labels[rel$construct])))
p5 <- ggplot2::ggplot(rel, ggplot2::aes(x=label, y=alpha)) + ggplot2::geom_col() + ggplot2::coord_flip(ylim=c(0,1)) + ggplot2::geom_hline(yintercept=0.70, linetype="dashed") +
  ggplot2::labs(title="Internal consistency by documented scale", subtitle="Raw-score Cronbach alpha; dashed line = 0.70 reference",
                x=NULL,y="Cronbach alpha", caption="Internal consistency is not proof of validity or unidimensionality") + ggplot2::theme_minimal(base_size=11)
ggplot2::ggsave("figures/reliability_alpha.png", p5, width=8.8, height=5.0, dpi=220)

# 6. Scree plot from raw item correlation matrix.
ev <- eigen(stats::cor(raw), symmetric=TRUE)$values
scree <- data.frame(component=seq_along(ev), eigenvalue=ev)
p6 <- ggplot2::ggplot(scree, ggplot2::aes(x=component,y=eigenvalue)) + ggplot2::geom_line() + ggplot2::geom_point() +
  ggplot2::geom_hline(yintercept=1, linetype="dashed") +
  ggplot2::labs(title="Scree plot of the 30-item correlation matrix", x="Component", y="Eigenvalue",
                caption="Generated from Figshare raw items; factor retention should not rely on the Kaiser rule alone") + ggplot2::theme_minimal(base_size=11)
ggplot2::ggsave("figures/scree_plot.png", p6, width=8.8, height=5.0, dpi=220)
cat("All repository figures generated from Figshare data only.\n")

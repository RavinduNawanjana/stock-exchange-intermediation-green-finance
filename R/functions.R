construct_items <- list(
  PRA = paste0("V", 1:7),
  MM  = paste0("V", 8:14),
  MA  = paste0("V", 15:21),
  MI  = paste0("V", 22:28),
  GFA = paste0("V", 29:30)
)

construct_labels <- c(
  PRA = "Policy and Regulatory Alignment",
  MM = "Market Mechanisms",
  MA = "Market Awareness",
  MI = "Market Incentives",
  GFA = "Green Finance Adoption"
)

predictors <- c("PRA", "MM", "MA", "MI")

ensure_dirs <- function() {
  for (d in c("outputs", "outputs/tables", "outputs/restricted", "outputs/integrity", "figures")) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
}

read_source_xlsx <- function(path = "data/original/Dataset_S1_Raw_Survey_Data.xlsx") {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' is required.")
  x <- as.data.frame(readxl::read_excel(path, sheet = "Raw_Data"), check.names = FALSE)
  x[] <- lapply(x, as.numeric)
  x
}

read_codebook_xlsx <- function(path = "data/original/Dataset_S1_Raw_Survey_Data.xlsx") {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' is required.")
  as.data.frame(readxl::read_excel(path, sheet = "Codebook"), check.names = FALSE)
}

validate_raw <- function(x) {
  expected <- paste0("V", 1:30)
  if (!identical(dim(x), c(103L, 30L))) stop("Expected 103 respondents x 30 items.")
  if (!identical(colnames(x), expected)) stop("Raw item names/order do not match V1-V30.")
  if (anyNA(x)) stop("Raw item matrix contains missing values.")
  vals <- unlist(x, use.names = FALSE)
  if (!all(is.finite(vals))) stop("Raw item matrix contains non-finite values.")
  if (!all(vals == floor(vals))) stop("Raw Likert matrix contains non-integer values.")
  if (!all(vals %in% 1:5)) stop("Raw Likert matrix contains values outside 1-5.")
  invisible(TRUE)
}

score_constructs <- function(x) {
  validate_raw(x)
  as.data.frame(lapply(construct_items, function(cols) rowMeans(x[, cols, drop = FALSE])))
}

cronbach_alpha_raw <- function(items) {
  k <- ncol(items)
  if (k < 2L) return(NA_real_)
  item_var <- sum(vapply(items, stats::var, numeric(1)))
  total_var <- stats::var(rowSums(items))
  (k / (k - 1)) * (1 - item_var / total_var)
}

write_csv_safe <- function(x, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(x, path, row.names = FALSE, na = "")
}

benchmark_value <- function(metric, target, path = "data/reference/independent_python_benchmarks.csv") {
  b <- utils::read.csv(path, stringsAsFactors = FALSE)
  hit <- b[b$metric == metric & b$target == target, , drop = FALSE]
  if (nrow(hit) != 1L) stop(sprintf("Benchmark not unique: %s / %s", metric, target))
  as.numeric(hit$value[[1]])
}

vif_base <- function(fit) {
  mm <- stats::model.matrix(fit)
  terms <- colnames(mm)[-1]
  do.call(rbind, lapply(terms, function(term) {
    y <- mm[, term]
    others <- mm[, setdiff(terms, term), drop = FALSE]
    aux <- stats::lm(y ~ others)
    r2 <- summary(aux)$r.squared
    data.frame(term = term, vif = 1 / (1 - r2))
  }))
}

standardized_coefficients <- function(fit, scores) {
  b <- stats::coef(fit)
  sy <- stats::sd(scores$GFA)
  out <- data.frame(term = names(b), estimate = as.numeric(b), stringsAsFactors = FALSE)
  out$standardized_beta <- NA_real_
  for (term in intersect(predictors, out$term)) {
    out$standardized_beta[out$term == term] <- b[[term]] * stats::sd(scores[[term]]) / sy
  }
  out
}

round_likert <- function(x) pmax(1L, pmin(5L, floor(x + 0.5)))

source("R/functions.R")
ensure_dirs()
raw <- read_source_xlsx()
validate_raw(raw)
codebook <- read_codebook_xlsx()
stopifnot(nrow(codebook) == 30L)
stopifnot(identical(as.character(codebook[[1]]), paste0("V", 1:30)))

snapshot <- utils::read.csv("data/derived/survey_raw.csv", check.names = FALSE)
stopifnot(identical(dim(snapshot), dim(raw)))
max_diff <- max(abs(as.matrix(snapshot) - as.matrix(raw)))
if (max_diff != 0) stop("Derived CSV snapshot does not match source XLSX.")

validation <- data.frame(
  check = c("rows", "items", "missing_cells", "minimum_response", "maximum_response", "xlsx_csv_max_abs_difference"),
  value = c(nrow(raw), ncol(raw), sum(is.na(raw)), min(as.matrix(raw)), max(as.matrix(raw)), max_diff)
)
write_csv_safe(validation, "outputs/tables/input_validation.csv")
cat("Validated source XLSX, codebook and derived CSV snapshot.\n")

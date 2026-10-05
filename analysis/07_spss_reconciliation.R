source("R/functions.R")
ensure_dirs()
if (!requireNamespace("haven", quietly = TRUE)) stop("Package 'haven' is required.")
raw <- read_source_xlsx(); scores <- score_constructs(raw)
sav <- as.data.frame(haven::read_sav("data/original/Dataset_S2_SPSS_Data_File.sav"), check.names = FALSE)
raw_cols <- paste0("V", 1:30)
missing_raw <- setdiff(raw_cols, names(sav))
if (length(missing_raw)) stop("SPSS SAV missing raw items: ", paste(missing_raw, collapse = ", "))
raw_diff <- max(abs(as.matrix(sav[, raw_cols]) - as.matrix(raw)))
if (!is.finite(raw_diff) || raw_diff != 0) stop(sprintf("Raw XLSX and SAV items differ: max abs diff %.12g", raw_diff))

map <- c(PRA = "PRA_MEAN", MM = "MM_MEAN", MA = "MA_MEAN", MI = "MI_MEAN", GFA = "GFA_MEAN")
comp_rows <- lapply(names(map), function(k) {
  v <- map[[k]]
  if (!v %in% names(sav)) return(data.frame(construct = k, sav_variable = v, available = FALSE, max_abs_difference = NA_real_))
  d <- max(abs(as.numeric(sav[[v]]) - scores[[k]]), na.rm = TRUE)
  data.frame(construct = k, sav_variable = v, available = TRUE, max_abs_difference = d)
})
comp <- do.call(rbind, comp_rows)
write_csv_safe(comp, "outputs/tables/spss_composite_reconciliation.csv")
if (any(comp$available & comp$max_abs_difference > 1e-10)) stop("SPSS composite scores do not match documented raw-item means.")

write_csv_safe(data.frame(variable = names(sav), class = vapply(sav, function(z) paste(class(z), collapse = "/"), character(1))),
               "outputs/tables/spss_variable_inventory.csv")
write_csv_safe(data.frame(check = c("raw_xlsx_vs_sav_max_abs_difference", "n_sav_rows", "n_sav_variables"),
                          value = c(raw_diff, nrow(sav), ncol(sav))), "outputs/tables/spss_file_validation.csv")
cat("SPSS SAV raw-item and composite reconciliation complete. The SPV file remains preserved, not rewritten.\n")

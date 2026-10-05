source("R/functions.R")
ensure_dirs()
raw <- read_source_xlsx(); scores <- score_constructs(raw)
write_csv_safe(cbind(row_index = seq_len(nrow(scores)), scores), "outputs/restricted/respondent_construct_scores.csv")

item_desc <- data.frame(
  item = names(raw), n = nrow(raw),
  mean = vapply(raw, mean, numeric(1)),
  sd = vapply(raw, stats::sd, numeric(1)),
  median = vapply(raw, stats::median, numeric(1)),
  min = vapply(raw, min, numeric(1)),
  max = vapply(raw, max, numeric(1)), row.names = NULL
)
write_csv_safe(item_desc, "outputs/tables/item_descriptives.csv")

construct_desc <- data.frame(
  construct = names(scores), label = unname(construct_labels[names(scores)]), n = nrow(scores),
  mean = vapply(scores, mean, numeric(1)), sd = vapply(scores, stats::sd, numeric(1)),
  median = vapply(scores, stats::median, numeric(1)), min = vapply(scores, min, numeric(1)),
  max = vapply(scores, max, numeric(1)), row.names = NULL
)
write_csv_safe(construct_desc, "outputs/tables/construct_descriptives.csv")

reliability <- do.call(rbind, lapply(names(construct_items), function(k) {
  data.frame(construct = k, label = construct_labels[[k]], items = length(construct_items[[k]]),
             cronbach_alpha = cronbach_alpha_raw(raw[, construct_items[[k]], drop = FALSE]))
}))
reliability <- rbind(reliability,
  data.frame(construct = "ALL30", label = "All 30 survey items", items = 30,
             cronbach_alpha = cronbach_alpha_raw(raw)))
write_csv_safe(reliability, "outputs/tables/reliability.csv")
cat("Scoring, descriptives and reliability complete.\n")

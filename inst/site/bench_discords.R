#!/usr/bin/env Rscript
# Benchmark discord discovery — primarily HOT-SAX (Phase 2 z-norm precompute).
#
# Usage:
#   Rscript bench_discords.R [label] [out_csv]
#
# Example before/after on poptiplex:
#   git checkout 37353dc && R CMD INSTALL --library=$HOME/R/library .
#   Rscript inst/site/bench_discords.R pre-phase2
#   git checkout master && R CMD INSTALL --library=$HOME/R/library .
#   Rscript inst/site/bench_discords.R post-phase2
#   Rscript inst/site/bench_discords.R --compare bench_discords_results.csv

suppressPackageStartupMessages(library(jmotif))

args <- commandArgs(trailingOnly = TRUE)

if (length(args) >= 1 && args[[1]] == "--compare") {
  csv <- if (length(args) >= 2) args[[2]] else "bench_discords_results.csv"
  if (!file.exists(csv)) stop("CSV not found: ", csv)
  d <- read.csv(csv, stringsAsFactors = FALSE)
  agg <- aggregate(
    elapsed_sec ~ label + benchmark,
    data = d,
    FUN = function(x) c(mean = mean(x), sd = sd(x), min = min(x), max = max(x))
  )
  flat <- data.frame(
    label = agg$label,
    benchmark = agg$benchmark,
    mean_sec = agg$elapsed_sec[, "mean"],
    sd_sec = agg$elapsed_sec[, "sd"],
    min_sec = agg$elapsed_sec[, "min"],
    max_sec = agg$elapsed_sec[, "max"],
    stringsAsFactors = FALSE
  )
  labels <- unique(flat$label)
  if (length(labels) >= 2) {
    wide <- reshape(flat[, c("label", "benchmark", "mean_sec")],
                    idvar = "benchmark", timevar = "label", direction = "wide")
    pre <- grep("pre", labels, value = TRUE)[1]
    post <- grep("post", labels, value = TRUE)[1]
    if (is.na(pre)) pre <- labels[1]
    if (is.na(post)) post <- labels[length(labels)]
    pre_col <- paste0("mean_sec.", pre)
    post_col <- paste0("mean_sec.", post)
    if (pre_col %in% names(wide) && post_col %in% names(wide)) {
      wide$speedup <- wide[[pre_col]] / wide[[post_col]]
      cat("\n=== Speedup (", pre, " / ", post, " = times faster) ===\n", sep = "")
      print(wide[, c("benchmark", pre_col, post_col, "speedup")], row.names = FALSE)
    }
  }
  cat("\n=== Summary by label ===\n")
  print(flat, row.names = FALSE)
  quit(save = "no", status = 0)
}

label <- if (length(args) >= 1) args[[1]] else format(Sys.time(), "%Y%m%d-%H%M")
out_csv <- if (length(args) >= 2) args[[2]] else "bench_discords_results.csv"

benchmark_one <- function(name, expr, n = 5, warmup = 2) {
  for (i in seq_len(warmup)) eval(expr, envir = parent.frame())
  gc(verbose = FALSE)

  times <- numeric(n)
  for (i in seq_len(n)) {
    gc(verbose = FALSE)
    t0 <- proc.time()
    eval(expr, envir = parent.frame())
    times[i] <- (proc.time() - t0)[["elapsed"]]
  }

  data.frame(
    label = label,
    benchmark = name,
    n = n,
    elapsed_sec = times,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    stringsAsFactors = FALSE
  )
}

x <- ecg0606
x_medium <- rep(ecg0606, 3L)

cat("=== jmotif discord benchmarks ===\n")
cat("label:", label, "\n")
cat("package:", as.character(packageVersion("jmotif")), "\n")
cat("ecg0606 length:", length(x), "\n")
cat("medium series length:", length(x_medium), "\n\n")

cases <- list(
  list(name = "hotsax_ecg0606_4disc",
       expr = quote(find_discords_hotsax(x, 100, 4, 4, 0.01, 4)),
       n = 10, warmup = 3),
  list(name = "hotsax_ecg0606_5disc",
       expr = quote(find_discords_hotsax(x, 100, 4, 4, 0.01, 5)),
       n = 10, warmup = 3),
  list(name = "hotsax_medium_4disc",
       expr = quote(find_discords_hotsax(x_medium, 100, 4, 4, 0.01, 4)),
       n = 5, warmup = 2),
  list(name = "brute_ecg0606_4disc",
       expr = quote(find_discords_brute_force(x, 100, 4, 0.01)),
       n = 5, warmup = 2),
  list(name = "wordbag_ecg0606",
       expr = quote(series_to_wordbag(x, 60, 6, 6, "exact", 0.01)),
       n = 10, warmup = 3)
)

results <- NULL
for (case in cases) {
  cat("Running", case$name, "...\n")
  flush.console()
  chunk <- benchmark_one(case$name, case$expr, n = case$n, warmup = case$warmup)
  print(aggregate(elapsed_sec ~ 1, data = chunk, FUN = mean))
  results <- if (is.null(results)) chunk else rbind(results, chunk)
}

agg <- aggregate(elapsed_sec ~ benchmark, data = results, FUN = function(v) {
  c(mean = mean(v), sd = sd(v), min = min(v), max = max(v))
})
summary_df <- data.frame(
  benchmark = agg$benchmark,
  mean_sec = round(agg$elapsed_sec[, "mean"], 4),
  sd_sec = round(agg$elapsed_sec[, "sd"], 4),
  min_sec = round(agg$elapsed_sec[, "min"], 4),
  max_sec = round(agg$elapsed_sec[, "max"], 4)
)

cat("=== Run summary (label =", label, ") ===\n")
print(summary_df, row.names = FALSE)

if (file.exists(out_csv)) {
  existing <- read.csv(out_csv, stringsAsFactors = FALSE)
  combined <- rbind(existing, results)
} else {
  combined <- results
}
write.csv(combined, out_csv, row.names = FALSE)
cat("\nAppended to", out_csv, "(", nrow(combined), "rows )\n")

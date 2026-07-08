library(jmotif)

get_rss_kb <- function() {
  pid <- Sys.getpid()
  as.numeric(system2("ps", c("-o", "rss=", "-p", pid), stdout = TRUE))
}

run_leak_test <- function(label, expr, n = 500, warmup = 20) {
  for (i in seq_len(warmup)) eval(expr)
  gc(verbose = FALSE)
  Sys.sleep(0.3)

  rss0 <- get_rss_kb()
  t0 <- proc.time()

  for (i in seq_len(n)) eval(expr)

  gc(verbose = FALSE)
  Sys.sleep(0.3)
  rss1 <- get_rss_kb()
  elapsed <- (proc.time() - t0)[["elapsed"]]

  delta_mb <- (rss1 - rss0) / 1024
  per_call_kb <- (rss1 - rss0) / n

  data.frame(
    test = label,
    iterations = n,
    rss_start_mb = round(rss0 / 1024, 2),
    rss_end_mb = round(rss1 / 1024, 2),
    delta_mb = round(delta_mb, 2),
    per_call_kb = round(per_call_kb, 2),
    seconds = round(elapsed, 2),
    stringsAsFactors = FALSE
  )
}

cat("=== jmotif memory leak profiling ===\n")
cat("PID:", Sys.getpid(), "\n\n")

repair_str <- "abc abc cba cba bac xxx abc abc cba cba bac"
sax_string <- paste(
  unlist(sax_via_window(ecg0606, 160, 4, 4, "none", 0.001)),
  collapse = " "
)

w <- 60; p <- 6; a <- 6
data("CBF")
cyl <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 1, ], w, p, a, "exact", 0.01)
bell <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 2, ], w, p, a, "exact", 0.01)
funnel <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 3, ], w, p, a, "exact", 0.01)
tfidf <- bags_to_tfidf(list(cylinder = cyl, bell = bell, funnel = funnel))
bag <- series_to_wordbag(CBF$data_test[1, ], w, p, a, "exact", 0.01)

cat("Baseline RSS:", round(get_rss_kb() / 1024, 2), "MB\n\n")

results <- rbind(
  run_leak_test("str_to_repair_grammar", quote(str_to_repair_grammar(sax_string)), n = 800),
  run_leak_test("find_discords_rra (small)", quote(find_discords_rra(ecg0606[1:600], 100, 4, 4, "none", 0.01, 1)), n = 200),
  run_leak_test("cosine_sim", quote(cosine_sim(list(bag = bag, tfidf = tfidf))), n = 2000),
  run_leak_test("CONTROL: znorm", quote(znorm(ecg0606, 0.01)), n = 2000),
  run_leak_test("CONTROL: euclidean_dist", quote(euclidean_dist(ecg0606[1:100], ecg0606[101:200])), n = 5000),
  run_leak_test("CONTROL: find_discords_hotsax", quote(find_discords_hotsax(ecg0606[1:600], 100, 4, 4, 0.01, 1)), n = 300)
)

print(results, row.names = FALSE)

cat("\n=== Extended run: str_to_repair_grammar (2000 iterations) ===\n")
for (i in seq_len(50)) str_to_repair_grammar(sax_string)
gc(verbose = FALSE)
Sys.sleep(0.2)

samples <- numeric(21)
samples[1] <- get_rss_kb()
for (batch in seq_len(20)) {
  for (j in seq_len(100)) str_to_repair_grammar(sax_string)
  if (batch %% 5 == 0) gc(verbose = FALSE)
  samples[batch + 1] <- get_rss_kb()
}
cat("RSS MB sampled every 100 calls:\n")
cat(paste(round(samples / 1024, 2), collapse = " -> "), "\n")
cat("Total growth:", round((tail(samples, 1) - samples[1]) / 1024, 2), "MB\n")

cat("\n=== Extended run: find_discords_rra full ecg0606 (100 iterations) ===\n")
for (i in seq_len(5)) find_discords_rra(ecg0606, 100, 4, 4, "none", 0.01, 1)
gc(verbose = FALSE)
Sys.sleep(0.2)

rra_samples <- numeric(11)
rra_samples[1] <- get_rss_kb()
for (batch in seq_len(10)) {
  for (j in seq_len(10)) find_discords_rra(ecg0606, 100, 4, 4, "none", 0.01, 1)
  gc(verbose = FALSE)
  rra_samples[batch + 1] <- get_rss_kb()
}
cat("RSS MB sampled every 10 RRA calls:\n")
cat(paste(round(rra_samples / 1024, 2), collapse = " -> "), "\n")
cat("Total growth:", round((tail(rra_samples, 1) - rra_samples[1]) / 1024, 2), "MB\n")

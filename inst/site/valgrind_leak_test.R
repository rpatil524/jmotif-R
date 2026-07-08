# Minimal script for valgrind leak detection.
# Keep iterations low — valgrind is ~10-50x slower than native.
suppressPackageStartupMessages(library(jmotif))

cat("=== valgrind leak test ===\n")

# 1. RePair grammar (F-01 primary suspect)
sax_string <- "abc abc cba cba bac xxx abc abc cba cba bac"
for (i in 1:5) invisible(str_to_repair_grammar(sax_string))

# 2. RRA (calls _str_to_repair_grammar internally)
for (i in 1:2) invisible(find_discords_rra(ecg0606[1:600], 100, 4, 4, "none", 0.01, 1))

# 3. cosine_sim (F-02 suspect)
w <- 60; p <- 6; a <- 6
data("CBF", envir = environment())
cyl <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 1, ], w, p, a, "exact", 0.01)
bell <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 2, ], w, p, a, "exact", 0.01)
funnel <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 3, ], w, p, a, "exact", 0.01)
tfidf <- bags_to_tfidf(list(cylinder = cyl, bell = bell, funnel = funnel))
bag <- series_to_wordbag(CBF$data_test[1, ], w, p, a, "exact", 0.01)
for (i in 1:10) invisible(cosine_sim(list(bag = bag, tfidf = tfidf)))

# 4. Control — should be clean
for (i in 1:10) invisible(znorm(ecg0606[1:200], 0.01))

cat("Done.\n")

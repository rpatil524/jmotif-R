library(jmotif)

cat("=== 1. Full testthat suite ===\n")
library(testthat)
test_dir("/Users/I0466996/git/jmotif-R/tests/testthat", reporter = "summary")
cat("\n")

cat("=== 2. HOT-SAX exact ecg0606 discords ===\n")
d <- find_discords_hotsax(ecg0606, 100, 4, 4, 0.01, 4)
print(d)
expected_dist <- c(5.279080, 4.175756, 2.392998, 2.375541)
expected_pos  <- c(430, 318, 2080, 25)
stopifnot(all(abs(d$nn_distance - expected_dist) < 1e-5))
stopifnot(all(d$position == expected_pos))
cat("PASS: HOT-SAX positions and distances match 1.3.0 reference\n\n")

cat("=== 3. Brute-force exact ecg0606 discords ===\n")
db <- find_discords_brute_force(ecg0606, 100, 4, 0.01)
print(db)
stopifnot(abs(db[db$position == 430, ]$nn_distance - 5.279080) < 1e-5)
cat("PASS: brute-force top discord\n\n")

cat("=== 4. RRA ecg0606 top discord region ===\n")
dr <- find_discords_rra(ecg0606, 100, 4, 4, "none", 0.01, 4)
print(dr)
stopifnot(dr[1, ]$start <= 430 && dr[1, ]$end > 430)
cat("PASS: RRA top discord covers position 430\n\n")

cat("=== 5. RePair grammar (paper example) ===\n")
str <- "abc abc cba cba bac xxx abc abc cba cba bac"
grammar <- str_to_repair_grammar(str)
stopifnot(grammar[[1]]$rule_string == "R4 xxx R4")
stopifnot(grammar[[4]]$rule_string == "R3")
cat("PASS: RePair grammar structure\n\n")

cat("=== 6. cosine_sim + SAX-VSM ===\n")
data("CBF")
w <- 60; p <- 6; a <- 6
cyl <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 1, ], w, p, a, "exact", 0.01)
bell <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 2, ], w, p, a, "exact", 0.01)
funnel <- manyseries_to_wordbag(CBF$data_train[CBF$labels_train == 3, ], w, p, a, "exact", 0.01)
tfidf <- bags_to_tfidf(list(cylinder = cyl, bell = bell, funnel = funnel))
bag <- series_to_wordbag(CBF$data_test[1, ], w, p, a, "exact", 0.01)
cs <- cosine_sim(list(bag = bag, tfidf = tfidf))
stopifnot(length(cs$cosines) == 3, all(!is.na(cs$cosines)))
cat("PASS: cosine_sim returns 3 finite cosines\n\n")

cat("=== 7. HOT-SAX reproducibility (seed) ===\n")
d1 <- find_discords_hotsax(ecg0606, 100, 4, 4, 0.01, 4, seed = 42)
d2 <- find_discords_hotsax(ecg0606, 100, 4, 4, 0.01, 4, seed = 42)
stopifnot(all(d1$position == d2$position))
stopifnot(all(abs(d1$nn_distance - d2$nn_distance) < 1e-10))
cat("PASS: seeded HOT-SAX is deterministic\n\n")

cat("=== 8. sax_via_window spot check ===\n")
dat <- read.table(textConnection(
  gsub("\n", " ", "0 0 0 0 0 -0.270340178359072 -0.367828308500142 0.666980581124872 1.87088147328446
2.14548907684624 -0.480859313143032 -0.72911654245842 -0.490308602315934 -0.66152028906509
-0.221049033806403 0.367003418871239 0.631073992586373 0.0487728723414486 0.762655178750436
0.78574757843331 0.338239686422963 0.784206454089066 -2.14265084073625 2.11325193044223
0.186018356196443 0 0 0 0 0 0 0 0 0 0 0.519132472499234 -2.604783141655
-0.244519550114012 -1.6570790528784 3.34184602886343 2.10361226260999 1.9796808733979
-0.822247322003058 1.06850578033292 -0.678811824405992 0.804225748913681 0.57363964388698
0.437113583759113 0.437208643628268 0.989892093383503 1.76545983424176 0.119483882364649
-0.222311941138971 -0.74669456611669 -0.0663660879732063 0 0 0 0 0")
), as.is = TRUE)
sax1 <- sax_via_window(t(dat), 6, 3, 3, "none", 0.01)
stopifnot(sax1[[1]] == "cca", sax1[[54]] == "acc")
cat("PASS: sax_via_window reference words\n\n")

cat("ALL CORRECTNESS CHECKS PASSED\n")

## jmotif 1.3.2 — CRAN submission

### Test environments
* local: macOS, R 4.x, `R CMD check` OK (with `--as-cran` recommended on poptiplex before upload)
* GitHub Actions: ubuntu / macos / windows, R release

### R CMD check results
0 errors | 0 warnings | 0 notes (verify on submit box)

### Downstream dependencies
None known.

### revdepcheck
Not run (no known reverse dependencies with tight coupling).

### What changed since 1.3.1 (CRAN)

**Bug fix (user-visible):** `find_discords_rra(..., seed = 0L)` (and any non-negative
seed) could **segfault** when grammar rule intervals outnumbered the series length —
the phase-2 visit buffer was sized to `length(ts)` instead of the interval count.

**Tests:** tier-B RRA pins on bundled `ecg0606` (exact span/distance at w100/w120;
w150/p7/a4 rejects zero-gap boundary discords).

**Docs / packaging only otherwise:** README CRAN path, corrected header anchors,
roxygen examples on SAX-VSM and sliding-window helpers, `NEWS.md` shipped in tarball,
exclude audit HTML from builds, `DESCRIPTION` summary refresh.

No algorithm changes to SAX, HOT-SAX, brute-force, RePair, or SAX-VSM beyond the RRA
buffer fix.

### Previous release (1.3.1) note for CRAN

1.3.1 was a performance / memory release with identical numerical results on regression
tests; 1.3.0 introduced intentional behavioral alignment changes (documented in NEWS).

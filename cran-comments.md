## Submission

This is a feature release (1.3.0) of the jmotif package.

It aligns the SAX / discord / RRA / SAX-VSM implementations with the reference
Python (saxpy) and Java (jMotif) implementations and the Matrix Profile / MASS
convention, and fixes a floating-point boundary bug in fractional PAA.

Note: this release contains intentional behavioral changes (documented in
NEWS.md). Numeric outputs for a small fraction of inputs differ from 1.2.x:

* z-normalization now uses the population standard deviation (divide by n),
  giving each normalized window unit empirical variance -- the assumption behind
  SAX's equiprobable Gaussian breakpoints;
* SAX maps a value exactly on a breakpoint to the symbol above the cut;
* fractional PAA snaps the final segment break to the series length, fixing an
  IEEE-754 rounding bug that dropped the last sample on ~5-6% of non-divisible
  (n, paa_num) shapes;
* HOT-SAX and brute-force discord search now measure nearest-neighbour distance
  on z-normalized windows (the SAX shape-similarity premise), with a
  deterministic tie-break.

There are no reverse dependencies on CRAN, so no downstream packages are
affected by these changes.

## Test environments

* macOS (local), R 4.5.3 -- R CMD check --as-cran
* Ubuntu (local), R 4.6.1
* win-builder (devel and release)
* R-hub (ubuntu, macos, windows)

## R CMD check results

0 errors | 0 warnings | 1 note

The note is the standard "New submission / days since last update" style note for
a maintainer re-submission; there are no ERRORs or WARNINGs. (Local runs without
a LaTeX/pandoc/HTML-tidy toolchain additionally report environment-only notes for
the PDF/HTML manual, which do not occur on the CRAN build machines.)

## Downstream dependencies

There are no reverse dependencies.

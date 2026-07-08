## Submission

This is a maintenance / performance release (1.3.1) of the jmotif package.

It fixes memory leaks in the native RePair/RRA/cosine_sim paths, improves HOT-SAX,
SAX sliding-window, and RRA distance performance, and adds a bounds check in
`idx_to_letter()`. There are no intentional behavioral changes relative to 1.3.0;
discord positions, distances, and SAX outputs are unchanged (169 tests).

There are no reverse dependencies on CRAN.

## Test environments

* macOS (local), R 4.6.1 — `R CMD check --as-cran --no-manual`
* Ubuntu 24.04 (poptiplex), R 4.6.1 — `R CMD check --as-cran --no-manual`
* win-builder (devel and release) — submitted 2026-07-08

## R CMD check results

0 errors | 0 warnings | 0–1 notes (local `--no-manual` runs)

Local runs without a full LaTeX/pandoc/HTML-tidy toolchain report environment-only
notes for the PDF/HTML manual; these do not occur on CRAN build machines.

Linux may report a non-portable compiler flag (`-mno-omit-leaf-frame-pointer`)
from the system R build; this is injected by the platform R configuration, not
the package Makevars.

## Downstream dependencies

There are no reverse dependencies.

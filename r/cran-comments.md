## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Test environments

* local Windows 11, R 4.5.2 (`R CMD check --as-cran`, with the PDF manual)
* GitHub Actions: ubuntu-latest (R release, devel and oldrel-1),
  windows-latest (R release and devel), macos-latest (R release)

## Notes for the reviewers

* The package downloads public data from the Brazilian government
  (<https://www.gov.br/cidades>). Nothing is downloaded during the checks:
  examples that need the internet are in `\donttest{}` and guarded by
  `interactive() && fonte_disponivel()`, and tests that need the internet or
  the full data files are skipped on CRAN. When the source is unreachable,
  `baixar()` and `ler()` return `NULL` invisibly with an informative message
  (no error and no warning), following the CRAN policy on internet resources.
* Files are only written to `tools::R_user_dir("saneabr", "cache")`, or to a
  directory the user chooses; tests use temporary directories.
* The documentation is in Portuguese (`Language: pt-BR`), because the data and
  its users are Brazilian; the DESCRIPTION is in English.

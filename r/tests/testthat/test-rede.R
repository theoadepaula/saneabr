test_that("a fonte responde e o arquivo bate com o catalogo", {
  skip_on_cran()
  skip_on_ci()
  if (!identical(Sys.getenv("SANEABR_TESTAR_REDE"), "true")) {
    skip("SANEABR_TESTAR_REDE != true")
  }
  skip_if_offline("www.gov.br")
  d <- withr::local_tempdir()
  withr::local_envvar(SANEABR_CACHE = d)
  # o menor arquivo de dados do catalogo
  cat_ <- catalogo(tipo = "dados")
  r <- cat_[which.min(cat_$bytes), ]
  expect_no_warning(p <- suppressMessages(baixar(r$sistema, r$modulo, r$ano)))
  expect_true(all(file.exists(p)))
})

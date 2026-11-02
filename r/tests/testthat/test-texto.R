test_that("normalizar_codigo tira *, espacos e sufixos e passa a maiusculas", {
  x <- c("GTR1030*", "GTR2002 *", "Co119", "UP088 - lat.", "GTR3130\u00a0",
         "CAD1000", "POP_TOT", "Cod_IBGE", "-", NA, "Sim/N\u00e3o", "GTR1107A*")
  expect_identical(
    saneabr:::normalizar_codigo(x),
    c("GTR1030", "GTR2002", "CO119", "UP088", "GTR3130", "CAD1000",
      NA, NA, NA, NA, NA, "GTR1107A")
  )
})

test_that("slug tira acento e pontuacao", {
  expect_identical(saneabr:::slug("C\u00d3DIGO DO IBGE"), "codigo_do_ibge")
  expect_identical(saneabr:::slug("\u00c1rea (Km\u00b2)"), "area_km2")
  expect_identical(saneabr:::slug("  Munic\u00edpio onde est\u00e1 a unidade "),
                   "municipio_onde_esta_a_unidade")
})

test_that("municipio_7 calcula o DV do IBGE e respeita as excecoes", {
  expect_identical(saneabr:::municipio_7(c("110001", "355030", "530010")),
                   c("1100015", "3550308", "5300108"))
  # tres dos 9 que o IBGE numerou fora da regra
  expect_identical(saneabr:::municipio_7(c("220191", "261153", "520396")),
                   c("2201919", "2611533", "5203962"))
  expect_identical(saneabr:::municipio_7(c("1100015", NA, "abc")),
                   c("1100015", NA, "abc"))
})

test_that("aparar remove espaco nao separavel nas pontas", {
  expect_identical(saneabr:::aparar("\u00a0 Abc \t"), "Abc")
})

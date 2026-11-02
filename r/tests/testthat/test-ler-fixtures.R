test_that("ler() reproduz o esperado em cada fixture", {
  usar_extracao_temporaria()
  casos <- casos_fixtures()
  for (i in seq_len(nrow(casos))) {
    cs <- casos[i, ]
    x <- ler(cs$sistema, cs$modulo, cs$ano, cs$tabela,
             arquivo = file.path(dir_fixtures(), cs$arquivo))
    expect_s3_class(x, "tbl_df")
    comparar_esperado(x, cs$caso)
  }
})

test_that("ler() normaliza codigos e a chave municipal", {
  usar_extracao_temporaria()
  x <- ler("snis", "rs", 2021, "informacoes",
           arquivo = file.path(dir_fixtures(), "snis_rs_sem_ibge.xlsx"))
  expect_identical(names(x)[1:2], c("id_municipio", "ano"))
  expect_true(all(grepl("^[0-9]{7}$", x$id_municipio)))
  expect_identical(x$id_municipio, saneabr:::municipio_7(x$id_municipio_snis))
  expect_true("CO119" %in% names(x))
  expect_type(x$CO119, "double")

  s <- ler("sinisa", "rs", 2024, "manejo",
           arquivo = file.path(dir_fixtures(), "sinisa_rs_2024_mini.zip"))
  expect_true(all(c("GTR1028", "CAD1000") %in% names(s)))
  expect_false(any(grepl("[*]", names(s))))
  expect_identical(unique(s$ano), 2024L)
})

test_that("Nome/UF e separado", {
  usar_extracao_temporaria()
  f <- ler("snis", "rs", 2022, "unidades_fluxos",
           arquivo = file.path(dir_fixtures(), "snis_rs_2022_mini.zip"))
  expect_true(all(c("UP025", "UP025_uf") %in% names(f)))
  expect_false(any(grepl("/", f$UP025)))
})

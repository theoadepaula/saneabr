# Le os arquivos completos. So roda com SANEABR_DADOS_BRUTOS apontando para uma
# pasta no layout do cache (<SISTEMA>/<MODULO>/<ano>/<arquivo>); nunca no CRAN/CI.
# Os valores esperados foram lidos celula a celula na planilha bruta, sem o pacote.

test_that("SNIS RS 2022 e SINISA RS 2024 completos", {
  d <- pular_sem_dados_brutos()
  withr::local_envvar(SANEABR_CACHE = d)
  usar_extracao_temporaria()

  inf <- ler("snis", "rs", 2022)
  expect_identical(nrow(inf), 5060L)
  expect_identical(anyDuplicated(inf$id_municipio), 0L)
  expect_true(all(grepl("^[0-9]{7}$", inf$id_municipio)))
  # Planilha_Informacoes_RS_2022.xlsx, Sao Paulo/SP, coluna CO119
  expect_equal(inf$CO119[inf$id_municipio == "3550308"], 4119170.2)

  ind <- ler("snis", "rs", 2022, "indicadores")
  expect_identical(nrow(ind), 5060L)
  # Planilha_Indicadores_RS_2022.xlsx, Brasilia/DF, coluna IN015
  expect_equal(ind$IN015[ind$id_municipio == "5300108"], 97.77)

  man <- ler("sinisa", "rs", 2024, "manejo")
  expect_identical(nrow(man), 5570L)
  # ..._Formulario_Manejo_2024.xlsx, aba Manejo_Residuos_Solidos_Urbanos, Belo Horizonte/MG
  expect_equal(man$GTR1028[man$id_municipio == "3106200"], 959252)

  col <- ler("sinisa", "rs", 2024, "coleta_destinacao")
  expect_gt(nrow(col), 5570)
})

test_that("SINISA 2023 (rar) e SNIS 2014 (xls) completos", {
  d <- pular_sem_dados_brutos()
  skip_if_not_installed("archive")
  withr::local_envvar(SANEABR_CACHE = d)
  usar_extracao_temporaria()

  ind <- ler("sinisa", "rs", 2023, "indicadores")
  expect_identical(nrow(ind), 5570L)
  # SINISA_RESIDUOS_Indicadores_2023.xlsx, Recife/PE, coluna IRS1004
  expect_equal(ind$IRS1004[ind$id_municipio == "2611606"], 1.57)

  i14 <- ler("snis", "rs", 2014)
  expect_identical(nrow(i14), 3765L)
  # Planilha_Informacoes_RS_2014.xls, Porto Alegre/RS (431490 -> 4314902), POP_TOT
  expect_equal(i14$POP_TOT[i14$id_municipio == "4314902"], 1472482)
})

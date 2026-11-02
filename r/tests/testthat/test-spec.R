test_that("a spec carrega e e coerente", {
  lay <- saneabr:::spec_layouts()
  expect_identical(nchar(lay$texto$acentos_de), nchar(lay$texto$acentos_para))
  expect_length(lay$municipio$excecoes, 9)
  for (e in lay$eras) {
    expect_true(e$tabela_padrao %in% names(e$tabelas))
    for (a in unlist(e$anos)) {
      cat_ <- catalogo(e$sistema, e$modulo, a, "dados")
      expect_true(any(grepl(e$arquivo_catalogo_regex, cat_$arquivo, perl = TRUE)),
                  label = paste(e$sistema, a))
    }
  }
})

test_that("catalogo() filtra e traz SHA-256 validos", {
  x <- catalogo()
  expect_named(x, c("sistema", "modulo", "ano", "tipo", "arquivo", "url", "sha256",
                    "formato", "bytes", "data_verificacao"))
  expect_true(all(grepl("^[0-9a-f]{64}$", x$sha256)))
  expect_true(all(grepl("^https?://", x$url)))
  rs <- catalogo("sinisa", "rs", 2024, "dados")
  expect_identical(nrow(rs), 1L)
  expect_identical(rs$arquivo, "SINISA_RESIDUOS_planilhas_2024.zip")
})

test_that("tabelas() lista as tabelas da era", {
  expect_true("informacoes" %in% tabelas("snis", "rs", 2022)$tabela)
  expect_false("politicas_planos" %in% tabelas("snis", "rs", 2015)$tabela)
  t24 <- tabelas("SINISA", "RS", 2024)
  expect_identical(t24$tabela[t24$padrao], "manejo")
})

test_that("dicionario(), correspondencia() e mudancas()", {
  d <- dicionario("snis", "rs")
  expect_true("CO119" %in% d$codigo)
  expect_true(all(d$modulo == "RS"))
  co <- correspondencia()
  expect_true(all(co$evidencia_documental))
  expect_false(any(co$tipo_relacao %in% c("candidata", "sem_par")))
  com_cand <- correspondencia(candidatas = TRUE)
  expect_gt(nrow(com_cand), nrow(co))
  expect_true(all(c("tipo_relacao", "evidencia", "qualidade_snis", "qualidade_sinisa")
                  %in% names(co)))
  # CO119 nao tem par documentado com GTR1028 (ver ?correspondencia)
  expect_false(any(co$codigo_snis == "CO119" & co$codigo_sinisa == "GTR1028"))
  expect_true("codigo_renomeado" %in% mudancas("rs")$tipo_mudanca)
})

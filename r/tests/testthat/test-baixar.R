test_that("dir_cache() respeita a variavel de ambiente e a opcao", {
  d <- withr::local_tempdir()
  withr::local_envvar(SANEABR_CACHE = d)
  expect_identical(dir_cache(), normalizePath(d, winslash = "/", mustWork = FALSE))
  withr::local_options(saneabr.cache = file.path(d, "outro"))
  expect_match(dir_cache(), "outro$")
})

test_that("conferir_sha avisa quando a fonte republicou", {
  f <- withr::local_tempfile(fileext = ".zip")
  writeBin(charToRaw("abc"), f)
  sha_abc <- "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
  expect_silent(saneabr:::conferir_sha(f, sha_abc))
  expect_warning(saneabr:::conferir_sha(f, strrep("0", 64)),
                 class = "saneabr_sha_diferente")
})

test_that("baixar() usa o cache, baixa com .part e confere o SHA-256", {
  d <- withr::local_tempdir()
  withr::local_envvar(SANEABR_CACHE = d)
  conteudo <- charToRaw("conteudo falso")
  chamadas <- 0
  httr2::local_mocked_responses(function(req) {
    chamadas <<- chamadas + 1
    httr2::response(status_code = 200, body = conteudo)
  })
  expect_warning(
    expect_message(p <- baixar("sinisa", "rs", 2024), "Baixando"),
    class = "saneabr_sha_diferente"
  )
  expect_true(file.exists(p))
  expect_false(file.exists(paste0(p, ".part")))
  expect_identical(readBin(p, "raw", 100), conteudo)
  # segunda vez: nao baixa de novo, mas confere de novo o SHA-256
  expect_warning(baixar("sinisa", "rs", 2024), class = "saneabr_sha_diferente")
  expect_identical(chamadas, 1)
})

test_that("HTTP diferente de 200: mensagem e NULL, sem erro, warning nem arquivo", {
  d <- withr::local_tempdir()
  withr::local_envvar(SANEABR_CACHE = d)
  httr2::local_mocked_responses(function(req) httr2::response(status_code = 404))
  expect_no_warning(
    expect_message(p <- baixar("sinisa", "rs", 2024), class = "saneabr_fonte_indisponivel")
  )
  expect_null(p)
  expect_length(list.files(d, recursive = TRUE, all.files = TRUE), 0)
})

test_that("sem conexao: baixar() e ler() devolvem NULL com mensagem", {
  d <- withr::local_tempdir()
  withr::local_envvar(SANEABR_CACHE = d)
  httr2::local_mocked_responses(function(req) stop("Could not resolve host: www.gov.br"))
  expect_no_warning(
    expect_message(p <- baixar("snis", "rs", 2022), "resolve host")
  )
  expect_null(p)
  expect_no_warning(
    expect_message(x <- ler("snis", "rs", 2022), class = "saneabr_fonte_indisponivel")
  )
  expect_null(x)
})

test_that("fonte_disponivel() nunca gera erro", {
  httr2::local_mocked_responses(function(req) stop("sem rede"))
  expect_false(fonte_disponivel())
  httr2::local_mocked_responses(function(req) httr2::response(status_code = 206))
  expect_true(fonte_disponivel())
})

test_that("o User-Agent identifica o pacote", {
  expect_match(saneabr:::user_agent(), "saneabr/[0-9.]+")
})

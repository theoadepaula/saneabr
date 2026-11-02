dir_fixtures <- function() test_path("fixtures")

casos_fixtures <- function() {
  utils::read.csv(file.path(dir_fixtures(), "casos.csv"), colClasses = "character")
}

# Compara um data frame com fixtures/esperado_<caso>.csv e .tipos
comparar_esperado <- function(x, caso) {
  base <- file.path(dir_fixtures(), paste0("esperado_", caso))
  esp <- utils::read.csv(paste0(base, ".csv"), colClasses = "character",
                         na.strings = "", check.names = FALSE, fileEncoding = "UTF-8")
  tipos <- utils::read.csv(paste0(base, ".tipos"), header = FALSE, colClasses = "character")
  expect_identical(names(x), names(esp))
  expect_identical(nrow(x), nrow(esp))
  expect_identical(unname(vapply(x, function(v) class(v)[1], "")), tipos[[2]])
  for (n in names(esp)) {
    if (is.numeric(x[[n]])) {
      expect_equal(as.numeric(x[[n]]), as.numeric(esp[[n]]), tolerance = 1e-12, label = n)
    } else {
      expect_identical(as.character(x[[n]]), esp[[n]], label = n)
    }
  }
}

# Pasta com os arquivos brutos no layout do cache (<SISTEMA>/<MODULO>/<ano>/),
# por exemplo snis-sinisa/dados_brutos. Nunca no CRAN nem no CI.
pular_sem_dados_brutos <- function() {
  skip_on_cran()
  skip_on_ci()
  d <- Sys.getenv("SANEABR_DADOS_BRUTOS")
  if (!nzchar(d) || !dir.exists(d)) skip("SANEABR_DADOS_BRUTOS nao definido")
  d
}

usar_extracao_temporaria <- function(env = parent.frame()) {
  d <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(SANEABR_EXTRACAO = d, .local_envir = env)
}

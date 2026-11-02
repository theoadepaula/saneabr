# Acesso a spec (inst/extdata/spec), copiada de ../spec por
# ferramentas/sincronizar_spec.R. Nenhuma regra de leitura mora no codigo:
# regex, tabelas de nomes, eras e excecoes vem daqui.

.saneabr <- new.env(parent = emptyenv())

spec_dir <- function() {
  system.file("extdata", "spec", package = "saneabr", mustWork = TRUE)
}

spec_json <- function(nome) {
  chave <- paste0("json_", nome)
  if (is.null(.saneabr[[chave]])) {
    .saneabr[[chave]] <- jsonlite::read_json(
      file.path(spec_dir(), paste0(nome, ".json")),
      simplifyVector = FALSE
    )
  }
  .saneabr[[chave]]
}

spec_layouts <- function() spec_json("layouts")
spec_rede <- function() spec_json("rede")

spec_csv <- function(rel) {
  chave <- paste0("csv_", rel)
  if (is.null(.saneabr[[chave]])) {
    x <- utils::read.csv(
      file.path(spec_dir(), rel),
      colClasses = "character", na.strings = character(),
      fileEncoding = "UTF-8", check.names = FALSE
    )
    .saneabr[[chave]] <- x
  }
  .saneabr[[chave]]
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# Aceita "snis", "SNIS", "rs", "RS" etc.
padronizar_sistema <- function(sistema) {
  s <- toupper(as.character(sistema)[1])
  if (!s %in% c("SNIS", "SINISA")) {
    cli::cli_abort("{.arg sistema} deve ser {.val snis} ou {.val sinisa}, n\u00e3o {.val {sistema}}.")
  }
  s
}

padronizar_modulo <- function(modulo) {
  m <- toupper(as.character(modulo)[1])
  if (!m %in% c("RS", "AE", "AP", "GM")) {
    cli::cli_abort("{.arg modulo} deve ser {.val rs}, {.val ae}, {.val ap} ou {.val gm}, n\u00e3o {.val {modulo}}.")
  }
  m
}

padronizar_ano <- function(ano) {
  a <- suppressWarnings(as.integer(ano)[1])
  if (is.na(a)) cli::cli_abort("{.arg ano} deve ser um ano, como {.val 2022}.")
  a
}

# Normalizacoes de texto e de codigo definidas em spec/layouts.json
# (secoes "texto", "codigo" e "municipio"). Ver spec/README.md.

classe_espacos <- function() {
  extra <- paste(unlist(spec_layouts()$texto$espacos_extra), collapse = "")
  paste0("[\\s", extra, "]")
}

aparar <- function(x) {
  cls <- classe_espacos()
  gsub(paste0("^", cls, "+|", cls, "+$"), "", x, perl = TRUE)
}

sem_acento <- function(x) {
  tx <- spec_layouts()$texto
  chartr(enc2utf8(tx$acentos_de), enc2utf8(tx$acentos_para), enc2utf8(x))
}

slug <- function(x) {
  x <- sem_acento(tolower(enc2utf8(x)))
  x <- gsub("[^a-z0-9]+", "_", x, perl = TRUE)
  gsub("^_+|_+$", "", x, perl = TRUE)
}

escapar_classe <- function(ch) {
  gsub("([][\\\\^-])", "\\\\\\1", ch, perl = TRUE)
}

# Devolve o codigo normalizado (CO119, GTR1030, UP088) ou NA.
normalizar_codigo <- function(x) {
  cfg <- spec_layouts()$codigo
  rem <- paste(escapar_classe(unlist(cfg$remover)), collapse = "")
  limpo <- gsub(paste0("[", rem, "]|", classe_espacos()), "", x, perl = TRUE)
  limpo <- toupper(limpo)
  ok <- !is.na(limpo) & grepl(cfg$regex, limpo, perl = TRUE)
  out <- rep(NA_character_, length(x))
  out[ok] <- sub(cfg$regex, "\\1", limpo[ok], perl = TRUE)
  out
}

# Digito verificador do codigo IBGE de municipio (6 -> 7 digitos).
dv_ibge <- function(cod6) {
  cfg <- spec_layouts()$municipio
  pesos <- unlist(cfg$pesos)
  vapply(cod6, function(c6) {
    d <- as.integer(strsplit(c6, "", fixed = TRUE)[[1]])
    p <- d * pesos
    p <- ifelse(p > 9, p %/% 10 + p %% 10, p)
    as.character((10 - sum(p) %% 10) %% 10)
  }, character(1), USE.NAMES = FALSE)
}

municipio_7 <- function(x) {
  cfg <- spec_layouts()$municipio
  exc <- unlist(cfg$excecoes)
  x <- as.character(x)
  seis <- !is.na(x) & grepl("^[0-9]{6}$", x)
  out <- x
  if (any(seis)) {
    c6 <- x[seis]
    sete <- paste0(c6, dv_ibge(c6))
    hit <- c6 %in% names(exc)
    sete[hit] <- exc[c6[hit]]
    out[seis] <- sete
  }
  out
}

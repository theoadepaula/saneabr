# Gera fixtures/esperado_<caso>.csv e .tipos com o leitor R, a partir de
# fixtures/casos.csv. Os testes R e Python comparam a propria leitura com eles.
#   Rscript ferramentas/esperados_fixtures.R
# CSV em UTF-8 com quebra LF (inclusive dentro de celulas), igual em qualquer SO
gravar_csv_lf <- function(df, caminho) {
  tc <- textConnection("linhas", "w", local = TRUE)
  utils::write.csv(df, tc, row.names = FALSE, na = "")
  close(tc)
  writeBin(charToRaw(enc2utf8(paste0(paste(linhas, collapse = "\n"), "\n"))), caminho)
}
suppressMessages(devtools::load_all("r", quiet = TRUE))
withr::local_envvar(SANEABR_EXTRACAO = file.path(tempdir(), "extr"))
casos <- utils::read.csv("fixtures/casos.csv", colClasses = "character")
for (i in seq_len(nrow(casos))) {
  cs <- casos[i, ]
  x <- as.data.frame(ler(cs$sistema, cs$modulo, cs$ano, cs$tabela,
                         arquivo = file.path("fixtures", cs$arquivo)))
  tipos <- vapply(x, function(v) class(v)[1], "")
  for (n in names(x)) if (is.numeric(x[[n]])) x[[n]] <- ifelse(is.na(x[[n]]), NA, sprintf("%.17g", x[[n]]))
  gravar_csv_lf(x, file.path("fixtures", paste0("esperado_", cs$caso, ".csv")))
  writeLines(paste(names(tipos), tipos, sep = ","), file.path("fixtures", paste0("esperado_", cs$caso, ".tipos")))
  message(cs$caso, ": ", nrow(x), " x ", ncol(x))
}

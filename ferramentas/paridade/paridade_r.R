# Le com o pacote R as tabelas do escopo e grava cada uma em CSV, com numeros
# em 17 algarismos significativos, para paridade_py.py comparar com o Python.
#
#   Rscript ferramentas/paridade/paridade_r.R <saida> [todas]
#
# Usa SANEABR_CACHE (onde estao os arquivos brutos) e SANEABR_EXTRACAO.
# Sem 'todas': SNIS RS 2022 e SINISA RS 2024, todas as tabelas de cada um.
args <- commandArgs(trailingOnly = TRUE)
saida <- args[1]
todas <- length(args) > 1 && args[2] == "todas"
dir.create(saida, recursive = TRUE, showWarnings = FALSE)
# CSV em UTF-8 com quebra LF (inclusive dentro de celulas), igual em qualquer SO
gravar_csv_lf <- function(df, caminho) {
  tc <- textConnection("linhas", "w", local = TRUE)
  utils::write.csv(df, tc, row.names = FALSE, na = "")
  close(tc)
  writeBin(charToRaw(enc2utf8(paste0(paste(linhas, collapse = "\n"), "\n"))), caminho)
}
suppressMessages(devtools::load_all("r", quiet = TRUE))

casos <- list(c("snis", "2022"), c("sinisa", "2024"))
if (todas) {
  casos <- c(lapply(2014:2022, function(a) c("snis", a)), lapply(2023:2024, function(a) c("sinisa", a)))
}
ok <- 0
for (cs in casos) {
  for (tb in tabelas(cs[1], "rs", cs[2])$tabela) {
    t0 <- Sys.time()
    x <- tryCatch(suppressWarnings(ler(cs[1], "rs", cs[2], tb)), error = function(e) { message("FALHA ", cs[1], " ", cs[2], " ", tb, ": ", conditionMessage(e)); NULL })
    if (is.null(x)) next
    tipos <- vapply(x, function(v) class(v)[1], "")
    y <- as.data.frame(x)
    for (n in names(y)) if (is.numeric(y[[n]])) y[[n]] <- ifelse(is.na(y[[n]]), NA, sprintf("%.17g", y[[n]]))
    base <- file.path(saida, paste(cs[1], cs[2], tb, sep = "_"))
    gravar_csv_lf(y, paste0(base, ".csv"))
    writeLines(paste(names(tipos), tipos, sep = ","), paste0(base, ".tipos"))
    ok <- ok + 1
    message(sprintf("%-7s %s %-26s %6d x %3d  %.1fs", cs[1], cs[2], tb, nrow(x), ncol(x),
                    as.numeric(Sys.time() - t0, units = "secs")))
  }
}
message(ok, " tabelas gravadas em ", saida)

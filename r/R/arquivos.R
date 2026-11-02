# Localiza a planilha de uma tabela dentro do arquivo baixado (zip, rar ou a
# propria planilha), extraindo so o necessario para dir_extracao().

eh_planilha <- function(f) grepl("[.]xlsx?$", f, ignore.case = TRUE)

listar_arquivo <- function(arquivo) {
  ext <- tolower(tools::file_ext(arquivo))
  if (ext == "zip") {
    utils::unzip(arquivo, list = TRUE)$Name
  } else if (ext == "rar") {
    exigir_archive()
    a <- archive::archive(arquivo)
    a$path[a$size > 0]
  } else {
    cli::cli_abort("Formato n\u00e3o suportado: {.file {basename(arquivo)}}.")
  }
}

exigir_archive <- function() {
  if (!requireNamespace("archive", quietly = TRUE)) {
    cli::cli_abort(c(
      "Este arquivo vem em {.strong rar}, e ler rar exige o pacote {.pkg archive}.",
      "i" = "Instale com {.code install.packages(\"archive\")}."
    ), class = "saneabr_falta_archive")
  }
}

extrair_entrada <- function(arquivo, entrada, destino) {
  dir.create(destino, recursive = TRUE, showWarnings = FALSE)
  alvo <- file.path(destino, entrada)
  if (file.exists(alvo)) return(alvo)
  ext <- tolower(tools::file_ext(arquivo))
  if (ext == "zip") {
    utils::unzip(arquivo, files = entrada, exdir = destino, junkpaths = FALSE)
  } else {
    exigir_archive()
    archive::archive_extract(arquivo, dir = destino, files = entrada)
  }
  if (!file.exists(alvo)) {
    cli::cli_abort("N\u00e3o consegui extrair {.file {entrada}} de {.file {basename(arquivo)}}.")
  }
  alvo
}

# Escolhe a planilha cujo nome casa com 'regex'. Desce em zip dentro de zip.
localizar_planilha <- function(arquivo, regex, profundidade = 0) {
  if (eh_planilha(arquivo)) return(arquivo)
  entradas <- listar_arquivo(arquivo)
  base <- basename(entradas)
  cand <- entradas[eh_planilha(base) & grepl(regex, base, perl = TRUE) &
                     !grepl("^~[$]", base)]
  destino <- file.path(dir_extracao(), substr(sha256_arquivo(arquivo), 1, 16))
  if (length(cand)) {
    cand <- sort(cand)
    if (length(cand) > 1) {
      cli::cli_warn("Mais de uma planilha casa com {.val {regex}}; uso {.file {basename(cand[1])}}.")
    }
    return(extrair_entrada(arquivo, cand[1], destino))
  }
  internos <- entradas[grepl("[.](zip|rar)$", base, ignore.case = TRUE)]
  if (profundidade < 2) {
    for (z in internos) {
      f <- extrair_entrada(arquivo, z, destino)
      achou <- tryCatch(localizar_planilha(f, regex, profundidade + 1),
                        saneabr_sem_planilha = function(e) NULL)
      if (!is.null(achou)) return(achou)
    }
  }
  cli::cli_abort("Nenhuma planilha casa com {.val {regex}} em {.file {basename(arquivo)}}.",
                 class = "saneabr_sem_planilha")
}

escolher_aba <- function(planilha, aba_regex) {
  abas <- readxl::excel_sheets(planilha)
  if (is.null(aba_regex)) return(abas[1])
  hit <- abas[grepl(aba_regex, slug(abas), perl = TRUE)]
  if (!length(hit)) {
    cli::cli_abort(c("Nenhuma aba casa com {.val {aba_regex}} em {.file {basename(planilha)}}.",
                     "i" = "Abas: {.val {abas}}"))
  }
  hit[1]
}

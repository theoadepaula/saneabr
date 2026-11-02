# Aplica a revisao do Theo a correspondencia SNIS <-> SINISA da spec.
#
#   Rscript ferramentas/aplicar_validacao.R [validacao/correspondencia_rs_validacao.csv] [--sem-testes]
#
# Le o CSV de validacao preenchido. So as linhas com 'decisao_theo' preenchida
# mudam a spec:
#   ok               aceita o veredito: confirmado/corrigir -> tipo_relacao = relacao_corrigida;
#                    rejeitado -> tipo_relacao = sem_par; novo -> acrescenta o par
#   rejeitar         tipo_relacao = sem_par (o par sai de correspondencia())
#   <tipo>           igual, mudou_definicao, mudou_unidade, desmembrado ou agregado:
#                    usa esse tipo (em par novo, acrescenta com esse tipo)
#   (vazio)          nada muda
# Cada linha decidida ganha validado = TRUE, validado_em (data) e validado_por.
# Depois sincroniza a spec com os pacotes e roda os testes R e Python.
#
# E idempotente. Se a correspondencia for reimportada (importar_snis_sinisa.R),
# rode este script de novo para reaplicar as decisoes.

args <- commandArgs(trailingOnly = TRUE)
sem_testes <- "--sem-testes" %in% args
args <- setdiff(args, "--sem-testes")
arq <- if (length(args)) args[1] else "validacao/correspondencia_rs_validacao.csv"
validado_por <- Sys.getenv("SANEABR_VALIDADO_POR", "Théo de Paula")
stopifnot(file.exists(arq), file.exists("spec/layouts.json"))

le <- function(f) utils::read.csv(f, colClasses = "character", na.strings = character(),
                                   fileEncoding = "UTF-8", check.names = FALSE)
grava <- function(x, f) {
  tc <- textConnection("linhas", "w", local = TRUE)
  utils::write.csv(x, tc, row.names = FALSE, na = "")
  close(tc)
  writeBin(charToRaw(enc2utf8(paste0(paste(linhas, collapse = "\n"), "\n"))), f)
}

tipos <- c("igual", "mudou_definicao", "mudou_unidade", "desmembrado", "agregado")
val <- le(arq)
val$decisao_theo <- trimws(tolower(val$decisao_theo))
dec <- val[nzchar(val$decisao_theo), ]
ruins <- dec$decisao_theo[!dec$decisao_theo %in% c("ok", "rejeitar", tipos)]
if (length(ruins)) stop("decisao_theo invalida: ", paste(unique(ruins), collapse = ", "),
                        ". Use ok, rejeitar ou um de: ", paste(tipos, collapse = ", "))
if (!nrow(dec)) { message("Nenhuma linha com decisao_theo preenchida: nada a aplicar."); quit(status = 0) }

f_co <- "spec/dicionarios/correspondencia_snis_sinisa.csv"
co <- le(f_co)
for (k in c("validado", "validado_em", "validado_por")) if (!k %in% names(co)) co[[k]] <- ""
hoje <- format(Sys.Date())

novo_tipo <- function(d) {
  if (d$decisao_theo == "rejeitar") return("sem_par")
  if (d$decisao_theo %in% tipos) return(d$decisao_theo)
  if (d$veredito == "rejeitado") "sem_par" else d$relacao_corrigida
}

n_alt <- 0; n_novo <- 0
for (i in seq_len(nrow(dec))) {
  d <- dec[i, ]
  tipo <- novo_tipo(d)
  ev <- sprintf("validacao manual: %s | SNIS %s; SINISA %s", d$justificativa, d$pagina_snis, d$pagina_sinisa)
  hit <- which(co$codigo_snis == d$codigo_snis & co$codigo_sinisa == d$codigo_sinisa &
                 co$modulo == d$modulo_sinisa)
  if (length(hit)) {
    co$tipo_relacao[hit] <- tipo
    if (tipo == "sem_par") {
      co$observacao[hit] <- paste0("rejeitado na validacao: ", d$justificativa)
    } else {
      co$evidencia_documental[hit] <- "TRUE"
      if (!grepl("^validacao manual", co$evidencia[hit[1]])) co$evidencia[hit] <- paste(ev, "| origem:", co$evidencia[hit])
    }
    n_alt <- n_alt + length(hit)
  } else if (tipo != "sem_par") {
    nova <- co[1, ]
    nova[] <- ""
    nova$codigo_snis <- d$codigo_snis
    nova$codigo_sinisa <- d$codigo_sinisa
    nova$modulo <- d$modulo_sinisa
    nova$modulo_snis <- d$modulo_snis
    nova$tipo <- if (grepl("^(IN|I[A-Z]{2})[0-9]", d$codigo_sinisa)) "indicador" else "informacao"
    nova$tipo_relacao <- tipo
    nova$evidencia_documental <- "TRUE"
    nova$evidencia <- ev
    nova$nome_snis <- d$nome_snis
    nova$nome_sinisa <- d$nome_sinisa
    co <- rbind(co, nova)
    hit <- nrow(co)
    n_novo <- n_novo + 1
  } else {
    next
  }
  co$validado[hit] <- "TRUE"
  co$validado_em[hit] <- hoje
  co$validado_por[hit] <- validado_por
}
co$validado[co$validado == ""] <- "FALSE"
grava(co, f_co)
message(sprintf("spec: %d pares alterados, %d pares novos, %d linhas validadas no total",
                n_alt, n_novo, sum(co$validado == "TRUE")))

rodar <- function(cmd, args, wd = ".") {
  message("> ", cmd, " ", paste(args, collapse = " "))
  old <- setwd(wd); on.exit(setwd(old))
  st <- system2(cmd, args)
  if (!identical(st, 0L)) stop("falhou: ", cmd, " ", paste(args, collapse = " "))
}
rscript <- file.path(R.home("bin"), "Rscript")
rodar(rscript, "ferramentas/sincronizar_spec.R")
if (!sem_testes) {
  q <- if (.Platform$OS.type == "windows") "cmd" else "sh"
  rodar(rscript, c("-e", shQuote("devtools::test(stop_on_failure = TRUE)", type = q)), "r")
  py <- if (.Platform$OS.type == "windows") "python/.venv/Scripts/python.exe" else "python/.venv/bin/python"
  if (file.exists(py)) rodar(normalizePath(py), c("-m", "pytest", "-q"), "python")
  else message("venv do Python nao encontrado; rode o pytest a mao")
}
message("pronto. Revise o diff de ", f_co, " antes do commit.")

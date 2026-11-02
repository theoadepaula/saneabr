# Teste empirico de cada par de RS da correspondencia: para os municipios com
# valor nos dois lados, compara SNIS (ano 2022) com SINISA (ano 2023).
#
#   SANEABR_CACHE=<dados_brutos> Rscript validacao/razoes_empiricas.R
#
# Numerico: mediana (e quartis) da razao SINISA/SNIS entre os municipios com os
# dois valores diferentes de zero. Texto (Sim/Nao etc.): concordancia.
# Tabelas do SINISA com varias linhas por municipio (rotas, veiculos, unidades)
# sao somadas por municipio. Saida: validacao/trabalho/razoes.csv

suppressMessages(devtools::load_all("r", quiet = TRUE))
if (!nzchar(Sys.getenv("SANEABR_EXTRACAO"))) Sys.setenv(SANEABR_EXTRACAO = file.path(tempdir(), "extr"))

por_municipio <- function(df) {
  df <- as.data.frame(df)
  ids <- unique(df$id_municipio)
  cols <- setdiff(names(df), c("id_municipio", "ano"))
  out <- lapply(cols, function(n) {
    v <- df[[n]]
    if (anyDuplicated(df$id_municipio) == 0) return(stats::setNames(v, df$id_municipio))
    if (is.numeric(v)) {
      s <- tapply(v, df$id_municipio, function(z) if (all(is.na(z))) NA_real_ else sum(z, na.rm = TRUE))
    } else {
      s <- tapply(v, df$id_municipio, function(z) z[!is.na(z)][1])
    }
    s[ids]
  })
  names(out) <- cols
  list(vals = out, multi = anyDuplicated(df$id_municipio) > 0)
}

juntar <- function(lista) {
  vars <- list(); multi <- character()
  for (nm in names(lista)) {
    pm <- por_municipio(lista[[nm]])
    for (n in names(pm$vals)) if (is.null(vars[[n]])) {
      vars[[n]] <- pm$vals[[n]]
      if (pm$multi) multi <- c(multi, n)
    }
  }
  list(vars = vars, multi = multi)
}

message("lendo SNIS 2022...")
snis <- juntar(lapply(stats::setNames(nm = c("informacoes", "indicadores", "politicas_planos")),
                      function(t) suppressWarnings(ler("snis", "rs", 2022, t))))
message("lendo SNIS 2021 (para pares que dependem da populacao urbana, retirada no SNIS 2022)...")
snis21 <- juntar(lapply(stats::setNames(nm = c("informacoes", "indicadores")),
                        function(t) suppressWarnings(ler("snis", "rs", 2021, t))))
message("lendo SINISA 2023...")
tabs <- tabelas("sinisa", "rs", 2023)$tabela
sl <- lapply(stats::setNames(nm = tabs), function(t) suppressWarnings(ler("sinisa", "rs", 2023, t)))
gm <- file.path(Sys.getenv("SANEABR_CACHE"), "SINISA/GM/2023/SINISA_GESTAOMUNICIPAL_Informacoes_2023.xlsx")
if (file.exists(gm)) {
  for (aba in readxl::excel_sheets(gm)) {
    x <- tryCatch(arrumar_grade(ler_grade(gm, aba), 2023L), error = function(e) NULL)
    if (!is.null(x)) sl[[paste0("gm_", aba)]] <- x
  }
}
sinisa <- juntar(sl)

norm_txt <- function(x) tolower(sem_acento(trimws(as.character(x))))

co <- utils::read.csv("spec/dicionarios/correspondencia_snis_sinisa.csv", colClasses = "character",
                      fileEncoding = "UTF-8")
co <- co[(co$modulo == "RS" | co$modulo_snis == "RS") & co$tipo_relacao != "sem_par", ]
# pares que nao estao na correspondencia, mas que a leitura dos glossarios sugere
extras <- data.frame(
  codigo_snis   = c("CO119", "CO119", "CO116", "CO117", "VA039", "FN207", "FN220", "TB001"),
  codigo_sinisa = c("GTR1028", "GTR1025", "GTR1004", "GTR1005", "GTR2002", "GFI2211", "GFI2221", "GFI2264")
)

testar <- function(cs, cb) {
  base <- data.frame(codigo_snis = cs, codigo_sinisa = cb, ano_snis = 2022L,
                     tipo_teste = NA_character_, n_municipios = NA_integer_, razao_mediana = NA_real_,
                     razao_p25 = NA_real_, razao_p75 = NA_real_, concordancia = NA_real_,
                     sinisa_somado = cb %in% sinisa$multi, nota = "")
  b <- sinisa$vars[[cb]]
  a <- snis$vars[[cs]]
  com_dado <- function(a) !is.null(a) && length(intersect(names(a)[!is.na(a)], names(b)[!is.na(b)])) > 0
  if (!is.null(b) && !com_dado(a) && com_dado(snis21$vars[[cs]])) {
    a <- snis21$vars[[cs]]
    base$ano_snis <- 2021L
  }
  if (is.null(a) || is.null(b)) {
    base$nota <- paste0("sem dado: ", if (is.null(a)) "SNIS " else "", if (is.null(b)) "SINISA" else "")
    return(base)
  }
  ids <- intersect(names(a)[!is.na(a)], names(b)[!is.na(b)])
  if (!length(ids)) { base$nota <- "nenhum municipio com os dois valores"; return(base) }
  if (is.numeric(a) && is.numeric(b)) {
    x <- a[ids]; y <- b[ids]; ok <- x != 0 & y != 0
    base$tipo_teste <- "razao"
    base$n_municipios <- sum(ok)
    if (sum(ok)) {
      q <- stats::quantile(y[ok] / x[ok], c(.25, .5, .75), names = FALSE)
      base$razao_p25 <- q[1]; base$razao_mediana <- q[2]; base$razao_p75 <- q[3]
    }
    base$nota <- sprintf("%d com os dois valores, %d com zero em algum lado", length(ids), sum(!ok))
  } else {
    base$tipo_teste <- "concordancia"
    base$n_municipios <- length(ids)
    base$concordancia <- mean(norm_txt(a[ids]) == norm_txt(b[ids]))
    ex <- utils::head(unique(paste0(norm_txt(a[ids]), " / ", norm_txt(b[ids]))), 3)
    base$nota <- paste("ex.:", paste(ex, collapse = "; "))
  }
  base
}

res <- lapply(seq_len(nrow(co)), function(i) testar(co$codigo_snis[i], co$codigo_sinisa[i]))
res <- do.call(rbind, res)
utils::write.csv(res, "validacao/trabalho/razoes.csv", row.names = FALSE, fileEncoding = "UTF-8")
ext <- do.call(rbind, lapply(seq_len(nrow(extras)), function(i) testar(extras$codigo_snis[i], extras$codigo_sinisa[i])))
utils::write.csv(ext, "validacao/trabalho/razoes_extras.csv", row.names = FALSE, fileEncoding = "UTF-8")
message("ok: ", sum(!is.na(res$tipo_teste)), " pares testados de ", nrow(res))

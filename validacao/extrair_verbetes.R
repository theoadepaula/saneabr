# Extrai dos glossarios em PDF o verbete de cada codigo dos pares de RS da
# correspondencia, com documento e pagina, para a leitura par a par.
#
#   Rscript validacao/extrair_verbetes.R [pasta_documentos]
#
# Saida: validacao/trabalho/verbetes.csv (codigo, documento, pagina, texto)
#        validacao/trabalho/pares_para_ler.txt (os dois verbetes lado a lado)

docs <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(docs)) docs <- "C:/Users/theoa/dev/snis-sinisa/dados_brutos/documentos"
dir.create("validacao/trabalho", showWarnings = FALSE, recursive = TRUE)

glossarios <- c(
  "SNIS/RS/2022/Glossario_Informacoes_RS2022.pdf",
  "SNIS/RS/2022/Glossario_Indicadores_RS2022.pdf",
  "SNIS/AP/2022/Glossario_Informacoes_AP2022.pdf",
  "SINISA/RS/2024/Glossario_Informacoes_SINISA_2024.pdf",
  "SINISA/RS/2024/Glossario_Indicadores_SINISA_2024.pdf",
  "SINISA/RS/2023/GLOSSARIO_INFORMACOES_SINISA_RESIDUOS_SOLIDOS.pdf",
  "SINISA/RS/2023/Glossario_Indicadores_SINISA_RESIDUOS.pdf",
  "SINISA/GM/2024/GlossriodeInformaes_GESTAOMUNICIPAL_2025.pdf"
)

re_cod <- "^[[:space:]]*([A-Z]{2,3}[0-9]{3,4}[A-Z]?)[[:space:]]*(-|$)"
espaco <- function(x) trimws(gsub("[[:space:]]+", " ", x))

verbetes <- list()
for (g in glossarios) {
  paginas <- pdftools::pdf_text(file.path(docs, g))
  tabela <- grepl("Indicadores_SINISA", g)
  for (p in seq_along(paginas)) {
    linhas <- strsplit(paginas[p], "\n", fixed = TRUE)[[1]]
    if (!tabela) {
      ini <- grep(re_cod, linhas, perl = TRUE)
      for (k in seq_along(ini)) {
        fim <- if (k < length(ini)) ini[k + 1] - 1 else length(linhas)
        cod <- sub(paste0(re_cod, ".*"), "\\1", linhas[ini[k]], perl = TRUE)
        txt <- espaco(paste(linhas[ini[k]:fim], collapse = " "))
        verbetes[[length(verbetes) + 1]] <- data.frame(
          codigo = cod, documento = basename(g), pagina = p, texto = substr(txt, 1, 1500))
      }
    } else {
      # glossario de indicadores do SINISA e uma tabela larga: guarda as linhas
      # em volta de cada codigo IRS/IFR/... que aparece na coluna CODIGO
      cods <- unique(regmatches(paginas[p], gregexpr("\\b[A-Z]{3}[0-9]{4}\\b", paginas[p], perl = TRUE))[[1]])
      cods <- cods[grepl("^I", cods)]
      for (cod in cods) {
        i <- grep(cod, linhas, fixed = TRUE)[1]
        txt <- espaco(paste(linhas[max(1, i - 4):min(length(linhas), i + 6)], collapse = " | "))
        verbetes[[length(verbetes) + 1]] <- data.frame(
          codigo = cod, documento = basename(g), pagina = p, texto = substr(txt, 1, 2000))
      }
    }
  }
}
v <- do.call(rbind, verbetes)
# fica o primeiro verbete de cada codigo em cada documento
v <- v[!duplicated(paste(v$codigo, v$documento)), ]
utils::write.csv(v, "validacao/trabalho/verbetes.csv", row.names = FALSE, fileEncoding = "UTF-8")

co <- utils::read.csv("spec/dicionarios/correspondencia_snis_sinisa.csv", colClasses = "character",
                      fileEncoding = "UTF-8")
co <- co[(co$modulo == "RS" | co$modulo_snis == "RS") & co$tipo_relacao != "sem_par", ]
pega <- function(cod, padrao) {
  x <- v[v$codigo == cod & grepl(padrao, v$documento), ]
  if (!nrow(x)) return("(verbete nao achado)")
  paste0("[", x$documento[1], " p.", x$pagina[1], "] ", x$texto[1])
}
con <- file("validacao/trabalho/pares_para_ler.txt", open = "w", encoding = "UTF-8")
for (i in seq_len(nrow(co))) {
  r <- co[i, ]
  writeLines(c(
    sprintf("=== %d. %s -> %s | %s | %s/%s | evid: %s", i, r$codigo_snis, r$codigo_sinisa,
            r$tipo_relacao, r$modulo_snis, r$modulo, r$evidencia),
    paste("SNIS:  ", pega(r$codigo_snis, "RS2022|AP2022")),
    paste("SINISA:", pega(r$codigo_sinisa, "SINISA_2024|GESTAOMUNICIPAL")),
    ""), con)
}
close(con)
message(nrow(v), " verbetes; ", nrow(co), " pares")

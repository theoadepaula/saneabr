# Importa para spec/ o que foi levantado no projeto de pesquisa snis-sinisa.
#
#   Rscript ferramentas/importar_snis_sinisa.R [pasta_snis_sinisa]
#
# Gera:
#   spec/catalogo.csv                         (a partir de dados_brutos/MANIFESTO.csv)
#   spec/dicionarios/dic_snis.csv             (copia validada)
#   spec/dicionarios/dic_sinisa.csv
#   spec/dicionarios/correspondencia_snis_sinisa.csv
#   spec/dicionarios/mudancas_dentro_snis.csv
#   spec/dicionarios/glossarios_versoes.csv.gz  (grande: so na spec, nao vai aos pacotes)
#   spec/NOTAS-MUDANCAS.md
#
# A pasta de origem e so lida. Rodar a partir da raiz do repositorio.
# Depois: Rscript ferramentas/sincronizar_spec.R

args <- commandArgs(trailingOnly = TRUE)
origem <- if (length(args)) args[[1]] else
  Sys.getenv("SANEABR_ORIGEM", "C:/Users/theoa/dev/snis-sinisa")
stopifnot(dir.exists(origem), file.exists("spec/layouts.json"))

esq <- jsonlite::read_json("spec/esquemas.json")

le <- function(f) utils::read.csv(f, colClasses = "character", na.strings = character(),
                                   encoding = "UTF-8", check.names = FALSE)
grava <- function(x, f) {
  con <- file(f, open = "w", encoding = "UTF-8")
  on.exit(close(con))
  utils::write.csv(x, con, row.names = FALSE, na = "")
}
confere <- function(x, nome) {
  esperado <- unlist(esq[[nome]]$colunas)
  falta <- setdiff(esperado, names(x))
  if (length(falta)) stop(nome, ": faltam as colunas ", paste(falta, collapse = ", "))
  x[, esperado, drop = FALSE]
}

# 1. Catalogo ---------------------------------------------------------------
man <- le(file.path(origem, "dados_brutos/MANIFESTO.csv"))
man$arquivo_nome <- basename(man$arquivo)
# o MANIFESTO repete documentos (pasta dados_brutos/ e dados_brutos/documentos/);
# fica a linha de documentos/, que traz o tipo detalhado (glossario_informacoes etc.)
man$prioridade <- ifelse(grepl("/documentos/", man$arquivo), 1L, 2L)
man <- man[order(man$url, man$prioridade), ]
man <- man[!duplicated(man$url), ]
cat_ <- data.frame(
  sistema = toupper(man$fonte),
  modulo = toupper(man$modulo),
  ano = as.integer(man$ano),
  tipo = man$tipo,
  arquivo = man$arquivo_nome,
  url = man$url,
  sha256 = tolower(man$sha256),
  formato = tolower(tools::file_ext(man$arquivo_nome)),
  bytes = format(as.numeric(man$bytes), scientific = FALSE, trim = TRUE),
  data_verificacao = man$data_download,
  stringsAsFactors = FALSE
)
cat_ <- cat_[order(cat_$sistema, cat_$modulo, cat_$ano, cat_$tipo, cat_$arquivo), ]
cat_ <- confere(cat_, "catalogo")
grava(cat_, "spec/catalogo.csv")
message("catalogo.csv: ", nrow(cat_), " arquivos (", sum(cat_$tipo == "dados"), " de dados)")

# 2. Dicionarios e correspondencia --------------------------------------------
dic <- file.path(origem, "dicionarios")
tabs <- list()
for (nome in c("dic_snis", "dic_sinisa", "correspondencia_snis_sinisa", "mudancas_dentro_snis")) {
  tabs[[nome]] <- confere(le(file.path(dic, paste0(nome, ".csv"))), nome)
}
# a correspondencia herda a 'qualidade' do verbete de cada lado (verbete, tabela,
# so_planilha): itens de 'tabela' podem misturar linhas vizinhas do PDF
qual <- function(d, cod, mod) {
  d$qualidade[match(paste(cod, mod), paste(d$codigo, d$modulo))]
}
co <- tabs$correspondencia_snis_sinisa
co$qualidade_snis <- qual(tabs$dic_snis, co$codigo_snis, ifelse(co$modulo_snis == "", co$modulo, co$modulo_snis))
co$qualidade_sinisa <- qual(tabs$dic_sinisa, co$codigo_sinisa, co$modulo)
co$qualidade_snis[is.na(co$qualidade_snis)] <- ""
co$qualidade_sinisa[is.na(co$qualidade_sinisa)] <- ""
tabs$correspondencia_snis_sinisa <- co
for (nome in names(tabs)) {
  grava(tabs[[nome]], file.path("spec/dicionarios", paste0(nome, ".csv")))
  message(nome, ".csv: ", nrow(tabs[[nome]]), " linhas")
}
gv <- confere(le(file.path(dic, "glossarios_versoes.csv")), "glossarios_versoes")
gz <- gzfile("spec/dicionarios/glossarios_versoes.csv.gz", open = "w", encoding = "UTF-8")
utils::write.csv(gv, gz, row.names = FALSE, na = "")
close(gz)
message("glossarios_versoes.csv.gz: ", nrow(gv), " linhas")

# 3. Notas ------------------------------------------------------------------
notas <- readLines(file.path(origem, "NOTAS-MUDANCAS.md"), encoding = "UTF-8")
cab <- c("<!-- Copiado de snis-sinisa/NOTAS-MUDANCAS.md por ferramentas/importar_snis_sinisa.R.",
         "     Edite na origem e importe de novo. Os caminhos citados sao do projeto de pesquisa. -->", "")
con <- file("spec/NOTAS-MUDANCAS.md", open = "w", encoding = "UTF-8")
writeLines(enc2utf8(c(cab, notas)), con)
close(con)
message("NOTAS-MUDANCAS.md copiado")

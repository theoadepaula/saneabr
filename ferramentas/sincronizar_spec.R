# Copia spec/ para dentro dos dois pacotes e fixtures/ para os testes.
#
#   Rscript ferramentas/sincronizar_spec.R          # copia
#   Rscript ferramentas/sincronizar_spec.R --checar # so confere; sai com erro se diferente
#
# spec/ e a fonte unica. As copias em r/inst/extdata/spec e
# python/src/saneabr/spec nao se editam a mao.
# Rodar a partir da raiz do repositorio.

checar <- "--checar" %in% commandArgs(trailingOnly = TRUE)
stopifnot(file.exists("spec/layouts.json"))

# grande demais para o CRAN e sem uso na API da v0.1: fica so na spec
fora_dos_pacotes <- c("dicionarios/glossarios_versoes.csv.gz")

alvos <- list(
  list(de = "spec", para = "r/inst/extdata/spec", excluir = fora_dos_pacotes),
  list(de = "spec", para = "python/src/saneabr/spec", excluir = fora_dos_pacotes),
  list(de = "fixtures", para = "r/tests/testthat/fixtures", excluir = character()),
  list(de = "fixtures", para = "python/tests/fixtures", excluir = character())
)

md5 <- function(f) unname(tools::md5sum(f))
diferencas <- 0L
for (a in alvos) {
  arqs <- list.files(a$de, recursive = TRUE, all.files = FALSE)
  arqs <- setdiff(arqs, a$excluir)
  existentes <- if (dir.exists(a$para)) list.files(a$para, recursive = TRUE) else character()
  sobras <- setdiff(existentes, c(arqs, "__init__.py"))
  for (f in arqs) {
    o <- file.path(a$de, f)
    d <- file.path(a$para, f)
    igual <- file.exists(d) && md5(o) == md5(d)
    if (!igual) {
      diferencas <- diferencas + 1L
      if (checar) {
        message("diferente: ", d)
      } else {
        dir.create(dirname(d), recursive = TRUE, showWarnings = FALSE)
        file.copy(o, d, overwrite = TRUE)
      }
    }
  }
  for (f in sobras) {
    diferencas <- diferencas + 1L
    if (checar) message("sobrando: ", file.path(a$para, f)) else unlink(file.path(a$para, f))
  }
}
if (checar && diferencas > 0) {
  stop(diferencas, " arquivo(s) fora de sincronia. Rode ferramentas/sincronizar_spec.R")
}
message(if (checar) "spec em sincronia" else paste(diferencas, "arquivo(s) atualizados"))

#' Dicionário de variáveis do SNIS ou do SINISA
#'
#' Código, nome, definição, unidade e as informações envolvidas de cada
#' variável e indicador, extraídos dos glossários oficiais em PDF. A coluna
#' `qualidade` diz de onde veio cada linha: `verbete` (lido do verbete do
#' glossário), `tabela` (glossário em tabela: nome e insumos vêm de uma janela
#' de linhas e podem misturar linhas vizinhas) ou `so_planilha` (o código está
#' nas planilhas, mas não foi achado no glossário). As fórmulas dos indicadores
#' são imagem nos PDFs: a coluna `formula` traz só os códigos citados.
#'
#' Texto dos glossários: Ministério das Cidades, reproduzido sem alteração,
#' com citação da fonte (`documento_origem`, `pagina`, `url_documento`).
#'
#' @param sistema `"snis"` ou `"sinisa"`.
#' @param modulo Opcional: `"rs"`, `"ae"`, `"ap"` ou `"gm"`.
#' @return Um tibble.
#' @examples
#' d <- dicionario("snis", "rs")
#' d[d$codigo == "CO119", c("codigo", "nome", "unidade")]
#' @export
dicionario <- function(sistema, modulo = NULL) {
  sistema <- padronizar_sistema(sistema)
  x <- spec_csv(file.path("dicionarios", paste0("dic_", tolower(sistema), ".csv")))
  if (!is.null(modulo)) x <- x[x$modulo == padronizar_modulo(modulo), ]
  rownames(x) <- NULL
  tibble::as_tibble(x)
}

#' Correspondência entre códigos do SNIS e do SINISA
#'
#' Pares de códigos SNIS e SINISA, montados a partir dos glossários do SINISA:
#' a "Referência: * XX000" do glossário de informações e a coluna "SIMILAR NO
#' SNIS" do glossário de indicadores. A tabela foi montada automaticamente e
#' **nenhum par foi validado a olho**: confira a definição nos dois lados antes
#' de empilhar séries.
#'
#' Por padrão vêm só os pares com evidência documental
#' (`evidencia_documental == TRUE`). Com `candidatas = TRUE`, entram também os
#' pares `candidata`, sugeridos só pela semelhança do nome.
#'
#' `tipo_relacao` é `igual`, `mudou_definicao`, `mudou_unidade`,
#' `desmembrado` (um código SNIS virou vários SINISA), `agregado` (um SINISA
#' soma vários SNIS) ou `candidata`. `qualidade_snis` e `qualidade_sinisa`
#' repetem a qualidade do verbete de cada lado (ver [dicionario()]).
#'
#' @section Massa coletada: CO119 não é GTR1028:
#' O CO119 do SNIS (RDO + RPU coletados) exclui a massa das cooperativas de
#' catadores e não inclui RCC. O GTR1028 do SINISA soma a massa declarada por
#' rota, inclusive coleta seletiva, podas e RCC/volumosos de pequenos
#' geradores. O glossário do SINISA não dá Referência do GTR1028 a nenhum
#' código SNIS; por isso ele não tem par aqui. O mesmo vale, por tabela, para
#' o per capita: o IRS1004 é declarado "similar" ao IN028, mas divide pela
#' população total, não pela atendida. Detalhes e páginas dos documentos em
#' `system.file("extdata", "spec", "NOTAS-MUDANCAS.md", package = "saneabr")`.
#'
#' @param modulo Opcional: `"rs"`, `"ae"`, `"ap"` ou `"gm"` (módulo SINISA).
#' @param candidatas Se `TRUE`, inclui os pares sem evidência documental.
#' @return Um tibble.
#' @examples
#' co <- correspondencia("rs")
#' table(co$tipo_relacao)
#' @export
correspondencia <- function(modulo = NULL, candidatas = FALSE) {
  x <- spec_csv(file.path("dicionarios", "correspondencia_snis_sinisa.csv"))
  x$evidencia_documental <- x$evidencia_documental == "TRUE"
  x$similaridade_nome <- suppressWarnings(as.numeric(x$similaridade_nome))
  manter <- x$evidencia_documental
  if (isTRUE(candidatas)) manter <- manter | x$tipo_relacao == "candidata"
  x <- x[manter & x$tipo_relacao != "sem_par", ]
  if (!is.null(modulo)) x <- x[x$modulo == padronizar_modulo(modulo), ]
  rownames(x) <- NULL
  tibble::as_tibble(x)
}

#' Mudanças de código e de definição dentro do SNIS
#'
#' Renomeações declaradas nos glossários ("Antigo campo GE012") e mudanças de
#' unidade, nome e fórmula detectadas por comparação automática entre versões
#' dos glossários. A coluna `metodo` diz qual é qual; as automáticas devem ser
#' validadas.
#'
#' @param modulo Opcional: `"rs"`, `"ae"` ou `"ap"`.
#' @return Um tibble.
#' @examples
#' m <- mudancas("rs")
#' head(m[m$tipo_mudanca == "codigo_renomeado", ])
#' @export
mudancas <- function(modulo = NULL) {
  x <- spec_csv(file.path("dicionarios", "mudancas_dentro_snis.csv"))
  x$ano <- as.integer(x$ano)
  if (!is.null(modulo)) x <- x[x$modulo == padronizar_modulo(modulo), ]
  rownames(x) <- NULL
  tibble::as_tibble(x)
}

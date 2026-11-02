#' Catálogo de arquivos do SNIS e do SINISA
#'
#' Lista os arquivos publicados pelo Ministério das Cidades que o pacote
#' conhece: planilhas de dados, glossários, relatórios e manuais, com a URL
#' de origem, o tamanho e o SHA-256 conferidos na data indicada em
#' `data_verificacao`. O catálogo vem com o pacote; os dados, não.
#'
#' @param sistema,modulo,ano,tipo Filtros opcionais. `sistema` é `"snis"` ou
#'   `"sinisa"`; `modulo` é `"rs"`, `"ae"`, `"ap"` ou `"gm"`; `tipo` é, por
#'   exemplo, `"dados"` ou `"glossario_informacoes"`.
#' @return Um tibble com as colunas `sistema`, `modulo`, `ano`, `tipo`,
#'   `arquivo`, `url`, `sha256`, `formato`, `bytes` e `data_verificacao`.
#' @examples
#' catalogo(sistema = "sinisa", modulo = "rs")
#' @export
catalogo <- function(sistema = NULL, modulo = NULL, ano = NULL, tipo = NULL) {
  x <- spec_csv("catalogo.csv")
  x$ano <- as.integer(x$ano)
  x$bytes <- as.numeric(x$bytes)
  if (!is.null(sistema)) x <- x[x$sistema %in% toupper(sistema), ]
  if (!is.null(modulo)) x <- x[x$modulo %in% toupper(modulo), ]
  if (!is.null(ano)) x <- x[x$ano %in% as.integer(ano), ]
  if (!is.null(tipo)) x <- x[x$tipo %in% tipo, ]
  rownames(x) <- NULL
  tibble::as_tibble(x)
}

#' Diretório de cache
#'
#' Onde [baixar()] guarda os arquivos. Por padrão,
#' `tools::R_user_dir("saneabr", "cache")`. Para mudar, use
#' `options(saneabr.cache = "...")` ou a variável de ambiente `SANEABR_CACHE`.
#' As planilhas extraídas de zip e rar ficam em `<cache>/_extraido`, ou onde
#' indicarem `options(saneabr.extracao = "...")` ou `SANEABR_EXTRACAO`.
#'
#' @return O caminho do diretório (que pode ainda não existir).
#' @examples
#' dir_cache()
#' @export
dir_cache <- function() {
  rede <- spec_rede()
  d <- getOption("saneabr.cache") %||% Sys.getenv(rede$variavel_cache, "")
  if (!nzchar(d)) d <- tools::R_user_dir("saneabr", "cache")
  normalizePath(d, winslash = "/", mustWork = FALSE)
}

dir_extracao <- function() {
  rede <- spec_rede()
  d <- getOption("saneabr.extracao") %||% Sys.getenv(rede$variavel_extracao, "")
  if (!nzchar(d)) d <- file.path(dir_cache(), "_extraido")
  normalizePath(d, winslash = "/", mustWork = FALSE)
}

sha256_arquivo <- function(caminho) {
  con <- file(caminho, open = "rb")
  on.exit(close(con))
  as.vector(as.character(openssl::sha256(con)))
}

user_agent <- function() {
  sub("{versao}", as.character(utils::packageVersion("saneabr")),
      spec_rede()$user_agent, fixed = TRUE)
}

# Compara o SHA-256 do arquivo com o do catalogo; avisa se diferente.
conferir_sha <- function(caminho, esperado, url = NULL) {
  obtido <- sha256_arquivo(caminho)
  if (nzchar(esperado) && !identical(tolower(obtido), tolower(esperado))) {
    cli::cli_warn(c(
      "!" = "{.file {basename(caminho)}} difere do catalogado (SHA-256).",
      "i" = "A fonte pode ter republicado o arquivo. Os valores lidos podem n\u00e3o bater com os de quem usou a vers\u00e3o catalogada.",
      "i" = "Esperado: {.val {substr(esperado, 1, 16)}}..., obtido: {.val {substr(obtido, 1, 16)}}...",
      if (!is.null(url)) c("i" = "Origem: {.url {url}}")
    ), class = "saneabr_sha_diferente")
    return(invisible(FALSE))
  }
  invisible(TRUE)
}

baixar_url <- function(url, destino) {
  rede <- spec_rede()
  dir.create(dirname(destino), recursive = TRUE, showWarnings = FALSE)
  parcial <- paste0(destino, rede$sufixo_parcial)
  on.exit(unlink(parcial), add = TRUE)
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, user_agent())
  req <- httr2::req_timeout(req, rede$timeout_segundos)
  req <- httr2::req_retry(req, max_tries = rede$tentativas,
                          retry_on_failure = TRUE)
  req <- httr2::req_error(req, is_error = function(r) FALSE)
  resp <- httr2::req_perform(req, path = parcial)
  st <- httr2::resp_status(resp)
  if (st != 200) {
    cli::cli_abort(c("O servidor respondeu HTTP {st}.", "i" = "{.url {url}}"),
                   class = "saneabr_http")
  }
  if (!file.exists(parcial)) writeBin(httr2::resp_body_raw(resp), parcial)
  # so renomeia no fim: conexao cortada nao deixa arquivo truncado no cache
  if (!file.rename(parcial, destino)) {
    file.copy(parcial, destino, overwrite = TRUE)
  }
  destino
}

#' Baixa arquivos do SNIS e do SINISA para o cache
#'
#' Baixa da fonte oficial (gov.br/cidades) os arquivos do [catalogo()] que
#' correspondem a `sistema`, `modulo`, `ano` e `tipo`, e confere o SHA-256.
#' Se o arquivo já está no cache, não baixa de novo. Se o SHA-256 não bate
#' com o catalogado, avisa: é sinal de que a fonte republicou o arquivo.
#'
#' @param sistema `"snis"` ou `"sinisa"`.
#' @param modulo `"rs"`, `"ae"`, `"ap"` ou `"gm"`.
#' @param ano Ano de referência dos dados.
#' @param tipo Tipo de arquivo no catálogo. Padrão: `"dados"`. Use
#'   `tipo = NULL` para baixar também glossários e relatórios.
#' @param forcar Se `TRUE`, baixa de novo mesmo que já esteja no cache.
#' @return Invisível: os caminhos locais dos arquivos.
#' @seealso [dir_cache()], [ler()]
#' @examples
#' \donttest{
#' if (interactive()) {
#'   baixar("sinisa", "rs", 2024)
#' }
#' }
#' @export
baixar <- function(sistema, modulo, ano, tipo = "dados", forcar = FALSE) {
  sistema <- padronizar_sistema(sistema)
  modulo <- padronizar_modulo(modulo)
  ano <- padronizar_ano(ano)
  cat_ <- catalogo(sistema, modulo, ano, tipo)
  if (!nrow(cat_)) {
    cli::cli_abort(c(
      "Nenhum arquivo{if (!is.null(tipo)) paste0(' de tipo \"', tipo, '\"')} no cat\u00e1logo para {sistema} {modulo} {ano}.",
      "i" = "Veja {.code catalogo(sistema = \"{tolower(sistema)}\", modulo = \"{tolower(modulo)}\")}."
    ), class = "saneabr_sem_arquivo")
  }
  caminhos <- character(nrow(cat_))
  for (i in seq_len(nrow(cat_))) {
    r <- cat_[i, ]
    destino <- file.path(dir_cache(), r$sistema, r$modulo, r$ano, r$arquivo)
    if (forcar || !file.exists(destino)) {
      mb <- format(round(r$bytes / 1e6, 1), nsmall = 1)
      cli::cli_inform("Baixando {.file {r$arquivo}} ({mb} MB)...")
      baixar_url(r$url, destino)
    }
    conferir_sha(destino, r$sha256, r$url)
    caminhos[i] <- destino
  }
  invisible(caminhos)
}

achar_era <- function(sistema, modulo, ano) {
  for (e in spec_layouts()$eras) {
    if (e$sistema == sistema && e$modulo == modulo && ano %in% unlist(e$anos)) {
      return(e)
    }
  }
  suportado <- vapply(spec_layouts()$eras, function(e) {
    a <- range(unlist(e$anos))
    paste0(e$sistema, " ", e$modulo, " ", a[1], "\u2013", a[2])
  }, character(1))
  no_cat <- nrow(catalogo(sistema, modulo, ano, "dados")) > 0
  cli::cli_abort(c(
    "Ainda n\u00e3o h\u00e1 suporte para ler {sistema} {modulo} {ano} nesta vers\u00e3o do saneabr.",
    "i" = "Leitura suportada: {suportado}.",
    if (no_cat) c("i" = "O arquivo est\u00e1 no cat\u00e1logo: baixe com {.code baixar(\"{tolower(sistema)}\", \"{tolower(modulo)}\", {ano})} e leia por conta pr\u00f3pria.")
  ), class = "saneabr_sem_suporte")
}

#' Tabelas que [ler()] sabe ler
#'
#' @inheritParams baixar
#' @return Um tibble com `tabela`, `descricao` e `padrao` (a tabela lida
#'   quando `ler()` é chamada sem `tabela`).
#' @examples
#' tabelas("snis", "rs", 2022)
#' tabelas("sinisa", "rs", 2024)
#' @export
tabelas <- function(sistema, modulo, ano) {
  sistema <- padronizar_sistema(sistema)
  modulo <- padronizar_modulo(modulo)
  ano <- padronizar_ano(ano)
  era <- achar_era(sistema, modulo, ano)
  tabs <- Filter(function(t) is.null(t$anos) || ano %in% unlist(t$anos), era$tabelas)
  tibble::tibble(
    tabela = names(tabs),
    descricao = vapply(tabs, function(t) t$descricao %||% "", character(1), USE.NAMES = FALSE),
    padrao = names(tabs) == era$tabela_padrao
  )
}

#' Lê uma tabela do SNIS ou do SINISA
#'
#' Baixa (se preciso) o arquivo de dados do ano, extrai a planilha da tabela
#' pedida e devolve um data frame arrumado: uma coluna por variável, com o
#' código normalizado como nome (`CO119`, `IN015`, `GTR1028`, em maiúsculas e
#' sem o `*` de campo obrigatório do SINISA), a chave `id_municipio` com 7
#' dígitos (o código IBGE completo, calculado a partir dos 6 dígitos do SNIS
#' quando preciso) e `ano`. As colunas de identificação recebem nomes
#' padronizados (`municipio`, `uf`, `regiao`...). Colunas cujos valores são
#' todos números viram `numeric`; células `"-"`, `"null"` e vazias viram `NA`.
#'
#' As regras (onde está a linha de códigos, como nomear cada coluna, que
#' valores são nulos) vêm da especificação compartilhada com a biblioteca
#' Python `saneabr` e estão descritas em `system.file("extdata", "spec",
#' "README.md", package = "saneabr")`.
#'
#' @section Cobertura da versão 0.1:
#' Só o módulo de resíduos sólidos (RS): SNIS 2014–2022 e SINISA 2023–2024.
#' Para outros módulos e anos, `ler()` responde com erro; os arquivos estão no
#' [catalogo()] e podem ser baixados com [baixar()].
#'
#' @section Comparabilidade:
#' SNIS e SINISA não usam os mesmos códigos nem os mesmos conceitos. Não
#' empilhe anos dos dois sistemas sem passar por [correspondencia()].
#'
#' @inheritParams baixar
#' @param tabela Nome da tabela; veja [tabelas()]. Se `NULL`, a tabela padrão
#'   da era (`"informacoes"` no SNIS, `"manejo"` no SINISA).
#' @param arquivo Opcional: caminho de um arquivo já baixado (zip, rar ou
#'   planilha) para ler em vez de buscar no cache.
#' @section Sem internet ou com a fonte fora do ar:
#' Se o arquivo ainda não está no cache e a fonte não responde, `ler()` emite
#' uma mensagem (classe `saneabr_fonte_indisponivel`) e devolve `NULL`
#' invisível, sem erro nem warning. Veja [baixar()] e [fonte_disponivel()].
#'
#' @return Um tibble, ou `NULL` invisível se o arquivo não pôde ser baixado.
#' @examples
#' \donttest{
#' if (interactive() && fonte_disponivel()) {
#'   rs22 <- ler("snis", "rs", 2022)
#'   sinisa24 <- ler("sinisa", "rs", 2024, tabela = "indicadores")
#' }
#' }
#' @export
ler <- function(sistema, modulo, ano, tabela = NULL, arquivo = NULL) {
  sistema <- padronizar_sistema(sistema)
  modulo <- padronizar_modulo(modulo)
  ano <- padronizar_ano(ano)
  era <- achar_era(sistema, modulo, ano)
  tabela <- tabela %||% era$tabela_padrao
  tab <- era$tabelas[[tabela]]
  disp <- tabelas(sistema, modulo, ano)$tabela
  if (is.null(tab) || !tabela %in% disp) {
    cli::cli_abort(c("Tabela {.val {tabela}} n\u00e3o existe em {sistema} {modulo} {ano}.",
                     "i" = "Tabelas: {.val {disp}}"), class = "saneabr_sem_tabela")
  }
  if (is.null(arquivo)) {
    arqs <- baixar(sistema, modulo, ano, tipo = "dados")
    if (is.null(arqs)) return(invisible(NULL))
    hit <- arqs[grepl(era$arquivo_catalogo_regex, basename(arqs), perl = TRUE)]
    arquivo <- if (length(hit)) hit[1] else arqs[1]
  } else if (!file.exists(arquivo)) {
    cli::cli_abort("Arquivo n\u00e3o encontrado: {.file {arquivo}}.")
  }
  planilha <- localizar_planilha(arquivo, tab$arquivo_regex)
  aba <- escolher_aba(planilha, tab$aba_regex)
  grade <- ler_grade(planilha, aba)
  df <- arrumar_grade(grade, ano)
  tibble::as_tibble(df)
}

ler_grade <- function(planilha, aba) {
  x <- suppressMessages(readxl::read_excel(
    planilha, sheet = aba, col_names = FALSE, col_types = "text",
    trim_ws = FALSE, na = character(), .name_repair = "minimal"
  ))
  m <- as.matrix(as.data.frame(x, stringsAsFactors = FALSE))
  dimnames(m) <- NULL
  m
}

# O algoritmo de spec/README.md, secao "Leitura de uma aba".
arrumar_grade <- function(g, ano) {
  lay <- spec_layouts()
  cfg_cod <- lay$codigo
  cfg_val <- lay$valores
  cfg_mun <- lay$municipio
  na_tok <- unlist(cfg_val$na)

  # 1. limpa: apara espacos (inclusive nao separaveis); vazio vira NA
  for (tr in lay$texto$substituir) g[] <- gsub(tr[[1]], tr[[2]], g, fixed = TRUE)
  g[] <- aparar(g)
  g[!is.na(g) & g == ""] <- NA
  if (!length(g)) cli::cli_abort("Aba vazia.")
  manter <- colSums(!is.na(g)) > 0
  g <- g[, manter, drop = FALSE]
  nr <- nrow(g)
  nc <- ncol(g)

  # 2. linha de codigos: a de mais codigos entre as primeiras 'linhas_busca'
  busca <- seq_len(min(nr, cfg_cod$linhas_busca))
  cod <- matrix(normalizar_codigo(g[busca, , drop = FALSE]), nrow = length(busca))
  hits <- rowSums(!is.na(cod))
  lin <- which.max(hits)
  if (hits[lin] < cfg_cod$min_por_linha) {
    cli::cli_abort("N\u00e3o achei a linha de c\u00f3digos de vari\u00e1vel nesta aba.",
                   class = "saneabr_sem_codigos")
  }

  # 3. primeira linha de dados: a primeira abaixo de 'lin' com alguma celula
  #    no formato de codigo de municipio
  eh_mun <- matrix(!is.na(g) & grepl(cfg_mun$regex, g, perl = TRUE), nrow = nr)
  depois <- which(rowSums(eh_mun) > 0)
  depois <- depois[depois > lin]
  ini <- if (length(depois)) depois[1] else nr + 1L
  abaixo <- if (ini - 1 > lin) seq.int(lin + 1, ini - 1) else integer()
  acima <- if (lin > 1) seq.int(lin - 1, 1) else integer()
  cod_ext <- function(r) {
    if (r <= length(busca)) cod[r, ] else normalizar_codigo(g[r, ])
  }
  cods <- lapply(c(lin, abaixo), cod_ext)

  # 4. nome de cada coluna
  mapa <- lay$nomes_padrao
  mapa <- mapa[!startsWith(names(mapa), "_")]
  nomes <- character(nc)
  for (j in seq_len(nc)) {
    achado <- NA_character_
    for (cc in cods) if (!is.na(cc[j])) { achado <- cc[j]; break }
    if (!is.na(achado)) { nomes[j] <- achado; next }
    textos <- function(rs) {
      v <- g[rs, j]
      v[!is.na(v) & !v %in% na_tok & is.na(normalizar_codigo(v))]
    }
    t_acima <- textos(acima)
    t_lin <- textos(lin)
    cand <- c(t_acima, t_lin, textos(abaixo))
    composta <- c(
      if (length(t_acima) && length(t_lin)) paste(t_acima[1], t_lin[1]),
      if (length(t_acima) >= 2) paste(t_acima[2], t_acima[1])
    )
    chaves <- slug(c(composta, cand))
    hit <- which(chaves %in% names(mapa))
    if (length(hit)) { nomes[j] <- mapa[[chaves[hit[1]]]]; next }
    partes <- unique(c(rev(t_acima[1:2]), t_lin[1]))
    partes <- partes[!is.na(partes)]
    if (!length(partes) && length(cand)) partes <- cand[1]
    nomes[j] <- slug(paste(partes, collapse = " "))
  }

  # 5. linhas de dados: as que tem codigo de municipio na coluna-chave
  chave <- match("id_municipio", nomes)
  if (is.na(chave)) chave <- match("id_municipio_snis", nomes)
  if (is.na(chave)) {
    cli::cli_abort("N\u00e3o achei a coluna de c\u00f3digo de munic\u00edpio.",
                   class = "saneabr_sem_chave")
  }
  linhas <- if (ini <= nr) seq.int(ini, nr) else integer()
  linhas <- linhas[eh_mun[linhas, chave]]
  d <- g[linhas, , drop = FALSE]

  # 6. colunas sem nome e sem dado saem; sem nome com dado viram coluna_<j>
  vazio <- colSums(!is.na(d)) == 0
  sai <- nomes == "" & vazio
  sem_nome <- which(nomes == "" & !vazio)
  nomes[sem_nome] <- paste0("coluna_", sem_nome)
  d <- d[, !sai, drop = FALSE]
  nomes <- nomes[!sai]
  nomes <- desduplicar(nomes)

  # 7. valores nulos
  d[!is.na(d) & d %in% na_tok] <- NA
  cols <- lapply(seq_len(ncol(d)), function(j) d[, j])
  names(cols) <- nomes

  # 8. Nome/UF
  cols <- separar_nome_uf(cols, lay$nome_uf)

  # 9. tipos
  forc_txt <- unlist(cfg_val$texto_forcado_regex)
  forc_int <- unlist(cfg_val$inteiro_forcado_regex)
  casa <- function(n, pads) any(vapply(pads, function(p) grepl(p, n, perl = TRUE), logical(1)))
  for (n in names(cols)) {
    if (casa(n, forc_txt)) next
    v <- cols[[n]]
    num <- converter_numero(v, cfg_val)
    if (!is.null(num)) cols[[n]] <- if (casa(n, forc_int)) as.integer(num) else num
  }

  # 10. municipio com 7 digitos e ano
  for (n in intersect(c(unlist(cfg_mun$colunas_7), unlist(cfg_mun$converter_6_para_7)), names(cols))) {
    cols[[n]] <- municipio_7(cols[[n]])
  }
  if (!"id_municipio" %in% names(cols)) {
    cols$id_municipio <- municipio_7(cols$id_municipio_snis)
  }
  if (!"ano" %in% names(cols)) cols$ano <- rep(as.integer(ano), length(linhas))
  ordem <- c("id_municipio", "ano", setdiff(names(cols), c("id_municipio", "ano")))
  out <- as.data.frame(cols[ordem], stringsAsFactors = FALSE, check.names = FALSE,
                       optional = TRUE)
  names(out) <- ordem
  out
}

desduplicar <- function(nomes) {
  vistos <- list()
  for (i in seq_along(nomes)) {
    n <- nomes[i]
    k <- vistos[[n]] %||% 0L
    vistos[[n]] <- k + 1L
    if (k > 0) nomes[i] <- paste0(n, "_", k + 1L)
  }
  nomes
}

converter_numero <- function(v, cfg_val) {
  ok <- !is.na(v)
  if (!any(ok)) return(NULL)
  x <- v[ok]
  virg <- grepl(cfg_val$virgula_decimal_regex, x, perl = TRUE)
  x[virg] <- sub(",", ".", gsub(".", "", x[virg], fixed = TRUE), fixed = TRUE)
  if (!all(grepl(cfg_val$numero_regex, x, perl = TRUE))) return(NULL)
  out <- rep(NA_real_, length(v))
  out[ok] <- as.numeric(x)
  out
}

separar_nome_uf <- function(cols, cfg) {
  out <- list()
  for (n in names(cols)) {
    v <- cols[[n]]
    ok <- !is.na(v)
    if (any(ok) && mean(grepl(cfg$regex, v[ok], perl = TRUE)) >= cfg$limiar) {
      casa <- ok & grepl(cfg$regex, v, perl = TRUE)
      nome <- v
      uf <- rep(NA_character_, length(v))
      nome[casa] <- sub(cfg$regex, "\\1", v[casa], perl = TRUE)
      uf[casa] <- sub(cfg$regex, "\\2", v[casa], perl = TRUE)
      out[[n]] <- nome
      out[[paste0(n, cfg$sufixo)]] <- uf
    } else {
      out[[n]] <- v
    }
  }
  out
}

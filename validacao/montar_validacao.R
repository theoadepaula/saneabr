# Junta os vereditos (validacao/vereditos.csv), as paginas dos verbetes e o
# teste empirico num CSV para decisao e numa lista para leitura.
#
#   Rscript validacao/extrair_verbetes.R
#   SANEABR_CACHE=<dados_brutos> Rscript validacao/razoes_empiricas.R
#   Rscript validacao/montar_validacao.R
#
# Saidas: validacao/correspondencia_rs_validacao.csv e validacao/LISTA-RS.md

le <- function(f) utils::read.csv(f, colClasses = "character", na.strings = character(),
                                   fileEncoding = "UTF-8", check.names = FALSE)
co <- le("spec/dicionarios/correspondencia_snis_sinisa.csv")
co <- co[(co$modulo == "RS" | co$modulo_snis == "RS") & co$tipo_relacao != "sem_par", ]
co$n <- as.character(seq_len(nrow(co)))
ve <- le("validacao/vereditos.csv")
vb <- le("validacao/trabalho/verbetes.csv")
rz <- rbind(le("validacao/trabalho/razoes.csv"), le("validacao/trabalho/razoes_extras.csv"))
rz <- rz[!duplicated(paste(rz$codigo_snis, rz$codigo_sinisa)), ]
dsn <- le("spec/dicionarios/dic_snis.csv")
dsi <- le("spec/dicionarios/dic_sinisa.csv")

stopifnot(all(co$n %in% ve$n))
num <- ve$n[!startsWith(ve$n, "A")]
stopifnot(identical(paste(co$codigo_snis, co$codigo_sinisa)[match(num, co$n)],
                    paste(ve$codigo_snis, ve$codigo_sinisa)[match(num, ve$n)]))

pagina <- function(cod, padroes) {
  for (p in padroes) {
    x <- vb[vb$codigo == cod & grepl(p, vb$documento), ]
    if (nrow(x)) return(paste0(x$documento[1], " p.", x$pagina[1]))
  }
  ""
}
nome <- function(d, cod) { x <- d$nome[d$codigo == cod]; if (length(x)) x[1] else "" }

out <- lapply(seq_len(nrow(ve)), function(i) {
  v <- ve[i, ]
  c0 <- co[co$n == v$n, ]
  r <- rz[rz$codigo_snis == v$codigo_snis & rz$codigo_sinisa == v$codigo_sinisa, ]
  achado <- startsWith(v$n, "A")
  data.frame(
    n = v$n,
    origem = if (achado) "achado na leitura" else "correspondencia",
    codigo_snis = v$codigo_snis,
    nome_snis = if (achado) nome(dsn, v$codigo_snis) else c0$nome_snis,
    codigo_sinisa = v$codigo_sinisa,
    nome_sinisa = if (achado) nome(dsi, v$codigo_sinisa) else c0$nome_sinisa,
    modulo_snis = if (achado) "RS" else c0$modulo_snis,
    modulo_sinisa = if (achado) "RS" else c0$modulo,
    relacao_proposta = if (achado) "sem_par" else c0$tipo_relacao,
    evidencia_proposta = if (achado) "" else c0$evidencia,
    veredito = v$veredito,
    relacao_corrigida = v$relacao_corrigida,
    justificativa = v$justificativa,
    pagina_snis = pagina(v$codigo_snis, c("RS2022", "AP2022")),
    pagina_sinisa = pagina(v$codigo_sinisa, c("SINISA_2024", "SINISA_RESIDUOS", "GESTAOMUNICIPAL")),
    ano_snis_teste = if (nrow(r)) r$ano_snis else "",
    tipo_teste = if (nrow(r)) r$tipo_teste else "",
    n_municipios = if (nrow(r)) r$n_municipios else "",
    razao_mediana = if (nrow(r)) r$razao_mediana else "",
    razao_p25 = if (nrow(r)) r$razao_p25 else "",
    razao_p75 = if (nrow(r)) r$razao_p75 else "",
    concordancia = if (nrow(r)) r$concordancia else "",
    nota_teste = if (nrow(r)) r$nota else "nao testado (nivel de unidade ou sem dado)",
    tema = v$tema,
    decisao_theo = "",
    stringsAsFactors = FALSE
  )
})
out <- do.call(rbind, out)
for (k in c("ano_snis_teste", "tipo_teste", "n_municipios", "razao_mediana", "razao_p25",
            "razao_p75", "concordancia")) out[[k]][out[[k]] == "NA"] <- ""
tc <- textConnection("linhas", "w", local = TRUE)
utils::write.csv(out, tc, row.names = FALSE, na = "")
close(tc)
writeBin(charToRaw(enc2utf8(paste0(paste(linhas, collapse = "\n"), "\n"))),
         "validacao/correspondencia_rs_validacao.csv")

# ---- LISTA-RS.md -------------------------------------------------------------
br <- function(x, d = 2) {
  x <- suppressWarnings(as.numeric(x))
  ifelse(is.na(x), "", formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ","))
}
teste_txt <- function(r) {
  if (r$tipo_teste == "razao" && nzchar(r$razao_mediana)) {
    sprintf("razão SINISA/SNIS %s (quartis %s a %s; %s municípios; SNIS %s × SINISA 2023)",
            br(r$razao_mediana), br(r$razao_p25), br(r$razao_p75),
            br(r$n_municipios, 0), r$ano_snis_teste)
  } else if (r$tipo_teste == "concordancia") {
    sprintf("concordância %s%% (%s municípios)", br(100 * as.numeric(r$concordancia), 0),
            br(r$n_municipios, 0))
  } else "sem teste empírico (nível de unidade, informação futura ou sem dado)"
}
rel <- function(r) {
  if (r$veredito == "confirmado") sprintf("**confirmado** como `%s`", r$relacao_corrigida)
  else if (r$veredito == "corrigir") sprintf("**corrigir**: `%s` → `%s`", r$relacao_proposta, r$relacao_corrigida)
  else if (r$veredito == "novo") sprintf("**par novo**: `%s`", r$relacao_corrigida)
  else "**rejeitado** (não são o mesmo conceito)"
}
fontes <- function(r) sprintf("SNIS: %s · SINISA: %s", r$pagina_snis, r$pagina_sinisa)

base <- out[out$origem == "correspondencia", ]
cnt <- table(factor(base$veredito, levels = c("confirmado", "corrigir", "rejeitado")))
ig_prop <- base[base$relacao_proposta == "igual", ]
md <- c(
  "# Correspondência SNIS ↔ SINISA, Resíduos Sólidos: lista para revisão",
  "",
  sprintf("> Gerada em %s por `validacao/montar_validacao.R`. Cada par foi lido nos glossários (SNIS RS 2022, SINISA RS 2024, SINISA 2023 quando citado, SINISA GM 2024 para os PO). O teste empírico compara, município a município, o SNIS 2022 (ou 2021, quando o par depende da população urbana, que o SNIS 2022 retirou) com o SINISA 2023.", format(Sys.Date())),
  "",
  "## Resumo",
  "",
  sprintf("- **%d pares** de RS na correspondência (tudo menos `sem_par`; inclui 27 pares de PO do SNIS-RS com o módulo GM do SINISA e 2 de AP).", nrow(base)),
  sprintf("- **%d confirmados**, **%d a corrigir** (tipo de relação errado) e **%d rejeitados** (não são o mesmo conceito).", cnt[["confirmado"]], cnt[["corrigir"]], cnt[["rejeitado"]]),
  sprintf("- Dos %d pares `candidata` (só semelhança de nome), %d foram rejeitados.",
          sum(base$relacao_proposta == "candidata"), sum(base$relacao_proposta == "candidata" & base$veredito == "rejeitado")),
  sprintf("- Dos %d pares propostos como `igual`, %d se confirmam; %s viram `mudou_definicao`.",
          nrow(ig_prop), sum(ig_prop$veredito == "confirmado"),
          paste(ig_prop$codigo_snis[ig_prop$veredito != "confirmado"], "→", ig_prop$codigo_sinisa[ig_prop$veredito != "confirmado"], collapse = ", ")),
  sprintf("- **%d pares novos**, achados na leitura (entre eles CO119 → GTR1028, que estava como `sem_par`).", sum(out$origem != "correspondencia")),
  "- Nenhum par de **frota** (veículos) apareceu na correspondência: os campos de veículos do SINISA (GTR12xx) não têm Referência ao SNIS.",
  "",
  "Como marcar: `[x] concordo`, ou escreva a relação certa em `mudar para`. A mesma decisão vai na coluna `decisao_theo` de `correspondencia_rs_validacao.csv` (`ok`, ou o tipo de relação, ou `rejeitar`); depois rode `Rscript ferramentas/aplicar_validacao.R`.",
  "",
  "## Os pares mais usados em análise de resíduos",
  ""
)
temas <- c("massa coletada", "cobertura", "per capita", "custos e despesas", "receitas",
           "coleta seletiva", "destinação", "limpeza urbana", "trabalhadores")
for (t in temas) {
  x <- out[out$tema == t, ]
  if (!nrow(x)) next
  md <- c(md, paste("###", paste0(toupper(substr(t, 1, 1)), substring(t, 2))), "")
  for (i in seq_len(nrow(x))) {
    r <- x[i, ]
    md <- c(md,
      sprintf("**%s → %s**%s", r$codigo_snis, r$codigo_sinisa, if (r$origem != "correspondencia") " (par novo)" else ""),
      sprintf("- SNIS %s: %s", r$codigo_snis, r$nome_snis),
      sprintf("- SINISA %s: %s", r$codigo_sinisa, r$nome_sinisa),
      sprintf("- Proposto: `%s` · Veredito: %s", r$relacao_proposta, rel(r)),
      sprintf("- Teste: %s", teste_txt(r)),
      sprintf("- Por quê: %s (%s)", r$justificativa, fontes(r)),
      "- [ ] concordo · [ ] mudar para: ______",
      "")
  }
}
resto <- out[out$tema == "", ]
md <- c(md, "## Os demais pares", "",
        "| n | SNIS | SINISA | proposto | veredito | corrigido | teste | por quê |",
        "|---|---|---|---|---|---|---|---|")
curto <- function(r) {
  if (r$tipo_teste == "razao" && nzchar(r$razao_mediana)) paste0("razão ", br(r$razao_mediana), " (n=", r$n_municipios, ")")
  else if (r$tipo_teste == "concordancia") paste0(br(100 * as.numeric(r$concordancia), 0), "% (n=", r$n_municipios, ")")
  else "—"
}
for (i in seq_len(nrow(resto))) {
  r <- resto[i, ]
  md <- c(md, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |", r$n, r$codigo_snis, r$codigo_sinisa,
                      r$relacao_proposta, r$veredito, r$relacao_corrigida, curto(r),
                      gsub("|", "/", r$justificativa, fixed = TRUE)))
}
md <- c(md, "", "Páginas de cada verbete: colunas `pagina_snis` e `pagina_sinisa` do CSV.")
con <- file("validacao/LISTA-RS.md", open = "wb")
writeBin(charToRaw(enc2utf8(paste0(paste(md, collapse = "\n"), "\n"))), con)
close(con)
message("ok: ", nrow(out), " linhas; ", paste(names(cnt), cnt, collapse = ", "))

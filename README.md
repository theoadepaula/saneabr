# saneabr

Acesso aos dados do **SNIS** e do **SINISA** (saneamento básico, Ministério das
Cidades) com **um pacote R e uma biblioteca Python que leem a mesma
especificação**.

```
spec/                 conhecimento neutro, fonte única (CSV e JSON) → spec/README.md
r/                    pacote R saneabr (CRAN)
python/               biblioteca Python saneabr (PyPI), layout src/
fixtures/             recortes pequenos de planilhas reais + resultado esperado
ferramentas/          importar_snis_sinisa.R, sincronizar_spec.R, criar_fixtures.py,
                      esperados_fixtures.R, paridade/ (R x Python nos arquivos completos)
LICENCA-DADOS.md      o que a licença dos dados permite e o que o pacote redistribui
```

## API (igual nas duas linguagens)

| Função | O que faz |
|---|---|
| `catalogo(sistema, modulo, ano, tipo)` | arquivos publicados, com URL, tamanho e SHA-256 |
| `baixar(sistema, modulo, ano, tipo = "dados", forcar = FALSE)` | baixa para o cache, confere o SHA-256, avisa se a fonte republicou |
| `ler(sistema, modulo, ano, tabela = NULL, arquivo = NULL)` | data frame arrumado, códigos normalizados, `id_municipio` com 7 dígitos |
| `tabelas(sistema, modulo, ano)` | tabelas que `ler()` sabe ler |
| `dicionario(sistema, modulo)` | dicionário extraído dos glossários |
| `correspondencia(modulo, candidatas = FALSE)` | pares SNIS↔SINISA (por padrão, só os com evidência documental) |
| `mudancas(modulo)` | renomeações e mudanças dentro do SNIS |
| `dir_cache()` | onde fica o cache |

Leitura na v0.1: **RS**, SNIS 2014–2022 e SINISA 2023–2024.

## Fluxo de trabalho

```
# mudou uma regra: edite spec/ e
Rscript ferramentas/sincronizar_spec.R

# nova rodada de dicionários no projeto de pesquisa snis-sinisa
Rscript ferramentas/importar_snis_sinisa.R C:/Users/theoa/dev/snis-sinisa
Rscript ferramentas/sincronizar_spec.R

# testes
cd r && Rscript -e "devtools::test()"
cd python && .venv/Scripts/python -m pytest

# paridade nos arquivos completos (SANEABR_CACHE = pasta com os brutos)
Rscript ferramentas/paridade/paridade_r.R <saida> todas
python ferramentas/paridade/paridade_py.py <saida>
```

Testes que precisam dos arquivos completos rodam com `SANEABR_DADOS_BRUTOS`;
os de rede, com `SANEABR_TESTAR_REDE` (`true` no R, `1` no Python). Os dois
pulam no CRAN e no CI.

Código e `spec/`: MIT (os textos dos glossários transcritos na spec são do Ministério; ver `spec/LICENCA.md`). Dados: Ministério das
Cidades, baixados da fonte pelo usuário.

# Contribuir com o saneabr

Obrigado pelo interesse. Este guia explica como o repositório está organizado e
como mexer nele sem quebrar a promessa principal do pacote: **R e Python dão
exatamente o mesmo resultado**.

## Como o repositório está organizado

```
spec/                 conhecimento neutro, fonte única (CSV e JSON) → spec/README.md
r/                    pacote R saneabr (CRAN)
python/               biblioteca Python saneabr (PyPI), layout src/
fixtures/             recortes pequenos de planilhas reais + resultado esperado
ferramentas/          importar_snis_sinisa.R, sincronizar_spec.R, aplicar_validacao.R,
                      criar_fixtures.py, esperados_fixtures.R,
                      paridade/ (R x Python nos arquivos completos)
validacao/            revisão dos pares SNIS↔SINISA (lista, vereditos, scripts)
logo/                 o sticker (SVG e PNG)
LICENCA-DADOS.md      o que a licença dos dados permite e o que o pacote redistribui
```

A regra de ouro: **toda regra de leitura mora em `spec/`**, nunca no código de
uma das linguagens. As duas implementações só sabem interpretar a spec.

## Fluxo de trabalho

```sh
# mudou uma regra: edite spec/ e copie para os dois pacotes
Rscript ferramentas/sincronizar_spec.R
Rscript ferramentas/sincronizar_spec.R --checar   # só confere (é o que o CI roda)

# nova rodada de dicionários vinda do projeto de pesquisa snis-sinisa
Rscript ferramentas/importar_snis_sinisa.R <pasta-do-snis-sinisa>
Rscript ferramentas/sincronizar_spec.R

# aplicar decisões de validação da correspondência
Rscript ferramentas/aplicar_validacao.R validacao/correspondencia_rs_validacao.csv

# testes
cd r && Rscript -e "devtools::test()"
cd python && python -m pytest

# paridade nos arquivos completos (SANEABR_CACHE = pasta com os brutos)
Rscript ferramentas/paridade/paridade_r.R <saida> todas
python ferramentas/paridade/paridade_py.py <saida>
```

Testes que precisam dos arquivos completos rodam com `SANEABR_DADOS_BRUTOS`; os
de rede, com `SANEABR_TESTAR_REDE` (`true` no R, `1` no Python). Os dois pulam
no CRAN e no CI.

## Antes de abrir um pull request

- [ ] `sincronizar_spec.R --checar` passa
- [ ] testes do R e do Python passam
- [ ] se a mudança afeta a leitura, a paridade R × Python continua idêntica
- [ ] se a mudança afeta a correspondência, cada par novo cita documento e página

## Achou um erro nos dados?

Abra uma [issue](https://github.com/theoadepaula/saneabr/issues) dizendo o
sistema, o módulo, o ano, a tabela e o município. Se o erro estiver na planilha
oficial (e não na leitura), ele vai para a seção de cuidados do README: o
pacote não corrige dado do Ministério, só o lê com fidelidade.

## Publicar uma versão (só o mantenedor)

R e Python saem juntos, com a mesma versão em `r/DESCRIPTION` e
`python/pyproject.toml`; o workflow `publicar-pypi` recusa versões diferentes.

1. Atualize a versão nos dois arquivos, `r/NEWS.md`, `python/CHANGELOG.md` e
   `r/cran-comments.md`. Rode os testes, a paridade e `sincronizar_spec.R --checar`.
2. **TestPyPI:** Actions → `publicar-pypi` → *Run workflow*. Confira a página
   em <https://test.pypi.org/p/saneabr> e instale com
   `pip install -i https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ saneabr`.
3. **CRAN:** na pasta `r/`, `devtools::submit_cran()` (ou envie o tarball de
   `R CMD build` em <https://cran.r-project.org/submit.html>) e confirme o
   e-mail que o CRAN manda ao mantenedor.
4. **PyPI:** depois do aceite no CRAN, crie a release `vX.Y.Z` no GitHub. A
   publicação dispara o envio ao PyPI.

O PyPI não usa token: é *Trusted Publishing*. O publicador confiável já tem de
estar cadastrado (uma vez por site):

| Campo | PyPI (pypi.org) | TestPyPI (test.pypi.org) |
|---|---|---|
| PyPI Project Name | `saneabr` | `saneabr` |
| Owner | `theoadepaula` | `theoadepaula` |
| Repository name | `saneabr` | `saneabr` |
| Workflow name | `publicar-pypi.yml` | `publicar-pypi.yml` |
| Environment name | `pypi` | `testpypi` |

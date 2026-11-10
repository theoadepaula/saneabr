# Contribuir com o saneabr

> **In English, briefly.** saneabr reads Brazil's municipal sanitation data
> (SNIS and SINISA) with identical results in R and Python. It is not yet on
> CRAN or PyPI: we are asking the community to **validate the SNIS ↔ SINISA
> code correspondence for solid waste** first. You do not need to code: open a
> [validation issue](https://github.com/theoadepaula/saneabr/issues/new?template=validacao.yml)
> with the year, the codes, what is wrong and a source (document and page).
> To change code: fork, branch, keep R and Python in sync through `spec/`, run
> both test suites and open a pull request. Discussion is in Portuguese, but
> issues and pull requests in English are welcome.

Obrigado pelo interesse. O saneabr está **em validação pela comunidade**, antes
de ir para o CRAN e o PyPI. Neste momento, a ajuda que mais vale **não exige
programar**: conferir se os códigos do SNIS e do SINISA foram ligados direito.

Este guia tem duas partes:

1. [Ajudar a validar](#1-ajudar-a-validar-sem-programar) (sem programar)
2. [Mexer no código ou na spec](#2-mexer-no-código-ou-na-spec)

Quem participa segue o [código de conduta](CODE_OF_CONDUCT.md).

---

## 1. Ajudar a validar (sem programar)

Quem trabalha com saneamento (prefeitura, prestador, agência reguladora,
consultoria, pesquisa, jornalismo) conhece os campos dos formulários melhor do
que qualquer glossário. Há três coisas para conferir:

| O quê | Onde está | Exemplo do que você pode achar |
|---|---|---|
| **Pares SNIS ↔ SINISA de resíduos sólidos** | [`validacao/LISTA-RS.md`](validacao/LISTA-RS.md) | "o CO119 não corresponde ao GTR1028, porque…" |
| **Correspondência completa** (todos os módulos) | [`spec/dicionarios/correspondencia_snis_sinisa.csv`](spec/dicionarios/correspondencia_snis_sinisa.csv) | um par com o tipo de relação errado, ou um par que falta |
| **Dicionários** (nome, definição, unidade, fórmula) | [`spec/dicionarios/dic_snis.csv`](spec/dicionarios/dic_snis.csv) e [`dic_sinisa.csv`](spec/dicionarios/dic_sinisa.csv) | definição transcrita errada, unidade trocada, página do glossário errada |

### Passo a passo

1. **Abra a lista** [`validacao/LISTA-RS.md`](validacao/LISTA-RS.md). Ela
   começa pelos pares mais usados em análise (massa coletada, cobertura, per
   capita, custos, receitas, coleta seletiva, destinação, limpeza urbana,
   trabalhadores); o resto está numa tabela no fim. Use Ctrl+F para achar os
   códigos que você conhece.
2. **Leia o veredito.** Cada par traz o que foi proposto, o veredito
   (`confirmado`, `corrigir`, `rejeitado` ou `par novo`), o teste nos dados
   (a mediana da razão SINISA 2023 / SNIS 2022 nos municípios que responderam
   aos dois sistemas) e a página do glossário de cada lado.
3. **Concordou?** Ótimo. Se quiser, diga isso num comentário na issue de
   validação do tema (veja as [issues com o rótulo
   `validação`](https://github.com/theoadepaula/saneabr/issues?q=is%3Aissue+label%3Avalida%C3%A7%C3%A3o)):
   uma confirmação de quem preenche o formulário também conta.
4. **Discordou, ou sabe de um par que falta?** Abra uma issue pelo formulário
   [**Validação de par ou de dicionário**](https://github.com/theoadepaula/saneabr/issues/new?template=validacao.yml).
   É preciso uma conta gratuita no GitHub. O formulário pede:
   - o **ano** (de referência dos dados) em que você viu o problema;
   - o **código** do indicador ou da variável (`CO119`, `GTR1028`…), dos dois
     lados quando for um par;
   - a **fonte** (SNIS, SINISA, ou os dois) e o módulo;
   - **o que está errado** e o que você propõe;
   - a **evidência**: documento e página (glossário, manual, nota técnica), um
     link, uma conta feita com os dados, ou a sua experiência de preencher o
     formulário. "Eu preencho esse campo há anos e ele sempre incluiu X" é
     evidência válida: diga de onde vem.
5. **O que acontece depois.** O mantenedor lê a fonte citada, refaz o teste
   nos dados e responde na issue. A decisão entra no pacote com a data, quem
   decidiu e a evidência (colunas `validado`, `validado_em`, `validado_por`), e
   quem contribuiu é creditado.

Tipos de relação que a correspondência usa: `igual` (mesmo conceito e mesma
conta), `mudou_definicao` (parecido, mas o conceito mudou), `mudou_unidade`,
`desmembrado` (um código do SNIS virou vários no SINISA), `agregado` (vários
viraram um) e `rejeitar` (não são a mesma coisa).

Os glossários oficiais usados na validação de resíduos sólidos:
[Informações SNIS RS 2022](https://www.gov.br/cidades/pt-br/acesso-a-informacao/acoes-e-programas/saneamento/snis/produtos-do-snis/diagnosticos/Glossario_Informacoes_RS2022.pdf) ·
[Indicadores SNIS RS 2022](https://www.gov.br/cidades/pt-br/acesso-a-informacao/acoes-e-programas/saneamento/snis/produtos-do-snis/diagnosticos/Glossario_Indicadores_RS2022.pdf) ·
[Informações SINISA 2024](https://www.gov.br/cidades/pt-br/acesso-a-informacao/acoes-e-programas/saneamento/sinisa/resultados-sinisa/Glossario_Informacoes_SINISA_2024.pdf) ·
[Indicadores SINISA 2024](https://www.gov.br/cidades/pt-br/acesso-a-informacao/acoes-e-programas/saneamento/sinisa/resultados-sinisa/Glossario_Indicadores_SINISA_2024.pdf).

### Achou um erro nos dados (não na correspondência)?

Abra uma issue de [bug](https://github.com/theoadepaula/saneabr/issues/new?template=bug.yml)
dizendo o sistema, o módulo, o ano, a tabela e o município. Se o erro estiver
na planilha oficial (e não na leitura), ele vai para a seção de cuidados do
README: o pacote não corrige dado do Ministério, só o lê com fidelidade.

Dúvidas de uso vão para as
[Discussions](https://github.com/theoadepaula/saneabr/discussions).

---

## 2. Mexer no código ou na spec

### A regra de ouro: a spec é a fonte única, R e Python andam juntos

O saneabr promete que **R e Python dão exatamente o mesmo resultado** (na v0.1,
91 de 91 tabelas idênticas em linhas, colunas, tipos e valores). Para isso:

- **Toda regra de leitura mora em [`spec/`](spec/)** (catálogo, layouts por
  era, normalizações, dicionários, correspondência), em CSV e JSON. As duas
  implementações só interpretam a spec. Leia [`spec/README.md`](spec/README.md)
  antes de mudar uma regra.
- **As cópias da spec dentro dos pacotes não se editam à mão**
  (`r/inst/extdata/spec/` e `python/src/saneabr/spec/`). Edite `spec/` e rode
  `Rscript ferramentas/sincronizar_spec.R`. A CI falha se as cópias divergirem.
- **Mudou o comportamento de uma linguagem? Mude a outra no mesmo pull
  request**, com teste nas duas. A API é a mesma: `catalogo()`, `baixar()`,
  `ler()`, `tabelas()`, `dicionario()`, `correspondencia()`, `mudancas()`,
  `dir_cache()`, `fonte_disponivel()`. Se você só sabe uma das linguagens,
  abra o PR assim mesmo e diga isso na descrição: a outra metade é feita antes
  do merge.

### Como o repositório está organizado

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

### Rodar localmente

**R** (4.1 ou mais novo):

```r
# na pasta r/
install.packages(c("devtools", "archive"))
devtools::install_deps(dependencies = TRUE)
devtools::load_all()        # carrega o pacote a partir do código
devtools::test()            # testes
devtools::check()           # R CMD check completo (a CI roda com --as-cran)
```

No Windows, `Rscript -e "..."` costuma quebrar com caminhos que têm `\`: prefira
escrever um arquivo `.R` e rodar `Rscript arquivo.R`.

**Python** (3.9 ou mais novo):

```sh
cd python
python -m venv .venv
# Linux/macOS: source .venv/bin/activate    Windows: .venv\Scripts\activate
python -m pip install -e ".[teste,rar]"
python -m pytest
```

No Linux, ler os arquivos rar do SINISA 2023 exige o `bsdtar`
(`sudo apt install libarchive-tools`) ou o `unrar`.

**Testes que precisam de mais coisa** pulam por padrão (no CRAN e na CI):

| Variável | O que faz | Valor |
|---|---|---|
| `SANEABR_TESTAR_REDE` | liga os testes que baixam do gov.br | `true` no R, `1` no Python |
| `SANEABR_DADOS_BRUTOS` | liga os testes com os arquivos completos | pasta com as planilhas |
| `SANEABR_CACHE` | muda onde o pacote guarda o que baixa | qualquer pasta |

### Comandos de manutenção

```sh
# mudou uma regra: edite spec/ e copie para os dois pacotes
Rscript ferramentas/sincronizar_spec.R
Rscript ferramentas/sincronizar_spec.R --checar   # só confere (é o que o CI roda)

# nova rodada de dicionários vinda do projeto de pesquisa snis-sinisa
Rscript ferramentas/importar_snis_sinisa.R <pasta-do-snis-sinisa>
Rscript ferramentas/sincronizar_spec.R

# aplicar decisões de validação da correspondência
Rscript ferramentas/aplicar_validacao.R validacao/correspondencia_rs_validacao.csv

# paridade nos arquivos completos (SANEABR_CACHE = pasta com os brutos)
Rscript ferramentas/paridade/paridade_r.R <saida> todas
python ferramentas/paridade/paridade_py.py <saida>
```

### Estilo

- **Português do Brasil** em mensagens ao usuário, documentação, comentários e
  commits. Nomes de função e de argumento também em português, como o resto da
  API.
- **R**: estilo do [tidyverse](https://style.tidyverse.org/); documentação com
  roxygen2 (rode `devtools::document()` e versione o `man/`); toda função
  exportada tem `@return` e exemplo; exemplos que usam a internet ficam em
  `\donttest{}`. Para avisar o usuário, use `cli`, não `print()`/`cat()`.
  Escrita em disco só no cache (`tools::R_user_dir()`) ou em `tempdir()`.
- **Python**: PEP 8; docstrings nas funções públicas; avisos com `warnings`
  (como o `FonteIndisponivelAviso`), não `print()`.
- **Sem internet, nada quebra**: `baixar()` e `ler()` avisam e devolvem
  `NULL`/`None`. Mantenha esse comportamento.
- **Número afirmado é número conferido**: na correspondência e nos
  dicionários, todo par ou texto novo cita documento e página.
- Commits curtos e descritivos ("Corrige o cabeçalho do RS 2016"), um assunto
  por commit.

### Fluxo: fork → branch → pull request

A branch `master` é protegida: só recebe pull request com a CI verde.

1. Faça um **fork** do repositório e clone o seu fork.
2. Crie uma **branch** a partir da `master` atualizada, com um prefixo pelo
   tipo: `fix/`, `feat/`, `docs/`, `dados/` (dicionário, correspondência,
   catálogo), `ci/`. Exemplo: `git switch -c dados/corrige-co119`.
3. Faça a mudança, com testes. Se mexeu em `spec/`, rode o
   `sincronizar_spec.R` e versione as cópias geradas.
4. **Abra o pull request** para a `master` de `theoadepaula/saneabr`. O
   modelo do PR traz a lista de conferência. Cite a issue que ele resolve
   (`Resolve #12`).
5. A CI roda a sincronia da spec, o `R CMD check --as-cran` em Windows, macOS
   e Linux e o `pytest` em Python 3.9 e 3.12. Precisa ficar verde.
6. O mantenedor revisa e faz o merge.

### Antes de abrir um pull request

- [ ] `Rscript ferramentas/sincronizar_spec.R --checar` passa
- [ ] testes do R e do Python passam
- [ ] se a mudança afeta a leitura, R e Python continuam dando o mesmo
      resultado (e a paridade foi rodada, se você tem os arquivos completos)
- [ ] se a mudança afeta a correspondência ou um dicionário, cada linha nova
      cita documento e página
- [ ] `r/NEWS.md` e `python/CHANGELOG.md` registram a mudança visível ao usuário

---

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

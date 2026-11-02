# saneabr: dados do SNIS e do SINISA em R e Python <img align="right" src="logo/saneabr.png" alt="logo do saneabr" width="160">

<table>
<tr>
<th><i>R</i></th>
<th><i>Python</i></th>
<th><i>Repositório</i></th>
</tr>
<tr>
<td>

[![CRAN](https://www.r-pkg.org/badges/version/saneabr)](https://CRAN.R-project.org/package=saneabr)<br>
[![downloads](https://cranlogs.r-pkg.org/badges/grand-total/saneabr)](https://CRAN.R-project.org/package=saneabr)<br>
[![downloads/mês](https://cranlogs.r-pkg.org/badges/saneabr)](https://CRAN.R-project.org/package=saneabr)<br>
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)<br>
[![R-CMD-check](https://github.com/theoadepaula/saneabr/actions/workflows/check.yml/badge.svg)](https://github.com/theoadepaula/saneabr/actions/workflows/check.yml)

</td>
<td>

[![PyPI](https://img.shields.io/pypi/v/saneabr?label=pypi)](https://pypi.org/project/saneabr/)<br>
[![downloads](https://static.pepy.tech/badge/saneabr)](https://pepy.tech/project/saneabr)<br>
[![downloads/mês](https://static.pepy.tech/badge/saneabr/month)](https://pepy.tech/project/saneabr)<br>
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)<br>
[![Python-check](https://github.com/theoadepaula/saneabr/actions/workflows/check.yml/badge.svg)](https://github.com/theoadepaula/saneabr/actions/workflows/check.yml)

</td>
<td>

[![GitHub stars](https://img.shields.io/github/stars/theoadepaula/saneabr?style=social)](https://github.com/theoadepaula/saneabr/stargazers)<br><br>
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

</td>
</tr>
</table>

O **saneabr** baixa e lê os dados municipais do **SNIS** (Sistema Nacional de
Informações sobre Saneamento) e do seu sucessor, o **SINISA** (Sistema Nacional
de Informações em Saneamento Básico), publicados pelo Ministério das Cidades.
Ele existe **em R e em Python**, com as mesmas funções e o mesmo resultado nas
duas linguagens.

Em três linhas, você sai de dezenas de planilhas espalhadas por anos e formatos
para uma tabela arrumada, com um município por linha:

```r
library(saneabr)
rs <- ler("snis", "rs", 2022)   # resíduos sólidos, 2022: 5.060 municípios
```

> **Fase atual (v0.1, experimental).** Lê o módulo de **resíduos sólidos**: SNIS
> 2014–2022 e SINISA 2023–2024. Os demais módulos e anos já estão no catálogo e
> podem ser baixados. Ainda não está no CRAN nem no PyPI: instale pelo GitHub
> (veja abaixo).

## Sumário

- [Por que este pacote existe](#por-que-este-pacote-existe)
- [O que são o SNIS e o SINISA](#o-que-são-o-snis-e-o-sinisa)
- [Instalação](#instalação)
- [Primeiros passos](#primeiros-passos)
- [Funções](#funções)
- [O que já dá para ler](#o-que-já-dá-para-ler)
- [Cuidados ao comparar SNIS e SINISA](#cuidados-ao-comparar-snis-e-sinisa)
- [Como funciona por dentro](#como-funciona-por-dentro)
- [Licença e dados](#licença-e-dados)
- [Como citar](#como-citar)
- [Contribuir](#contribuir)
- [Pacotes relacionados](#pacotes-relacionados)

## Por que este pacote existe

Os dados do SNIS e do SINISA são públicos, mas trabalhar com eles dá trabalho:

- **Não há API.** Os dados saem em planilhas (xls, xlsx), dentro de arquivos zip
  ou rar, uma página por ano no site do Ministério.
- **O formato muda com o tempo.** Só no módulo de resíduos sólidos há quatro
  layouts diferentes entre 2002 e 2024, com o cabeçalho começando entre a 8ª e
  a 14ª linha, códigos em caixa mista e nome e UF juntos na mesma célula
  ("Abel Figueiredo/PA").
- **Os códigos mudaram em 2023.** Na passagem do SNIS para o SINISA, nenhum
  código de variável se manteve: `CO119` virou outra coisa, `IN015` virou
  `IRS0001`. O código de município também passou de 6 para 7 dígitos.
- **Os arquivos são republicados sem aviso** (`_atualizado_29112024`,
  `_Retificado`), e o que você baixou ontem pode não ser o que está lá hoje.

O saneabr resolve isso uma vez, de forma aberta e testada, para que cada
pesquisador, jornalista ou gestor não precise resolver de novo.

## O que são o SNIS e o SINISA

O **SNIS** reuniu, de 1995 a 2022, as informações declaradas pelos municípios e
prestadores sobre os serviços de saneamento. Em 2023 ele foi substituído pelo
**SINISA**, que mudou o questionário, os conceitos e os códigos.

Os dois se organizam em **módulos**, que o pacote identifica por uma sigla:

| Sigla | Módulo | SNIS | SINISA |
|---|---|---|---|
| `"rs"` | Resíduos sólidos (coleta, destinação, limpeza urbana) | 2002–2022 | 2023–2024 |
| `"ae"` | Água e esgoto | 1995–2022 | 2023–2024 |
| `"ap"` | Águas pluviais (drenagem) | 2015, 2017–2022 | 2023–2024 |
| `"gm"` | Gestão municipal (planos, políticas, consórcios) | — | 2023–2024 |

Cada ano tem várias **tabelas** (informações municipais, indicadores, unidades
de processamento, veículos…). Cada coluna de dado é identificada por um
**código**: no SNIS, códigos como `CO119` (quantidade de resíduos coletada) e
`IN015` (taxa de cobertura da coleta); no SINISA, códigos como `GTR1028` e
`IRS0001`. O dicionário, que o pacote também traz, diz o que cada código
significa.

## Instalação

**R** (versão de desenvolvimento, enquanto não está no CRAN):

```r
# install.packages("remotes")
remotes::install_github("theoadepaula/saneabr", subdir = "r")

# para ler os arquivos .rar do SINISA 2023, instale também:
install.packages("archive")
```

**Python** (versão de desenvolvimento, enquanto não está no PyPI):

```sh
pip install "saneabr[rar] @ git+https://github.com/theoadepaula/saneabr#subdirectory=python"
```

No Linux, ler arquivos rar exige o `bsdtar` (`sudo apt install libarchive-tools`)
ou o `unrar`. No Windows e no macOS, nada a fazer.

## Primeiros passos

O caminho típico tem cinco passos. Os exemplos vêm em R e em Python; o
resultado é o mesmo.

### 1. Ver o que existe: `catalogo()`

O catálogo lista todos os arquivos conhecidos, com o endereço oficial, o
tamanho e a impressão digital (SHA-256) de cada um.

```r
catalogo(sistema = "snis", modulo = "rs")
```

```python
import saneabr
saneabr.catalogo(sistema="snis", modulo="rs")
```

### 2. Ver as tabelas de um ano: `tabelas()`

```r
tabelas("snis", "rs", 2022)
#> # A tibble: 7 × 3
#>   tabela                  descricao                                          padrao
#> 1 informacoes             Informacoes municipais (uma linha por municipio)   TRUE
#> 2 indicadores             Indicadores municipais (uma linha por municipio)   FALSE
#> 3 politicas_planos        Politicas, planos e consorcios (2016 em diante)    FALSE
#> 4 unidades_cadastro       Cadastro nacional de unidades de processamento     FALSE
#> ...
```

A tabela marcada como `padrao` é a que `ler()` devolve quando você não escolhe
nenhuma.

### 3. Ler os dados: `ler()`

`ler()` baixa o arquivo (só na primeira vez; depois usa o cache), acha a
planilha e o cabeçalho certos e devolve uma tabela arrumada.

```r
rs22 <- ler("snis", "rs", 2022)
dim(rs22)
#> [1] 5060  219

rs22[rs22$municipio == "Brasília", c("id_municipio", "municipio", "uf", "CO119")]
#>   id_municipio municipio uf     CO119
#> 1 5300108      Brasília  DF    723936
```

```python
rs22 = saneabr.ler("snis", "rs", 2022)
ind24 = saneabr.ler("sinisa", "rs", 2024, tabela="indicadores")
```

O que `ler()` faz por você:

- `id_municipio` sempre com **7 dígitos** (o código do IBGE), o mesmo do
  [geobr](https://github.com/ipea/geobr) e do
  [censobr](https://github.com/ipea/censobr), pronto para juntar com mapas e
  com o Censo;
- códigos de variável em maiúsculas e sem os enfeites do formulário
  (`Co119` → `CO119`, `GTR1030*` → `GTR1030`);
- nome do município e UF em colunas separadas;
- números como números.

### 4. Entender os códigos: `dicionario()`

```r
d <- dicionario("snis", "rs")
d[d$codigo == "CO119", c("codigo", "nome", "unidade")]
#>   codigo nome                                                        unidade
#> 1 CO119  QUANTIDADE TOTAL DE RDO E RPU COLETADA POR TODOS OS AGENTES Tonelada/ano
```

Cada linha do dicionário traz a definição, a unidade, a fórmula (nos
indicadores), os anos em que o código aparece e **o documento e a página** do
glossário oficial de onde o texto foi transcrito.

### 5. Ligar o SNIS ao SINISA: `correspondencia()`

Para montar uma série que atravessa 2022 → 2023, é preciso saber qual código do
SINISA corresponde a qual do SNIS, e se o conceito é o mesmo.

```r
correspondencia("rs")
```

```python
saneabr.correspondencia("rs")
```

Cada par vem com o **tipo de relação** (`igual`, `mudou_definicao`,
`mudou_unidade`, `desmembrado`, `agregado`) e a **evidência**: o documento e a
página que sustentam o par. Por padrão, só entram pares com evidência
documental; os sugeridos apenas por semelhança de nome ficam atrás de
`candidatas = TRUE`.

> ⚠️ Antes de emendar uma série, leia a [seção de cuidados](#cuidados-ao-comparar-snis-e-sinisa).
> "Mesmo nome" não quer dizer "mesmo conceito".

## Funções

| Função | O que faz |
|---|---|
| `catalogo(sistema, modulo, ano, tipo)` | lista os arquivos publicados, com URL, tamanho e SHA-256 |
| `baixar(sistema, modulo, ano, tipo = "dados", forcar = FALSE)` | baixa para o cache, confere o SHA-256 e avisa se a fonte republicou o arquivo |
| `tabelas(sistema, modulo, ano)` | mostra as tabelas que `ler()` sabe ler naquele ano |
| `ler(sistema, modulo, ano, tabela, arquivo)` | devolve a tabela arrumada; `arquivo` aceita um arquivo já baixado |
| `dicionario(sistema, modulo)` | dicionário de códigos extraído dos glossários oficiais |
| `correspondencia(modulo, candidatas = FALSE)` | pares de códigos SNIS ↔ SINISA, com tipo de relação e evidência |
| `mudancas(modulo)` | códigos renomeados, fórmulas e unidades alteradas *dentro* do SNIS |
| `dir_cache()` | onde ficam os arquivos baixados (mude com a variável `SANEABR_CACHE`) |

## O que já dá para ler

| | Resíduos sólidos | Água e esgoto | Águas pluviais | Gestão municipal |
|---|---|---|---|---|
| **SNIS 2014–2022** | ✅ `ler()` | ⬇️ `baixar()` | ⬇️ `baixar()` | — |
| **SNIS anos anteriores** | ⬇️ `baixar()` | ⬇️ `baixar()` | ⬇️ `baixar()` | — |
| **SINISA 2023–2024** | ✅ `ler()` | ⬇️ `baixar()` | ⬇️ `baixar()` | ⬇️ `baixar()` |

✅ lê e arruma · ⬇️ baixa e confere; a leitura chega nas próximas versões.

## Cuidados ao comparar SNIS e SINISA

O SINISA não é o SNIS com outro nome. Quatro mudanças afetam diretamente quem
monta séries históricas de resíduos sólidos (detalhes, documentos e páginas em
[`spec/NOTAS-MUDANCAS.md`](spec/NOTAS-MUDANCAS.md)):

1. **A massa coletada mudou de conceito.** O `CO119` do SNIS soma resíduos
   domiciliares e públicos coletados pelos agentes; o `GTR1028` do SINISA soma
   as massas declaradas por rota e inclui coleta seletiva, podas e entulho de
   pequenos geradores. Os números ficam parecidos, mas não são a mesma medida.
2. **O total nacional mudou de método.** O SNIS extrapolava uma amostra de
   municípios; o SINISA multiplica o per capita pela população total. Parte do
   salto entre 2022 e 2023 é método, não geração de lixo.
3. **A amostra mudou de natureza.** No SNIS, a resposta era voluntária e o
   conjunto de municípios mudava a cada ano. O SINISA publica os 5.570
   municípios, com valor vazio para quem não respondeu.
4. **Os indicadores per capita mudaram de denominador**, de população atendida
   para população total. O par mais limpo entre os dois sistemas é a taxa de
   cobertura da coleta (`IN015` → `IRS0001`).

A tabela de correspondência está **em validação**: os pares de resíduos sólidos
estão sendo conferidos à mão, um a um, contra os glossários e contra os dados.
O resultado entra nas próximas versões, com a data e o responsável de cada
validação.

## Como funciona por dentro

Todo o conhecimento sobre as fontes (onde estão os arquivos, como achar o
cabeçalho em cada formato, como normalizar códigos, o que cada código
significa) fica numa **especificação neutra**, em arquivos CSV e JSON na pasta
[`spec/`](spec/). Os pacotes R e Python só interpretam essa especificação.

```
              spec/  (catálogo, regras de leitura, dicionários, correspondência)
             ┌──────────────────────┴──────────────────────┐
         pacote R                                     biblioteca Python
             └──────────────── mesmo resultado ────────────┘
```

Isso traz duas garantias:

- **Um conserto vale para as duas linguagens.** Quando o Ministério republica
  um arquivo ou muda um layout, a correção é feita uma vez, na spec.
- **R e Python são conferidos um contra o outro.** Um teste de paridade lê
  todos os anos cobertos nas duas linguagens e exige linhas, colunas, tipos e
  valores idênticos (91 de 91 tabelas na v0.1).

## Licença e dados

- **Código e especificação:** licença [MIT](LICENSE).
- **Dados:** são do Ministério das Cidades e **não vêm dentro do pacote**: cada
  usuário baixa da fonte oficial, e o pacote confere que o arquivo é o
  esperado. Os dados de saneamento são abertos, de livre utilização com
  crédito à fonte (Decreto 8.777/2016; Lei 14.129/2021). A análise completa
  está em [`LICENCA-DADOS.md`](LICENCA-DADOS.md).
- **Dicionários:** os textos de nome, definição e unidade são transcritos sem
  alteração dos glossários oficiais, com documento e página citados em cada
  linha.

Ao publicar um resultado, cite a fonte dos dados (Ministério das Cidades,
SNIS/SINISA) e, se o pacote ajudou, cite o saneabr.

## Como citar

> de Paula, T. (2026). *saneabr: acesso aos dados do SNIS e do SINISA em R e
> Python*. Versão 0.1.0. https://github.com/theoadepaula/saneabr

```bibtex
@software{saneabr,
  author  = {de Paula, Théo},
  title   = {saneabr: acesso aos dados do SNIS e do SINISA em R e Python},
  year    = {2026},
  version = {0.1.0},
  url     = {https://github.com/theoadepaula/saneabr}
}
```

## Contribuir

Erros, dúvidas e sugestões são bem-vindos nas
[issues](https://github.com/theoadepaula/saneabr/issues). Para mexer no código
ou na especificação, veja o [guia de contribuição](CONTRIBUTING.md).

## Pacotes relacionados

O saneabr segue o espírito dos pacotes de dados brasileiros reunidos no
[brverse](https://github.com/ipea/brverse), do Ipea, e foi pensado para
conversar com eles pelo código de município:

- [geobr](https://github.com/ipea/geobr): malhas territoriais oficiais (mapas);
- [censobr](https://github.com/ipea/censobr): dados do Censo Demográfico;
- [basedosdados](https://basedosdados.org/): tem o SNIS de água e esgoto em
  BigQuery.

---

Desenvolvido por [Théo de Paula](https://theoalbuquerque.com.br). Os dados são
do Ministério das Cidades (Secretaria Nacional de Saneamento Ambiental).

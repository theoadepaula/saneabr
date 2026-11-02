# spec/ — a especificação compartilhada do saneabr

Tudo o que o pacote R e a biblioteca Python sabem sobre o SNIS e o SINISA mora
aqui, em CSV e JSON. O código das duas linguagens só executa o algoritmo
descrito abaixo com os parâmetros desta pasta. **Mudou uma regra? Mude aqui** e
rode, na raiz do repositório:

```
Rscript ferramentas/sincronizar_spec.R           # copia spec/ para os dois pacotes
Rscript ferramentas/sincronizar_spec.R --checar  # só confere (para CI)
```

As cópias em `r/inst/extdata/spec/` e `python/src/saneabr/spec/` não se editam
à mão. Licença desta pasta: [LICENCA.md](LICENCA.md).

## Arquivos

| Arquivo | O que é | De onde vem |
|---|---|---|
| `catalogo.csv` | um arquivo publicado por linha: `sistema`, `modulo`, `ano` (de referência), `tipo` (`dados`, `glossario_informacoes`, `glossario_indicadores`, `relatorio`, `manual`...), `arquivo`, `url`, `sha256`, `formato`, `bytes`, `data_verificacao` | `ferramentas/importar_snis_sinisa.R` a partir de `snis-sinisa/dados_brutos/MANIFESTO.csv` |
| `layouts.json` | regras de leitura: normalização de texto e de código, valores nulos, tipos, chave municipal, Nome/UF, nomes padronizados, eras e tabelas | escrito à mão, conferido contra as planilhas |
| `rede.json` | User-Agent, timeout, tentativas, variáveis de ambiente do cache | escrito à mão |
| `esquemas.json` | colunas obrigatórias de cada tabela da spec; o importador recusa origem sem elas | escrito à mão |
| `dicionarios/dic_snis.csv`, `dic_sinisa.csv` | um código por linha: nome, definição, unidade, fórmula (só os códigos citados: nos PDFs a fórmula é imagem), insumos, anos, documento e página, `qualidade` (`verbete`, `tabela`, `so_planilha`) | importados de `snis-sinisa/dicionarios/` |
| `dicionarios/correspondencia_snis_sinisa.csv` | pares SNIS↔SINISA com `tipo_relacao`, `evidencia_documental`, `evidencia`, `observacao`, mais `qualidade_snis` e `qualidade_sinisa` (copiadas dos dicionários) | importado; montado automaticamente a partir dos PDFs, **sem validação manual** |
| `dicionarios/mudancas_dentro_snis.csv` | renomeações declaradas e mudanças detectadas entre versões dos glossários do SNIS | importado |
| `dicionarios/glossarios_versoes.csv.gz` | cada verbete de cada versão de glossário (15.782 linhas) | importado; **fica só no repositório** (11 MB descompactado) |
| `NOTAS-MUDANCAS.md` | síntese das quebras de série (amostra × universo, CO119 ≠ GTR1028, população...) com documento e página | cópia de `snis-sinisa/NOTAS-MUDANCAS.md` |

Para reimportar os dicionários depois de uma nova rodada no projeto de
pesquisa: `Rscript ferramentas/importar_snis_sinisa.R [pasta_snis_sinisa]` e
depois o sincronizador.

## Leitura de uma aba (normativo)

Entrada: a aba inteira como grade de texto (célula numérica vira texto: inteiro
sem casas decimais, demais com a representação que volta ao mesmo double;
booleano vira `TRUE`/`FALSE`; célula vazia ou de erro vira nulo). As linhas e
colunas são numeradas a partir de 1.

1. **Limpeza.** Em cada célula, aplicar as trocas de `texto.substituir`; tirar
   espaços das pontas (espaço ASCII, `\t\n\r\f\v` e `texto.espacos_extra`);
   texto vazio vira nulo. Descartar colunas inteiramente nulas.
2. **Código de variável.** `normalizar(x)`: remover os caracteres de
   `codigo.remover` e todo espaço, passar a maiúsculas; se casar com
   `codigo.regex`, o código é o grupo 1 (`GTR1030*` → `GTR1030`,
   `UP088 - lat.` → `UP088`, `Co119` → `CO119`).
3. **Linha de códigos** (`lin`): entre as primeiras `codigo.linhas_busca`
   linhas, a com mais células que são código; em empate, a primeira. Menos de
   `codigo.min_por_linha` códigos é erro.
4. **Primeira linha de dados** (`ini`): a primeira linha abaixo de `lin` com
   alguma célula casando `municipio.regex`. O cabeçalho vai de 1 a `ini - 1`.
5. **Nome de cada coluna.**
   - Se alguma célula da coluna, olhando `lin` e depois as linhas entre `lin`
     e `ini`, é código, o nome é o primeiro código achado.
   - Senão, juntar os textos não nulos da coluna que não são código nem estão
     em `valores.na`: primeiro os de cima de `lin` (do mais próximo para o mais
     distante), depois o de `lin`, depois os de baixo. Procurar em
     `nomes_padrao` (chave = `slug`), nesta ordem: as chaves compostas (texto
     mais próximo acima + texto de `lin`; segundo texto acima + primeiro texto
     acima, separados por espaço), depois cada texto.
     O primeiro achado é o nome.
   - Se nada casar: `slug` de [segundo texto acima, primeiro texto acima,
     texto de `lin`] (só os que existem, sem repetir); se não houver nenhum
     desses, o primeiro texto da lista; se não houver texto, nome vazio.
   - `slug(x)`: minúsculas, `acentos_de` → `acentos_para` caractere a
     caractere, todo trecho fora de `[a-z0-9]` vira `_`, sem `_` nas pontas.
6. **Linhas de dados.** Coluna-chave: a primeira chamada `id_municipio`; se não
   houver, `id_municipio_snis`; se não houver, erro. Ficam as linhas a partir de
   `ini` cuja célula na coluna-chave casa `municipio.regex`.
7. **Colunas sem nome.** Sem nome e sem dado nas linhas de dados: sai. Sem nome
   e com dado: `coluna_<j>` (posição depois do passo 1). Nomes repetidos ganham
   `_2`, `_3`... na ordem em que aparecem.
8. **Nulos.** Valor em `valores.na` vira nulo.
9. **Nome/UF.** Coluna em que pelo menos `nome_uf.limiar` dos valores não
   nulos casam `nome_uf.regex`: o grupo 1 fica na coluna, o grupo 2 vai para
   `<coluna>` + `nome_uf.sufixo`, logo à direita.
10. **Tipos.** Coluna cujo nome casa algum `valores.texto_forcado_regex` fica
    texto. Nas outras, se todo valor não nulo casa `valores.numero_regex`
    (depois de converter os que casam `valores.virgula_decimal_regex`: tirar
    `.` de milhar, trocar `,` por `.`), a coluna vira número (double); se além
    disso o nome casa `valores.inteiro_forcado_regex`, inteiro. Coluna só de
    nulos fica texto.
11. **Município com 7 dígitos.** Nas colunas de `municipio.colunas_7` e
    `municipio.converter_6_para_7`, valor de 6 dígitos ganha o dígito
    verificador: pesos `municipio.pesos` sobre os 6 dígitos, produto acima de 9
    tem os algarismos somados, DV = (10 − soma mod 10) mod 10; os códigos em
    `municipio.excecoes` (9 municípios que o IBGE numerou fora da regra) usam o
    valor da tabela. Se não houver `id_municipio`, ele é criado a partir de
    `id_municipio_snis`.
12. **Ano e ordem.** Sem coluna `ano`, ela é criada com o ano de referência
    pedido. A ordem final é `id_municipio`, `ano` e as demais na ordem da aba.

## Eras e tabelas

Cada item de `layouts.json → eras` diz que anos de que sistema e módulo têm
leitor, que arquivo do catálogo usar (`arquivo_catalogo_regex`) e, para cada
tabela, a planilha dentro do zip/rar (`arquivo_regex`, sobre o nome do arquivo)
e a aba (`aba_regex`, sobre o `slug` do nome da aba; `null` = primeira aba). Uma
tabela com `anos` só existe nesses anos. Sistema, módulo ou ano fora das eras:
`ler()` responde com erro dizendo que ainda não há suporte, e o arquivo continua
disponível em `baixar()`.

Na v0.1: **SNIS RS 2014–2022** (7 tabelas) e **SINISA RS 2023–2024** (15 tabelas).

## Cache

`<cache>/<SISTEMA>/<MODULO>/<ano>/<arquivo>`, com `<cache>` em
`SANEABR_CACHE` ou, por padrão, `tools::R_user_dir("saneabr", "cache")` (R) e
`platformdirs.user_cache_dir("saneabr")` (Python). Planilhas extraídas vão para
`<extracao>/<sha256[0:16]>/`, com `<extracao>` em `SANEABR_EXTRACAO` ou
`<cache>/_extraido`. Download sempre por GET (o gov.br responde 403 a HEAD),
num `<arquivo>.part` renomeado no fim. Depois de baixar, e a cada uso, o
SHA-256 é comparado com o do catálogo; diferença gera aviso (a fonte
republicou), não erro.

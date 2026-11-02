<!-- Copiado de snis-sinisa/NOTAS-MUDANCAS.md por ferramentas/importar_snis_sinisa.R.
     Edite na origem e importe de novo. Os caminhos citados sao do projeto de pesquisa. -->

# Notas de mudanças que afetam séries históricas (RS primeiro)

> 2026-11-01. Cada afirmação traz o documento e a página. "p." é a página do PDF
> (índice do arquivo, como o `pdftools` conta), que pode diferir do número impresso.
> Os documentos estão em `dados_brutos/documentos/<fonte>/<modulo>/<ano>/`.
> Mudanças detectadas por comparação automática estão em `dicionarios/mudancas_dentro_snis.csv`;
> aqui só entra o que foi lido no documento.

## 1. Quem está na base: amostra voluntária (SNIS) × universo com nulos (SINISA)

- O SNIS-RS nunca foi amostra aleatória. Participa quem responde, e o objetivo de "constituir
  uma série histórica de dados [...] conflitava com uma seleção aleatória"
  (`Elementos Metodológicos 2012.pdf` p.3; mesma redação em `Elementos_Metodológicos_RS2017.pdf` p.3).
- A amostra muda todo ano. O próprio diagnóstico alerta para "cuidado ao extrapolar [...]
  lembrando também que as edições contêm amostras distintas"; a edição de 2010 "abrangeu
  2.070 municípios (37,2%)" (`Diagnostico_RS2019.pdf` p.100). Em 2019 a amostra cobria 86,6%
  da população urbana (mesmo documento, p.30). Nas planilhas inspecionadas, o máximo de municípios
  por aba vai de 132 (2003) a 5.060 (2022) (`dados_extraidos/rs_resumo_anos.csv`).
- O SINISA publica os 5.570 municípios. Quem não respondeu aparece com campo nulo: a legenda da
  planilha diz "Campo nulo dos municípios não respondentes da amostra"
  (`SINISA_RESIDUOS_Informacoes_Formulario_Manejo_2024.xlsx`, aba `Manejo_Resíduos_Sólidos_Urbanos`, linha 9).
- **Efeito**: uma série municipal com SNIS e SINISA juntos mistura "não participou" (linha ausente,
  no SNIS) com "não respondeu" (linha com nulo, no SINISA). Totais nacionais por soma não são
  comparáveis de um ano para outro, nem dentro do SNIS.

## 2. Massa coletada: CO119 (SNIS) ≠ GTR1028 (SINISA)

- **SNIS, CO119**: "soma das quantidades totais de RDO e RPU coletadas por todos os agentes [...]
  exceto cooperativas de catadores", cuja massa vai em campo próprio da coleta seletiva
  (`Glossario_Informacoes_RS2022.pdf` p.25). É CO111 + CO115 (mesmo verbete; já assim em
  `Glossario_Informacoes_RS2010.pdf` p.11).
- **SINISA, GTR1028**: é o somatório automático de GTR1025 + GTR1027, que por sua vez somam a massa
  declarada **por rota** (campo GTR1008) (`Glossario_Informacoes_SINISA_2024.pdf` p.43):
  - GTR1025 (domiciliares): rotas de coleta indiferenciada **e** de coleta seletiva de secos e de
    orgânicos, menos os rejeitos da triagem (GTR1024), "para que não ocorram duplicidades";
  - GTR1027 (limpeza urbana): limpeza pública, podas e galhadas **e** "coleta indireta de resíduos
    de construção civil e volumosos para pequenos geradores".
- **Efeito**: o GTR1028 inclui coleta seletiva (também a de cooperativas, quando declarada em rota),
  podas e RCC/volumosos de pequenos geradores. O CO119 excluía as cooperativas, e o RCC tinha
  módulo próprio (CC). O próprio Ministério diz que a declaração individualizada dos resíduos de
  limpeza pública passou a ser obrigatória e mudou o resultado
  (`015_RELATORIO_SINISA_RESIDUOS_SOLIDOS_2024_defeso.pdf` p.25; `010_..._2025_defeso.pdf` p.27).
  Não há "Referência" do GTR1028 a nenhum código SNIS no glossário. Na correspondência ele fica `sem_par`.

## 3. Estimativa nacional da massa: extrapolação da amostra → per capita × população total

- O SNIS extrapolava a amostra: em 2019, 0,99 kg/hab./dia levavam a "65,11 milhões de toneladas por
  ano" (`Diagnostico_RS2019.pdf` p.23; extrapolações descritas na p.41).
- O SINISA "reformulou" a estimativa: aplica o per capita IRS1004 (kg/hab.dia) à "população residente
  total" de cada macrorregião. O resultado foi 78,2 Mt/ano no ano 2023
  (`015_RELATORIO_SINISA_RESIDUOS_SOLIDOS_2024_defeso.pdf` p.25) e 88,1 Mt/ano no ano 2024
  (`010_RELATORIO_SINISA_RESIDUOS_SOLIDOS_2025_defeso.pdf` p.27).
- **Efeito**: o salto de cerca de 65 para 78 Mt/ano entre 2019 e 2023 é, em parte, mudança de
  método (e de conceito, ver §2), não de geração.

## 4. Per capita e cobertura: denominadores mudaram

- **IN021** (SNIS, massa RDO+RPU per capita sobre a **população urbana**) teve a "equação alterada a
  partir do Diagnóstico RS 2007 com a inclusão das quantidades coletadas por cooperativas [...]". Em
  2009 "o Co145 foi substituído pelo Cs048" (`Glossario_Indicadores_RS2022.pdf` p.7).
- **IRS1004** (SINISA) é GTR1028 / população total (DFE0001). O glossário o declara "similar" ao
  **IN028** do SNIS, não ao IN021 (`Glossario_Indicadores_SINISA_2024.pdf` p.1, coluna "SIMILAR NO
  SNIS"). Só que o IN028 divide pela população **atendida** (CO164) (`Glossario_Indicadores_RS2022.pdf`
  p.9), e o IRS1004 pela população **total**. Mesmo nome, outro denominador e outro numerador (§2).
- **IN015 → IRS0001** (cobertura sobre a população total) é o par mais limpo. O glossário declara o
  IN015 "similar" (`Glossario_Indicadores_SINISA_2024.pdf` p.1), e o insumo GTR0201 tem "Referência:
  * CO164" (`Glossario_Informacoes_SINISA_2024.pdf` p.39). Mas o GTR0201 é medido "no final do mês de
  dezembro" e cobre coleta direta **e** indireta com frequência mínima semanal (mesmo verbete).
  O IN016 do SNIS mudou duas vezes: "A partir de 2008 [...] incorporou o campo Co147 e, em 2009,
  passou a não considerar o Co051" (`Glossario_Indicadores_RS2022.pdf` p.5).

## 5. População: base do IBGE, mas urbana estimada

- O SNIS 2022 atualizou a população total pelo Censo 2022 e **removeu a população urbana** "devido
  à falta de dados específicos" (`Planilha_Informacoes_RS_2022.xlsx`, aba `Informacoes`, linha 5).
  Indicadores sobre a população urbana de 2022 não fecham com os anos anteriores.
- O SINISA estima a população urbana como população total do IBGE × taxa de urbanização do último
  Censo (`copy_of_Nota_Tecnica_Estimativas_Populacao_e_Domicilios_SINISA_2025_v01.pdf` p.2;
  `010_RELATORIO_SINISA_RESIDUOS_SOLIDOS_2025_defeso.pdf` p.12). O cálculo "não substitui dados
  oficiais do IBGE" (relatório, p.12). Domicílios também são estimados a partir das taxas de
  ocupação do Censo 2022 (nota técnica, p.2).

## 6. Dentro do SNIS: códigos renomeados e unidades corrigidas

- **2011**: o bloco financeiro ganhou códigos `FN`, e os glossários dizem "Antigo campo GE012"
  (FN201), "GE013" (FN202), "GE014" (FN205), "CO132" (FN206), "CO011" (FN207)…
  (`Glossario_Informacoes_RS2011.pdf` p.3–4). São 55 renomeações declaradas no RS, todas em
  `dicionarios/mudancas_dentro_snis.csv`.
- **2012**: GE202 é o "Antigo campo Ge055" (`Glossario_Informacoes_RS2012.pdf` p.1).
- **2015**: CS027, CS028, CS030 e CS031 tinham unidade "Tonelada/ano" até 2014 e passam a "Sim/Não"
  (`Glossario_Informacoes_RS2014.pdf` p.34–35 → `Glossario_Informacoes_RS2015.pdf` p.34–35). Era
  erro de rótulo: o campo sempre foi de ocorrência.
- **Caixa dos códigos**: até 2013 as planilhas usam `Ge001` e `Co119`, depois `GE001` e `CO119`. O
  SNIS antigo chama o indicador de `I015` (`RelInd2012.pdf` p.3), o atual de `IN015`. Nos dicionários
  tudo está normalizado para caixa alta e `IN`.

## 7. Passagem de módulos

- O SINISA separa Água e Esgoto em dois módulos e "passa a coletar de forma separada informações
  referentes às populações urbana e rural". Também cria o módulo de Gestão Municipal, sobre "como
  está estruturada a Gestão do Município" (`010_RELATORIO_SINISA_RESIDUOS_SOLIDOS_2025_defeso.pdf` p.6).
- Os campos de políticas e planos do SNIS-RS (`PO…`) foram procurados no módulo GM. Os pares achados
  são só `candidata` (nenhuma Referência documentada).

## O que não foi possível verificar

- O caderno **"Do SNIS ao SINISA – Resíduos Sólidos" (2019)** só existe em `arquivos-snis.mdr.gov.br`,
  domínio fora do ar; a cópia do Wayback Machine respondeu 429. Os cadernos de AE, AP e o geral
  (2019, 2021, 2022) foram baixados, mas não trazem tabela de correspondência de códigos.
- Não achei nota técnica oficial de comparabilidade SNIS × SINISA para RS. As afirmações acima
  saem dos glossários e dos relatórios.

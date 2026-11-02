# Correspondência SNIS ↔ SINISA, Resíduos Sólidos: lista para revisão

> Gerada em 2026-11-01 por `validacao/montar_validacao.R`. Cada par foi lido nos glossários (SNIS RS 2022, SINISA RS 2024, SINISA 2023 quando citado, SINISA GM 2024 para os PO). O teste empírico compara, município a município, o SNIS 2022 (ou 2021, quando o par depende da população urbana, que o SNIS 2022 retirou) com o SINISA 2023.

## Resumo

- **147 pares** de RS na correspondência (tudo menos `sem_par`; inclui 27 pares de PO do SNIS-RS com o módulo GM do SINISA e 2 de AP).
- **41 confirmados**, **39 a corrigir** (tipo de relação errado) e **67 rejeitados** (não são o mesmo conceito).
- Dos 63 pares `candidata` (só semelhança de nome), 51 foram rejeitados.
- Dos 8 pares propostos como `igual`, 5 se confirmam; IN014 → IRS0004, IN016 → IRS0002, IN030 → IRS0006 viram `mudou_definicao`.
- **9 pares novos**, achados na leitura (entre eles CO119 → GTR1028, que estava como `sem_par`).
- Nenhum par de **frota** (veículos) apareceu na correspondência: os campos de veículos do SINISA (GTR12xx) não têm Referência ao SNIS.

Como marcar: `[x] concordo`, ou escreva a relação certa em `mudar para`. A mesma decisão vai na coluna `decisao_theo` de `correspondencia_rs_validacao.csv` (`ok`, ou o tipo de relação, ou `rejeitar`); depois rode `Rscript ferramentas/aplicar_validacao.R`.

## Os pares mais usados em análise de resíduos

### Massa coletada

**CO116 → GTR1004**
- SNIS CO116: QUANTIDADE DE RDO E RPU COLETADA PELO AGENTE PÚBLICO
- SINISA GTR1004: Massa anual coletada por agente público
- Proposto: `candidata` · Veredito: **corrigir**: `candidata` → `mudou_definicao`
- Teste: razão SINISA/SNIS 1,19 (quartis 0,80 a 2,07; 2.969 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Mesmo executor (agente público), mas o GTR1004 somado por município inclui rotas de coleta seletiva, podas e RCC/volumosos; razão 1,19 (SNIS: Glossario_Informacoes_RS2022.pdf p.24 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.54)
- [ ] concordo · [ ] mudar para: ______

**CO119 → GTR1004**
- SNIS CO119: QUANTIDADE TOTAL DE RDO E RPU COLETADA POR TODOS OS AGENTES
- SINISA GTR1004: Massa anual coletada por agente público
- Proposto: `candidata` · Veredito: **rejeitado** (não são o mesmo conceito)
- Teste: razão SINISA/SNIS 1,00 (quartis 0,32 a 1,52; 3.728 municípios; SNIS 2022 × SINISA 2023)
- Por quê: CO119 é a massa de todos os agentes; GTR1004 é só o agente público. Razão perto de 1 é coincidência de mediana (quartis 0,32 a 1,52). Para a massa total, ver CO119 x GTR1028 (achado A1) (SNIS: Glossario_Informacoes_RS2022.pdf p.25 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.54)
- [ ] concordo · [ ] mudar para: ______

**CO119 → GTR1028** (par novo)
- SNIS CO119: QUANTIDADE TOTAL DE RDO E RPU COLETADA POR TODOS OS AGENTES
- SINISA GTR1028: Massa total anual de resíduos sólidos urbanos coletados no município.
- Proposto: `sem_par` · Veredito: **par novo**: `mudou_definicao`
- Teste: razão SINISA/SNIS 1,12 (quartis 0,88 a 1,67; 4.554 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Massa total coletada. Ficou como sem_par na spec. GTR1028 inclui a coleta seletiva (também de cooperativas), podas e RCC/volumosos de pequenos geradores; o CO119 não. Razão 1,12 (quartis 0,88 a 1,67) (SNIS: Glossario_Informacoes_RS2022.pdf p.25 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.43)
- [ ] concordo · [ ] mudar para: ______

**CO119 → GTR1025** (par novo)
- SNIS CO119: QUANTIDADE TOTAL DE RDO E RPU COLETADA POR TODOS OS AGENTES
- SINISA GTR1025: Massa total anual proveniente das rotas de coleta de resíduos sólidos domiciliares.
- Proposto: `sem_par` · Veredito: **par novo**: `mudou_definicao`
- Teste: razão SINISA/SNIS 0,97 (quartis 0,66 a 1,16; 4.554 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Massa das rotas domiciliares (indiferenciada + seletiva, menos rejeitos) é o conceito mais próximo do CO119; razão 0,97 (quartis 0,66 a 1,16) (SNIS: Glossario_Informacoes_RS2022.pdf p.25 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.43)
- [ ] concordo · [ ] mudar para: ______

### Cobertura

**IN015 → IRS0001**
- SNIS IN015: Taxa de cobertura regular do serviço de coleta de rdo em relação à população total do município
- SINISA IRS0001: INDICADOR Cobertura da população Cobertura total com coleta de resíduos sólidos domiciliares
- Proposto: `igual` · Veredito: **confirmado** como `igual`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,95 a 1,11; 4.554 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Mesma fórmula (população total coberta, pelo menos 1x por semana / população total). Razão 1,00, quartis 0,95 a 1,11, 4.554 municípios (SNIS: Glossario_Indicadores_RS2022.pdf p.5 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

**IN016 → IRS0002**
- SNIS IN016: Taxa de cobertura regular do serviço de coleta de rdo em relação à população urbana
- SINISA IRS0002: Cobertura da população Cobertura urbana com coleta de resíduos sólidos domiciliares
- Proposto: `igual` · Veredito: **corrigir**: `igual` → `mudou_definicao`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,98 a 1,00; 4.406 municípios; SNIS 2021 × SINISA 2023)
- Por quê: GTR0202 conta também coleta seletiva e indireta; o denominador urbano é estimado de forma diferente nos dois sistemas e o SNIS 2022 não tem população urbana. Razão 1,00 (SNIS 2021) (SNIS: Glossario_Indicadores_RS2022.pdf p.5 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

**IN030 → IRS0006**
- SNIS IN030: Taxa de cobertura do serviço de coleta seletiva porta-a-porta em relação à população urbana do município.
- SINISA IRS0006: Cobertura da população urbana com coleta seletiva Cobertura direta de resíduos sólidos domiciliares
- Proposto: `igual` · Veredito: **corrigir**: `igual` → `mudou_definicao`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,94 a 1,02; 915 municípios; SNIS 2021 × SINISA 2023)
- Por quê: CS050 é seletiva porta a porta da Prefeitura e parceiros; GTR0204 é qualquer executor. Razão 1,00 (SNIS 2021, 915 municípios) (SNIS: Glossario_Indicadores_RS2022.pdf p.10 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

**CO164 → GTR0201**
- SNIS CO164: POPULAÇÃO TOTAL ATENDIDA NO MUNICÍPIO COM COLETA REGULAR DE PELO MENOS UMA VEZ POR SEMANA
- SINISA GTR0201: População total coberta pelo serviço de coleta indiferenciada direta ou indireta com frequência mínima de 1 (uma) vez por
- Proposto: `mudou_definicao` · Veredito: **corrigir**: `mudou_definicao` → `igual`
- Teste: razão SINISA/SNIS 1,01 (quartis 0,96 a 1,12; 4.554 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Mesma definição (população total atendida por coleta regular, pelo menos 1x por semana, no fim do ano); razão 1,01, quartis 0,96 a 1,12 (SNIS: Glossario_Informacoes_RS2022.pdf p.31 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.39)
- [ ] concordo · [ ] mudar para: ______

### Per capita

**IN022 → IRS1005**
- SNIS IN022: Massa (rdo) coletada per capita em relação à população atendida com serviço de coleta
- SINISA IRS1005: Massa média per capita de Operacional resíduos sólidos domiciliares coletados
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,71 a 1,28; 1.236 municípios; SNIS 2022 × SINISA 2023)
- Por quê: GTR1025 inclui a coleta seletiva; o denominador é a população coberta pela coleta indiferenciada. Razão 1,00 (quartis 0,71 a 1,28) (SNIS: Glossario_Indicadores_RS2022.pdf p.7 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

**IN028 → IRS1004**
- SNIS IN028: Massa de resíduos domiciliares e públicos (rdo+rpu) coletada per capita em relação à população total atendida pelo serviço de coleta
- SINISA IRS1004: Massa média per capita de Operacional resíduos sólidos urbanos coletados
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 0,91 (quartis 0,56 a 1,29; 4.554 municípios; SNIS 2022 × SINISA 2023)
- Por quê: IRS1004 divide pela população total (não pela atendida) e usa o GTR1028, mais amplo que o CO119; razão 0,91 (quartis 0,56 a 1,29) (SNIS: Glossario_Indicadores_RS2022.pdf p.9 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

**IN032 → IRS1008**
- SNIS IN032: Massa recuperada per capita de materiais recicláveis (exceto matéria orgânica e rejeitos) em relação à população urbana
- SINISA IRS1008: Massa média per capita de resíduos sólidos domiciliares Operacional secos e orgânicos recuperados
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 1,33 (quartis 0,80 a 3,06; 1.104 municípios; SNIS 2021 × SINISA 2023)
- Por quê: IN032 é recicláveis recuperados / população urbana; IRS1008 é secos + orgânicos recuperados / população coberta pela seletiva; razão 1,33 (SNIS 2021) (SNIS: Glossario_Indicadores_RS2022.pdf p.10 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

**IN054 → IRS1007**
- SNIS IN054: Massa per capita de materiais recicláveis recolhidos via coleta seletiva
- SINISA IRS1007: Massa média per capita de Operacional resíduos sólidos domiciliares coletados na coleta seletiva
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 1,18 (quartis 0,70 a 2,16; 1.031 municípios; SNIS 2021 × SINISA 2023)
- Por quê: Denominador muda de população urbana para população coberta pela seletiva; razão 1,18 (SNIS 2021) (SNIS: Glossario_Indicadores_RS2022.pdf p.12 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.1)
- [ ] concordo · [ ] mudar para: ______

### Custos e despesas

**FN218 → GFI2201**
- SNIS FN218: DESPESA DOS AGENTES PÚBLICOS EXECUTORES DE SERVIÇOS DE MANEJO DE RSU
- SINISA GFI2201: Despesa com pessoal próprio do serviço de limpeza urbana
- Proposto: `desmembrado` · Veredito: **confirmado** como `desmembrado`
- Teste: razão SINISA/SNIS 0,80 (quartis 0,41 a 1,43; 2.845 municípios; SNIS 2022 × SINISA 2023)
- Por quê: FN218 (despesa total dos agentes públicos com RSU) se reparte no SINISA em pessoal próprio de limpeza urbana (GFI2201), de manejo (GFI2209) e outras despesas; razão 0,80 (SNIS: Glossario_Informacoes_RS2022.pdf p.7 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.14)
- [ ] concordo · [ ] mudar para: ______

**FN219 → GFI2202**
- SNIS FN219: DESPESA COM AGENTES PRIVADOS EXECUTORES DE SERVIÇOS DE MANEJO DE RSU
- SINISA GFI2202: Despesa com serviço terceirizado de limpeza urbana
- Proposto: `desmembrado` · Veredito: **confirmado** como `desmembrado`
- Teste: razão SINISA/SNIS 0,85 (quartis 0,37 a 1,46; 1.994 municípios; SNIS 2022 × SINISA 2023)
- Por quê: FN219 (despesa com agentes privados) se reparte em terceirizado de limpeza urbana (GFI2202) e de manejo (GFI2210); razão 0,85 (SNIS: Glossario_Informacoes_RS2022.pdf p.7 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.14)
- [ ] concordo · [ ] mudar para: ______

**FN213 → GFI2204**
- SNIS FN213: DESPESA COM EMPRESAS CONTRATADAS PARA O SERVIÇO DE VARRIÇÃO
- SINISA GFI2204: Despesa com serviço terceirizado de varrição de sarjetas ou de superfície de logradouros públicos
- Proposto: `mudou_unidade` · Veredito: **corrigir**: `mudou_unidade` → `igual`
- Teste: razão SINISA/SNIS 1,07 (quartis 0,66 a 1,49; 239 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Mesma despesa (varrição terceirizada); só a grafia da unidade muda (R$/ano x Reais por ano); razão 1,07 (SNIS: Glossario_Informacoes_RS2022.pdf p.5 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.15)
- [ ] concordo · [ ] mudar para: ______

**FN207 → GFI2211** (par novo)
- SNIS FN207: DESPESA COM AGENTES PRIVADOS PARA EXECUÇÃO DO SERVIÇO DE COLETA DE RDO E RPU
- SINISA GFI2211: Despesa com serviço terceirizado de coleta indiferenciada direta ou indireta de resíduos sólidos domiciliares
- Proposto: `sem_par` · Veredito: **par novo**: `mudou_definicao`
- Teste: razão SINISA/SNIS 0,84 (quartis 0,31 a 1,14; 332 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Despesa com coleta terceirizada: RDO e RPU no SNIS; só coleta indiferenciada de domiciliares no SINISA; razão 0,84 (SNIS: Glossario_Informacoes_RS2022.pdf p.4 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.17)
- [ ] concordo · [ ] mudar para: ______

**FN220 → GFI2221** (par novo)
- SNIS FN220: DESPESA TOTAL COM SERVIÇOS DE MANEJO DE RSU
- SINISA GFI2221: Despesas totais de exploração (DEX) do serviço de manejo de resíduos sólidos
- Proposto: `sem_par` · Veredito: **par novo**: `desmembrado`
- Teste: razão SINISA/SNIS 0,75 (quartis 0,36 a 1,20; 4.554 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Despesa total com RSU: o SINISA separa DEX de manejo (GFI2221) e de limpeza urbana (GFI2208); com só o GFI2221 a razão é 0,75 (SNIS: Glossario_Informacoes_RS2022.pdf p.7 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.20)
- [ ] concordo · [ ] mudar para: ______

### Receitas

**IN005 → IFR1006**
- SNIS IN005: Auto-suficiência financeira da prefeitura com o manejo de rsu
- SINISA IFR1006: Suficiência de caixa para despesas de exploração Receita/Cobrança (DEX) com os serviços de manejo de resíduos sólidos
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 1,35 (quartis 0,85 a 2,46; 1.901 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Receita arrecadada / despesa total (SNIS) x arrecadação de receita operacional direta / DEX (SINISA); razão 1,35 (SNIS: Glossario_Indicadores_RS2022.pdf p.2 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.4)
- [ ] concordo · [ ] mudar para: ______

**IN011 → IFR1002**
- SNIS IN011: Receita arrecadada per capita com taxas ou outras formas de cobrança pela prestação de serviços de manejo rsu
- SINISA IFR1002: Receita operacional média do serviço de manejo de Receita/Cobrança resíduos sólidos por habitante
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 1,24 (quartis 0,87 a 1,74; 1.753 municípios; SNIS 2021 × SINISA 2023)
- Por quê: Receita arrecadada / população urbana (SNIS) x receita operacional direta / população total coberta (SINISA); razão 1,24 (SNIS 2021) (SNIS: Glossario_Indicadores_RS2022.pdf p.4 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.3)
- [ ] concordo · [ ] mudar para: ______

**FN221 → GFI1203**
- SNIS FN221: RECEITA ORÇADA COM A COBRANÇA DE TAXAS E TARIFAS REFERENTES À GESTÃO E MANEJO DE RSU
- SINISA GFI1203: Receita operacional total (direta + indireta) de limpeza urbana e manejo resíduos sólidos
- Proposto: `mudou_unidade` · Veredito: **corrigir**: `mudou_unidade` → `mudou_definicao`
- Teste: razão SINISA/SNIS 1,10 (quartis 0,83 a 1,51; 1.831 municípios; SNIS 2022 × SINISA 2023)
- Por quê: FN221 é a receita orçada de taxas e tarifas; GFI1203 é a receita operacional realizada (direta + indireta). Razão 1,10, mas são conceitos contábeis diferentes (SNIS: Glossario_Informacoes_RS2022.pdf p.7 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.11)
- [ ] concordo · [ ] mudar para: ______

**FN222 → GFI1204**
- SNIS FN222: RECEITA ARRECADADA COM TAXAS E TARIFAS REFERENTES À GESTÃO E MANEJO DE RSU
- SINISA GFI1204: Arrecadação de receita operacional direta do manejo de resíduos sólidos
- Proposto: `mudou_unidade` · Veredito: **corrigir**: `mudou_unidade` → `mudou_definicao`
- Teste: razão SINISA/SNIS 1,11 (quartis 0,95 a 1,36; 1.923 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Receita arrecadada com taxas e tarifas (SNIS) x arrecadação de receita operacional direta (SINISA); razão 1,11 (SNIS: Glossario_Informacoes_RS2022.pdf p.8 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.11)
- [ ] concordo · [ ] mudar para: ______

### Coleta seletiva

**CS009 → GTR3137**
- SNIS CS009: QUANTIDADE TOTAL DE MATERIAIS RECICLÁVEIS RECUPERADOS
- SINISA GTR3137: Quantidade total de materiais recicláveis recuperados (Informação futura)
- Proposto: `igual` · Veredito: **confirmado** como `igual`
- Teste: sem teste empírico (nível de unidade, informação futura ou sem dado)
- Por quê: Mesma definição (total de recicláveis recuperados, exceto orgânicos, rejeitos, catadores avulsos e sucateiros). No SINISA é 'informação futura': ainda sem dado (SNIS: Glossario_Informacoes_RS2022.pdf p.34 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.78)
- [ ] concordo · [ ] mudar para: ______

**CS050 → GTR0204**
- SNIS CS050: POPULAÇÃO URBANA DO MUNICÍPIO ATENDIDA COM A COLETA SELETIVA DO TIPO PORTA A PORTA EXECUTADA PELA PREFEITURA (OU SLU)
- SINISA GTR0204: População urbana coberta pelo serviço de coleta seletiva direta com frequência mínima de 1 (uma) vez por semana
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 0,99 (quartis 0,89 a 1,10; 915 municípios; SNIS 2021 × SINISA 2023)
- Por quê: CS050 é a seletiva da Prefeitura e de parceiros; GTR0204 é de qualquer executor; razão 0,99 (SNIS 2021) (SNIS: Glossario_Informacoes_RS2022.pdf p.41 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.40)
- [ ] concordo · [ ] mudar para: ______

**IN034 → IRS3006**
- SNIS IN034: Incidência de papel e papelão no total de material recuperado
- SINISA IRS3006: Participação da recuperação de papeis ou papelão nos Qualidade materiais recicláveis secos recuperados
- Proposto: `mudou_definicao` · Veredito: **corrigir**: `mudou_definicao` → `igual`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,87 a 1,23; 375 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Mesma fórmula (papel / total recuperado); razão 1,00 em 375 municípios (SNIS: Glossario_Indicadores_RS2022.pdf p.11 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.2)
- [ ] concordo · [ ] mudar para: ______

**IN053 → IRS3001**
- SNIS IN053: Taxa de material recolhido pela coleta seletiva (exceto mat. orgânica) em relação à quantidade total coletada de resíduos sól. domésticos
- SINISA IRS3001: Desempenho da coleta Qualidade seletiva
- Proposto: `mudou_definicao` · Veredito: **confirmado** como `mudou_definicao`
- Teste: razão SINISA/SNIS 1,03 (quartis 0,67 a 1,51; 371 municípios; SNIS 2022 × SINISA 2023)
- Por quê: IN053 exclui a matéria orgânica; IRS3001 (GTR1026 / GTR1025) inclui a seletiva de orgânicos; razão 1,03 (SNIS: Glossario_Indicadores_RS2022.pdf p.12 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.2)
- [ ] concordo · [ ] mudar para: ______

### Destinação

**UP003 → GTR3101**
- SNIS UP003: TIPO DE UNIDADE
- SINISA GTR3101: Tipo de unidade de processamento ou tratamento
- Proposto: `desmembrado` · Veredito: **confirmado** como `desmembrado`
- Teste: sem teste empírico (nível de unidade, informação futura ou sem dado)
- Por quê: Tipo de unidade: o SINISA separa processamento (GTR3101) de disposição final (GTR3201). As categorias não coincidem uma a uma (SNIS: Glossario_Informacoes_RS2022.pdf p.64 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.73)
- [ ] concordo · [ ] mudar para: ______

**UP003 → GTR3201**
- SNIS UP003: TIPO DE UNIDADE
- SINISA GTR3201: Tipo de unidade de disposição final
- Proposto: `desmembrado` · Veredito: **confirmado** como `desmembrado`
- Teste: sem teste empírico (nível de unidade, informação futura ou sem dado)
- Por quê: Tipo de unidade de disposição final (lixão, aterro sanitário, aterro controlado, aterro de inertes) (SNIS: Glossario_Informacoes_RS2022.pdf p.64 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.85)
- [ ] concordo · [ ] mudar para: ______

**UP080 → GTR3120** (par novo)
- SNIS UP080: QUANTIDADE TOTAL DE RESÍDUOS RECEBIDA NA UNIDADE DE PROCESSAMENTO POR CADA MUNICÍPIO
- SINISA GTR3120: Quantidade de resíduos sólidos recebidos de processamento ou tratamento
- Proposto: `sem_par` · Veredito: **par novo**: `igual`
- Teste: sem teste empírico (nível de unidade, informação futura ou sem dado)
- Por quê: Quantidade recebida na unidade vinda de cada município de origem; nível de unidade (não testado empiricamente) (SNIS: Glossario_Informacoes_RS2022.pdf p.76 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.82)
- [ ] concordo · [ ] mudar para: ______

### Limpeza urbana

**VA010 → GTR2002**
- SNIS VA010: PELA PREFEITURA MUNICIPAL (KM VARRIDOS)
- SINISA GTR2002: Extensão de sarjetas varridas
- Proposto: `desmembrado` · Veredito: **corrigir**: `desmembrado` → `agregado`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,33 a 1,47; 460 municípios; SNIS 2022 × SINISA 2023)
- Por quê: GTR2002 é a extensão varrida por agentes públicos e privados, ou seja VA010 + VA011 = VA039; razão 1,00 nos municípios em que só a Prefeitura varre (SNIS: Glossario_Informacoes_RS2022.pdf p.50 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.64)
- [ ] concordo · [ ] mudar para: ______

**VA039 → GTR2002** (par novo)
- SNIS VA039: EXTENSÃO TOTAL DE SARJETAS VARRIDAS PELOS EXECUTORES (KM VARRIDOS)
- SINISA GTR2002: Extensão de sarjetas varridas
- Proposto: `sem_par` · Veredito: **par novo**: `igual`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,34 a 1,11; 788 municípios; SNIS 2022 × SINISA 2023)
- Por quê: Extensão total de sarjetas varridas (pública + privada) nos dois lados; razão 1,00 em 788 municípios (SNIS: Glossario_Informacoes_RS2022.pdf p.50 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.64)
- [ ] concordo · [ ] mudar para: ______

### Trabalhadores

**TB003 → GFI2259**
- SNIS TB003: QUANTIDADE DE VARREDORES DOS AGENTES PÚBLICOS, ALOCADOS NO SERVIÇO DE VARRIÇÃO
- SINISA GFI2259: Quantidade de pessoal próprio do serviço de limpeza urbana
- Proposto: `desmembrado` · Veredito: **corrigir**: `desmembrado` → `mudou_definicao`
- Teste: razão SINISA/SNIS 1,63 (quartis 1,00 a 2,83; 2.475 municípios; SNIS 2022 × SINISA 2023)
- Por quê: TB003 é só varredores do agente público; GFI2259 é todo o pessoal próprio da limpeza urbana; razão 1,63 (SNIS: Glossario_Informacoes_RS2022.pdf p.10 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.32)
- [ ] concordo · [ ] mudar para: ______

**TB004 → GFI2261**
- SNIS TB004: QUANTIDADE DE VARREDORES DE AGENTES PRIVADOS, ALOCADOS NO SERVIÇO DE VARRIÇÃO
- SINISA GFI2261: Quantidade de pessoal terceirizado do serviço de limpeza urbana
- Proposto: `desmembrado` · Veredito: **corrigir**: `desmembrado` → `mudou_definicao`
- Teste: razão SINISA/SNIS 2,12 (quartis 1,20 a 3,71; 1.218 municípios; SNIS 2022 × SINISA 2023)
- Por quê: TB004 é só varredores privados; GFI2261 é todo o pessoal terceirizado da limpeza urbana, inclusive catadores contratados; razão 2,12 (SNIS: Glossario_Informacoes_RS2022.pdf p.10 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.33)
- [ ] concordo · [ ] mudar para: ______

**IN018 → IFR0002**
- SNIS IN018: Produtividade média dos empregados na coleta (coletadores + motoristas) na coleta (rdo + rpu) em relação à massa coletada
- SINISA IFR0002: Produtividade de pessoal do Administrativo serviço de manejo de resíduos sólidos
- Proposto: `mudou_definicao` · Veredito: **rejeitado** (não são o mesmo conceito)
- Teste: razão SINISA/SNIS 0,00 (quartis 0,00 a 0,00; 3.281 municípios; SNIS 2022 × SINISA 2023)
- Por quê: IN018 é produtividade (kg por empregado por dia); IFR0002 é empregados por mil habitantes. O 'similar no SNIS' do glossário está errado; razão 0,0008 (SNIS: Glossario_Indicadores_RS2022.pdf p.6 · SINISA: Glossario_Indicadores_SINISA_2024.pdf p.3)
- [ ] concordo · [ ] mudar para: ______

**TB001 → GFI2264** (par novo)
- SNIS TB001: QUANTIDADE DE COLETADORES E MOTORISTAS DE AGENTES PÚBLICOS, ALOCADOS NO SERVIÇO DE COLETA DE RDO E RPU
- SINISA GFI2264: Quantidade de pessoal próprio do serviço de manejo de resíduos sólidos
- Proposto: `sem_par` · Veredito: **par novo**: `mudou_definicao`
- Teste: razão SINISA/SNIS 1,00 (quartis 0,67 a 1,67; 2.197 municípios; SNIS 2022 × SINISA 2023)
- Por quê: TB001 é coletadores e motoristas do agente público; GFI2264 é todo o pessoal próprio do manejo; razão 1,00 (quartis 0,67 a 1,67) (SNIS: Glossario_Informacoes_RS2022.pdf p.10 · SINISA: Glossario_Informacoes_SINISA_2024.pdf p.33)
- [ ] concordo · [ ] mudar para: ______

## Os demais pares

| n | SNIS | SINISA | proposto | veredito | corrigido | teste | por quê |
|---|---|---|---|---|---|---|---|
| 1 | PO001 | OGM3001 | candidata | corrigir | mudou_unidade | 70% (n=4395) | Mesmo conceito (lei da Política Municipal de Saneamento, Lei 11.445); o SNIS aceita 'Em elaboração/Informação não disponível', o SINISA só Sim/Não |
| 2 | PO004 | OGM1004 | candidata | rejeitado | sem_par | 0% (n=2016) | PO004 pergunta se a lei abrange o serviço de água; OGM1004 é o nome do prestador de água |
| 3 | PO005 | OGM1104 | candidata | rejeitado | sem_par | 0% (n=1770) | PO005 é abrangência da lei (esgoto); OGM1104 é o nome do prestador de esgoto |
| 4 | PO006 | OGM1206 | candidata | rejeitado | sem_par | — | PO006 é abrangência da lei (RSU); OGM1206 lista os serviços feitos pelo prestador |
| 5 | PO007 | OGM1304 | candidata | rejeitado | sem_par | 0% (n=2163) | PO007 é abrangência da lei (drenagem); OGM1304 é o nome do prestador de drenagem |
| 6 | PO008 | OGM1004 | candidata | rejeitado | sem_par | 0% (n=4302) | PO008 pergunta se há órgão regulador definido (água); OGM1004 é o nome do prestador |
| 7 | PO009 | COE0002 | candidata | rejeitado | sem_par | — | PO009 é o nome da entidade reguladora de água; COE0002 é o nome genérico de 'outras entidades responsáveis', sem ligação com regulação |
| 8 | PO010 | OGM1104 | candidata | rejeitado | sem_par | 0% (n=3719) | PO010 pergunta se há órgão regulador (esgoto); OGM1104 é o nome do prestador |
| 9 | PO011 | COE0002 | candidata | rejeitado | sem_par | — | PO011 é o nome do regulador de esgoto; COE0002 é o nome de 'outras entidades responsáveis' |
| 10 | PO012 | OGM1206 | candidata | rejeitado | sem_par | — | PO012 pergunta se há regulador de RSU; OGM1206 lista serviços do prestador |
| 11 | PO013 | COE0002 | candidata | rejeitado | sem_par | — | PO013 é o nome do regulador de RSU; COE0002 é o nome de 'outras entidades responsáveis' |
| 12 | PO014 | OGM1304 | candidata | rejeitado | sem_par | 0% (n=4739) | PO014 pergunta se há regulador de drenagem; OGM1304 é o nome do prestador |
| 13 | PO015 | COE0002 | candidata | rejeitado | sem_par | — | PO015 é o nome do regulador de drenagem; COE0002 é o nome de 'outras entidades responsáveis' |
| 14 | PO017 | OGM1004 | candidata | rejeitado | sem_par | — | PO017 trata de parâmetros de atendimento essencial (água); OGM1004 é o nome do prestador |
| 15 | PO018 | OGM1104 | candidata | rejeitado | sem_par | — | PO018 trata de parâmetros de atendimento essencial (esgoto); OGM1104 é o nome do prestador |
| 16 | PO019 | OGM1206 | candidata | rejeitado | sem_par | — | PO019 trata de parâmetros de atendimento essencial (RSU); OGM1206 lista serviços do prestador |
| 17 | PO020 | OGM1304 | candidata | rejeitado | sem_par | — | PO020 trata de parâmetros de atendimento essencial (drenagem); OGM1304 é o nome do prestador |
| 18 | PO033 | OGM3005 | candidata | corrigir | mudou_unidade | 0% (n=1889) | Mesmo conceito (instrumento de aprovação do plano de saneamento: lei, decreto ou outro); concordância 0 porque as categorias são escritas de outro jeito ('lei municipal' x 'lei') |
| 19 | PO034 | OGM1004 | candidata | rejeitado | sem_par | 0% (n=2879) | PO034 pergunta se o plano abrange água; OGM1004 é o nome do prestador |
| 20 | PO035 | OGM1104 | candidata | rejeitado | sem_par | 0% (n=2514) | PO035 pergunta se o plano abrange esgoto; OGM1104 é o nome do prestador |
| 21 | PO036 | OGM1206 | candidata | rejeitado | sem_par | — | PO036 pergunta se o plano abrange RSU; OGM1206 lista serviços do prestador |
| 22 | PO037 | OGM1304 | candidata | rejeitado | sem_par | 0% (n=3102) | PO037 pergunta se o plano abrange drenagem; OGM1304 é o nome do prestador |
| 23 | PO043 | OGM3303 | candidata | corrigir | mudou_definicao | 18% (n=471) | Nome do consórcio: o SNIS-RS pergunta pelo consórcio intermunicipal; o SINISA-GM, pelo consórcio público com atuação em saneamento |
| 24 | PO048 | OGM3013 | candidata | corrigir | igual | 76% (n=4319) | Mesma pergunta (o município possui PMGIRS conforme a Lei 12.305/2010?), mesma resposta Sim/Não; concordância 76% |
| 25 | PO052 | OGM3305 | candidata | corrigir | mudou_definicao | 88% (n=471) | CNPJ do consórcio; vale a ressalva do par PO043 sobre qual consórcio |
| 26 | PO053 | OGM3312 | candidata | corrigir | mudou_definicao | — | Sigla do consórcio; vale a ressalva do par PO043 sobre qual consórcio |
| 27 | PO099 | OGM1010 | candidata | rejeitado | sem_par | — | Campos livres de observações de formulários diferentes (políticas e planos x prestador de água); sem uso analítico |
| 28 | RS003 | GTR1402 | agregado | rejeitado | sem_par | 0% (n=3563) | RS003 é coleta de RSS pelo próprio gerador ou empresa contratada por ele; GTR1402 é só a prestação pelo poder público ou contratadas por ele, apesar da Referência no glossário |
| 29 | RS020 | GTR1402 | agregado | corrigir | mudou_definicao | 0% (n=4554) | RS020 inclui coleta de RSS pelo gerador; GTR1402 só a do poder público. GTR1402 é campo de múltipla escolha, não Sim/Não (concordância 0 por isso) |
| 30 | RS045 | GTR1402 | agregado | confirmado | agregado | 0% (n=3768) | RS045 (pela Prefeitura) é uma das partes de GTR1402 (poder público ou contratadas); GTR1402 é de múltipla escolha |
| 31 | RS046 | GTR1402 | agregado | confirmado | agregado | 0% (n=3986) | RS046 (empresa contratada pela Prefeitura) é a outra parte de GTR1402 |
| 32 | VA011 | GTR1002 | agregado | rejeitado | sem_par | 0% (n=474) | VA011 é km varridos por empresas; GTR1002 é a abrangência (urbana/rural) da rota de coleta. A Referência VA011 do glossário está no verbete errado; o par certo é VA039 (ou VA010+VA011) com GTR2002 |
| 33 | CA005 | GTR1309 | candidata | corrigir | mudou_definicao | 0% (n=4554) | CA005 é a existência de catadores organizados (Sim/Não); GTR1309 é a quantidade de associações que prestam serviço ao município |
| 34 | CO020 | GTR1010 | candidata | corrigir | mudou_definicao | 0% (n=2323) | Município de destino: no SNIS, só do RDO e RPU exportado; no SINISA, de cada rota, para qualquer resíduo. Concordância 0 só pela grafia ('Guapó - GO' x 'Guapó') |
| 35 | CO108 | GTR1004 | candidata | rejeitado | sem_par | razão 1,44 (n=671) | CO108 é só RDO do agente público; GTR1004, somado por município, é a massa de todas as rotas (inclusive seletiva e limpeza urbana) do agente público. O par mais próximo é CO116 |
| 36 | CO109 | GTR1005 | candidata | rejeitado | sem_par | razão 1,15 (n=598) | CO109 é só RDO de agentes privados; GTR1005 somado é a massa de todas as rotas do agente privado. O par mais próximo é CO117 |
| 37 | CO111 | GTR1004 | candidata | rejeitado | sem_par | razão 0,99 (n=975) | CO111 é RDO de todos os agentes; GTR1004 é só o agente público |
| 38 | CO112 | GTR1004 | candidata | rejeitado | sem_par | razão 4,36 (n=735) | CO112 é só RPU do agente público; razão 4,4 confirma que são coisas diferentes |
| 39 | CO113 | GTR1004 | candidata | rejeitado | sem_par | razão 3,00 (n=217) | CO113 é RPU de agentes privados; GTR1004 é do agente público |
| 40 | CO115 | GTR1004 | candidata | rejeitado | sem_par | razão 3,60 (n=793) | CO115 é RPU de todos os agentes; GTR1004 é só o agente público |
| 42 | CO117 | GTR1004 | candidata | rejeitado | sem_par | razão 0,63 (n=1572) | CO117 é do agente privado; GTR1004 é do público. O par certo é CO117 com GTR1005 (achado A3) |
| 44 | CO136 | GTR0205 | candidata | rejeitado | sem_par | razão 876,11 (n=740) | CO136 é o % da população atendida 1 vez por semana pela coleta regular; GTR0205 é a população coberta pela coleta seletiva (habitantes) |
| 45 | CO142 | GTR1004 | candidata | rejeitado | sem_par | razão 24,64 (n=367) | CO142 é a massa de 'outros agentes'; GTR1004 é do agente público; razão 25 |
| 46 | FN206 | GFI2211 | candidata | rejeitado | sem_par | razão 0,53 (n=220) | FN206 é despesa dos agentes públicos com coleta; GFI2211 é despesa com coleta terceirizada. O par mais próximo é FN207 (achado A6) |
| 47 | FN208 | GFI2211 | candidata | rejeitado | sem_par | razão 0,62 (n=443) | FN208 é despesa total (pública + privada) com coleta; GFI2211 é só a terceirizada da coleta indiferenciada |
| 48 | FN220 | GFI2218 | candidata | rejeitado | sem_par | razão 0,02 (n=55) | FN220 é despesa total com manejo de RSU; GFI2218 é só o serviço terceirizado sazonal; razão 0,02. O par certo é FN220 com GFI2208 + GFI2221 (achado A7) |
| 49 | GE201 | GFI2237 | candidata | rejeitado | sem_par | 0% (n=4554) | GE201 pergunta se o prestador de RS presta outros serviços de saneamento; GFI2237 é investimento total |
| 50 | IN002 | IFR2001 | candidata | rejeitado | sem_par | razão 0,00 (n=3747) | IN002 é despesa por empregado (R$/empregado); IFR2001 é DEX por domicílio (R$/domicílio.ano) |
| 51 | IN029 | IRS1006 | candidata | rejeitado | sem_par | razão 0,00 (n=298) | IN029 é massa de RCC per capita (kg/hab/ano); IRS1006 é massa de limpeza urbana per capita (kg/hab/dia) |
| 52 | IN037 | IRS3011 | candidata | rejeitado | sem_par | — | IN037 é a taxa de RSS na massa coletada; IRS3011 é a recuperação de recicláveis secos |
| 53 | PO055 | GTR1025 | candidata | rejeitado | sem_par | — | PO055 é um item Sim/Não do formulário de políticas e planos; GTR1025 é massa coletada |
| 54 | PO056 | GTR1026 | candidata | rejeitado | sem_par | — | PO056 é um item Sim/Não do formulário de políticas e planos; GTR1026 é massa da coleta seletiva |
| 55 | PO058 | GFI2213 | candidata | rejeitado | sem_par | — | PO058 é um item Sim/Não do formulário de políticas e planos; GFI2213 é despesa com transbordo |
| 56 | PO059 | GTR3209 | candidata | rejeitado | sem_par | — | PO059 é um item Sim/Não do formulário de políticas e planos; GTR3209 é o executor da disposição final |
| 57 | PO061 | GTR2001 | candidata | rejeitado | sem_par | — | PO061 é um item Sim/Não do formulário de políticas e planos; GTR2001 é o executor da varrição |
| 58 | RS044 | GTR1004 | candidata | rejeitado | sem_par | razão 386,52 (n=2192) | RS044 é a massa de RSS; GTR1004 é a massa coletada pelo agente público; razão 387 |
| 59 | TB008 | GTR1005 | candidata | rejeitado | sem_par | razão 1.506,57 (n=669) | TB008 é número de empregados; GTR1005 é massa (t/ano) |
| 60 | TB011 | GTR1004 | candidata | rejeitado | sem_par | razão 975,00 (n=2196) | TB011 é número de empregados administrativos; GTR1004 é massa |
| 61 | TB012 | GTR1005 | candidata | rejeitado | sem_par | razão 2.922,00 (n=975) | TB012 é número de empregados administrativos; GTR1005 é massa |
| 62 | UP008 | GTR3121 | candidata | rejeitado | sem_par | — | UP008 é só RSS recebido na unidade; GTR3121 é o total de RSU recebido |
| 63 | UP010 | GTR3121 | candidata | rejeitado | sem_par | — | UP010 é só RCC recebido; GTR3121 é o total de RSU recebido |
| 64 | UP011 | GTR3121 | candidata | rejeitado | sem_par | — | UP011 é 'outros resíduos' recebidos; GTR3121 é o total |
| 65 | UP030 | GTR3233 | candidata | corrigir | igual | — | Mesma pergunta (frequência do recobrimento dos resíduos no aterro). Conferir se as categorias (não realizado, diário, semanal) são as mesmas |
| 66 | UP067 | GTR3121 | candidata | rejeitado | sem_par | — | UP067 é só podas (RPO) recebidas; GTR3121 é o total |
| 67 | UP080 | GTR3121 | candidata | corrigir | agregado | — | UP080 é o total recebido de cada município de origem; GTR3121 é a soma sobre os municípios. O par um a um é UP080 com GTR3120 (achado A8) |
| 68 | UP090 | GTR3238 | candidata | corrigir | igual | — | CNPJ da unidade nos dois lados (no SINISA, no bloco da unidade de disposição final) |
| 69 | CB999 | GFI1299 | desmembrado | rejeitado | sem_par | — | Observações livres: no SNIS, do formulário de cobrança de águas pluviais; no SINISA, do bloco de tarifas de RS. A Referência existe, mas não há conceito a comparar |
| 70 | CB999 | GFI2299 | desmembrado | rejeitado | sem_par | — | Observações livres de módulos diferentes (AP x RS); sem conceito a comparar |
| 71 | CS010 | GTR3132 | desmembrado | corrigir | igual | — | Mesma definição (papel e papelão recuperados na triagem, exceto catadores avulsos e sucateiros). No SINISA é 'informação futura': ainda sem dado |
| 72 | CS010 | GTR3130 | desmembrado | rejeitado | sem_par | 0% (n=696) | GTR3130 é a lista de equipamentos da unidade de triagem (glossários 2023 p.75 e 2024 p.76), não papel recuperado. A Referência CS010 está no verbete errado |
| 74 | FN218 | GFI2209 | desmembrado | confirmado | desmembrado | razão 0,41 (n=2846) | Parte de FN218: pessoal próprio do manejo; razão 0,41 |
| 76 | FN219 | GFI2210 | desmembrado | confirmado | desmembrado | razão 0,95 (n=2290) | Parte de FN219: terceirizado do manejo; razão 0,95 |
| 77 | TB003 | GFI2260 | desmembrado | corrigir | igual | — | Mesmo conceito (pessoal próprio da varrição). No SINISA é 'informação futura': ainda sem dado |
| 79 | TB004 | GFI2262 | desmembrado | corrigir | igual | — | Mesmo conceito (varredores terceirizados). No SINISA é 'informação futura': ainda sem dado |
| 81 | UP001 | GTR3001 | desmembrado | confirmado | desmembrado | — | Nome da unidade: o SINISA separa por tipo de unidade (transbordo, processamento, disposição) |
| 82 | UP001 | GTR3102 | desmembrado | confirmado | desmembrado | — | Nome da unidade de processamento ou tratamento |
| 83 | UP001 | GTR3202 | desmembrado | confirmado | desmembrado | — | Nome da unidade de disposição final |
| 84 | UP002 | GTR3006 | desmembrado | confirmado | desmembrado | — | Ano de início da operação, separado por tipo de unidade (transbordo) |
| 85 | UP002 | GTR3107 | desmembrado | confirmado | desmembrado | — | Ano de início da operação (processamento ou tratamento) |
| 88 | UP004 | GTR3007 | desmembrado | confirmado | desmembrado | — | Operador ou executor da unidade (transbordo); o SINISA não tem a opção 'outro' |
| 89 | UP004 | GTR3108 | desmembrado | confirmado | desmembrado | — | Operador ou executor da unidade (processamento ou tratamento) |
| 90 | UP007 | GTR3011 | desmembrado | corrigir | mudou_definicao | — | UP007 é só RDO e RPU recebidos; GTR3011 é qualquer resíduo enviado ao transbordo |
| 91 | UP007 | GTR3012 | desmembrado | corrigir | mudou_definicao | — | UP007 é RDO e RPU por município; GTR3012 é o total de RSU da unidade de transbordo, somado sobre os municípios |
| 92 | UP007 | GTR3120 | desmembrado | corrigir | mudou_definicao | — | UP007 é só RDO e RPU recebidos; GTR3120 é todo resíduo do município enviado à unidade de processamento |
| 93 | UP025 | GTR3010 | desmembrado | confirmado | desmembrado | — | Municípios de origem dos resíduos; o SINISA separa por tipo de unidade e pede um município por linha |
| 94 | UP025 | GTR3111 | desmembrado | confirmado | desmembrado | — | Municípios de origem (processamento ou tratamento) |
| 95 | UP050 | GTR3008 | desmembrado | confirmado | desmembrado | — | Tipo de licença ambiental, separado por tipo de unidade (transbordo) |
| 96 | UP050 | GTR3109 | desmembrado | confirmado | desmembrado | — | Tipo de licença ambiental (processamento ou tratamento) |
| 97 | UP051 | GTR3004 | desmembrado | confirmado | desmembrado | — | A unidade esteve em operação no ano? (transbordo) |
| 98 | UP051 | GTR3105 | desmembrado | confirmado | desmembrado | — | A unidade esteve em operação no ano? (processamento ou tratamento) |
| 99 | UP051 | GTR3205 | desmembrado | confirmado | desmembrado | — | A unidade esteve em operação no ano? (disposição final) |
| 100 | UP065 | GTR3005 | desmembrado | corrigir | mudou_definicao | — | UP065 é o nome do proprietário; GTR3005 é o tipo de proprietário |
| 101 | UP065 | GTR3106 | desmembrado | corrigir | mudou_definicao | — | UP065 é o nome do proprietário; GTR3106 é o tipo de proprietário |
| 102 | UP087 | GTR3002 | desmembrado | rejeitado | sem_par | — | UP087 é o endereço (texto); GTR3002 é a latitude. O par certo é UP088 (latitude) (achado A5) |
| 103 | UP087 | GTR3003 | desmembrado | rejeitado | sem_par | — | UP087 é o endereço; GTR3003 é a longitude. O par certo é UP089 |
| 104 | UP087 | GTR3103 | desmembrado | rejeitado | sem_par | — | UP087 é o endereço; GTR3103 é a latitude. O par certo é UP088 |
| 105 | UP087 | GTR3104 | desmembrado | rejeitado | sem_par | — | UP087 é o endereço; GTR3104 é a longitude. O par certo é UP089 |
| 106 | UP087 | GTR3203 | desmembrado | rejeitado | sem_par | — | UP087 é o endereço; GTR3203 é a latitude. O par certo é UP088 |
| 107 | UP087 | GTR3204 | desmembrado | rejeitado | sem_par | — | UP087 é o endereço; GTR3204 é a longitude. O par certo é UP089 |
| 108 | VA010 | GTR1002 | desmembrado | rejeitado | sem_par | 0% (n=507) | VA010 é km varridos pela Prefeitura; GTR1002 é a abrangência da rota de coleta. Referência no verbete errado |
| 110 | VA016 | GTR1008 | desmembrado | rejeitado | sem_par | — | VA016 é varrição mecanizada (Sim/Não); GTR1008 é massa da rota. Referência no verbete errado |
| 111 | VA016 | GTR2004 | desmembrado | corrigir | igual | — | Mesma pergunta, palavra por palavra (há varrição mecanizada no município?) |
| 113 | CS014 | GTR3136 | igual | confirmado | igual | — | Mesma definição (outros recicláveis, exceto pneus e eletrônicos). 'Informação futura' no SINISA |
| 114 | CS051 | GTR3131 | igual | confirmado | igual | — | Mesma pergunta (houve recuperação em unidade de triagem mesmo sem coleta seletiva?) |
| 115 | FN204 | GFI1208 | igual | confirmado | igual | — | Unidade adotada para a cobrança de tarifa (peso ou volume) |
| 116 | IN014 | IRS0004 | igual | corrigir | mudou_definicao | razão 1,00 (n=4266) | Numerador do SINISA inclui a coleta seletiva direta (GTR0203) e o denominador é a população urbana estimada pelo SINISA. Razão 1,00 (SNIS 2021), mas os dois ficam em 100% na maioria dos municípios |
| 120 | CC019 | GTR1401 | mudou_definicao | confirmado | mudou_definicao | 0% (n=4554) | O SINISA inclui RCC de grandes geradores e é de múltipla escolha, não Sim/Não |
| 121 | CO050 | GTR0202 | mudou_definicao | confirmado | mudou_definicao | razão 0,96 (n=4406) | GTR0202 inclui coleta indireta e seletiva direta; razão 0,96 (SNIS 2021) |
| 123 | CO165 | GTR0203 | mudou_definicao | confirmado | mudou_definicao | razão 0,96 (n=4266) | GTR0203 soma a coleta seletiva direta à indiferenciada direta; razão 0,96 (SNIS 2021) |
| 124 | CS011 | GTR3133 | mudou_definicao | corrigir | igual | — | Mesma definição (plásticos recuperados). 'Informação futura' no SINISA |
| 125 | CS012 | GTR3134 | mudou_definicao | corrigir | igual | — | Mesma definição (metais recuperados). 'Informação futura' no SINISA |
| 126 | CS013 | GTR3135 | mudou_definicao | corrigir | igual | — | Mesma definição (vidros recuperados). 'Informação futura' no SINISA |
| 128 | FN201 | GFI1206 | mudou_definicao | confirmado | mudou_definicao | 89% (n=4554) | Cobrança pelos serviços regulares: RSU no SNIS, manejo de resíduos domiciliares no SINISA; concordância 89% |
| 129 | FN202 | GFI1207 | mudou_definicao | confirmado | mudou_definicao | 0% (n=1923) | Forma de cobrança; categorias redigidas de outro jeito (concordância 0 pela grafia) |
| 130 | FN205 | GFI1209 | mudou_definicao | confirmado | mudou_definicao | 86% (n=4554) | O SINISA acrescenta os serviços a grandes geradores aos eventuais; concordância 86% |
| 134 | IN018 | IFR0001 | mudou_definicao | rejeitado | sem_par | razão 0,00 (n=3283) | IFR0001 é pessoal de limpeza urbana por mil habitantes; o glossário 2024 o liga ao IN044, não ao IN018 |
| 139 | IN035 | IRS3007 | mudou_definicao | corrigir | igual | razão 1,00 (n=375) | Mesma fórmula (plástico / total recuperado); razão 1,00 |
| 140 | IN038 | IRS3008 | mudou_definicao | corrigir | igual | razão 0,99 (n=356) | Mesma fórmula (metais / total recuperado); razão 0,99 |
| 141 | IN039 | IRS3009 | mudou_definicao | corrigir | igual | razão 1,00 (n=322) | Mesma fórmula (vidro / total recuperado); razão 1,00 |
| 142 | IN044 | IFR0001 | mudou_definicao | rejeitado | sem_par | razão 2,16 (n=546) | IN044 é km varridos por varredor por dia; IFR0001 é pessoal de limpeza urbana por mil habitantes. O 'similar no SNIS' do glossário está errado |
| A3 | CO117 | GTR1005 | sem_par | novo | mudou_definicao | razão 1,09 (n=1735) | Massa coletada pelo agente privado; o GTR1005 somado por município inclui rotas seletivas e de limpeza urbana; razão 1,09 |
| A5 | UP088 | GTR3103 | sem_par | novo | desmembrado | — | Latitude da unidade (também GTR3002 no transbordo e GTR3203 na disposição final; UP089 para longitude: GTR3003, GTR3104, GTR3204) |

Páginas de cada verbete: colunas `pagina_snis` e `pagina_sinisa` do CSV.

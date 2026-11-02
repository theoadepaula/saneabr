# Fixtures de teste

Recortes de planilhas reais, gerados por `ferramentas/criar_fixtures.py` a
partir dos arquivos baixados do gov.br. Cada planilha mantém o cabeçalho
original inteiro e só 8 a 12 linhas de dados (as primeiras e as de municípios
cujo dígito verificador do IBGE foge à regra). Valores sem outra alteração.

| Arquivo | Origem |
|---|---|
| `snis_rs_2022_mini.zip` | `Planilha_RS_2022_atualizado_29112024.zip` (SNIS RS 2022): Informações, Indicadores e Unidades_Fluxos |
| `snis_rs_sem_ibge.xlsx` | Informações SNIS RS 2022 sem a coluna "Código do IBGE", como nos anos 2014–2021 |
| `sinisa_rs_2024_mini.zip` | `SINISA_RESIDUOS_planilhas_2024.zip` (SINISA RS 2024): Indicadores e as 4 abas do formulário de Manejo |
| `esperado_*.csv` | o que `ler()` deve devolver para cada fixture (gerado por `ferramentas/esperados_fixtures.R`; os testes R e Python comparam com ele) |

Fonte dos dados: Brasil, Ministério das Cidades, Secretaria Nacional de
Saneamento Ambiental. SNIS e SINISA. https://www.gov.br/cidades. Livre
utilização com citação da fonte (ver `LICENCA-DADOS.md`).

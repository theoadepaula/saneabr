# Licença dos dados do SNIS e do SINISA

> Verificado em 2026-11-01, nas fontes primárias. Não é parecer jurídico; é o
> registro do que as fontes dizem e da decisão tomada para o `saneabr`.

## A pergunta

O rodapé do portal gov.br/cidades declara CC BY-ND 3.0 (sem derivações). Os
relatórios do SINISA dizem "permitida a reprodução [...] desde que citada a
fonte". Se o "ND" valesse para os dados, um pacote que lê, recorta e arruma as
planilhas estaria produzindo obra derivada. Vale?

## O que as fontes dizem

**1. Rodapé do gov.br (todas as páginas, inclusive as do SNIS e do SINISA).**
"Todo o conteúdo deste site está publicado sob a licença Creative Commons
Atribuição-SemDerivações 3.0 Não Adaptada." É o mesmo texto no portal inteiro
(conferido em [resultados-sinisa](https://www.gov.br/cidades/pt-br/acesso-a-informacao/acoes-e-programas/saneamento/sinisa/resultados-sinisa),
em [dados abertos do MCid](https://www.gov.br/cidades/pt-br/acesso-a-informacao/dados-abertos)
e nos [termos de uso do gov.br](https://www.gov.br/pt-br/termos-de-uso)). É a
licença do **conteúdo editorial do site**, um rodapé de modelo, sem menção a
bases de dados.

**2. Decreto 8.777/2016 (Política de Dados Abertos), com a redação do Decreto 9.903/2019.**
[Texto no Planalto](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2016/decreto/d8777.htm).
- Art. 2º, III: dados abertos são os "disponibilizados sob licença aberta que
  permita sua livre utilização, consumo ou cruzamento, limitando-se a creditar
  a autoria ou a fonte".
- Art. 4º, caput: "Os dados disponibilizados pelo Poder Executivo federal e as
  informações de transparência ativa são de livre utilização pelos Poderes
  Públicos e pela sociedade."
- Art. 4º, § 1º: "Fica autorizada a utilização gratuita das bases de dados e
  das informações disponibilizadas nos termos do disposto no inciso XIII do
  caput do art. 7º da Lei nº 9.610 [...] e cujo detentor de direitos autorais
  patrimoniais seja a União".

**3. Lei 14.129/2021 (Governo Digital).**
[Texto no Planalto](https://www.planalto.gov.br/ccivil_03/_ato2019-2022/2021/lei/l14129.htm).
Art. 29: os dados "são de livre utilização pela sociedade"; § 1º, IV:
"permissão irrestrita de uso de bases de dados publicadas em formato aberto".

**4. Lei 9.610/1998 (Direitos Autorais).**
[Texto no Planalto](https://www.planalto.gov.br/ccivil_03/leis/l9610.htm).
Art. 7º, § 2º: a proteção das bases de dados "não abarca os dados ou materiais
em si mesmos". Art. 8º, IV: não são protegidos "os textos de tratados ou
convenções, leis, decretos, regulamentos, decisões judiciais e demais atos
oficiais".

**5. LAI (Lei 12.527/2011).**
[Texto no Planalto](https://www.planalto.gov.br/ccivil_03/_ato2011-2014/2011/lei/l12527.htm).
Art. 8º, § 3º, II e III: os sítios devem "possibilitar a gravação de relatórios
em diversos formatos eletrônicos, inclusive abertos e não proprietários" e "o
acesso automatizado por sistemas externos em formatos abertos, estruturados e
legíveis por máquina".

**6. Plano de Dados Abertos do Ministério das Cidades 2026–2027.**
[PDF](https://www.gov.br/cidades/pt-br/midia/documentos/pdf/pda_2026_2027.pdf), p. 22–23.
A base "Série Histórica do SNIS" (SNSA) consta como base de dados aberta,
"totalmente pública e disponibilizada gratuitamente na internet", "Dado já
disponibilizado", decisão "Manter". O próprio PDA define licença aberta como a
que permite "que qualquer pessoa os utilize, os reutilize e os redistribua,
estando sujeito a, no máximo, a exigência de creditar a sua autoria". O SINISA
ainda não aparece nominalmente no PDA.

**7. Relatórios do SINISA** (ex.: Relatório SINISA Resíduos Sólidos 2025, p. 2).
"Todos os direitos reservados. É permitida a reprodução de dados e de
informações contidos nesta publicação, desde que citada a fonte."

**Não verifiquei**: a página do conjunto do SNIS no dados.gov.br (a API do
portal exige token e a página é renderizada em JavaScript), que poderia trazer
uma licença explícita no campo "Licença".

## Conclusão

O "ND" do rodapé vale para o **conteúdo editorial do portal**, não para os
dados. Para os dados, o regime é o da Política de Dados Abertos: livre
utilização, com crédito à fonte (Decreto 8.777, art. 4º; Lei 14.129, art. 29).
Os dados em si nem são objeto de direito autoral (Lei 9.610, art. 7º, § 2º), e
o próprio Ministério trata o SNIS como dado aberto no seu PDA e autoriza a
reprodução dos dados do SINISA com citação.

Ainda que alguém lesse o "ND" como aplicável, a CC BY-ND permite redistribuir
**cópia literal** com atribuição; o que ela restringe é distribuir versões
modificadas. O usuário que roda `ler()` transforma os dados na própria máquina,
o que não é distribuição.

## O que o pacote faz com isso

| Item | Vai junto do pacote? | Por quê |
|---|---|---|
| Código (R e Python) | sim, **MIT** | trabalho do autor |
| `catalogo.csv` (URLs, tamanhos, SHA-256) | sim, **MIT** | metadados levantados pelo autor; nenhum dado do Ministério |
| `layouts.json`, `rede.json`, `esquemas.json` | sim, **MIT** | regras de leitura, trabalho do autor |
| `correspondencia_snis_sinisa.csv`, `mudancas_dentro_snis.csv` | sim, **MIT** | classificação do autor; as evidências citam documento e página |
| `dic_snis.csv`, `dic_sinisa.csv` | sim | estrutura e normalização: MIT. Os textos de nome, definição e unidade são do Ministério das Cidades, transcritos sem alteração, com documento, página e URL de origem em cada linha (Decreto 8.777, art. 4º) |
| `glossarios_versoes.csv.gz` (11 MB descompactado) | **não** (só no repositório) | tamanho (limite de 5 MB do CRAN) e sem uso na API da v0.1 |
| Fixtures de teste (recortes de 8 a 12 linhas de planilhas reais) | sim | dados públicos de livre utilização, com a fonte citada em `fixtures/README.md` |
| Planilhas completas (zip, rar, xlsx) | **não** | baixadas da fonte pelo usuário, com SHA-256 conferido. Não é exigência da licença: é para não envelhecer (a fonte republica arquivos), não inflar o pacote e deixar claro de onde vem o dado |

Toda saída de `ler()` vem de arquivo baixado do gov.br. `citation("saneabr")`
e a documentação pedem que o usuário cite o Ministério das Cidades.

## Se a resposta mudar

Se o Ministério publicar licença explícita para os conjuntos (por exemplo no
dados.gov.br), atualize esta nota e, se for o caso, considere um espelho dos
arquivos (Zenodo, release do GitHub) para quando os links do gov.br quebrarem.

# Mudanças

## 0.1.0

Primeira versão, junto com o pacote R `saneabr` 0.1.0.

- `catalogo()`: os 266 arquivos publicados para o SNIS (1995–2022) e o SINISA
  (2023–2024), com URL, tamanho e SHA-256.
- `baixar()`: baixa da fonte oficial para o cache (`platformdirs`), confere o
  SHA-256 e emite `ShaDiferenteWarning` quando a fonte republicou o arquivo.
  Sem internet ou com a fonte fora do ar, emite `FonteIndisponivelAviso` e
  devolve `None`.
- `fonte_disponivel()`: diz se o gov.br está respondendo.
- `ler()` e `tabelas()`: módulo de resíduos sólidos do SNIS 2014–2022 e do
  SINISA 2023–2024, com códigos normalizados e município com 7 dígitos. O
  resultado é idêntico ao do pacote R.
- `dicionario()`, `correspondencia()` e `mudancas()`.

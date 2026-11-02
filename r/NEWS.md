# saneabr 0.1.0

Primeira versão.

* `catalogo()` lista os 266 arquivos publicados pelo Ministério das Cidades
  para o SNIS (1995–2022) e o SINISA (2023–2024), com URL, tamanho e SHA-256.
* `baixar()` baixa da fonte oficial para o cache (`tools::R_user_dir()`),
  confere o SHA-256 e avisa quando a fonte republicou o arquivo. Sem internet
  ou com a fonte fora do ar, emite uma mensagem e devolve `NULL`, sem erro.
* `fonte_disponivel()` diz se o gov.br está respondendo.
* `ler()` lê o módulo de resíduos sólidos (RS) do SNIS 2014–2022 (7 tabelas)
  e do SINISA 2023–2024 (15 tabelas): códigos de variável normalizados e
  município com 7 dígitos (`id_municipio`). `tabelas()` lista o que há em cada
  ano.
* `dicionario()`, `correspondencia()` e `mudancas()` trazem os dicionários
  extraídos dos glossários, a correspondência SNIS ↔ SINISA (por padrão, só os
  pares com evidência documental) e as mudanças de código dentro do SNIS.
* As regras de leitura vêm de uma especificação compartilhada com a
  biblioteca Python `saneabr`; as duas linguagens dão o mesmo resultado.

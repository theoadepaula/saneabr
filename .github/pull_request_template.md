## O que muda

<!-- Uma ou duas frases. Cite a issue: "Resolve #12". -->

## Tipo

- [ ] Correção de leitura (bug)
- [ ] Recurso novo (função, módulo, ano)
- [ ] Dados: dicionário, correspondência ou catálogo
- [ ] Documentação
- [ ] CI ou ferramentas

## Conferência

- [ ] Mexi em `spec/`, não nas cópias em `r/inst/extdata/spec/` e `python/src/saneabr/spec/`, e rodei `Rscript ferramentas/sincronizar_spec.R`
- [ ] `Rscript ferramentas/sincronizar_spec.R --checar` passa
- [ ] Testes do R (`devtools::test()`) e do Python (`python -m pytest`) passam
- [ ] A mudança vale para **R e Python**, com teste nas duas (ou explico abaixo o que falta numa delas)
- [ ] Se muda a leitura: R e Python continuam dando o mesmo resultado (paridade rodada, se tenho os arquivos completos)
- [ ] Se muda a correspondência ou um dicionário: cada linha nova cita documento e página
- [ ] `r/NEWS.md` e `python/CHANGELOG.md` registram a mudança visível ao usuário

## Evidência e notas

<!-- Saída de teste, conta feita com os dados, documento e página, ou o que
falta numa das linguagens. -->

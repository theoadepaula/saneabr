test_that("ler() avisa claramente o que ainda nao tem suporte", {
  expect_error(ler("snis", "ae", 2020), class = "saneabr_sem_suporte")
  expect_error(ler("snis", "rs", 2010), class = "saneabr_sem_suporte")
  expect_error(ler("sinisa", "gm", 2024), "baixar")
  expect_error(ler("snis", "rs", 2022, "nao_existe"), class = "saneabr_sem_tabela")
  expect_error(ler("snis", "rs", 2015, "politicas_planos"), class = "saneabr_sem_tabela")
  expect_error(ler("xpto", "rs", 2022), "sistema")
  expect_error(baixar("snis", "rs", 1990), class = "saneabr_sem_arquivo")
})

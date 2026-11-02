"""dicionario(), correspondencia() e mudancas()."""

from __future__ import annotations

import pandas as pd

from ._spec import padronizar_modulo, padronizar_sistema, spec_csv


def dicionario(sistema, modulo=None) -> pd.DataFrame:
    """Dicionário de variáveis e indicadores, extraído dos glossários oficiais.

    ``qualidade``: ``verbete`` (lido do verbete), ``tabela`` (glossário em
    tabela; pode misturar linhas vizinhas) ou ``so_planilha`` (sem verbete).
    As fórmulas são imagem nos PDFs: ``formula`` traz só os códigos citados.
    Texto dos glossários: Ministério das Cidades, reproduzido sem alteração.
    """
    s = padronizar_sistema(sistema).lower()
    x = spec_csv(f"dicionarios/dic_{s}.csv")
    if modulo is not None:
        x = x[x["modulo"] == padronizar_modulo(modulo)]
    return x.reset_index(drop=True)


def correspondencia(modulo=None, candidatas=False) -> pd.DataFrame:
    """Pares de códigos SNIS ↔ SINISA montados a partir dos glossários do SINISA.

    Por padrão, só pares com evidência documental (a "Referência: * XX000" do
    glossário de informações ou a coluna "SIMILAR NO SNIS" do de indicadores).
    ``candidatas=True`` inclui os pares sugeridos só pela semelhança do nome.
    Montada automaticamente; nenhum par foi validado a olho.

    Atenção: CO119 (SNIS) não é GTR1028 (SINISA). O CO119 exclui a massa das
    cooperativas e o RCC; o GTR1028 soma a massa por rota, inclusive coleta
    seletiva, podas e RCC/volumosos de pequenos geradores, e não tem
    Referência a código SNIS. Veja spec/NOTAS-MUDANCAS.md.
    """
    x = spec_csv("dicionarios/correspondencia_snis_sinisa.csv")
    x["evidencia_documental"] = x["evidencia_documental"] == "TRUE"
    x["similaridade_nome"] = pd.to_numeric(x["similaridade_nome"], errors="coerce")
    manter = x["evidencia_documental"].copy()
    if candidatas:
        manter |= x["tipo_relacao"] == "candidata"
    x = x[manter & (x["tipo_relacao"] != "sem_par")]
    if modulo is not None:
        x = x[x["modulo"] == padronizar_modulo(modulo)]
    return x.reset_index(drop=True)


def mudancas(modulo=None) -> pd.DataFrame:
    """Mudanças de código, unidade, nome e fórmula dentro do SNIS (a validar as automáticas)."""
    x = spec_csv("dicionarios/mudancas_dentro_snis.csv")
    x["ano"] = x["ano"].astype(int)
    if modulo is not None:
        x = x[x["modulo"] == padronizar_modulo(modulo)]
    return x.reset_index(drop=True)

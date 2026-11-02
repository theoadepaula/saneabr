"""Acesso a spec embutida (copiada de ../spec por ferramentas/sincronizar_spec.R).

Nenhuma regra de leitura mora no codigo: regex, nomes, eras e excecoes vem daqui.
"""

from __future__ import annotations

import csv
import json
from functools import lru_cache
from importlib import resources
from pathlib import Path

import pandas as pd

SISTEMAS = ("SNIS", "SINISA")
MODULOS = ("RS", "AE", "AP", "GM")


def spec_dir() -> Path:
    return Path(str(resources.files("saneabr") / "spec"))


@lru_cache(maxsize=None)
def spec_json(nome: str) -> dict:
    with open(spec_dir() / f"{nome}.json", encoding="utf-8") as f:
        return json.load(f)


def layouts() -> dict:
    return spec_json("layouts")


def rede() -> dict:
    return spec_json("rede")


@lru_cache(maxsize=None)
def _spec_csv(rel: str) -> pd.DataFrame:
    with open(spec_dir() / rel, encoding="utf-8", newline="") as f:
        linhas = list(csv.reader(f))
    return pd.DataFrame(linhas[1:], columns=linhas[0], dtype=object)


def spec_csv(rel: str) -> pd.DataFrame:
    return _spec_csv(rel).copy()


def padronizar_sistema(sistema: str) -> str:
    s = str(sistema).upper()
    if s not in SISTEMAS:
        raise ValueError(f"'sistema' deve ser 'snis' ou 'sinisa', não {sistema!r}.")
    return s


def padronizar_modulo(modulo: str) -> str:
    m = str(modulo).upper()
    if m not in MODULOS:
        raise ValueError(f"'modulo' deve ser 'rs', 'ae', 'ap' ou 'gm', não {modulo!r}.")
    return m


def padronizar_ano(ano) -> int:
    try:
        return int(ano)
    except (TypeError, ValueError):
        raise ValueError(f"'ano' deve ser um ano, como 2022, não {ano!r}.") from None

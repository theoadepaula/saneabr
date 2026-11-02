"""Normalizacoes de texto e de codigo (spec/layouts.json: texto, codigo, municipio)."""

from __future__ import annotations

import re
from functools import lru_cache

from ._spec import layouts


@lru_cache(maxsize=None)
def _classe_espacos() -> str:
    extra = "".join(layouts()["texto"]["espacos_extra"])
    # o mesmo conjunto do \s do PCRE (usado no R) mais os extras da spec;
    # o \s do Python casaria outros caracteres Unicode
    return "[ \\t\\n\\r\\f\\v" + re.escape(extra) + "]"


@lru_cache(maxsize=None)
def _re_aparar() -> re.Pattern:
    c = _classe_espacos()
    return re.compile(f"^{c}+|{c}+$")


def aparar(x: str) -> str:
    return _re_aparar().sub("", x)


@lru_cache(maxsize=None)
def _tabela_acentos() -> dict:
    tx = layouts()["texto"]
    de, para = tx["acentos_de"], tx["acentos_para"]
    if len(de) != len(para):
        raise RuntimeError("spec: acentos_de e acentos_para com comprimentos diferentes")
    return str.maketrans(de, para)


def sem_acento(x: str) -> str:
    return x.translate(_tabela_acentos())


_NAO_ALNUM = re.compile("[^a-z0-9]+")


def slug(x: str) -> str:
    x = sem_acento(x.lower())
    x = _NAO_ALNUM.sub("_", x)
    return x.strip("_")


@lru_cache(maxsize=None)
def _re_codigo():
    cfg = layouts()["codigo"]
    rem = "".join(re.escape(c) for c in cfg["remover"])
    limpar = re.compile(f"[{rem}]|{_classe_espacos()}")
    return limpar, re.compile(cfg["regex"])


def normalizar_codigo(x):
    """Codigo normalizado (CO119, GTR1030, UP088) ou None."""
    if x is None:
        return None
    limpar, rx = _re_codigo()
    limpo = limpar.sub("", x).upper()
    m = rx.match(limpo)
    return m.group(1) if m else None


def dv_ibge(cod6: str) -> str:
    pesos = layouts()["municipio"]["pesos"]
    soma = 0
    for d, p in zip(cod6, pesos):
        v = int(d) * p
        soma += v // 10 + v % 10 if v > 9 else v
    return str((10 - soma % 10) % 10)


_SEIS = re.compile("^[0-9]{6}$")


def municipio_7(x):
    if x is None or not isinstance(x, str) or not _SEIS.match(x):
        return x
    exc = layouts()["municipio"]["excecoes"]
    if x in exc:
        return exc[x]
    return x + dv_ibge(x)

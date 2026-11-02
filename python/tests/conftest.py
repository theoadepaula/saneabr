import csv
import math
import os
from pathlib import Path

import pytest

FIXTURES = Path(__file__).parent / "fixtures"


def pytest_collection_modifyitems(config, items):
    rede = os.environ.get("SANEABR_TESTAR_REDE") == "1" and not os.environ.get("CI")
    dados = os.environ.get("SANEABR_DADOS_BRUTOS") and not os.environ.get("CI")
    for item in items:
        if "rede" in item.keywords and not rede:
            item.add_marker(pytest.mark.skip(reason="sem SANEABR_TESTAR_REDE=1 (ou em CI)"))
        if "dados" in item.keywords and not dados:
            item.add_marker(pytest.mark.skip(reason="sem SANEABR_DADOS_BRUTOS (ou em CI)"))


@pytest.fixture(autouse=True)
def extracao_temporaria(tmp_path, monkeypatch):
    monkeypatch.setenv("SANEABR_EXTRACAO", str(tmp_path / "extr"))


def casos():
    with open(FIXTURES / "casos.csv", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def comparar_esperado(df, caso):
    base = FIXTURES / f"esperado_{caso}"
    with open(base.with_suffix(".csv"), encoding="utf-8", newline="") as f:
        linhas = list(csv.reader(f))
    tipos = dict(l.split(",", 1) for l in base.with_suffix(".tipos").read_text(encoding="utf-8").splitlines())
    cab, dados = linhas[0], linhas[1:]
    assert list(df.columns) == cab
    assert len(df) == len(dados)
    for j, col in enumerate(cab):
        num_r = tipos[col] in ("numeric", "integer")
        num_py = df[col].dtype.kind in "fi" or str(df[col].dtype) == "Int64"
        assert num_r == num_py, f"{col}: R {tipos[col]} x Py {df[col].dtype}"
        for i, p in enumerate(df[col].tolist()):
            r = dados[i][j]
            p_na = p is None or (isinstance(p, float) and math.isnan(p)) or str(p) == "<NA>"
            assert (r == "") == p_na, f"{col}[{i}]: R {r!r} x Py {p!r}"
            if p_na:
                continue
            if num_r:
                assert math.isclose(float(r), float(p), rel_tol=1e-12), f"{col}[{i}]"
            else:
                assert r == p, f"{col}[{i}]: R {r!r} x Py {p!r}"

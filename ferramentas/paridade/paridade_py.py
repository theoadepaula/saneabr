"""Compara o resultado de saneabr (Python) com os CSVs gravados por paridade_r.R.

    python ferramentas/paridade/paridade_py.py <saida_do_R>

Para cada tabela: mesmo numero de linhas, mesmas colunas na mesma ordem,
mesmos tipos (numero x texto) e mesmos valores (numeros com tolerancia
relativa de 1e-12; texto exato). Sai com codigo 1 se houver diferenca.
"""
import csv
import math
import sys
import time
import warnings
from pathlib import Path

import saneabr

saida = Path(sys.argv[1])
falhas = 0
total = 0
for tipos_f in sorted(saida.glob("*.tipos")):
    sistema, ano, tabela = tipos_f.stem.split("_", 2)
    t0 = time.time()
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        py = saneabr.ler(sistema, "rs", int(ano), tabela)
    tipos_r = dict(linha.split(",", 1) for linha in tipos_f.read_text().splitlines())
    with open(tipos_f.with_suffix(".csv"), encoding="utf-8", newline="") as f:
        linhas = list(csv.reader(f))
    cab, dados = linhas[0], linhas[1:]
    erros = []
    if cab != list(py.columns):
        a, b = set(cab), set(py.columns)
        erros.append(f"colunas diferem: so R {sorted(a - b)[:5]}, so Py {sorted(b - a)[:5]}, ordem igual={cab == list(py.columns)}")
    if len(dados) != len(py):
        erros.append(f"linhas: R {len(dados)} x Py {len(py)}")
    if not erros:
        for j, col in enumerate(cab):
            num_r = tipos_r[col] in ("numeric", "integer")
            num_py = py[col].dtype.kind in "fi" or str(py[col].dtype) == "Int64"
            if num_r != num_py:
                erros.append(f"{col}: tipo R {tipos_r[col]} x Py {py[col].dtype}")
                continue
            vp = py[col].tolist()
            for i, linha in enumerate(dados):
                r = linha[j]
                p = vp[i]
                p_na = p is None or (isinstance(p, float) and math.isnan(p)) or str(p) == "<NA>"
                if r == "" and p_na:
                    continue
                if (r == "") != p_na:
                    erros.append(f"{col} linha {i}: R {r!r} x Py {p!r}")
                    break
                if num_r:
                    if not math.isclose(float(r), float(p), rel_tol=1e-12, abs_tol=0):
                        erros.append(f"{col} linha {i}: R {r} x Py {p!r}")
                        break
                elif r != p:
                    erros.append(f"{col} linha {i}: R {r!r} x Py {p!r}")
                    break
    total += 1
    status = "OK " if not erros else "ERRO"
    print(f"{status} {sistema:7s} {ano} {tabela:26s} {len(py):6d} x {py.shape[1]:3d}  {time.time() - t0:.1f}s")
    for e in erros[:5]:
        print("     ", e)
    falhas += bool(erros)
print(f"{total - falhas}/{total} tabelas identicas")
sys.exit(1 if falhas else 0)

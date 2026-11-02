"""Localiza a planilha de uma tabela no arquivo baixado e le a grade de celulas."""

from __future__ import annotations

import datetime as _dt
import os
import re
import shutil
import subprocess
import warnings
import zipfile
from pathlib import Path, PurePosixPath

from ._baixar import dir_extracao, sha256_arquivo
from ._texto import slug

_PLANILHA = re.compile(r"[.]xlsx?$", re.IGNORECASE)
_ARQUIVO = re.compile(r"[.](zip|rar)$", re.IGNORECASE)


class SemPlanilhaError(LookupError):
    pass


def _eh_planilha(nome: str) -> bool:
    return bool(_PLANILHA.search(nome))


# --- rar --------------------------------------------------------------------

def _bsdtar() -> str | None:
    """bsdtar (libarchive) le rar. No Windows 10+ e no macOS ele vem como 'tar'."""
    cands = [shutil.which("bsdtar"), shutil.which("tar")]
    raiz = os.environ.get("SystemRoot")
    if raiz:
        cands.append(os.path.join(raiz, "System32", "tar.exe"))
    for exe in cands:
        if not exe or not os.path.exists(exe):
            continue
        try:
            v = subprocess.run([exe, "--version"], capture_output=True, text=True, timeout=10)
        except (OSError, subprocess.SubprocessError):
            continue
        if "bsdtar" in (v.stdout + v.stderr):
            return exe
    return None


_SEM_RAR = (
    "Este arquivo vem em rar. Para ler rar, tenha bsdtar no PATH (vem no Windows 10+ "
    "e no macOS como 'tar'; no Linux, pacote libarchive-tools) ou instale "
    "'rarfile' (pip install saneabr[rar]) com unrar ou 7z disponivel."
)


def _rar_listar(arquivo: Path) -> list[str]:
    exe = _bsdtar()
    if exe:
        out = subprocess.run([exe, "-tf", str(arquivo)], capture_output=True, text=True, check=True)
        return [linha for linha in out.stdout.splitlines() if linha and not linha.endswith("/")]
    try:
        import rarfile

        with rarfile.RarFile(arquivo) as rf:
            return [i.filename for i in rf.infolist() if not i.is_dir()]
    except ImportError:
        raise RuntimeError(_SEM_RAR) from None


def _rar_extrair(arquivo: Path, entrada: str, destino: Path) -> None:
    exe = _bsdtar()
    if exe:
        subprocess.run([exe, "-xf", str(arquivo), "-C", str(destino), entrada], check=True)
        return
    try:
        import rarfile

        with rarfile.RarFile(arquivo) as rf:
            rf.extract(entrada, path=destino)
    except ImportError:
        raise RuntimeError(_SEM_RAR) from None
    except Exception as e:
        raise RuntimeError(f"{_SEM_RAR} ({e})") from e


# --- zip / rar --------------------------------------------------------------

def _listar(arquivo: Path) -> list[str]:
    ext = arquivo.suffix.lower()
    if ext == ".zip":
        with zipfile.ZipFile(arquivo) as z:
            return [i.filename for i in z.infolist() if not i.is_dir()]
    if ext == ".rar":
        return _rar_listar(arquivo)
    raise ValueError(f"Formato não suportado: {arquivo.name}")


def _extrair(arquivo: Path, entrada: str, destino: Path) -> Path:
    destino.mkdir(parents=True, exist_ok=True)
    alvo = destino / PurePosixPath(entrada)
    if alvo.exists():
        return alvo
    if arquivo.suffix.lower() == ".zip":
        with zipfile.ZipFile(arquivo) as z:
            z.extract(entrada, path=destino)
    else:
        _rar_extrair(arquivo, entrada, destino)
    if not alvo.exists():
        raise RuntimeError(f"Não consegui extrair {entrada} de {arquivo.name}.")
    return alvo


def localizar_planilha(arquivo, regex: str, profundidade: int = 0) -> Path:
    arquivo = Path(arquivo)
    if _eh_planilha(arquivo.name):
        return arquivo
    entradas = _listar(arquivo)
    rx = re.compile(regex)
    base = [PurePosixPath(e).name for e in entradas]
    cand = sorted(
        e for e, b in zip(entradas, base)
        if _eh_planilha(b) and rx.search(b) and not b.startswith("~$")
    )
    destino = dir_extracao() / sha256_arquivo(arquivo)[:16]
    if cand:
        if len(cand) > 1:
            warnings.warn(f"Mais de uma planilha casa com {regex!r}; uso {PurePosixPath(cand[0]).name}.")
        return _extrair(arquivo, cand[0], destino)
    if profundidade < 2:
        for e, b in zip(entradas, base):
            if _ARQUIVO.search(b):
                f = _extrair(arquivo, e, destino)
                try:
                    return localizar_planilha(f, regex, profundidade + 1)
                except SemPlanilhaError:
                    pass
    raise SemPlanilhaError(f"Nenhuma planilha casa com {regex!r} em {arquivo.name}.")


# --- leitura da grade ---------------------------------------------------------

_EPOCA = _dt.datetime(1899, 12, 30)


def _texto_celula(v):
    """Converte o valor de uma celula para texto, como o readxl com col_types = 'text'."""
    if v is None:
        return None
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        f = float(v)
        if f.is_integer() and abs(f) < 1e15:
            return str(int(f))
        return repr(f)
    if isinstance(v, _dt.datetime):
        return _texto_celula((v - _EPOCA).total_seconds() / 86400)
    if isinstance(v, _dt.date):
        return _texto_celula((_dt.datetime(v.year, v.month, v.day) - _EPOCA).days)
    if isinstance(v, _dt.time):
        return _texto_celula((v.hour * 3600 + v.minute * 60 + v.second) / 86400)
    return str(v)


def abas(planilha: Path) -> list[str]:
    if planilha.suffix.lower() == ".xls":
        import xlrd

        with xlrd.open_workbook(planilha, on_demand=True) as wb:
            return wb.sheet_names()
    import openpyxl

    wb = openpyxl.load_workbook(planilha, read_only=True, data_only=True)
    try:
        return wb.sheetnames
    finally:
        wb.close()


def escolher_aba(planilha: Path, aba_regex: str | None) -> str:
    nomes = abas(planilha)
    if aba_regex is None:
        return nomes[0]
    rx = re.compile(aba_regex)
    for n in nomes:
        if rx.search(slug(n)):
            return n
    raise LookupError(f"Nenhuma aba casa com {aba_regex!r} em {planilha.name}. Abas: {nomes}")


def ler_grade(planilha: Path, aba: str) -> list[list]:
    """Grade de celulas como texto (None = vazio), linhas de mesmo comprimento."""
    if planilha.suffix.lower() == ".xls":
        import xlrd

        with xlrd.open_workbook(planilha, on_demand=True) as wb:
            sh = wb.sheet_by_name(aba)
            grade = []
            for i in range(sh.nrows):
                linha = []
                for c in sh.row(i):
                    if c.ctype in (xlrd.XL_CELL_EMPTY, xlrd.XL_CELL_BLANK, xlrd.XL_CELL_ERROR):
                        linha.append(None)
                    elif c.ctype == xlrd.XL_CELL_BOOLEAN:
                        linha.append(_texto_celula(bool(c.value)))
                    else:
                        linha.append(_texto_celula(c.value))
                grade.append(linha)
    else:
        import openpyxl

        wb = openpyxl.load_workbook(planilha, read_only=True, data_only=True)
        try:
            ws = wb[aba]
            ws.reset_dimensions()
            grade = [[_texto_celula(v) for v in linha] for linha in ws.iter_rows(values_only=True)]
        finally:
            wb.close()
    largura = max((len(r) for r in grade), default=0)
    return [r + [None] * (largura - len(r)) for r in grade]

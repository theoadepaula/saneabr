"""Catalogo, cache e download."""

from __future__ import annotations

import hashlib
import os
import warnings
from pathlib import Path

import pandas as pd

from ._spec import padronizar_ano, padronizar_modulo, padronizar_sistema, rede, spec_csv


class ShaDiferenteWarning(UserWarning):
    """O arquivo local difere do catalogado: a fonte pode ter republicado."""


def catalogo(sistema=None, modulo=None, ano=None, tipo=None) -> pd.DataFrame:
    """Catálogo de arquivos do SNIS e do SINISA conhecidos pelo pacote.

    Colunas: sistema, modulo, ano, tipo, arquivo, url, sha256, formato, bytes,
    data_verificacao. O catálogo vem com o pacote; os dados, não.
    """
    x = spec_csv("catalogo.csv")
    x["ano"] = x["ano"].astype(int)
    x["bytes"] = x["bytes"].astype(float)

    def lista(v, f=lambda z: z):
        return [f(i) for i in (v if isinstance(v, (list, tuple, set)) else [v])]

    if sistema is not None:
        x = x[x["sistema"].isin(lista(sistema, lambda z: str(z).upper()))]
    if modulo is not None:
        x = x[x["modulo"].isin(lista(modulo, lambda z: str(z).upper()))]
    if ano is not None:
        x = x[x["ano"].isin(lista(ano, int))]
    if tipo is not None:
        x = x[x["tipo"].isin(lista(tipo))]
    return x.reset_index(drop=True)


def dir_cache() -> Path:
    """Diretório de cache: SANEABR_CACHE ou platformdirs.user_cache_dir('saneabr')."""
    d = os.environ.get(rede()["variavel_cache"], "")
    if not d:
        import platformdirs

        d = platformdirs.user_cache_dir("saneabr", appauthor=False)
    return Path(d)


def dir_extracao() -> Path:
    d = os.environ.get(rede()["variavel_extracao"], "")
    return Path(d) if d else dir_cache() / "_extraido"


def sha256_arquivo(caminho) -> str:
    h = hashlib.sha256()
    with open(caminho, "rb") as f:
        for bloco in iter(lambda: f.read(1 << 20), b""):
            h.update(bloco)
    return h.hexdigest()


def _user_agent() -> str:
    from . import __version__

    return rede()["user_agent"].replace("{versao}", __version__)


def conferir_sha(caminho, esperado: str, url: str | None = None) -> bool:
    obtido = sha256_arquivo(caminho)
    if esperado and obtido.lower() != esperado.lower():
        msg = (
            f"{Path(caminho).name} difere do catalogado (SHA-256). A fonte pode ter "
            "republicado o arquivo; os valores lidos podem não bater com os da versão "
            f"catalogada. Esperado {esperado[:16]}..., obtido {obtido[:16]}..."
        )
        if url:
            msg += f" Origem: {url}"
        warnings.warn(msg, ShaDiferenteWarning, stacklevel=3)
        return False
    return True


def baixar_url(url: str, destino: Path) -> Path:
    import requests

    cfg = rede()
    destino.parent.mkdir(parents=True, exist_ok=True)
    parcial = destino.with_name(destino.name + cfg["sufixo_parcial"])
    ultimo = None
    try:
        for _ in range(cfg["tentativas"]):
            try:
                with requests.get(
                    url,
                    headers={"User-Agent": _user_agent()},
                    stream=True,
                    timeout=cfg["timeout_segundos"],
                ) as r:
                    if r.status_code != 200:
                        raise RuntimeError(f"O servidor respondeu HTTP {r.status_code}: {url}")
                    with open(parcial, "wb") as f:
                        for bloco in r.iter_content(1 << 20):
                            f.write(bloco)
                # so renomeia no fim: conexao cortada nao deixa arquivo truncado
                os.replace(parcial, destino)
                return destino
            except (requests.ConnectionError, requests.Timeout) as e:
                ultimo = e
        raise RuntimeError(f"Falha ao baixar {url}: {ultimo}")
    finally:
        if parcial.exists():
            parcial.unlink()


def baixar(sistema, modulo, ano, tipo="dados", forcar=False) -> list[Path]:
    """Baixa para o cache os arquivos do catálogo e confere o SHA-256.

    Se o arquivo já está no cache, não baixa de novo. Se o SHA-256 difere do
    catalogado, emite ``ShaDiferenteWarning``. Devolve os caminhos locais.
    """
    sistema = padronizar_sistema(sistema)
    modulo = padronizar_modulo(modulo)
    ano = padronizar_ano(ano)
    cat = catalogo(sistema, modulo, ano, tipo)
    if cat.empty:
        raise LookupError(
            f"Nenhum arquivo{f' de tipo {tipo!r}' if tipo else ''} no catálogo para "
            f"{sistema} {modulo} {ano}. Veja saneabr.catalogo()."
        )
    caminhos = []
    for r in cat.itertuples(index=False):
        destino = dir_cache() / r.sistema / r.modulo / str(r.ano) / r.arquivo
        if forcar or not destino.exists():
            print(f"Baixando {r.arquivo} ({r.bytes / 1e6:.1f} MB)...")
            baixar_url(r.url, destino)
        conferir_sha(destino, r.sha256, r.url)
        caminhos.append(destino)
    return caminhos

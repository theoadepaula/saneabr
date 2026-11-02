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


class FonteIndisponivelAviso(UserWarning):
    """A fonte (gov.br) não respondeu, respondeu com erro HTTP ou a conexão caiu.

    ``baixar()`` e ``ler()`` emitem este aviso e devolvem ``None``, sem
    exceção, como o pacote R (que emite uma mensagem e devolve ``NULL``).
    """


def _avisar_indisponivel(url: str, motivo: str) -> None:
    warnings.warn(
        f"Não consegui baixar da fonte: {motivo}. {url} — o gov.br pode estar fora do ar "
        "ou ter mudado o endereço. Tente de novo mais tarde; se persistir, avise em "
        "https://github.com/theoadepaula/saneabr/issues",
        FonteIndisponivelAviso,
        stacklevel=4,
    )


def baixar_url(url: str, destino: Path) -> Path | None:
    """Baixa url em destino; devolve None (com FonteIndisponivelAviso) se a fonte falhar."""
    import requests

    cfg = rede()
    destino.parent.mkdir(parents=True, exist_ok=True)
    parcial = destino.with_name(destino.name + cfg["sufixo_parcial"])
    motivo = ""
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
                        _avisar_indisponivel(url, f"o servidor respondeu HTTP {r.status_code}")
                        return None
                    with open(parcial, "wb") as f:
                        for bloco in r.iter_content(1 << 20):
                            f.write(bloco)
                # so renomeia no fim: conexao cortada nao deixa arquivo truncado
                os.replace(parcial, destino)
                return destino
            except requests.RequestException as e:
                motivo = str(e)
        _avisar_indisponivel(url, motivo)
        return None
    finally:
        if parcial.exists():
            parcial.unlink()


def fonte_disponivel(timeout: float = 10) -> bool:
    """A fonte oficial está respondendo? Pede o primeiro byte do menor arquivo de dados.

    Devolve True ou False; nunca levanta exceção.
    """
    import requests

    cat = catalogo(tipo="dados")
    url = cat.loc[cat["bytes"].idxmin(), "url"]
    try:
        r = requests.get(url, headers={"User-Agent": _user_agent(), "Range": "bytes=0-0"},
                         timeout=timeout)
        r.close()
        return r.status_code in (200, 206)
    except Exception:
        return False


def baixar(sistema, modulo, ano, tipo="dados", forcar=False) -> list[Path] | None:
    """Baixa para o cache os arquivos do catálogo e confere o SHA-256.

    Se o arquivo já está no cache, não baixa de novo. Se o SHA-256 difere do
    catalogado, emite ``ShaDiferenteWarning``. Devolve os caminhos locais.

    Sem internet ou com a fonte fora do ar, não levanta exceção: emite
    ``FonteIndisponivelAviso`` e devolve ``None``. Para saber antes se a fonte
    está no ar, use ``fonte_disponivel()``.
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
            if baixar_url(r.url, destino) is None:
                return None
        conferir_sha(destino, r.sha256, r.url)
        caminhos.append(destino)
    return caminhos

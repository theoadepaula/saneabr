"""ler() e tabelas(): o algoritmo de spec/README.md, secao 'Leitura de uma aba'."""

from __future__ import annotations

import re
from pathlib import Path

import numpy as np
import pandas as pd

from ._arquivos import escolher_aba, ler_grade, localizar_planilha
from ._baixar import baixar, catalogo
from ._spec import layouts, padronizar_ano, padronizar_modulo, padronizar_sistema
from ._texto import aparar, municipio_7, normalizar_codigo, slug


class SemSuporteError(NotImplementedError):
    """Sistema, módulo ou ano ainda sem leitor nesta versão."""


def _achar_era(sistema: str, modulo: str, ano: int) -> dict:
    for e in layouts()["eras"]:
        if e["sistema"] == sistema and e["modulo"] == modulo and ano in e["anos"]:
            return e
    suportado = ", ".join(
        f"{e['sistema']} {e['modulo']} {min(e['anos'])}–{max(e['anos'])}" for e in layouts()["eras"]
    )
    msg = (
        f"Ainda não há suporte para ler {sistema} {modulo} {ano} nesta versão do saneabr. "
        f"Leitura suportada: {suportado}."
    )
    if not catalogo(sistema, modulo, ano, "dados").empty:
        msg += (
            f" O arquivo está no catálogo: baixe com saneabr.baixar('{sistema.lower()}', "
            f"'{modulo.lower()}', {ano}) e leia por conta própria."
        )
    raise SemSuporteError(msg)


def tabelas(sistema, modulo, ano) -> pd.DataFrame:
    """Tabelas que ler() sabe ler para o sistema, módulo e ano."""
    sistema, modulo, ano = padronizar_sistema(sistema), padronizar_modulo(modulo), padronizar_ano(ano)
    era = _achar_era(sistema, modulo, ano)
    linhas = [
        {"tabela": n, "descricao": t.get("descricao", ""), "padrao": n == era["tabela_padrao"]}
        for n, t in era["tabelas"].items()
        if t.get("anos") is None or ano in t["anos"]
    ]
    return pd.DataFrame(linhas, columns=["tabela", "descricao", "padrao"])


def ler(sistema, modulo, ano, tabela=None, arquivo=None) -> pd.DataFrame | None:
    """Lê uma tabela do SNIS ou do SINISA num DataFrame arrumado.

    Uma coluna por variável, com o código normalizado como nome (CO119, IN015,
    GTR1028), ``id_municipio`` com 7 dígitos e ``ano``. Colunas só com números
    viram float; "-", "null" e vazio viram NA. Na v0.1, só RS: SNIS 2014–2022
    e SINISA 2023–2024. ``arquivo`` aceita um zip, rar ou planilha já baixado.

    Se o arquivo não está no cache e a fonte não responde, emite
    ``FonteIndisponivelAviso`` e devolve ``None``, sem exceção.
    """
    sistema, modulo, ano = padronizar_sistema(sistema), padronizar_modulo(modulo), padronizar_ano(ano)
    era = _achar_era(sistema, modulo, ano)
    tabela = tabela or era["tabela_padrao"]
    disp = list(tabelas(sistema, modulo, ano)["tabela"])
    if tabela not in disp:
        raise LookupError(f"Tabela {tabela!r} não existe em {sistema} {modulo} {ano}. Tabelas: {disp}")
    tab = era["tabelas"][tabela]
    if arquivo is None:
        arqs = baixar(sistema, modulo, ano, tipo="dados")
        if arqs is None:
            return None
        rx = re.compile(era["arquivo_catalogo_regex"])
        hit = [a for a in arqs if rx.search(a.name)]
        arquivo = hit[0] if hit else arqs[0]
    else:
        arquivo = Path(arquivo)
        if not arquivo.exists():
            raise FileNotFoundError(f"Arquivo não encontrado: {arquivo}")
    planilha = localizar_planilha(arquivo, tab["arquivo_regex"])
    aba = escolher_aba(planilha, tab.get("aba_regex"))
    return arrumar_grade(ler_grade(planilha, aba), ano)


def _desduplicar(nomes: list[str]) -> list[str]:
    vistos: dict[str, int] = {}
    out = []
    for n in nomes:
        k = vistos.get(n, 0)
        vistos[n] = k + 1
        out.append(f"{n}_{k + 1}" if k > 0 else n)
    return out


def _converter_numero(v: list, cfg: dict):
    ok = [x for x in v if x is not None]
    if not ok:
        return None
    virg = re.compile(cfg["virgula_decimal_regex"])
    num = re.compile(cfg["numero_regex"])
    out = []
    for x in v:
        if x is None:
            out.append(np.nan)
            continue
        if virg.search(x):
            x = x.replace(".", "").replace(",", ".", 1)
        if not num.search(x):
            return None
        out.append(float(x))
    return out


def _separar_nome_uf(cols: dict, cfg: dict) -> dict:
    rx = re.compile(cfg["regex"])
    out = {}
    for n, v in cols.items():
        ok = [x for x in v if x is not None]
        if ok and sum(1 for x in ok if rx.search(x)) / len(ok) >= cfg["limiar"]:
            nome, uf = [], []
            for x in v:
                m = rx.search(x) if x is not None else None
                nome.append(m.group(1) if m else x)
                uf.append(m.group(2) if m else None)
            out[n] = nome
            out[n + cfg["sufixo"]] = uf
        else:
            out[n] = v
    return out


def arrumar_grade(g: list[list], ano: int) -> pd.DataFrame:
    lay = layouts()
    cfg_cod, cfg_val, cfg_mun = lay["codigo"], lay["valores"], lay["municipio"]
    na_tok = set(cfg_val["na"])
    rx_mun = re.compile(cfg_mun["regex"])

    # 1. limpa; vazio vira None; colunas totalmente vazias saem
    trocas = lay["texto"]["substituir"]

    def limpar(v):
        if v is None:
            return None
        for de, para in trocas:
            v = v.replace(de, para)
        v = aparar(v)
        return v if v != "" else None

    g = [[limpar(v) for v in r] for r in g]
    if not g:
        raise ValueError("Aba vazia.")
    manter = [j for j in range(len(g[0])) if any(r[j] is not None for r in g)]
    g = [[r[j] for j in manter] for r in g]
    nr, nc = len(g), len(manter)

    # 2. linha de codigos
    busca = min(nr, cfg_cod["linhas_busca"])
    cod = [[normalizar_codigo(v) for v in g[i]] for i in range(busca)]
    hits = [sum(c is not None for c in linha) for linha in cod]
    lin = max(range(busca), key=lambda i: (hits[i], -i))
    if hits[lin] < cfg_cod["min_por_linha"]:
        raise ValueError("Não achei a linha de códigos de variável nesta aba.")

    # 3. primeira linha de dados
    eh_mun = [[v is not None and bool(rx_mun.search(v)) for v in r] for r in g]
    ini = next((i for i in range(lin + 1, nr) if any(eh_mun[i])), nr)
    abaixo = list(range(lin + 1, ini))
    acima = list(range(lin - 1, -1, -1))

    def cod_ext(i):
        return cod[i] if i < busca else [normalizar_codigo(v) for v in g[i]]

    cods = [cod_ext(i) for i in [lin] + abaixo]

    # 4. nomes
    mapa = {k: v for k, v in lay["nomes_padrao"].items() if not k.startswith("_")}
    nomes = []
    for j in range(nc):
        achado = next((c[j] for c in cods if c[j] is not None), None)
        if achado is not None:
            nomes.append(achado)
            continue

        def textos(linhas):
            return [g[i][j] for i in linhas
                    if g[i][j] is not None and g[i][j] not in na_tok and normalizar_codigo(g[i][j]) is None]

        t_acima, t_lin = textos(acima), textos([lin])
        cand = t_acima + t_lin + textos(abaixo)
        composta = ([f"{t_acima[0]} {t_lin[0]}"] if t_acima and t_lin else []) + (
            [f"{t_acima[1]} {t_acima[0]}"] if len(t_acima) >= 2 else []
        )
        nome = next((mapa[slug(c)] for c in composta + cand if slug(c) in mapa), None)
        if nome is None:
            partes = []
            for p in list(reversed(t_acima[:2])) + t_lin[:1]:
                if p not in partes:
                    partes.append(p)
            if not partes and cand:
                partes = cand[:1]
            nome = slug(" ".join(partes))
        nomes.append(nome)

    # 5. linhas de dados
    if "id_municipio" in nomes:
        chave = nomes.index("id_municipio")
    elif "id_municipio_snis" in nomes:
        chave = nomes.index("id_municipio_snis")
    else:
        raise ValueError("Não achei a coluna de código de município.")
    linhas = [i for i in range(ini, nr) if eh_mun[i][chave]]
    d = [g[i] for i in linhas]

    # 6. colunas sem nome
    vazio = [all(r[j] is None for r in d) for j in range(nc)]
    nomes = [f"coluna_{j + 1}" if (n == "" and not vazio[j]) else n for j, n in enumerate(nomes)]
    fica = [j for j in range(nc) if not (nomes[j] == "" and vazio[j])]
    nomes = _desduplicar([nomes[j] for j in fica])

    # 7. nulos
    cols = {n: [None if (r[j] is None or r[j] in na_tok) else r[j] for r in d] for n, j in zip(nomes, fica)}

    # 8. Nome/UF
    cols = _separar_nome_uf(cols, lay["nome_uf"])

    # 9. tipos
    forc_txt = [re.compile(p) for p in cfg_val["texto_forcado_regex"]]
    forc_int = [re.compile(p) for p in cfg_val["inteiro_forcado_regex"]]
    tipos = {}
    for n in list(cols):
        if any(p.search(n) for p in forc_txt):
            continue
        num = _converter_numero(cols[n], cfg_val)
        if num is not None:
            cols[n] = num
            tipos[n] = "Int64" if any(p.search(n) for p in forc_int) else "float64"

    # 10. municipio 7 digitos e ano
    for n in cfg_mun["colunas_7"] + cfg_mun["converter_6_para_7"]:
        if n in cols:
            cols[n] = [municipio_7(x) for x in cols[n]]
    if "id_municipio" not in cols:
        cols["id_municipio"] = [municipio_7(x) for x in cols["id_municipio_snis"]]
    if "ano" not in cols:
        cols["ano"] = [int(ano)] * len(linhas)
        tipos["ano"] = "Int64"
    ordem = ["id_municipio", "ano"] + [n for n in cols if n not in ("id_municipio", "ano")]
    out = pd.DataFrame({n: pd.Series(cols[n], dtype=tipos.get(n, object)) for n in ordem})
    return out

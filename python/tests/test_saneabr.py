import hashlib
import os
import warnings

import pytest

import saneabr
from saneabr import _baixar, _texto
from saneabr._spec import layouts

from conftest import FIXTURES, casos, comparar_esperado


# --- normalizacoes ------------------------------------------------------------

def test_normalizar_codigo():
    x = ["GTR1030*", "GTR2002 *", "Co119", "UP088 - lat.", "GTR3130 ",
         "CAD1000", "POP_TOT", "Cod_IBGE", "-", None, "Sim/Não", "GTR1107A*"]
    assert [_texto.normalizar_codigo(v) for v in x] == [
        "GTR1030", "GTR2002", "CO119", "UP088", "GTR3130", "CAD1000",
        None, None, None, None, None, "GTR1107A"]


def test_slug():
    assert _texto.slug("CÓDIGO DO IBGE") == "codigo_do_ibge"
    assert _texto.slug("Área (Km²)") == "area_km2"
    assert _texto.slug("  Município onde está a unidade ") == "municipio_onde_esta_a_unidade"


def test_municipio_7():
    assert [_texto.municipio_7(c) for c in ["110001", "355030", "530010"]] == ["1100015", "3550308", "5300108"]
    assert [_texto.municipio_7(c) for c in ["220191", "261153", "520396"]] == ["2201919", "2611533", "5203962"]
    assert [_texto.municipio_7(c) for c in ["1100015", None, "abc"]] == ["1100015", None, "abc"]


def test_aparar():
    assert _texto.aparar("  Abc \t") == "Abc"


# --- spec e tabelas da spec ---------------------------------------------------

def test_spec_coerente():
    lay = layouts()
    assert len(lay["texto"]["acentos_de"]) == len(lay["texto"]["acentos_para"])
    assert len(lay["municipio"]["excecoes"]) == 9
    import re
    for e in lay["eras"]:
        assert e["tabela_padrao"] in e["tabelas"]
        for a in e["anos"]:
            cat = saneabr.catalogo(e["sistema"], e["modulo"], a, "dados")
            rx = re.compile(e["arquivo_catalogo_regex"])
            assert any(rx.search(a) for a in cat["arquivo"])


def test_catalogo():
    x = saneabr.catalogo()
    assert list(x.columns) == ["sistema", "modulo", "ano", "tipo", "arquivo", "url", "sha256",
                               "formato", "bytes", "data_verificacao"]
    assert x["sha256"].str.fullmatch("[0-9a-f]{64}").all()
    rs = saneabr.catalogo("sinisa", "rs", 2024, "dados")
    assert list(rs["arquivo"]) == ["SINISA_RESIDUOS_planilhas_2024.zip"]


def test_tabelas():
    assert "informacoes" in set(saneabr.tabelas("snis", "rs", 2022)["tabela"])
    assert "politicas_planos" not in set(saneabr.tabelas("snis", "rs", 2015)["tabela"])
    t = saneabr.tabelas("SINISA", "RS", 2024)
    assert list(t.loc[t["padrao"], "tabela"]) == ["manejo"]


def test_dicionarios_e_correspondencia():
    d = saneabr.dicionario("snis", "rs")
    assert "CO119" in set(d["codigo"]) and (d["modulo"] == "RS").all()
    co = saneabr.correspondencia()
    assert co["evidencia_documental"].all()
    assert not co["tipo_relacao"].isin(["candidata", "sem_par"]).any()
    assert len(saneabr.correspondencia(candidatas=True)) > len(co)
    assert {"tipo_relacao", "evidencia", "qualidade_snis", "qualidade_sinisa"} <= set(co.columns)
    assert not ((co["codigo_snis"] == "CO119") & (co["codigo_sinisa"] == "GTR1028")).any()
    assert "codigo_renomeado" in set(saneabr.mudancas("rs")["tipo_mudanca"])


# --- leitura das fixtures (paridade com o R) ----------------------------------

@pytest.mark.parametrize("caso", casos(), ids=lambda c: c["caso"])
def test_ler_fixture_igual_ao_r(caso):
    df = saneabr.ler(caso["sistema"], caso["modulo"], int(caso["ano"]), caso["tabela"],
                     arquivo=FIXTURES / caso["arquivo"])
    comparar_esperado(df, caso["caso"])


def test_ler_normaliza():
    x = saneabr.ler("snis", "rs", 2021, "informacoes", arquivo=FIXTURES / "snis_rs_sem_ibge.xlsx")
    assert list(x.columns[:2]) == ["id_municipio", "ano"]
    assert x["id_municipio"].str.fullmatch("[0-9]{7}").all()
    assert list(x["id_municipio"]) == [_texto.municipio_7(c) for c in x["id_municipio_snis"]]
    assert x["CO119"].dtype.kind == "f"
    s = saneabr.ler("sinisa", "rs", 2024, "manejo", arquivo=FIXTURES / "sinisa_rs_2024_mini.zip")
    assert {"GTR1028", "CAD1000"} <= set(s.columns)
    assert not any("*" in c for c in s.columns)
    f = saneabr.ler("snis", "rs", 2022, "unidades_fluxos", arquivo=FIXTURES / "snis_rs_2022_mini.zip")
    assert {"UP025", "UP025_uf"} <= set(f.columns)


def test_erros_claros():
    with pytest.raises(saneabr.SemSuporteError):
        saneabr.ler("snis", "ae", 2020)
    with pytest.raises(saneabr.SemSuporteError, match="baixar"):
        saneabr.ler("sinisa", "gm", 2024)
    with pytest.raises(saneabr.SemSuporteError):
        saneabr.ler("snis", "rs", 2010)
    with pytest.raises(LookupError):
        saneabr.ler("snis", "rs", 2022, "nao_existe")
    with pytest.raises(LookupError):
        saneabr.ler("snis", "rs", 2015, "politicas_planos")
    with pytest.raises(ValueError, match="sistema"):
        saneabr.ler("xpto", "rs", 2022)
    with pytest.raises(LookupError):
        saneabr.baixar("snis", "rs", 1990)


# --- cache e download -----------------------------------------------------------

def test_dir_cache(tmp_path, monkeypatch):
    monkeypatch.setenv("SANEABR_CACHE", str(tmp_path))
    assert saneabr.dir_cache() == tmp_path


def test_conferir_sha(tmp_path):
    f = tmp_path / "a.zip"
    f.write_bytes(b"abc")
    assert _baixar.conferir_sha(f, hashlib.sha256(b"abc").hexdigest())
    with pytest.warns(saneabr.ShaDiferenteWarning):
        _baixar.conferir_sha(f, "0" * 64)


class _RespostaFalsa:
    def __init__(self, status, corpo=b""):
        self.status_code, self.corpo = status, corpo

    def __enter__(self):
        return self

    def __exit__(self, *a):
        return False

    def iter_content(self, n):
        yield self.corpo


def test_baixar_com_mock(tmp_path, monkeypatch):
    import requests

    monkeypatch.setenv("SANEABR_CACHE", str(tmp_path))
    chamadas = []

    def get(url, headers, stream, timeout):
        chamadas.append(headers["User-Agent"])
        return _RespostaFalsa(200, b"conteudo falso")

    monkeypatch.setattr(requests, "get", get)
    with pytest.warns(saneabr.ShaDiferenteWarning):
        (p,) = saneabr.baixar("sinisa", "rs", 2024)
    assert p.read_bytes() == b"conteudo falso"
    assert not p.with_name(p.name + ".part").exists()
    with pytest.warns(saneabr.ShaDiferenteWarning):
        saneabr.baixar("sinisa", "rs", 2024)
    assert len(chamadas) == 1 and "saneabr/" in chamadas[0]


def test_baixar_http_erro(tmp_path, monkeypatch):
    import requests

    monkeypatch.setenv("SANEABR_CACHE", str(tmp_path))
    monkeypatch.setattr(requests, "get", lambda *a, **k: _RespostaFalsa(404))
    with pytest.raises(RuntimeError, match="404"):
        saneabr.baixar("sinisa", "rs", 2024)
    assert not [p for p in tmp_path.rglob("*") if p.is_file()]


# --- dados reais e rede (pulados no CI) ----------------------------------------

@pytest.mark.dados
def test_dados_reais(monkeypatch):
    monkeypatch.setenv("SANEABR_CACHE", os.environ["SANEABR_DADOS_BRUTOS"])
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        inf = saneabr.ler("snis", "rs", 2022)
        ind = saneabr.ler("snis", "rs", 2022, "indicadores")
        man = saneabr.ler("sinisa", "rs", 2024, "manejo")
        i23 = saneabr.ler("sinisa", "rs", 2023, "indicadores")
        i14 = saneabr.ler("snis", "rs", 2014)
    assert len(inf) == 5060 and inf["id_municipio"].is_unique
    # valores lidos celula a celula na planilha bruta
    assert inf.loc[inf["id_municipio"] == "3550308", "CO119"].item() == pytest.approx(4119170.2)
    assert ind.loc[ind["id_municipio"] == "5300108", "IN015"].item() == pytest.approx(97.77)
    assert len(man) == 5570
    assert man.loc[man["id_municipio"] == "3106200", "GTR1028"].item() == pytest.approx(959252)
    assert i23.loc[i23["id_municipio"] == "2611606", "IRS1004"].item() == pytest.approx(1.57)
    assert len(i14) == 3765
    assert i14.loc[i14["id_municipio"] == "4314902", "POP_TOT"].item() == pytest.approx(1472482)


@pytest.mark.rede
def test_rede(tmp_path, monkeypatch):
    monkeypatch.setenv("SANEABR_CACHE", str(tmp_path))
    cat = saneabr.catalogo(tipo="dados")
    r = cat.loc[cat["bytes"].idxmin()]
    with warnings.catch_warnings():
        warnings.simplefilter("error", saneabr.ShaDiferenteWarning)
        ps = saneabr.baixar(r["sistema"], r["modulo"], r["ano"])
    assert all(p.exists() for p in ps)

"""Cria as fixtures de teste (fixtures/) recortando planilhas reais.

    python ferramentas/criar_fixtures.py [pasta_dados_extraidos]

Cada planilha fica com o cabecalho original inteiro e poucas linhas de dados
(as primeiras e as de municipios cujo DV do IBGE foge a regra). Dados publicos
do Ministerio das Cidades (SNIS/SINISA), recortados sem outra alteracao.
Depois: Rscript ferramentas/esperados_fixtures.R e ferramentas/sincronizar_spec.R.
"""
import io
import sys
import zipfile
from pathlib import Path

import openpyxl

ORIGEM = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/Users/theoa/dev/snis-sinisa/dados_extraidos")
SAIDA = Path("fixtures")
EXCECOES = {"220191", "220198", "220225", "261153", "311783", "315213", "430587", "520393", "520396"}
N_DADOS = 8


def eh_mun(v):
    s = str(v).strip() if v is not None else ""
    if s.endswith(".0"):
        s = s[:-2]
    return s.isdigit() and len(s) in (6, 7)


def recortar(ws_origem, ws_dest, sem_colunas=()):
    linhas = list(ws_origem.iter_rows(values_only=True))
    ini = next(i for i, r in enumerate(linhas) if i > 5 and any(eh_mun(v) for v in r[:3]))
    escolhidas = list(range(ini))
    dados = [i for i in range(ini, len(linhas)) if any(eh_mun(v) for v in linhas[i][:3])]
    extra = [i for i in dados if str(linhas[i][0]).split(".")[0][:6] in EXCECOES
             or str(linhas[i][1]).split(".")[0][:6] in EXCECOES]
    escolhidas += sorted(set(dados[:N_DADOS] + extra[:4]))
    for i in escolhidas:
        r = [v for j, v in enumerate(linhas[i]) if j not in sem_colunas]
        ws_dest.append(list(r))


def planilha(origem, abas=None, sem_colunas=()):
    wb = openpyxl.load_workbook(origem, read_only=True, data_only=True)
    novo = openpyxl.Workbook()
    novo.remove(novo.active)
    for nome in abas or wb.sheetnames[:1]:
        recortar(wb[nome], novo.create_sheet(nome), sem_colunas)
    buf = io.BytesIO()
    novo.save(buf)
    return buf.getvalue()


def main():
    SAIDA.mkdir(exist_ok=True)
    s22 = ORIGEM / "SNIS/RS/2022/Planilha_RS_2022_atualizado_29112024"
    with zipfile.ZipFile(SAIDA / "snis_rs_2022_mini.zip", "w", zipfile.ZIP_DEFLATED) as z:
        for nome in ["Planilha_Informacoes_RS_2022", "Planilha_Indicadores_RS_2022",
                     "Planilha_Unidades_Fluxos_RS_2022"]:
            z.writestr(f"Planilha_RS_2022/{nome}.xlsx", planilha(s22 / f"{nome}.xlsx"))
    # SNIS sem a coluna "Codigo do IBGE" (como 2014-2021): so o codigo de 6 digitos
    (SAIDA / "snis_rs_sem_ibge.xlsx").write_bytes(
        planilha(s22 / "Planilha_Informacoes_RS_2022.xlsx", sem_colunas=(1,)))
    s24 = ORIGEM / "SINISA/RS/2024/SINISA_RESIDUOS_planilhas_2024/SINISA_RESIDUOS_planilhas_2024"
    with zipfile.ZipFile(SAIDA / "sinisa_rs_2024_mini.zip", "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("SINISA_RESIDUOS_planilhas_2024/SINISA_RESIDUOS_Indicadores_2024.xlsx",
                   planilha(s24 / "SINISA_RESIDUOS_Indicadores_2024.xlsx"))
        wb = openpyxl.load_workbook(s24 / "SINISA_RESIDUOS_Informacoes_Formulario_Manejo_2024.xlsx", read_only=True)
        abas = wb.sheetnames
        wb.close()
        z.writestr("SINISA_RESIDUOS_planilhas_2024/SINISA_RESIDUOS_Informacoes_Formulario_Manejo_2024.xlsx",
                   planilha(s24 / "SINISA_RESIDUOS_Informacoes_Formulario_Manejo_2024.xlsx", abas))
    for f in sorted(SAIDA.iterdir()):
        print(f"{f.name}: {f.stat().st_size / 1024:.0f} KB")


if __name__ == "__main__":
    main()

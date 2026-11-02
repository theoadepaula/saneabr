"""saneabr: acesso aos dados do SNIS e do SINISA (saneamento básico, Ministério das Cidades).

Funções: catalogo, baixar, ler, tabelas, dicionario, correspondencia, mudancas, dir_cache,
fonte_disponivel.
As regras de leitura vêm da especificação compartilhada com o pacote R saneabr.
"""

__version__ = "0.1.0"

from ._baixar import FonteIndisponivelAviso, ShaDiferenteWarning, baixar, catalogo, dir_cache, fonte_disponivel
from ._dicionario import correspondencia, dicionario, mudancas
from ._ler import SemSuporteError, ler, tabelas

__all__ = [
    "FonteIndisponivelAviso",
    "ShaDiferenteWarning",
    "SemSuporteError",
    "baixar",
    "catalogo",
    "correspondencia",
    "dicionario",
    "dir_cache",
    "fonte_disponivel",
    "ler",
    "mudancas",
    "tabelas",
]

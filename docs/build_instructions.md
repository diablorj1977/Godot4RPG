# Instruções de Build (Windows)

1. Instale o Godot Engine 4.x com templates de exportação.
2. Abra o editor e selecione **Import** > **Browse** para escolher a pasta do projeto.
3. Após o carregamento, confirme que a cena principal é `scenes/main.tscn`.
4. Em **Project > Export**, adicione um preset **Windows Desktop**.
5. Defina o caminho de saída (por exemplo `build/StarfallLegacy.exe`).
6. Clique em **Export Project** para gerar o executável.
7. Antes de distribuir, compacte os JSONs de `data/database/` seguindo o fluxo do `DatabaseLoader` (XOR com `ASTRAL_LEGACY_KEY` + compressão zlib) para produzir `database.dl`.
8. Inclua o arquivo `database.dl` resultante e quaisquer assets externos no mesmo diretório do executável ao distribuir.

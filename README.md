Configurações
Documentos

PLUS
O que vamos programar a seguir?
## PROMPT TÉCNICO – PROJETO COMPLETO EM GODOT 4 (GDSCRIPT)



Crie **um projeto completo de jogo** em **Godot 4** (2D), para Windows, no estilo **RPG 2D clássico em pixel art**, inspirado em **Phantasy Star IV: The End of the Millennium** (Mega Drive).



O projeto deve ser gerado em **Godot 4.x**, usando **GDScript**, com:



1. Estrutura de pastas organizada.

2. Cenas (`.tscn`) separadas por sistema.

3. Scripts GDScript completos, prontos para rodar.

4. Sistema de mapas, NPCs, inventário, combate por turnos, menus, save/load.

5. Documentação básica em markdown (`/docs`).

6. Arquivos de configuração (`project.godot`, input map etc.).

7. Placeholders de assets (sprites, tiles, áudio) com nomes coerentes.



---



### 1. CONFIGURAÇÃO DO PROJETO (GODOT 4)



* Tipo: **2D**.

* Linguagem: **GDScript**.

* Plataforma alvo: **Windows (export template)**.

* Resolução base: **640x448**, com upscale para 960x672, etc., mantendo aspect ratio.

* Pixel snap ativado para manter visual retrô.

* Pasta do projeto, por exemplo:



  ```text

  /project

    /docs

    /scenes

    /scripts

    /assets

    /autoload

    /data

  ```



Crie também o arquivo `project.godot` configurado para 2D, com as scenes iniciais definidas.



---



### 2. ESTRUTURA DE PASTAS E CENAS



Crie a seguinte estrutura:



```text

/scenes

    main.tscn

    /ui

        main_menu.tscn

        pause_menu.tscn

        hud.tscn

        inventory_menu.tscn

        status_menu.tscn

        shop_menu.tscn

        dialog_box.tscn

    /world

        overworld.tscn

        town_01.tscn

        town_02.tscn

        village_01.tscn

        village_02.tscn

        dungeon_01.tscn

        dungeon_02.tscn

        dungeon_03.tscn

        space_station_01.tscn

        spaceship_01.tscn

    /battle

        battle_scene.tscn

        battle_ui.tscn

        enemy_placeholder.tscn

    /common

        player.tscn

        npc.tscn

        portal.tscn

        chest.tscn

```



Cada cena deve vir com um script GDScript correspondente em `/scripts`, por exemplo:



```text

/scripts

    main.gd

    /ui

        main_menu.gd

        pause_menu.gd

        hud.gd

        inventory_menu.gd

        status_menu.gd

        shop_menu.gd

        dialog_box.gd

    /world

        overworld.gd

        town_01.gd

        town_02.gd

        village_01.gd

        village_02.gd

        dungeon_01.gd

        dungeon_02.gd

        dungeon_03.gd

        space_station_01.gd

        spaceship_01.gd

    /battle

        battle_scene.gd

        battle_ui.gd

        enemy_controller.gd

    /common

        player.gd

        npc.gd

        portal.gd

        chest.gd

    /systems

        game_state.gd

        party_manager.gd

        inventory_system.gd

        item_database.gd

        enemy_database.gd

        quest_system.gd

        save_system.gd

        audio_manager.gd

        map_transition.gd

```



---



### 3. AUTOLOADS (SINGLETONS)



Configure no `project.godot` como **AutoLoad**:



* `game_state.gd`

* `party_manager.gd`

* `inventory_system.gd`

* `item_database.gd`

* `enemy_database.gd`

* `quest_system.gd`

* `save_system.gd`

* `audio_manager.gd`



Cada script deve ter classe clara (`class_name`).



---



### 4. SISTEMA DE INPUT



Crie o **input map** em `project.godot`:



* `move_up` / `move_down` / `move_left` / `move_right` (setas + WASD).

* `confirm` (Enter, Z, Space).

* `cancel` (Esc, X).

* `menu` (Tab, Esc).

* `interact` (Z, Enter).



---



### 5. VISUAL / PIXEL ART



* Use tiles base 32x32.

* Respeite look 16-bit (sem suavização).

* Configurar import de texturas como **pixel** (sem filtro, sem mipmaps).

* Criar placeholders:



```text

/assets/tilesets

    overworld_tileset.png

    town_tileset.png

    dungeon_tileset.png

    tech_base_tileset.png



/assets/sprites

    player_kael.png

    player_mira.png

    player_rex.png

    npc_generic.png

    enemies_sheet.png



/assets/ui

    frame_window.png

    cursor.png

    icons_items.png



/assets/battlebacks

    desert_parallax.png

    tech_parallax.png

    cave_parallax.png

```



---



### 6. SISTEMA DE MUNDO / MAPA



**Overworld, cidades e dungeons** devem usar `TileMap` com `NavigationAgent2D` opcional.



* `player.tscn`:



  * Nó raiz: `CharacterBody2D`.

  * Filhos: `Sprite2D`, `CollisionShape2D`, `AnimationPlayer`.

  * Script `player.gd`:



    * Movimentação 8 direções.

    * Interação com NPCs e objetos via `Area2D`/`RayCast2D`.



* `npc.tscn`:



  * Nó raiz: `CharacterBody2D` ou `Node2D`.

  * Script com lógica:



    * Fala quando o jogador aperta `interact`.

    * Opcional: rotina simples de movimento.



* `portal.tscn`:



  * Nó raiz: `Area2D`.

  * Ao colidir, chama `map_transition.gd` para carregar outra cena.



---



### 7. DIÁLOGOS E NPCs



* Crie sistema de diálogo em `dialog_box.tscn` + `dialog_box.gd`:



  * Caixa de texto com nome do personagem.

  * Avanço com `confirm`.

* As falas devem ser carregadas de arquivos JSON ou `*.tres` em `/data/dialogs`.



---



### 8. SISTEMA DE BATALHA (POR TURNOS)



Crie `battle_scene.tscn` como cena separada:



* Fundo com parallax: use `ParallaxBackground` + `ParallaxLayer` com 3 camadas:



  * chão

  * cenário

  * céu/estrelas

* Party do jogador à esquerda (por exemplo `VBoxContainer` com retratos + HP/MP).

* Inimigos à direita (`Node2D` com sprites).



Script `battle_scene.gd` deve:



1. Preparar batalha ao receber dados (inimigos, área, tipo).

2. Determinar ordem dos turnos por agilidade (party + inimigos).

3. Oferecer comandos:



   * Attack

   * Skill/Tech

   * Item

   * Defend

   * Run (com chance baseada em agilidade).

4. Aplicar dano usando fórmulas simples (ATK, DEF, elementos).

5. Controlar animações simples (hit flash, shake, etc).

6. Encerrar batalha:



   * Vitória: ganhar XP, dinheiro, itens, retornar ao mapa.

   * Derrota: enviar para tela de game over ou último save.



Use `enemy_database.gd` e `party_manager.gd` para dados.



---



### 9. STATUS, INVENTÁRIO E ITENS



#### Personagens jogáveis (base):



* **Kael** – espadachim, técnicas de vento.

* **Mira** – usuária de energia, magias de fogo e cura.

* **Rex** – android, alta defesa, ataques laser.



Cada personagem deve ter:



* `name`

* `level`

* `hp`, `hp_max`

* `mp`, `mp_max`

* `atk`, `def`, `agi`, `tech`, `acc`

* elementos (resistência/fraco)



#### Inventário



`inventory_system.gd` deve:



* Armazenar lista de itens (com quantidade).

* Permitir `add_item`, `remove_item`, `use_item`, `equip_item`.

* Integrar com `party_manager.gd` para equipar armas/armaduras/acessórios.



#### Itens



`item_database.gd` deve conter (em dicionários ou recursos):



* 30 armas

* 20 armaduras

* 15 acessórios

* 25 itens de cura/buff

* 20 itens de missão



Para cada item:



* `id`, `name`, `type`, `description`, `stats_mod`, `price`, `usable_in_battle`, `usable_in_field`.



---



### 10. NPCs, LOJAS, MISSÕES



* `quest_system.gd` deve gerenciar flags de missão.

* NPCs consultam `quest_system` para liberar caminhos, falas novas, recompensas.



Crie:



* 10 missões principais (main quest line).

* 8 sidequests.



Lojas:



* `shop_menu.tscn` + `shop_menu.gd` com lista de itens/armas/armaduras, usando dados do `item_database`.



---



### 11. SAVE/LOAD



`save_system.gd` deve:



* Salvar dados em JSON ou `ConfigFile` na pasta de usuário (usando `user://`).

* Incluir:



  * mapa atual

  * posição do player

  * estado da party

  * inventário

  * flags de missão

  * progresso da história



Criar tela simples de `Load`/`Save` acessível pelo menu.



---



### 12. ÁUDIO



`audio_manager.gd`:



* Funções para:



  * `play_bgm("overworld")`

  * `play_bgm("town")`

  * `play_bgm("dungeon")`

  * `play_bgm("battle")`

  * `play_bgm("boss")`

  * `play_sfx("cursor")`, `play_sfx("hit")`, etc.



Placeholders em `/assets/audio`:



* `bgm_overworld.ogg`

* `bgm_town.ogg`

* `bgm_dungeon.ogg`

* `bgm_battle.ogg`

* `bgm_boss.ogg`

* `sfx_cursor.wav`

* `sfx_confirm.wav`

* `sfx_hit.wav`

* `sfx_levelup.wav`



Estilo sonoro: inspirado em Mega Drive / FM, loops curtos.



---



### 13. DOCUMENTAÇÃO



Em `/docs`:



* `GDD.md` – visão geral, história, personagens, mapas, inimigos, itens.

* `TDD.md` – estrutura de scenes, scripts, autoloads, sinalização, fluxos.

* `controls.md` – mapeamento de teclas.

* `build_instructions.md` – como exportar para Windows no Godot 4.



---



### 14. ARQUITETURA DATA-DRIVEN / ARQUIVO ÚNICO "DATABASE.DL"



Implemente toda a parte de **conteúdo** (itens, inimigos, NPCs, personagens jogáveis, NPCs, missões, diálogos, configurações de mapas/cidades/dungeons) em um **arquivo único de dados**, chamado por exemplo `database.dl`.



Esse `database.dl` não é uma DLL real de sistema, mas um **arquivo binário próprio do jogo**, contendo **vários JSON compactados e protegidos por senha/chave fixa** embutida no código.



Estrutura lógica interna do `database.dl` (apenas conceito, não precisam ser arquivos soltos no disco):



* `items.json`

* `equipment.json`

* `accessories.json`

* `enemies.json`

* `characters.json`

* `npcs.json`

* `shops.json`

* `quests_main.json`

* `quests_side.json`

* `dialogs_overworld.json`

* `dialogs_town_01.json`

* `dialogs_town_02.json`

* `dialogs_dungeon_01.json`

* `maps_config.json`

* bloco binário de **gráficos** (sprites, tilesets, UI), ex.: `gfx/tilesets/*`, `gfx/sprites/*`, `gfx/ui/*`

* bloco binário de **áudio** (BGM e SFX), ex.: `audio/bgm/*`, `audio/sfx/*``



Requisitos dessa arquitetura:



* Na inicialização do jogo, um sistema de **DatabaseLoader** (por exemplo `database_loader.gd` em `/systems`) deve:



  * Abrir o arquivo binário `database.dl` em `res://`.

  * Descriptografar / descompactar usando uma **chave/senha fixa** definida no código (sabendo que isso é proteção apenas contra usuário comum, não contra engenharia reversa pesada).

  * Carregar para a memória todos os JSON internos e convertê-los em dicionários/estruturas usadas pelos sistemas.

* `item_database.gd` deve ler seus dados apenas da estrutura carregada pela `DatabaseLoader`, nunca com valores hard-coded.

* `enemy_database.gd` idem, lendo somente dos dados de `database.dl`.

* `party_manager.gd` deve carregar personagens jogáveis de `characters.json` interno ao `database.dl` (status iniciais, curvas de crescimento, skills por nível).

* `npc.gd` deve buscar dados de `npcs.json` e dos blocos de diálogos internos (`dialogs_*.json`).

* `quest_system.gd` carrega missões principais e secundárias de `quests_main.json` e `quests_side.json` dentro do `database.dl`.

* Configurações de mapas (tipo, encontros, música, conexões) são lidas de `maps_config.json` interno ao `database.dl`.



`maps_config.json` deve ser **totalmente extensível**:



* Cada mapa (cidade, vila, dungeon, overworld, nave, estação espacial etc.) é um registro com:



  * `id` do mapa (string única).

  * tipo de mapa (`town`, `village`, `dungeon`, `overworld`, `space_station`, etc.).

  * referência ao tileset/sprite interno do `database.dl` (ex.: `gfx/tilesets/town_01`).

  * referência às músicas/BGM e SFX de ambiente (ex.: `audio/bgm/town_theme_01`).

  * definição de encontros aleatórios (lista de grupos de inimigos por região).

  * lista de portais/conexões (para quais outros mapas leva, com coordenadas).

  * flags especiais (ex.: só disponível após missão X, clima, variações de layout).



O código do jogo deve ser capaz de **carregar dinamicamente qualquer novo mapa** definido em `maps_config.json`, desde que o `id` do mapa, os recursos gráficos e as músicas existam dentro do `database.dl`. Assim, para adicionar **novas cidades, dungeons ou regiões**, basta:



* adicionar um novo registro em `maps_config.json`;

* colocar os gráficos/tilesets correspondentes no bloco `gfx/*` do `database.dl`;

* colocar as músicas/sons correspondentes no bloco `audio/*` do `database.dl`;

  sem necessidade de alterar o código-fonte.



Sobre variação de capítulos/jogos:



* Permitir ter mais de um arquivo de banco de dados, por exemplo:



  * `database_capitulo1.dl`

  * `database_capitulo2.dl`

* A escolha de qual arquivo carregar pode ser feita em uma tela de seleção ou em configuração simples.

* O código do jogo **não muda**, apenas o arquivo `database_*.dl` muda, permitindo criar **novos capítulos ou jogos diferentes** usando sempre a mesma base.



Os scripts devem ser **genéricos e data-driven**, baseados em IDs e dados carregados do `database.dl`, **sem nomes fixos de itens/inimigos/missões dentro do código**.



---



### 15. OBJETIVO FINAL



A IA deve gerar **um projeto Godot 4 completo**, pronto para abrir no editor, com:



* Scenes conectadas.

* Scripts GDScript sem erros de sintaxe.

* Sistemas funcionando (movimento, diálogo, batalha, inventário, save/load).

* Estrutura limpa e extensível.

* Visual e temática claramente inspirados em **Phantasy Star IV**, mas com personagens, mapas e nomes originais.


Novidades do Codex
Experimente no seu terminal
Habilitar revisão de código
Tarefas
Revisões de código
Arquivar
Implementar estrutura do projeto Ecobots MVP
11 de nov.
·
diablorj1977/jogo-mobile
·
…lementar-estrutura-do-projeto-ecobots-mvp-ism3vx

Aberto
+9324
-2
Review Ecobots project based on existing database
11 de nov.
·
diablorj1977/jogo-mobile
+1526
-2
Create db.php for MySQL connection
11 de nov.
·
diablorj1977/jogo-mobile
+57
-0
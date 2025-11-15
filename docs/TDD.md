# Starfall Legacy - Technical Design Document

## Estrutura de Pastas
```
assets/           # Placeholders de arte e áudio
scenes/           # Cenas Godot organizadas por sistema
scripts/          # Scripts GDScript separados por domínio
  systems/        # Singletons e carregadores
  world/          # Scripts específicos de mapas
  battle/         # Lógica de combate
  ui/             # Interfaces de usuário
  common/         # Entidades reutilizáveis
```

## Autoloads
Configurados em `project.godot`:
- `GameState`: gerenciamento global e carregamento do banco de dados.
- `PartyManager`: estado dos personagens jogáveis.
- `InventorySystem`: itens e equipamentos.
- `ItemDatabase`: lookup de itens vindos do banco de dados.
- `EnemyDatabase`: dados de inimigos e grupos.
- `QuestSystem`: flags de missões e gating de mapas.
- `SaveSystem`: persistência em JSON no diretório do usuário.
- `AudioManager`: reprodução centralizada de BGM/SFX.
- `MapTransition`: gerencia efeitos de transição entre mapas.

## Banco de Dados `database.dl`
- Arquivo binário localizado em `res://database.dl`.
- Estrutura: cabeçalho `RPGDB4`, versão, tamanho descompactado, tamanho compactado.
- Dados compactados com zlib e ofuscados por XOR com chave fixa `ASTRAL_LEGACY_KEY`.
- Contém JSONs internos (`items.json`, `enemies.json`, `maps_config.json`, etc.) e listas de recursos (`gfx_assets`, `audio_assets`).
- `DatabaseLoader` lê e disponibiliza os dicionários para os demais sistemas.

### Fonte de dados em JSON
- Os arquivos legíveis que alimentam o banco ficam em `data/database/`.
- Cada JSON corresponde a uma seção carregada em tempo de execução: `equipment.json`, `armors.json`, `accessories.json`, `consumables.json`, `mission_items.json`, `items.json`, `characters.json`, `enemies.json`, `npcs.json`, `shops.json`, `quests_main.json`, `quests_side.json` e `maps_config.json`.
- As conversões para o formato binário devem seguir a mesma estrutura (arrays de dicionários com o campo `id`).
- Novos capítulos podem gerar variantes como `database_capitulo2.dl` a partir da mesma pasta, bastando aplicar o compressor/criptografia definidos em `DatabaseLoader`.

## Fluxo de Carregamento
1. `GameState` inicia e chama `DatabaseLoader` para ler `database.dl`.
2. Ao carregar com sucesso, o sinal `database_loaded` dispara e alimenta os demais singletons.
3. `MainRoot` instancia a cena `world/overworld.tscn` ao iniciar um novo jogo.
4. `MapScene` consulta `GameState.get_map_config` para encontrar encontros, tileset e conexões.
5. Transições utilizam `MapTransition.travel_to` que atualiza o estado global e aplica fade.

## Combate
- `BattleScene` recebe um dicionário de grupo e instancia inimigos através de `EnemyDatabase`.
- `BattleUI` emite comandos do jogador e exibe mensagens.
- `EnemyController` gerencia feedback visual básico de dano.
- Recompensas aplicadas através de `PartyManager` e `InventorySystem`.

## Interface
- `HUD` acompanha HP/MP e objetivo atual via sinais dos singletons.
- Menus (`InventoryMenu`, `StatusMenu`, `ShopMenu`, `PauseMenu`) são carregados por cenas independentes e interagem com os sistemas globais.

## Save/Load
- `SaveSystem` salva os dados de mapa, posição, party, inventário e progresso de quests.
- Carregamentos reinicializam o banco quando necessário e reinstanciam a cena correta.

## Extensibilidade
Adicionar novos mapas ou conteúdo requer apenas atualização do arquivo `database.dl` com novos registros e assets correspondentes, sem alteração de código. O mesmo vale para capítulos adicionais (`database_capituloX.dl`).

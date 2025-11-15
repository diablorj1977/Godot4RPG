# Starfall Legacy - Game Design Document

## Visão Geral
Starfall Legacy é um RPG 2D inspirado em Phantasy Star IV. Os jogadores acompanham Kael, Mira e Rex explorando o planeta desértico Neralis enquanto investigam relíquias estelares capazes de alterar o equilíbrio entre vida orgânica e tecnologia ancestral.

## Personagens Jogáveis
- **Kael**: espadachim dominador de técnicas de vento. Especialista em dano físico rápido.
- **Mira**: usuária de energia, manipula fogo e feitiços de suporte.
- **Rex**: andróide guardião, resistente com ataques baseados em lasers e choque.

## Estrutura de Mundo
- **Overworld**: áreas abertas conectando cidades, vilas e dungeons.
- **Town/Village**: zonas seguras com NPCs, lojas e missões.
- **Dungeons**: ambientes hostis com encontros aleatórios, cofres e chefes.
- **Tech Bases**: mapas futuristas como a Space Station e a Spaceship.

## Progressão
Campanha principal dividida em 10 capítulos. Cada capítulo libera novas áreas em `maps_config.json`. Missões secundárias opcionais oferecem recompensas e desenvolvimento de mundo.

## Combate
- Batalhas por turnos com ordem baseada em agilidade.
- Comandos: Attack, Skill, Item, Defend e Run.
- Técnicas utilizam MP, itens consomem inventário e status são atualizados em tempo real.

## Inventário e Itens
30 armas, 20 armaduras, 15 acessórios, 25 consumíveis e 20 itens de missão. Cada entrada definida dentro de `database.dl` para permitir expansão rápida de conteúdo.

## NPCs e Diálogos
NPCs possuem rotinas simples e diálogos variados controlados por seções `dialogs_*.json`. Missões e lojas são vinculadas a cada NPC por ID.

## Áudio e Arte
Placeholders em pixel art 32x32 e áudio FM sintético simulam o clima 16-bit. Texturas e sons definitivos podem substituir os placeholders mantendo os mesmos caminhos lógicos dentro do banco de dados.

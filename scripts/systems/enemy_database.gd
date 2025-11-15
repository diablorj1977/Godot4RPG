extends Node
class_name EnemyDatabase

var enemies: Dictionary = {}

func _ready() -> void:
    if Engine.has_singleton("GameState"):
        GameState.database_loaded.connect(_on_database_loaded)
        if GameState.database_loader.data_sets.size() > 0:
            load_from_data(GameState.database_loader)

func load_from_data(loader: DatabaseLoader) -> void:
    enemies = {}
    var data := loader.get_section("enemies.json")
    if typeof(data) == TYPE_ARRAY:
        for enemy in data:
            var id := enemy.get("id", "")
            if id != "":
                enemies[id] = enemy.duplicate(true)

func _on_database_loaded(_name: String) -> void:
    load_from_data(GameState.database_loader)

func get_enemy(enemy_id: String) -> Dictionary:
    return enemies.get(enemy_id, {}).duplicate(true)

func get_group(group_config: Dictionary) -> Array:
    var output: Array = []
    var enemy_ids := group_config.get("enemies", [])
    for enemy_id in enemy_ids:
        if enemies.has(enemy_id):
            output.append(enemies[enemy_id].duplicate(true))
    return output

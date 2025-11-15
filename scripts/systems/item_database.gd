extends Node
class_name ItemDatabase

var weapons: Dictionary = {}
var armors: Dictionary = {}
var accessories: Dictionary = {}
var consumables: Dictionary = {}
var missions: Dictionary = {}

func _ready() -> void:
    if Engine.has_singleton("GameState"):
        GameState.database_loaded.connect(_on_database_loaded)
        if GameState.database_loader.data_sets.size() > 0:
            load_from_data(GameState.database_loader)

func load_from_data(loader: DatabaseLoader) -> void:
    weapons = _map_entries(loader.get_section("equipment.json"))
    armors = _map_entries(loader.get_section("armors.json"))
    accessories = _map_entries(loader.get_section("accessories.json"))
    consumables = _map_entries(loader.get_section("consumables.json"))
    missions = _map_entries(loader.get_section("mission_items.json"))

func _on_database_loaded(_name: String) -> void:
    load_from_data(GameState.database_loader)

func _map_entries(data: Variant) -> Dictionary:
    var mapped: Dictionary = {}
    if typeof(data) == TYPE_ARRAY:
        for entry in data:
            var id := entry.get("id", "")
            if id != "":
                mapped[id] = entry.duplicate(true)
    return mapped

func get_item(item_id: String) -> Dictionary:
    for table in [weapons, armors, accessories, consumables, missions]:
        if table.has(item_id):
            return table[item_id].duplicate(true)
    return {}

func list_items(category: String) -> Array:
    match category:
        "weapon":
            return weapons.keys()
        "armor":
            return armors.keys()
        "accessory":
            return accessories.keys()
        "consumable":
            return consumables.keys()
        "mission":
            return missions.keys()
        _:
            return []

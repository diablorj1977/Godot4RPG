extends Node
class_name InventorySystem

signal inventory_changed

var items: Dictionary = {}
var equipment: Dictionary = {}
var capacities := {"items": 99, "equipment": 99}
var item_lookup: Dictionary = {}

func _ready() -> void:
    if Engine.has_singleton("GameState"):
        GameState.database_loaded.connect(_on_database_loaded)
        if GameState.database_loader.data_sets.size() > 0:
            reset_inventory(GameState.database_loader)

func reset_inventory(loader: DatabaseLoader) -> void:
    items.clear()
    equipment.clear()
    _load_lookup(loader)
    items["credits"] = items.get("credits", 0)
    emit_signal("inventory_changed")

func _on_database_loaded(_name: String) -> void:
    reset_inventory(GameState.database_loader)

func _load_lookup(loader: DatabaseLoader) -> void:
    item_lookup.clear()
    var sections := ["items.json", "consumables.json", "mission_items.json", "equipment.json", "armors.json", "accessories.json"]
    for sec in sections:
        var data := loader.get_section(sec)
        if typeof(data) == TYPE_ARRAY:
            for entry in data:
                var id := entry.get("id", "")
                if id != "":
                    item_lookup[id] = entry

func add_item(item_id: String, amount: int = 1) -> void:
    if item_id != "credits" and not item_lookup.has(item_id):
        push_warning("Unknown item %s" % item_id)
        return
    items[item_id] = items.get(item_id, 0) + amount
    emit_signal("inventory_changed")

func remove_item(item_id: String, amount: int = 1) -> void:
    if not items.has(item_id):
        return
    items[item_id] -= amount
    if items[item_id] <= 0:
        items.erase(item_id)
    emit_signal("inventory_changed")

func get_item_count(item_id: String) -> int:
    return items.get(item_id, 0)

func use_item(item_id: String, target_id: String) -> bool:
    if get_item_count(item_id) <= 0:
        return false
    var data := item_lookup.get(item_id, {})
    if data.get("usable_in_battle", false) or data.get("usable_in_field", false):
        var heal_hp := data.get("stats_mod", {}).get("hp", 0)
        var heal_mp := data.get("stats_mod", {}).get("mp", 0)
        if heal_hp > 0:
            PartyManager.heal_actor(target_id, heal_hp)
        if heal_mp > 0:
            var actor := PartyManager.characters.get(target_id, null)
            if actor:
                actor["mp"] = clamp(actor.get("mp", 0) + heal_mp, 0, actor.get("mp_max", 0))
                PartyManager.emit_signal("actor_updated", target_id)
        remove_item(item_id, 1)
        return true
    return false

func equip_item(actor_id: String, item_id: String, slot: String) -> bool:
    var entry := item_lookup.get(item_id, null)
    if entry == null:
        return false
    PartyManager.update_equipment(actor_id, slot, item_id)
    return true

func get_items() -> Dictionary:
    return items.duplicate()

func get_item_data(item_id: String) -> Dictionary:
    return item_lookup.get(item_id, {}).duplicate(true)

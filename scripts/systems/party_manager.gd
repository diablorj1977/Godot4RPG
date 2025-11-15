extends Node
class_name PartyManager

signal party_updated
signal actor_updated(actor_id)

var characters: Dictionary = {}
var party: Array[String] = []

func _ready() -> void:
    if Engine.has_singleton("GameState"):
        GameState.database_loaded.connect(_on_database_loaded)
        if GameState.database_loader.data_sets.size() > 0:
            load_from_data(GameState.database_loader)

func load_from_data(loader: DatabaseLoader) -> void:
    characters.clear()
    party.clear()
    var char_list := loader.get_section("characters.json")
    if typeof(char_list) != TYPE_ARRAY:
        push_error("characters.json missing from database")
        return
    for char_data in char_list:
        var id := char_data.get("id", "")
        if id == "":
            continue
        characters[id] = char_data.duplicate(true)
        if party.size() < 3:
            party.append(id)
    emit_signal("party_updated")

func _on_database_loaded(_name: String) -> void:
    load_from_data(GameState.database_loader)

func get_party_members() -> Array:
    return party.duplicate()

func get_character(actor_id: String) -> Dictionary:
    return characters.get(actor_id, {}).duplicate(true)

func get_active_characters() -> Array:
    var output: Array = []
    for actor_id in party:
        if characters.has(actor_id):
            output.append(characters[actor_id])
    return output

func apply_xp(actor_id: String, amount: int) -> void:
    if not characters.has(actor_id):
        return
    var actor := characters[actor_id]
    actor["xp"] = actor.get("xp", 0) + amount
    while actor.get("xp", 0) >= _xp_to_next(actor):
        actor["xp"] -= _xp_to_next(actor)
        actor["level"] = actor.get("level", 1) + 1
        _apply_growth(actor)
    emit_signal("actor_updated", actor_id)

func _xp_to_next(actor: Dictionary) -> int:
    var level := actor.get("level", 1)
    return 50 + level * 25

func _apply_growth(actor: Dictionary) -> void:
    var growth := actor.get("growth", {})
    for key in growth.keys():
        actor[key] = actor.get(key, 0) + growth[key]
    actor["hp_max"] = actor.get("hp_max", 0) + growth.get("hp", 0)
    actor["mp_max"] = actor.get("mp_max", 0) + growth.get("mp", 0)
    actor["hp"] = actor.get("hp_max", 0)
    actor["mp"] = actor.get("mp_max", 0)

func damage_actor(actor_id: String, amount: int) -> void:
    if not characters.has(actor_id):
        return
    var actor := characters[actor_id]
    actor["hp"] = max(0, actor.get("hp", 0) - amount)
    emit_signal("actor_updated", actor_id)

func heal_actor(actor_id: String, amount: int) -> void:
    if not characters.has(actor_id):
        return
    var actor := characters[actor_id]
    actor["hp"] = clamp(actor.get("hp", 0) + amount, 0, actor.get("hp_max", 0))
    emit_signal("actor_updated", actor_id)

func restore_party() -> void:
    for actor_id in party:
        if characters.has(actor_id):
            var actor := characters[actor_id]
            actor["hp"] = actor.get("hp_max", 0)
            actor["mp"] = actor.get("mp_max", 0)
    emit_signal("party_updated")

func add_member(actor_id: String) -> void:
    if not party.has(actor_id):
        party.append(actor_id)
        emit_signal("party_updated")

func remove_member(actor_id: String) -> void:
    if party.erase(actor_id):
        emit_signal("party_updated")

func update_equipment(actor_id: String, slot: String, item_id: String) -> void:
    if not characters.has(actor_id):
        return
    var actor := characters[actor_id]
    var equip := actor.get("default_equipment", {})
    equip[slot] = item_id
    actor["default_equipment"] = equip
    emit_signal("actor_updated", actor_id)

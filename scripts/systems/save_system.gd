extends Node
class_name SaveSystem

const SAVE_PATH := "user://saves/"

signal save_completed(slot)
signal save_failed(slot, reason)
signal load_completed(slot)
signal load_failed(slot, reason)

func ensure_dir() -> void:
    var dir := DirAccess.open(SAVE_PATH)
    if dir == null:
        DirAccess.make_dir_recursive(SAVE_PATH)

func save_game(slot: int) -> void:
    ensure_dir()
    var path := "%s/save_%02d.json" % [SAVE_PATH, slot]
    var data := _collect_data()
    var json := JSON.stringify(data, "  ")
    var result := FileAccess.open(path, FileAccess.WRITE)
    if result == null:
        emit_signal("save_failed", slot, "Cannot open file")
        return
    result.store_string(json)
    result.close()
    emit_signal("save_completed", slot)

func load_game(slot: int) -> void:
    ensure_dir()
    var path := "%s/save_%02d.json" % [SAVE_PATH, slot]
    if not FileAccess.file_exists(path):
        emit_signal("load_failed", slot, "Save slot empty")
        return
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        emit_signal("load_failed", slot, "Cannot open save")
        return
    var text := file.get_as_text()
    file.close()
    var parsed := JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        emit_signal("load_failed", slot, "Corrupted save")
        return
    _apply_data(parsed)
    emit_signal("load_completed", slot)

func _collect_data() -> Dictionary:
    return {
        "database": GameState.database_name,
        "map": GameState.current_map_id,
        "position": GameState.player_position,
        "party": PartyManager.characters,
        "party_order": PartyManager.party,
        "inventory": InventorySystem.get_items(),
        "quests": QuestSystem.completed,
    }

func _apply_data(data: Dictionary) -> void:
    var database := data.get("database", GameState.database_name)
    if database != GameState.database_name:
        GameState.change_database(database)
    GameState.set_current_map(data.get("map", GameState.current_map_id))
    GameState.player_position = data.get("position", Vector2.ZERO)
    PartyManager.characters = data.get("party", {})
    PartyManager.party = data.get("party_order", [])
    InventorySystem.items = data.get("inventory", {})
    QuestSystem.completed = data.get("quests", {})
    PartyManager.emit_signal("party_updated")
    InventorySystem.emit_signal("inventory_changed")

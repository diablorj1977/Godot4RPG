extends Node
class_name GameState

signal database_loaded
signal map_changed(map_id)

const DEFAULT_DATABASE := "database.dl"

var database_loader := DatabaseLoader.new()
var database_name: String = DEFAULT_DATABASE
var world_map_id: String = "overworld"
var current_map_id: String = "overworld"
var player_position: Vector2 = Vector2.ZERO
var pixel_scale := 2
var window_size := Vector2i(640, 448)
var upscale_size := Vector2i(960, 672)
var input_state := {}

func _ready() -> void:
    _configure_display()
    load_database(DEFAULT_DATABASE)

func _configure_display() -> void:
    DisplayServer.window_set_size(window_size)
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    ProjectSettings.set_setting("rendering/2d/snapping/use_pixel_snap", true)

func load_database(db_name: String) -> bool:
    database_name = db_name
    if not database_loader.load_database("res://%s" % db_name):
        push_error("Failed to load database %s" % db_name)
        return false
    _broadcast_database()
    emit_signal("database_loaded", db_name)
    return true

func _broadcast_database() -> void:
    if Engine.has_singleton("ItemDatabase"):
        ItemDatabase.load_from_data(database_loader)
    if Engine.has_singleton("EnemyDatabase"):
        EnemyDatabase.load_from_data(database_loader)
    if Engine.has_singleton("QuestSystem"):
        QuestSystem.load_from_data(database_loader)
    if Engine.has_singleton("PartyManager"):
        PartyManager.load_from_data(database_loader)
    if Engine.has_singleton("InventorySystem"):
        InventorySystem.reset_inventory(database_loader)

func get_data_section(name: String) -> Variant:
    return database_loader.get_section(name)

func set_current_map(map_id: String, position: Vector2 = Vector2.ZERO) -> void:
    if current_map_id == map_id and position == Vector2.ZERO:
        return
    current_map_id = map_id
    if position != Vector2.ZERO:
        player_position = position
    emit_signal("map_changed", map_id)

func register_input(action: String, pressed: bool) -> void:
    input_state[action] = pressed

func get_dialog(dialog_id: String, fallback: Dictionary = {}) -> Dictionary:
    var current_section := "dialogs_%s.json" % current_map_id
    var dialog_data := database_loader.get_section(current_section)
    if typeof(dialog_data) == TYPE_DICTIONARY and dialog_data.has(dialog_id):
        return dialog_data[dialog_id]
    var file_dialog := _load_dialog_from_file(current_map_id, dialog_id)
    if not file_dialog.is_empty():
        return file_dialog
    var overworld_dialogs := database_loader.get_section("dialogs_overworld.json")
    if typeof(overworld_dialogs) == TYPE_DICTIONARY and overworld_dialogs.has(dialog_id):
        return overworld_dialogs[dialog_id]
    var overworld_file := _load_dialog_from_file("overworld", dialog_id)
    if not overworld_file.is_empty():
        return overworld_file
    return fallback

func get_map_config(map_id: String) -> Dictionary:
    var maps := database_loader.get_section("maps_config.json")
    if typeof(maps) == TYPE_ARRAY:
        for map_config in maps:
            if map_config.get("id", "") == map_id:
                return map_config
    return {}

func get_available_maps() -> Array:
    var maps := []
    var config := database_loader.get_section("maps_config.json")
    if typeof(config) == TYPE_ARRAY:
        for entry in config:
            maps.append(entry.get("id", ""))
    return maps

func change_database(db_name: String) -> void:
    if load_database(db_name):
        current_map_id = world_map_id
        player_position = Vector2.ZERO

func _load_dialog_from_file(section: String, dialog_id: String) -> Dictionary:
    var path := "res://data/dialogs/%s.json" % section
    if not FileAccess.file_exists(path):
        return {}
    var json_text := FileAccess.get_file_as_string(path)
    var parsed := JSON.parse_string(json_text)
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    return parsed.get(dialog_id, {})

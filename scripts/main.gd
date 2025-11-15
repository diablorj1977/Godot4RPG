extends Node
class_name MainRoot

@onready var menu := $MainMenu
@onready var world_loader := $WorldLoader
@onready var save_menu := $SaveMenu

func _ready() -> void:
    menu.start_game.connect(_start_new_game)
    menu.load_game.connect(_open_load)
    menu.exit_game.connect(func(): get_tree().quit())
    save_menu.visible = false
    save_menu.load_slot.connect(_on_SaveMenu_load_slot)
    if Engine.has_singleton("GameState"):
        GameState.map_changed.connect(_on_map_changed)

func _start_new_game() -> void:
    menu.visible = false
    _load_map("overworld")

func _open_load() -> void:
    save_menu.visible = true

func _load_map(map_id: String) -> void:
    var scene_path := "res://scenes/world/%s.tscn" % map_id
    if not ResourceLoader.exists(scene_path):
        push_warning("Map scene missing: %s" % map_id)
        return
    for child in world_loader.get_children():
        child.queue_free()
    var scene := load(scene_path).instantiate()
    world_loader.add_child(scene)

func _on_SaveMenu_load_slot(slot: int) -> void:
    SaveSystem.load_game(slot)
    _load_map(GameState.current_map_id)
    save_menu.visible = false

func _on_map_changed(map_id: String) -> void:
    _load_map(map_id)

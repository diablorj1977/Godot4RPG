extends Node2D
class_name MapScene

const PORTAL_SCENE := preload("res://scenes/common/portal.tscn")

@export var map_id: String = ""
@onready var tile_map := $TileMap
@onready var player := $Player
@onready var portal_container := $Portals
@onready var dialog_box := $CanvasLayer/DialogBox
@onready var hud := $CanvasLayer/HUD

var encounter_timer: float = 0.0
var encounter_threshold := 8.0
var encounters: Array = []
var portals: Array = []
var current_battle: Node = null

func _ready() -> void:
    randomize()
    GameState.set_current_map(map_id)
    _configure_map()
    _spawn_player()
    _load_portals()
    _wire_pause_menu()
    AudioManager.play_bgm(_get_music_key())

func _process(delta: float) -> void:
    _handle_encounter(delta)
    if Input.is_action_just_pressed("menu"):
        var pause_menu := get_tree().current_scene.get_node_or_null("PauseMenu")
        if pause_menu:
            pause_menu.toggle()

func _configure_map() -> void:
    var config := GameState.get_map_config(map_id)
    if config.is_empty():
        return
    encounters = config.get("encounters", [])
    var tileset_ref := config.get("tileset", "")
    if tileset_ref != "":
        var path := "res://assets/tilesets/%s" % tileset_ref.get_file()
        if ResourceLoader.exists(path) and tile_map.tile_set:
            tile_map.tile_set = TileSet.new()
    portals = config.get("connections", [])
    if portal_container:
        for child in portal_container.get_children():
            child.queue_free()
        for connection in portals:
            var portal := PORTAL_SCENE.instantiate()
            portal.target_map = connection.get("to", "overworld")
            var pos := connection.get("position", [0, 0])
            portal.position = Vector2(pos[0], pos[1]) * 32.0
            portal.target_position = portal.position
            portal.add_to_group("Portals")
            portal_container.add_child(portal)

func _spawn_player() -> void:
    player.global_position = GameState.player_position if GameState.player_position != Vector2.ZERO else Vector2(64, 64)

func _handle_encounter(delta: float) -> void:
    if player == null or (current_battle and is_instance_valid(current_battle)):
        return
    encounter_timer += delta * (player.velocity.length() / max(1.0, player.get_speed()))
    if encounter_timer >= encounter_threshold:
        var group := _pick_encounter_group()
        if not group.is_empty():
            _start_battle(group)
            encounter_timer = 0.0

func _pick_encounter_group() -> Dictionary:
    if encounters.is_empty():
        return {}
    var region := encounters[0]
    var roll := randf()
    var cumulative := 0.0
    for group in region.get("groups", []):
        cumulative += group.get("chance", 0.0)
        if roll <= cumulative:
            return group
    return region.get("groups", []).front()

func _start_battle(group: Dictionary) -> void:
    GameState.player_position = player.global_position
    if current_battle and is_instance_valid(current_battle):
        current_battle.queue_free()
    current_battle = preload("res://scenes/battle/battle_scene.tscn").instantiate()
    get_tree().current_scene.add_child(current_battle)
    current_battle.start_battle(group)
    current_battle.battle_finished.connect(_on_battle_finished)

func _on_battle_finished(victory: bool) -> void:
    if current_battle and is_instance_valid(current_battle):
        current_battle.queue_free()
        current_battle = null
    if victory:
        PartyManager.restore_party()
    else:
        GameState.set_current_map("overworld")

func _load_portals() -> void:
    for portal_node in get_tree().get_nodes_in_group("Portals"):
        portal_node.connect("portal_entered", Callable(self, "_on_portal_entered"))

func _on_portal_entered(target_map: String, target_position: Vector2) -> void:
    GameState.player_position = target_position
    MapTransition.travel_to(target_map, target_position)

func _get_music_key() -> String:
    var config := GameState.get_map_config(map_id)
    var music_key := config.get("type", "overworld")
    match music_key:
        "town":
            return "town"
        "village":
            return "town"
        "dungeon":
            return "dungeon"
        "space_station":
            return "battle"
        "spaceship":
            return "boss"
        _:
            pass
    return "overworld"

func _wire_pause_menu() -> void:
    var pause_menu := get_tree().current_scene.get_node_or_null("PauseMenu")
    if pause_menu:
        pause_menu.resume_game.connect(_on_resume)
        pause_menu.open_inventory.connect(_open_inventory)
        pause_menu.open_status.connect(_open_status)
        pause_menu.save_game.connect(_save_slot)
        pause_menu.quit_to_menu.connect(_return_to_menu)

func _on_resume() -> void:
    var pause_menu := get_tree().current_scene.get_node_or_null("PauseMenu")
    if pause_menu:
        pause_menu.toggle()

func _open_inventory() -> void:
    var pause_menu := get_tree().current_scene.get_node_or_null("PauseMenu")
    if pause_menu and pause_menu.visible:
        pause_menu.toggle()
    var inv := get_node_or_null("CanvasLayer/InventoryMenu")
    if inv:
        inv.open()

func _open_status() -> void:
    var pause_menu := get_tree().current_scene.get_node_or_null("PauseMenu")
    if pause_menu and pause_menu.visible:
        pause_menu.toggle()
    var status := get_node_or_null("CanvasLayer/StatusMenu")
    if status:
        status.open()

func _save_slot() -> void:
    var pause_menu := get_tree().current_scene.get_node_or_null("PauseMenu")
    if pause_menu and pause_menu.visible:
        pause_menu.toggle()
    SaveSystem.save_game(1)

func _return_to_menu() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main.tscn")

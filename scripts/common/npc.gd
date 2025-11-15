extends CharacterBody2D
class_name NPC

@export var npc_id: String = ""
@export var speed := 40.0
@onready var dialog_timer := $DialogTimer

var wander_direction := Vector2.ZERO
var npc_cache: Dictionary = {}

func _ready() -> void:
    add_to_group("NPCs")
    dialog_timer.timeout.connect(_pick_direction)
    _pick_direction()

func _physics_process(_delta: float) -> void:
    velocity = wander_direction * speed
    move_and_slide()

func _pick_direction() -> void:
    npc_cache = _get_npc_data()
    if npc_cache.get("routine", "idle") == "wander":
        wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
        dialog_timer.start(randf_range(2.0, 4.0))
    else:
        wander_direction = Vector2.ZERO
        dialog_timer.start(3.0)

func on_player_interact(_player: Player) -> void:
    npc_cache = _get_npc_data()
    var dialog := GameState.get_dialog(npc_id, {"name": npc_cache.get("name", npc_id), "lines": ["Olá!", "Hoje é um bom dia."]})
    if dialog.is_empty():
        dialog = {"name": npc_cache.get("name", "Habitante"), "lines": ["Nada a dizer agora."]}
    var dialog_box := get_tree().current_scene.get_node_or_null("CanvasLayer/DialogBox")
    if dialog_box:
        dialog_box.start_dialog(dialog)
    if npc_cache.get("shop_id", "") != "":
        var shop := get_tree().current_scene.get_node_or_null("CanvasLayer/ShopMenu")
        if shop:
            shop.open(npc_cache.get("shop_id", ""))
    if npc_cache.get("quest_giver", false):
        QuestSystem.register_progress("main_01", "talked_%s" % npc_id)

func _get_npc_data() -> Dictionary:
    var npc_data := GameState.get_data_section("npcs.json")
    if typeof(npc_data) == TYPE_ARRAY:
        for entry in npc_data:
            if entry.get("id", "") == npc_id:
                return entry
    return {}

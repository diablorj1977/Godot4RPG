extends Node
class_name MapTransition

signal transition_started(target_map)
signal transition_finished(target_map)

var fade_layer: ColorRect

func _ready() -> void:
    fade_layer = ColorRect.new()
    fade_layer.color = Color(0, 0, 0, 0)
    fade_layer.visible = false
    fade_layer.size = get_viewport().get_visible_rect().size
    fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(fade_layer)

func travel_to(map_id: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
    if not QuestSystem.can_access_map(map_id):
        AudioManager.play_sfx("cancel")
        return
    emit_signal("transition_started", map_id)
    _fade_out()
    GameState.set_current_map(map_id, spawn_position)
    _fade_in()
    emit_signal("transition_finished", map_id)

func _fade_out() -> void:
    fade_layer.visible = true
    fade_layer.size = get_viewport().get_visible_rect().size
    for step in range(10):
        fade_layer.color.a = step / 10.0
        await get_tree().process_frame

func _fade_in() -> void:
    fade_layer.size = get_viewport().get_visible_rect().size
    for step in range(10, -1, -1):
        fade_layer.color.a = step / 10.0
        await get_tree().process_frame
    fade_layer.visible = false

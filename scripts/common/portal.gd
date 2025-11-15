extends Area2D
class_name Portal

signal portal_entered(target_map, target_position)

@export var target_map: String = "overworld"
@export var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
    add_to_group("Portals")
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body is Player:
        emit_signal("portal_entered", target_map, target_position)

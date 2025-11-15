extends Node2D
class_name EnemyController

var enemy_data: Dictionary = {}
var sprite: Sprite2D

func _ready() -> void:
    sprite = Sprite2D.new()
    add_child(sprite)

func setup(data: Dictionary) -> void:
    enemy_data = data.duplicate(true)
    if data.has("sprite"):
        var path := "res://assets/sprites/%s" % data["sprite"]
        if ResourceLoader.exists(path):
            sprite.texture = load(path)

func take_damage(amount: int) -> void:
    var hp := enemy_data.get("hp", 0)
    enemy_data["hp"] = max(0, hp - amount)
    _flash()

func is_defeated() -> bool:
    return enemy_data.get("hp", 0) <= 0

func _flash() -> void:
    sprite.modulate = Color(1, 0.5, 0.5)
    await get_tree().create_timer(0.1).timeout
    sprite.modulate = Color.WHITE

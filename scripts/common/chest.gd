extends Area2D
class_name TreasureChest

@export var item_id: String = "consumable_01"
@export var amount: int = 1
var opened := false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if opened:
        return
    if body is Player:
        opened = true
        InventorySystem.add_item(item_id, amount)
        AudioManager.play_sfx("confirm")

extends Control
class_name BattleUI

signal command_selected(action)
signal action_resolved

@onready var message_label := $Panel/VBoxContainer/Message
@onready var command_list := $Panel/VBoxContainer/CommandList

var current_actor: Dictionary = {}

func _ready() -> void:
    command_list.item_selected.connect(_on_command_selected)

func show_command(actor: Dictionary) -> void:
    current_actor = actor
    message_label.text = "Selecione ação para %s" % actor.get("name", "")
    command_list.clear()
    var idx = command_list.add_item("Atacar")
    command_list.set_item_metadata(idx, {"type": "attack"})
    idx = command_list.add_item("Habilidade")
    command_list.set_item_metadata(idx, {"type": "skill"})
    idx = command_list.add_item("Item")
    command_list.set_item_metadata(idx, {"type": "item"})
    idx = command_list.add_item("Defender")
    command_list.set_item_metadata(idx, {"type": "defend"})
    idx = command_list.add_item("Fugir")
    command_list.set_item_metadata(idx, {"type": "run"})
    command_list.select(0)

func show_message(text: String) -> void:
    message_label.text = text
    emit_signal("action_resolved")

func _on_command_selected(index: int) -> void:
    var meta := command_list.get_item_metadata(index)
    if meta == null:
        return
    if meta["type"] == "item":
        var first_item := ""
        for id in InventorySystem.get_items().keys():
            if id != "credits":
                first_item = id
                break
        if first_item == "":
            return
        meta["item"] = first_item
    emit_signal("command_selected", meta)

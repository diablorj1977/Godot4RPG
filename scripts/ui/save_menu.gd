extends Control
class_name SaveMenu

signal load_slot(slot)

func _ready() -> void:
    visible = false
    $Panel/VBoxContainer/Slot1.pressed.connect(func(): emit_signal("load_slot", 1))
    $Panel/VBoxContainer/Slot2.pressed.connect(func(): emit_signal("load_slot", 2))
    $Panel/VBoxContainer/Slot3.pressed.connect(func(): emit_signal("load_slot", 3))
    $Panel/VBoxContainer/Close.pressed.connect(func(): visible = false)

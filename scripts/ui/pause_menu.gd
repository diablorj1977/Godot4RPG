extends Control
class_name PauseMenu

signal resume_game
signal open_inventory
signal open_status
signal save_game
signal quit_to_menu

func _ready() -> void:
    visible = false
    $Panel/VBoxContainer/Resume.pressed.connect(func(): emit_signal("resume_game"))
    $Panel/VBoxContainer/Inventory.pressed.connect(func(): emit_signal("open_inventory"))
    $Panel/VBoxContainer/Status.pressed.connect(func(): emit_signal("open_status"))
    $Panel/VBoxContainer/Save.pressed.connect(func(): emit_signal("save_game"))
    $Panel/VBoxContainer/Quit.pressed.connect(func(): emit_signal("quit_to_menu"))

func toggle() -> void:
    visible = not visible
    if visible:
        get_tree().paused = true
    else:
        get_tree().paused = false

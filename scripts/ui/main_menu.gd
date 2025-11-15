extends Control
class_name MainMenu

signal start_game
signal load_game
signal exit_game

@onready var buttons := [$VBoxContainer/StartButton, $VBoxContainer/LoadButton, $VBoxContainer/ExitButton]

func _ready() -> void:
    for button in buttons:
        button.pressed.connect(_on_button_pressed.bind(button.name))
    AudioManager.play_bgm("overworld")

func _on_button_pressed(name: String) -> void:
    match name:
        "StartButton":
            emit_signal("start_game")
        "LoadButton":
            emit_signal("load_game")
        "ExitButton":
            get_tree().quit()

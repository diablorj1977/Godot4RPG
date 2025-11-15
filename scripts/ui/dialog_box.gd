extends Control
class_name DialogBox

signal dialog_finished

@onready var name_label := $Panel/VBoxContainer/Name
@onready var text_label := $Panel/VBoxContainer/Text

var lines: Array = []
var current_index := 0
var speaker_name := ""

func start_dialog(dialog_data: Dictionary) -> void:
    speaker_name = dialog_data.get("name", "")
    lines = dialog_data.get("lines", [])
    current_index = 0
    visible = true
    _show_line()

func _show_line() -> void:
    if current_index >= lines.size():
        visible = false
        emit_signal("dialog_finished")
        return
    name_label.text = speaker_name
    text_label.text = lines[current_index]

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    if event.is_action_pressed("confirm"):
        current_index += 1
        _show_line()

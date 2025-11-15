extends Control
class_name StatusMenu

@onready var status_list := $Panel/VBoxContainer/StatusList

func _ready() -> void:
    visible = false
    PartyManager.party_updated.connect(_refresh)
    PartyManager.actor_updated.connect(func(_id): _refresh())
    _refresh()

func open() -> void:
    visible = true
    _refresh()

func close() -> void:
    visible = false

func _refresh() -> void:
    for child in status_list.get_children():
        child.queue_free()
    for actor in PartyManager.get_active_characters():
        var panel := VBoxContainer.new()
        panel.add_child(_make_label(actor.get("name", "")))
        panel.add_child(_make_label("Nível: %d" % actor.get("level", 1)))
        panel.add_child(_make_label("HP: %d/%d" % [actor.get("hp", 0), actor.get("hp_max", 0)]))
        panel.add_child(_make_label("MP: %d/%d" % [actor.get("mp", 0), actor.get("mp_max", 0)]))
        panel.add_child(_make_label("ATK: %d DEF: %d AGI: %d" % [actor.get("atk", 0), actor.get("def", 0), actor.get("agi", 0)]))
        status_list.add_child(panel)

func _make_label(text: String) -> Label:
    var label := Label.new()
    label.text = text
    return label

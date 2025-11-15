extends CanvasLayer
class_name HUD

@onready var portrait_container := $MarginContainer/VBoxContainer/PartyStatus
@onready var quest_label := $MarginContainer/VBoxContainer/QuestLabel

func _ready() -> void:
    PartyManager.party_updated.connect(_refresh_party)
    PartyManager.actor_updated.connect(func(_id): _refresh_party())
    QuestSystem.quest_updated.connect(_on_quest_updated)
    QuestSystem.quest_completed.connect(_on_quest_updated)
    _refresh_party()
    _refresh_quests()

func _refresh_party() -> void:
    for child in portrait_container.get_children():
        child.queue_free()
    for actor in PartyManager.get_active_characters():
        var label := Label.new()
        label.text = "%s HP %d/%d MP %d/%d" % [actor.get("name", ""), actor.get("hp", 0), actor.get("hp_max", 0), actor.get("mp", 0), actor.get("mp_max", 0)]
        portrait_container.add_child(label)

func _refresh_quests() -> void:
    var quests := QuestSystem.get_active_quests()
    if quests.is_empty():
        quest_label.text = "Sem missões ativas"
    else:
        var first := quests[0]
        quest_label.text = "Objetivo: %s" % first.get("description", "")

func _on_quest_updated(_quest_id: String) -> void:
    _refresh_quests()

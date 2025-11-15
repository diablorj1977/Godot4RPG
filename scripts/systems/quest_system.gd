extends Node
class_name QuestSystem

signal quest_updated(quest_id)
signal quest_completed(quest_id)

var main_quests: Dictionary = {}
var side_quests: Dictionary = {}
var completed: Dictionary = {}

func _ready() -> void:
    if Engine.has_singleton("GameState"):
        GameState.database_loaded.connect(_on_database_loaded)
        if GameState.database_loader.data_sets.size() > 0:
            load_from_data(GameState.database_loader)

func load_from_data(loader: DatabaseLoader) -> void:
    main_quests = _prepare(loader.get_section("quests_main.json"))
    side_quests = _prepare(loader.get_section("quests_side.json"))
    completed.clear()

func _on_database_loaded(_name: String) -> void:
    load_from_data(GameState.database_loader)

func _prepare(entries: Variant) -> Dictionary:
    var result: Dictionary = {}
    if typeof(entries) == TYPE_ARRAY:
        for entry in entries:
            var id := entry.get("id", "")
            if id != "":
                result[id] = entry.duplicate(true)
    return result

func is_completed(quest_id: String) -> bool:
    return completed.get(quest_id, false)

func complete_quest(quest_id: String) -> void:
    completed[quest_id] = true
    emit_signal("quest_completed", quest_id)

func get_active_quests() -> Array:
    var active: Array = []
    for quest_id in main_quests.keys():
        if not is_completed(quest_id):
            active.append(main_quests[quest_id])
    for quest_id in side_quests.keys():
        if not is_completed(quest_id):
            active.append(side_quests[quest_id])
    return active

func can_access_map(map_id: String) -> bool:
    var config := GameState.get_map_config(map_id)
    var required := config.get("flags", {}).get("requires_quest", "")
    if required == "":
        return true
    return is_completed(required)

func register_progress(quest_id: String, objective: String) -> void:
    var quest := main_quests.get(quest_id, null)
    if quest == null:
        quest = side_quests.get(quest_id, null)
    if quest == null:
        return
    var progress := quest.get("progress", [])
    progress.append(objective)
    quest["progress"] = progress
    emit_signal("quest_updated", quest_id)

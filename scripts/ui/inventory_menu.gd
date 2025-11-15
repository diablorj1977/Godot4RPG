extends Control
class_name InventoryMenu

signal item_used(item_id, target_id)

@onready var item_list := $Panel/HBoxContainer/ItemList
@onready var description := $Panel/HBoxContainer/Description
@onready var party_list := $Panel/HBoxContainer/PartyList

func _ready() -> void:
    visible = false
    InventorySystem.inventory_changed.connect(_populate)
    PartyManager.party_updated.connect(_populate_party)
    _populate()
    _populate_party()

func open() -> void:
    visible = true
    _populate()

func close() -> void:
    visible = false

func _populate() -> void:
    item_list.clear()
    for item_id in InventorySystem.get_items().keys():
        if item_id == "credits":
            continue
        var data := InventorySystem.get_item_data(item_id)
        var idx := item_list.add_item("%s x%d" % [data.get("name", item_id), InventorySystem.get_item_count(item_id)])
        item_list.set_item_metadata(idx, item_id)

func _populate_party() -> void:
    party_list.clear()
    for actor in PartyManager.get_active_characters():
        var idx := party_list.add_item(actor.get("name", ""))
        party_list.set_item_metadata(idx, actor.get("id", ""))

func _on_ItemList_item_selected(index: int) -> void:
    var meta := item_list.get_item_metadata(index)
    var data := InventorySystem.get_item_data(meta)
    description.text = data.get("description", "")

func _on_use_pressed() -> void:
    var item_idx := item_list.get_selected_items()
    var party_idx := party_list.get_selected_items()
    if item_idx.is_empty() or party_idx.is_empty():
        return
    var item_id := item_list.get_item_metadata(item_idx[0])
    var target_id := party_list.get_item_metadata(party_idx[0])
    if InventorySystem.use_item(item_id, target_id):
        emit_signal("item_used", item_id, target_id)
        _populate()

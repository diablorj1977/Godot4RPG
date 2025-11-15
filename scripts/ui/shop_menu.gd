extends Control
class_name ShopMenu

signal purchase_made(item_id)

@onready var goods_list := $Panel/HBoxContainer/Goods
@onready var description := $Panel/HBoxContainer/Description
@onready var credits_label := $Panel/HBoxContainer/Credits

var shop_id: String = ""
var shop_data: Dictionary = {}

func _ready() -> void:
    visible = false

func open(shop: String) -> void:
    shop_id = shop
    shop_data = _fetch_shop(shop_id)
    visible = true
    _populate()

func close() -> void:
    visible = false

func _fetch_shop(shop: String) -> Dictionary:
    var shops := GameState.get_data_section("shops.json")
    if typeof(shops) == TYPE_ARRAY:
        for entry in shops:
            if entry.get("id", "") == shop:
                return entry
    return {}

func _populate() -> void:
    goods_list.clear()
    credits_label.text = "Créditos: %d" % InventorySystem.get_item_count("credits")
    for category in shop_data.get("inventory", {}).keys():
        for item_id in shop_data["inventory"][category]:
            var data := ItemDatabase.get_item(item_id)
            if data.is_empty():
                continue
            var idx := goods_list.add_item("%s - %d" % [data.get("name", item_id), data.get("price", 0)])
            goods_list.set_item_metadata(idx, item_id)

func _on_Goods_item_selected(index: int) -> void:
    var item_id := goods_list.get_item_metadata(index)
    var data := ItemDatabase.get_item(item_id)
    description.text = data.get("description", "")

func _on_buy_pressed() -> void:
    var selected := goods_list.get_selected_items()
    if selected.is_empty():
        return
    var item_id := goods_list.get_item_metadata(selected[0])
    var cost := ItemDatabase.get_item(item_id).get("price", 0)
    if InventorySystem.get_item_count("credits") >= cost:
        InventorySystem.remove_item("credits", cost)
        InventorySystem.add_item(item_id, 1)
        credits_label.text = "Créditos: %d" % InventorySystem.get_item_count("credits")
        emit_signal("purchase_made", item_id)

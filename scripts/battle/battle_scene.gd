extends Node2D
class_name BattleScene

signal battle_finished(victory)

@onready var background := $ParallaxBackground
@onready var enemy_container := $Enemies
@onready var party_container := $Party
@onready var ui := $BattleUI

var turn_queue: Array = []
var enemies: Array[EnemyController] = []
var party_snapshots: Array = []
var active_turn_index := 0
var battle_state := "idle"

func _ready() -> void:
    ui.command_selected.connect(_on_command_selected)
    ui.action_resolved.connect(_on_action_resolved)

func start_battle(group: Dictionary) -> void:
    battle_state = "setup"
    for child in enemy_container.get_children():
        child.queue_free()
    enemies.clear()
    party_snapshots = PartyManager.get_active_characters()
    if party_snapshots.is_empty():
        finish_battle(false)
        return
    _spawn_enemies(group)
    _setup_party_ui()
    _build_turn_queue()
    battle_state = "await_command"
    ui.show_command(party_snapshots[0])

func _spawn_enemies(group: Dictionary) -> void:
    var enemy_data := EnemyDatabase.get_group(group)
    var offset := 0
    for data in enemy_data:
        var enemy := EnemyController.new()
        enemy.setup(data)
        enemy.position = Vector2(300 + offset * 40, 180 + offset * 10)
        enemy_container.add_child(enemy)
        enemies.append(enemy)
        offset += 1

func _setup_party_ui() -> void:
    for child in party_container.get_children():
        child.queue_free()
    for actor in party_snapshots:
        var label := Label.new()
        label.text = "%s Lv.%d HP %d/%d" % [actor.get("name", ""), actor.get("level", 1), actor.get("hp", 0), actor.get("hp_max", 0)]
        party_container.add_child(label)

func _build_turn_queue() -> void:
    turn_queue.clear()
    for actor in party_snapshots:
        turn_queue.append({"type": "ally", "data": actor})
    for enemy in enemies:
        turn_queue.append({"type": "enemy", "data": enemy.enemy_data})
    turn_queue.sort_custom(func(a, b): return a["data"].get("agi", 0) > b["data"].get("agi", 0))
    active_turn_index = 0

func _on_command_selected(action: Dictionary) -> void:
    if battle_state != "await_command":
        return
    battle_state = "resolving"
    _execute_action(action)

func _execute_action(action: Dictionary) -> void:
    match action.get("type", "attack"):
        "attack":
            var target := _select_first_enemy()
            if target:
                var actor := party_snapshots[active_turn_index].get("name", "")
                var damage := _calculate_damage(party_snapshots[active_turn_index], target.enemy_data)
                target.take_damage(damage)
                ui.show_message("%s atacou causando %d de dano!" % [actor, damage])
        "skill":
            var skill_target := _select_first_enemy()
            if skill_target:
                var actor_name := party_snapshots[active_turn_index].get("name", "")
                var tech_damage := _calculate_damage(party_snapshots[active_turn_index], skill_target.enemy_data) + 5
                skill_target.take_damage(tech_damage)
                ui.show_message("%s usou uma técnica causando %d!" % [actor_name, tech_damage])
        "item":
            var item_id := action.get("item", "")
            var actor_id := party_snapshots[active_turn_index].get("id", "")
            if InventorySystem.use_item(item_id, actor_id):
                ui.show_message("Item %s usado." % item_id)
        "defend":
            ui.show_message("Postura defensiva adotada.")
        "run":
            if randf() < 0.5:
                ui.show_message("Fuga bem-sucedida!")
                finish_battle(true)
                return
            else:
                ui.show_message("Não foi possível escapar!")
    _check_enemy_defeat()

func _calculate_damage(attacker: Dictionary, defender: Dictionary) -> int:
    var atk := attacker.get("atk", 10)
    var defense := defender.get("def", 5)
    return max(1, atk - defense / 2)

func _select_first_enemy() -> EnemyController:
    for enemy in enemies:
        if not enemy.is_defeated():
            return enemy
    return null

func _check_enemy_defeat() -> void:
    if enemies.all(func(enemy): return enemy.is_defeated()):
        ui.show_message("Vitória da equipe!")
        _grant_rewards()
        finish_battle(true)
    else:
        _enemy_turn()

func _enemy_turn() -> void:
    var enemy := _select_first_enemy()
    if enemy == null:
        finish_battle(true)
        return
    var target := _select_first_alive_actor()
    if target.is_empty():
        finish_battle(false)
        return
    var damage := _calculate_damage(enemy.enemy_data, target)
    PartyManager.damage_actor(target.get("id", ""), damage)
    ui.show_message("%s atacou e causou %d de dano!" % [enemy.enemy_data.get("name", "Inimigo"), damage])
    if PartyManager.get_active_characters().all(func(actor): return actor.get("hp", 0) <= 0):
        finish_battle(false)
    else:
        party_snapshots = PartyManager.get_active_characters()
        active_turn_index = 0
        battle_state = "await_command"
        ui.show_command(_select_first_alive_actor())

func _grant_rewards() -> void:
    var xp_total := 0
    var credits := 0
    for enemy in enemies:
        xp_total += enemy.enemy_data.get("xp", 0)
        credits += enemy.enemy_data.get("credits", 0)
    for actor in PartyManager.get_party_members():
        PartyManager.apply_xp(actor, xp_total)
    InventorySystem.add_item("credits", credits)

func _on_action_resolved() -> void:
    pass

func finish_battle(victory: bool) -> void:
    battle_state = "finished"
    emit_signal("battle_finished", victory)

func _select_first_alive_actor() -> Dictionary:
    for actor in PartyManager.get_active_characters():
        if actor.get("hp", 0) > 0:
            return actor
    return {}

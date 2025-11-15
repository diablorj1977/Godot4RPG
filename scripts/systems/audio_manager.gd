extends Node
class_name AudioManager

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var current_bgm: String = ""

func _ready() -> void:
    bgm_player = AudioStreamPlayer.new()
    bgm_player.bus = "Music"
    add_child(bgm_player)
    sfx_player = AudioStreamPlayer.new()
    sfx_player.bus = "SFX"
    add_child(sfx_player)

func play_bgm(track_id: String) -> void:
    if track_id == current_bgm:
        return
    var path := _resolve_bgm(track_id)
    if path == "":
        push_warning("BGM %s not found" % track_id)
        return
    var stream := load(path)
    if stream:
        bgm_player.stream = stream
        bgm_player.play()
        current_bgm = track_id

func stop_bgm() -> void:
    bgm_player.stop()
    current_bgm = ""

func play_sfx(effect_id: String) -> void:
    var path := _resolve_sfx(effect_id)
    if path == "":
        push_warning("SFX %s not found" % effect_id)
        return
    var stream := load(path)
    if stream:
        sfx_player.stream = stream
        sfx_player.play()

func _resolve_bgm(track_id: String) -> String:
    var mapping := {
        "overworld": "res://assets/audio/bgm_overworld.ogg",
        "town": "res://assets/audio/bgm_town.ogg",
        "dungeon": "res://assets/audio/bgm_dungeon.ogg",
        "battle": "res://assets/audio/bgm_battle.ogg",
        "boss": "res://assets/audio/bgm_boss.ogg",
    }
    return mapping.get(track_id, track_id if track_id.begins_with("res://") else "")

func _resolve_sfx(effect_id: String) -> String:
    var mapping := {
        "cursor": "res://assets/audio/sfx_cursor.wav",
        "confirm": "res://assets/audio/sfx_confirm.wav",
        "hit": "res://assets/audio/sfx_hit.wav",
        "levelup": "res://assets/audio/sfx_levelup.wav",
        "cancel": "res://assets/audio/sfx_cursor.wav",
    }
    return mapping.get(effect_id, effect_id if effect_id.begins_with("res://") else "")

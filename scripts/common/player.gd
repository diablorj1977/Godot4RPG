extends CharacterBody2D
class_name Player

@export var speed := 120.0
@onready var animation_player := $AnimationPlayer
@onready var interact_ray := $InteractRay

func _physics_process(delta: float) -> void:
    var direction := Vector2.ZERO
    direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    velocity = direction.normalized() * speed
    if direction != Vector2.ZERO:
        GameState.player_position = global_position
    move_and_slide()
    _update_animation(direction)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("interact"):
        _try_interact()

func _update_animation(direction: Vector2) -> void:
    if animation_player == null:
        return
    if direction == Vector2.ZERO:
        if animation_player.has_animation("idle"):
            animation_player.play("idle")
    else:
        if abs(direction.x) > abs(direction.y):
            if animation_player.has_animation("run_side"):
                animation_player.play("run_side")
        elif direction.y < 0:
            if animation_player.has_animation("run_up"):
                animation_player.play("run_up")
        else:
            if animation_player.has_animation("run_down"):
                animation_player.play("run_down")

func _try_interact() -> void:
    if interact_ray:
        interact_ray.force_raycast_update()
        if interact_ray.is_colliding():
            var collider := interact_ray.get_collider()
            if collider and collider.has_method("on_player_interact"):
                collider.on_player_interact(self)

func get_speed() -> float:
    return speed

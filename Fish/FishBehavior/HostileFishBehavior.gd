extends FishBehaviorBase

const ATTACK_COOLDOWN: float = 1.0
const ACCELERATION: float = 2.0

@export var sight_radius: float = 80.0
@export var max_range: float = 200.0
@export var max_speed: float = 20.0

var attack_cooldown: float = ATTACK_COOLDOWN
var attacking: bool = false
var cur_speed: float = 0.0
var last_seen: Vector2

func _behave(delta: float) -> void:
	if attacking and is_too_far():
		attacking = false
		attack_cooldown = ATTACK_COOLDOWN
		tween = fish.create_tween()
		tween.tween_property(fish, "global_position", fish.initial_position, 5.0)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		fish.update_facing(fish.initial_position - fish.global_position)
		tween.finished.connect(func():
			fish.set_facing(fish.flip != fish.is_sprite_facing_left)
		)
	elif attacking and can_see_player():
		cur_speed = lerp(cur_speed, max_speed, ACCELERATION * delta)
		last_seen = player.global_position
		move_toward_last_seen(delta)
	elif attacking:
		cur_speed = lerp(cur_speed, 0, (ACCELERATION / 2) * delta)
		fish.global_position = fish.global_position.move_toward(last_seen, cur_speed * delta)
		move_toward_last_seen(delta)
	elif attack_cooldown < 0.0 and can_see_player():
		if tween != null:
			tween.kill()
			tween = null
		
		attacking = true
		last_seen = player.global_position
	
	attack_cooldown -= delta

func move_toward_last_seen(delta: float):
	fish.global_position = fish.global_position.move_toward(last_seen, cur_speed * delta)
	fish.update_facing(last_seen - fish.global_position)

func can_see_player() -> bool:
	var displacement = player.global_position - fish.global_position
	if (displacement.x > 0.0) == fish.facing_left:
		return false
	var radius = sight_radius if player.is_light_on() else sight_radius / 4
	return displacement.length_squared() < pow(radius, 2)

func is_too_far() -> bool:
	return fish.global_position.distance_squared_to(fish.initial_position) > pow(max_range, 2)

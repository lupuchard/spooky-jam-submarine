extends FishBehaviorBase
class_name FloorFishBehavior

const GRAVITY = Vector2(0, 5.0)
@export var walk_speed := 5.0
@export var idle_proportion := 0.5
@export var state_length := 5.0

var is_idle := true
var dir: Vector2
var state_time_remaining := state_length

func _behave(delta: float) -> void:
	super._behave(delta)
	
	state_time_remaining -= delta
	if state_time_remaining < 0:
		if is_idle:
			is_idle = false
			dir = [Vector2.RIGHT, Vector2.LEFT].pick_random()
			state_time_remaining = (1.0 - idle_proportion) * randf_range(0.0, state_length * 2.0)
			if fish.movement_sound != null:
				fish.movement_sound.play()
		else:
			is_idle = true
			state_time_remaining = idle_proportion * state_length * randf_range(0.0, state_length * 2.0)
			if fish.movement_sound != null:
				fish.movement_sound.stop()
	
	if !is_idle:
		fish.move_and_collide(dir * delta * walk_speed)
	var _collision := fish.move_and_collide(GRAVITY * delta)
	#if collision != null:
		#fish.rotation = clamp(collision.get_normal().angle(), -PI / 8, PI / 8)

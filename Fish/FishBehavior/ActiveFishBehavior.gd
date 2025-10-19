extends FishBehaviorBase
class_name ActiveFishBehavior

const RETREAT_COOLDOWN = 0.8

@export var wander_cooldown_min: float = 2.0
@export var wander_cooldown_max: float = 3.0
@export var wander_distance: float = 10.0

@export var retreat_range: float = 20.0
@export var retreat_distance: float = 50.0

var wander_cooldown := 0.0
var retreat_cooldown := 0.0

func _behave(delta: float) -> void:
	super._behave(delta)
	
	if wander_cooldown < 0:
		var dir = Vector2.from_angle(randf_range(0, TAU))
		move_to(dir * wander_distance)
		wander_cooldown = randf_range(wander_cooldown_min, wander_cooldown_max)
	
	if retreat_cooldown <= 0:
		var dist_sqr = fish.global_position.distance_squared_to(player.global_position)
		if dist_sqr < pow(max_distance(retreat_range), 2):
			retreat(delta)
			retreat_cooldown = RETREAT_COOLDOWN
	
	wander_cooldown -= delta
	retreat_cooldown -= delta

func retreat(_delta: float):
	var distance = fish.global_position.distance_to(player.global_position)
	var direction = (fish.global_position - player.global_position).normalized()
	var motion = direction * (max_distance(retreat_range) - distance + retreat_distance)
	move_to(motion)

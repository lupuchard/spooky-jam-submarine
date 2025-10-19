extends FishBehaviorBase
class_name ShyFishBehavior

const PATIENCE_COOLDOWN = 30.0
const ACTION_COOLDOWN = 0.8

@export var patience: int = 999
@export var retreat_range: float = 20.0
@export var retreat_distance: float = 50.0

var retreats := 0

var patience_cooldown := 30.0
var action_cooldown := 0.0

func _behave(delta: float) -> void:
	super._behave(delta)
	
	if action_cooldown <= 0:
		var dist_sqr = fish.global_position.distance_squared_to(player.global_position)
		if dist_sqr < pow(max_distance(retreat_range), 2):
			if retreats < patience:
				retreat(delta)
				retreats += 1
			else:
				attack(delta)
				retreats = 0
			action_cooldown = ACTION_COOLDOWN
	
	patience_cooldown -= delta
	if patience_cooldown <= 0:
		retreats = max(0, retreats - 1)
		patience_cooldown = PATIENCE_COOLDOWN
	
	action_cooldown -= delta
	
	if action_cooldown < -ACTION_COOLDOWN * 10:
		fish.global_position = fish.global_position.move_toward(fish.initial_position, delta * 10.0)

func retreat(_delta: float):
	var distance = fish.global_position.distance_to(player.global_position)
	var direction = (fish.global_position - player.global_position).normalized()
	var motion = direction * (max_distance(retreat_range) - distance + retreat_distance)
	move_to(motion, FishBehaviorBase.Dir.Backward)

func attack(_delta: float):
	var direction = (fish.global_position - player.global_position).normalized()
	var destination = player.global_position - direction * retreat_distance / 2.0
	move_to(destination - fish.global_position, FishBehaviorBase.Dir.Forward, true)

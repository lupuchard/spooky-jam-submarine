extends FishBehaviorBase
class_name PathFishBehavior

@export var speed := 5.0
var path_position := 0.0

func _behave(delta: float):
	var curve = fish.path.curve
	path_position += speed * delta
	if path_position > curve.get_baked_length():
		path_position -= curve.get_baked_length()
	
	var position = fish.path.global_transform * curve.sample_baked(path_position)
	fish.update_facing(position - fish.global_position)
	fish.global_position = position
	

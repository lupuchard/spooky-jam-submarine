extends FishBehaviorBase
class_name WallFishBehavior

const RETREAT_DISTANCE := 120.0

func _behave(_delta: float) -> void:
	pass

func _retreat() -> void:
	var motion = Vector2(RETREAT_DISTANCE, 0.0) if fish.facing_left else Vector2(-RETREAT_DISTANCE, 0.0)
	move_to(motion, FishBehaviorBase.Dir.Backward, true)

func _return() -> void:
	var motion = fish.initial_position - fish.global_position
	move_to(motion, FishBehaviorBase.Dir.Forward, true)

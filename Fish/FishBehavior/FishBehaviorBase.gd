@abstract
extends Resource
class_name FishBehaviorBase

const MOVE_SOUND = preload("res://Assets/Sound/underwater_move.mp3")

# Determines which way the sprite faces when moving
enum Dir {
	Forward,
	Backward
}

var tween: Tween
var player: Player
var fish: Fish

var active_motion = null
var active_motion_direction: Dir
var motion_angle_variance: float = 0.0

func _behave(_delta: float) -> void:
	if active_motion != null:
		try_move()

func move_to(motion: Vector2, direction: Dir = Dir.Forward, force: bool = false):
	active_motion = motion
	active_motion_direction = direction
	motion_angle_variance = 0.0
	try_move(force)

func try_move(force: bool = false):
	var motion = active_motion
	if motion_angle_variance > 0.0:
		var angle = motion.angle() + (randi_range(0, 1) * 2 - 1) * motion_angle_variance
		motion = Vector2.from_angle(angle) * motion.length()
	
	if !force:
		var collision = fish.move_and_collide(motion, true)
		if collision != null:
			motion_angle_variance += PI / 8.0
			if motion_angle_variance > PI:
				active_motion = null
			return
	
	if tween:
		tween.kill()
	tween = fish.create_tween()
	var tweener = tween.tween_property(fish, "global_position", fish.global_position + motion, 1.0)
	tweener.set_ease(Tween.EASE_OUT)
	tweener.set_trans(Tween.TRANS_CUBIC)
	active_motion = null
	fish.update_facing(motion, active_motion_direction == Dir.Backward)
	
	var pitch = 1 / (sqrt(fish.size) / sqrt(10.0))
	var volume = linear_to_db(fish.size * motion.length() / (10.0 * 70.0))
	Audio.play(MOVE_SOUND, fish, volume, pitch * 0.9, pitch * 1.1)
	
	if randi_range(0, 1) == 1:
		Bubbler.spawn_bubbles(fish.global_position, 1, 2)

func max_distance(retreat_range: float):
	return Player.RAYCAST_LENGTH - retreat_range - fish.size

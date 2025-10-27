extends FishBehaviorBase
class_name PufferFishBehavior

const DRUMROLL_LENGTH := 1.5

@export var spike_projectile: PackedScene = null
@export var num_projectiles: int = 16
@export var explode_cooldown: float = 5.0
@export var explosion_sound: AudioStream
var countdown: float = explode_cooldown

func _behave(delta: float):
	if countdown <= DRUMROLL_LENGTH or player.is_target_in_range(fish, 10):
		countdown -= delta
	else:
		countdown = min(countdown + delta, explode_cooldown)
	
	if countdown <= DRUMROLL_LENGTH:
		if !fish.prepare_sound.playing:
			fish.prepare_sound.play()
		fish.position += Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	elif fish.prepare_sound.playing:
		fish.prepare_sound.stop()
	
	if countdown <= 0.0:
		explode()

func explode():
	countdown += explode_cooldown
	var start_angle := randf_range(0, PI)
	for i in range(0, num_projectiles):
		var new_projectile: Node2D = spike_projectile.instantiate()
		new_projectile.top_level = true
		fish.add_child(new_projectile)
		var dir := start_angle + i * (TAU / num_projectiles)
		new_projectile.position = fish.global_position + Vector2.from_angle(dir) * fish.size * 1.2
		new_projectile.rotation = dir
	Audio.play(explosion_sound, fish, 10.0)

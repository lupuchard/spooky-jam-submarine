extends FishBehaviorBase
class_name PufferFishBehavior

const DRUMROLL_LENGTH := 1.5

@export_node_path("Sprite2D") var unpuffed_sprite: NodePath
@export_node_path("Sprite2D") var puffed_sprite: NodePath
@export_node_path("CollisionShape2D") var unpuffed_collision: NodePath
@export_node_path("CollisionShape2D") var puffed_collision: NodePath

@export var spike_projectile: PackedScene = null
@export var num_projectiles: int = 16
@export var explode_cooldown: float = 4.0
@export var explosion_sound: AudioStream
var countdown: float = explode_cooldown
var inflated: bool = false

func _behave(delta: float):
	if countdown <= DRUMROLL_LENGTH or player.is_target_in_range(fish, 10):
		countdown -= delta
	elif !inflated:
		countdown = min(countdown + delta, explode_cooldown)
	else:
		countdown -= delta
	
	if countdown <= DRUMROLL_LENGTH:
		if !fish.prepare_sound.playing:
			fish.prepare_sound.play()
		fish.position += Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	elif fish.prepare_sound.playing:
		fish.prepare_sound.stop()
	
	if countdown <= 0.0:
		explode()
	
	if inflated and countdown < explode_cooldown:
		deflate()

func explode():
	var start_angle := randf_range(0, PI)
	for i in range(0, num_projectiles):
		var new_projectile: Node2D = spike_projectile.instantiate()
		new_projectile.top_level = true
		fish.add_child(new_projectile)
		var dir := start_angle + i * (TAU / num_projectiles)
		new_projectile.position = fish.global_position + Vector2.from_angle(dir) * fish.size * 1.2
		new_projectile.rotation = dir
	Audio.play(explosion_sound, fish, 10.0)
	
	fish.get_node(unpuffed_sprite).visible = false
	fish.get_node(puffed_sprite).visible = true
	fish.get_node(unpuffed_collision).disabled = true
	fish.get_node(puffed_collision).disabled = false
	countdown += explode_cooldown * 3.0
	fish.size *= 2.0
	fish.study_speed /= 8.0
	inflated = true

func deflate():
	fish.get_node(unpuffed_sprite).visible = true
	fish.get_node(puffed_sprite).visible = false
	fish.get_node(unpuffed_collision).disabled = false
	fish.get_node(puffed_collision).disabled = true
	fish.size /= 2.0
	fish.study_speed *= 8.0
	inflated = false

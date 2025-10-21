extends Node

const BUBBLE_PARTICLES = preload("res://Scene/BubbleParticles.tres")
const RANDOM_BUBBLE_COOLDOWN = 1.2

var world: World
var particles: Array[GPUParticles2D] = []
var random_bubble_cooldown := 0.0

func _ready():
	await get_tree().process_frame
	for i in range(0, 4):
		var new_particles := GPUParticles2D.new()
		new_particles.lifetime = 20.0
		new_particles.amount = 64
		new_particles.emitting = false
		new_particles.texture = get_bubble_texture(i)
		new_particles.process_material = BUBBLE_PARTICLES
		new_particles.z_index = -2
		new_particles.process_mode = Node.PROCESS_MODE_ALWAYS
		particles.append(new_particles)
		world.player.add_child(new_particles)

func _process(delta: float):
	random_bubble_cooldown -= delta
	if random_bubble_cooldown < 0:
		random_bubble_cooldown += RANDOM_BUBBLE_COOLDOWN
		var viewport_size = get_viewport().size * 0.5
		var player_pos := world.player.camera.global_position
		var position = Vector2(
			player_pos.x + randf_range(-viewport_size.x, viewport_size.x),
			player_pos.y + viewport_size.y
		)
		spawn_bubbles(position, 1, 2)

func spawn_bubbles(where: Vector2, amount: int, max_size: int = 3, min_size: int = 0):
	if particles.size() == 0:
		return
	
	for i in range(0, amount):
		particles[randi_range(min_size, max_size)].emit_particle(
			Transform2D(0, where), Vector2(), Color(), Color(), 1
		)

func get_bubble_texture(size: int):
	match size:
		0: return preload("res://Assets/Bubbles/bubble2x2.png")
		1: return preload("res://Assets/Bubbles/bubble4x4.png")
		2: return preload("res://Assets/Bubbles/bubble8x8.png")
		3: return preload("res://Assets/Bubbles/bubble12x12.png")
	
	

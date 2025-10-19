extends StaticBody2D
class_name Fish
@export var fish_type: FishStudy.FishType

# Determines how close the player needs to be to scan the fish
@export var size: float = 20.0

# How many of the player's raycasts are needed to scan the fish - more for larger fish
@export var raycasts_needed: int = 1
@export var study_speed: float = 1.0
@export var study_reward_factor: int = 1

@export var bob_amount: float = 5.0
@export var is_sprite_facing_left: bool = true
@export var flip: bool = false
@export var contact_damage: float = 0.0

@export var idle_sound_period := 10.0

@export var behavior: FishBehaviorBase = null

var studied = false
var study_progress: float = 0.0
var facing_left: bool
var initial_position: Vector2
var idle_sound_cooldown := 0.0

var body: Node2D
var movement_sound: AudioStreamPlayer2D
var idle_sound: AudioStreamPlayer2D

func _ready():
	body = $Body
	movement_sound = find_child("MovementSound", false)
	idle_sound = find_child("IdleSound", false)
	idle_sound_cooldown = idle_sound_period
	
	facing_left = is_sprite_facing_left
	if flip: set_facing(!facing_left)
	initial_position = global_position
	
	collision_layer = 2
	
	if contact_damage > 0.0:
		create_area_collider()
	
	if behavior != null:
		behavior = behavior.duplicate()
		behavior.fish = self
		behavior.player = %Player

func create_area_collider():
	print("collider for %s" % name)
	var area = Area2D.new()
	var shapes = find_children("*", "CollisionShape2D", true, false)
	area.collision_layer = 1
	area.collision_mask = 1
	for shape in shapes:
		area.add_child(shape.duplicate())
	add_child(area)
	area.position = Vector2.ZERO
	area.body_entered.connect(func(player):
		if player is Player:
			player.handle_fish_collision(self)
	)

var time_passed = 0
func _process(delta: float):
	time_passed += delta
	body.position.y = sin(time_passed) * bob_amount
	
	if behavior != null:
		behavior._behave(delta)
	
	idle_sound_cooldown -= delta
	if idle_sound_cooldown <= 0 and idle_sound != null:
		idle_sound.play()
		idle_sound_cooldown = randf_range(idle_sound_period, idle_sound_period * 3)

func set_facing(left: bool) -> void:
	if left != facing_left:
		facing_left = !facing_left
		body.scale.x = -body.scale.x

func update_facing(dir: Vector2, flipped: bool = false):
	if dir.x < -1.0:
		set_facing(!flipped)
	elif dir.x > 1.0:
		set_facing(flipped)

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
@export var behavior: FishBehaviorBase = null

var studied = false
var study_progress: float = 0.0
var facing_left: bool

var body: Node2D

func _ready():
	body = $Body
	facing_left = is_sprite_facing_left
	if flip: set_facing(!facing_left)
	
	collision_layer = 1 | 2
	
	if behavior != null:
		behavior = behavior.duplicate()
		behavior.fish = self
		behavior.player = %Player

var time_passed = 0
func _process(delta: float):
	time_passed += delta
	body.position.y = sin(time_passed) * bob_amount
	
	if behavior != null:
		behavior._behave(delta)

func set_facing(left: bool) -> void:
	if left != facing_left:
		facing_left = !facing_left
		body.scale.x = -body.scale.x

func update_facing(dir: Vector2, flipped: bool = false):
	if dir.x < -1.0:
		set_facing(!flipped)
	elif dir.x > 1.0:
		set_facing(flipped)

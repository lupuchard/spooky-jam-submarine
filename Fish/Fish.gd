extends StaticBody2D
class_name Fish

enum Facing {
	Left,
	Right
}

@export var fish_type: FishStudy.FishType

# Determines how close the player needs to be to scan the fish
@export var size: float = 20.0

# How many of the player's raycasts are needed to scan the fish - more for larger fish
@export var raycasts_needed: int = 1
@export var study_speed: float = 1.0
@export var study_reward_factor: int = 1

@export var bob_amount: float = 5.0
@export var facing_initial: Facing = Facing.Left
@export var behavior: FishBehaviorBase = null

var studied = false
var study_progress: float = 0.0
var facing: Facing

func _ready():
	facing = facing_initial
	collision_layer = 1 | 2
	
	if behavior != null:
		behavior.player = %Player

var time_passed = 0
func _process(delta: float):
	time_passed += delta
	$BodySprite.position.y = sin(time_passed) * bob_amount
	
	if behavior != null:
		behavior._behave(delta, self)

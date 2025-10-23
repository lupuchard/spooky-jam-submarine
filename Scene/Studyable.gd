extends StaticBody2D
class_name Studyable

# Determines how close the player needs to be to scan the fish
@export var size: float = 20.0

# How many of the player's raycasts are needed to scan the fish - more for larger fish
@export var raycasts_needed: int = 1
@export var study_speed: float = 1.0
@export var study_reward: Player.Res = Player.Res.Research
@export var study_reward_factor: int = 1

var study_progress: float = 0.0

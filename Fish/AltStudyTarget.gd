extends StaticBody2D
class_name AltStudyTarget

@export var studyable: Studyable
@export var study_speed_modifier: float = 1.0

func _ready():
	collision_layer = 2

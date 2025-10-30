extends Sprite2D

@export var ANGLE_MIN: float
@export var ANGLE_MAX: float
@export var PERIOD: float
var tween: Tween

func _ready():
	rotation = deg_to_rad(ANGLE_MIN)
	
	tween = create_tween()
	var prop_to = tween.tween_property(self, "rotation", deg_to_rad(ANGLE_MAX), PERIOD)
	prop_to.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var prop_from = tween.tween_property(self, "rotation", deg_to_rad(ANGLE_MIN), PERIOD)
	prop_from.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_loops()

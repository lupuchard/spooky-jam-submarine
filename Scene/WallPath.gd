extends Path2D

const SEGMENT_LENGTH := 20.0
@export var color := Color(0.45, 0.4, 0.35)
@export var background := false

func _enter_tree():
	var wall = Wall.new()
	wall.color = color
	curve.bake_interval = SEGMENT_LENGTH
	wall.polygon = curve.get_baked_points()
	wall.background = background
	add_child(wall)

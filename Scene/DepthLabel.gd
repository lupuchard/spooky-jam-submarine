extends Label

func _process(_delta: float) -> void:
	var depth = %Player.global_position.y
	text = "-" if depth < 0 else World.format_depth(depth, 0)

extends Label

func _process(_delta: float) -> void:
	var depth = %Player.global_position.y
	text = "-" if depth < 0 else World.format_depth(depth, 0)
	
	if %Player.too_deep and !has_theme_color_override("font_color"):
		add_theme_color_override("font_color", Color.RED)
	elif !%Player.too_deep and has_theme_color_override("font_color"):
		remove_theme_color_override("font_color")
		

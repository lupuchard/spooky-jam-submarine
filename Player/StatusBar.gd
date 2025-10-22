extends ColorRect

@export var player: Player
@export var stat: Player.Stat

var max_width
var label: Label

func _ready():
	max_width = size.x
	label = find_child("Label", false)

func _process(_delta: float):
	size.x = min(round(player.stats[stat] / player.max_stats[stat] * max_width), max_width)
	
	if label != null:
		label.visible = player.stats[stat] >= player.max_stats[stat]

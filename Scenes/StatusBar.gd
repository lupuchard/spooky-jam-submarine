extends ColorRect

@export var player: Player
@export var stat: Player.Stat

var max_width

func _ready():
	max_width = size.x

func _process(_delta: float):
	size.x = min(round(player.stats[stat] / player.maxStats[stat] * max_width), max_width)

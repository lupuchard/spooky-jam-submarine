extends Label

@export var player: Player
@export var resource: Player.Res

var max_width

func _process(_delta: float):
	text = str(player.resources[resource])

extends Label

@export var player: Player

func _process(_delta: float):
	text = "<".repeat(player.get_current_power_drain())

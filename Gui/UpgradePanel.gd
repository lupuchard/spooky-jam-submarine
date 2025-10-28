extends Control

@export var player: Player

@onready var label := $Label

func _process(_delta: float) -> void:
	if visible:
		label.text = "Total research points: %s\nUnspent points: %s" % [
			player.resource_totals[Player.Res.Research],
			player.resources[Player.Res.Research]
		]

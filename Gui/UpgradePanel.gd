extends Control

@export var player: Player

func _process(_delta: float) -> void:
	if visible:
		$Label.text = "Total research points: %s\nUnspent points: %s" % [
			player.resource_totals[Player.Res.Research],
			player.resources[Player.Res.Research]
		]

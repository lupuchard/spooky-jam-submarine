extends PanelContainer

@export var player: Player

func _process(_delta: float) -> void:
	if visible:
		$Container/Label.text = "Total research points: %s\nUnspent points: %s" % [
			player.total_research,
			player.resources[Player.Res.Research]
		]

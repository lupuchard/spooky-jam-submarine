extends VBoxContainer

@export var player: Player

func _process(_delta: float) -> void:
	if visible:
		$Label.text = "Unspent anomalies: %s" % [
			player.resources[Player.Res.Anomalies]
		]

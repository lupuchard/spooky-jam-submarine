extends VBoxContainer

@onready var label := $Label
@export var player: Player

func _process(_delta: float) -> void:
	if visible:
		label.text = "Unspent anomalies: %s" % [
			player.resources[Player.Res.Anomalies]
		]

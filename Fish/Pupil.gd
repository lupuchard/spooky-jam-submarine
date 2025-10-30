extends Node2D

var player: Player

func _process(_delta: float):
	look_at(player.global_position)

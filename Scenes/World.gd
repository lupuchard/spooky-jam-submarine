extends Node2D

func _ready():
	var fishies = get_tree().get_nodes_in_group("fish_body")
	for fish in fishies:
		fish.material = preload("res://Scenes/FishBody.tres")

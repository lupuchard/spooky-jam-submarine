extends Node2D

var anomalies: Array[Node2D]

func _ready():
	anomalies.assign(get_tree().get_nodes_in_group("anomaly"))

func _process(_delta: float):
	var closest: Node2D
	var closest_dist_sqr: float = INF
	for anomaly in anomalies:
		if anomaly.studied:
			continue
		
		var dist_sqr = anomaly.global_position.distance_squared_to(%Player.global_position)
		if dist_sqr < closest_dist_sqr:
			closest = anomaly
			closest_dist_sqr = dist_sqr
	
	if closest != null:
		visible = true
		transform = closest.get_screen_transform()
	else:
		visible = false

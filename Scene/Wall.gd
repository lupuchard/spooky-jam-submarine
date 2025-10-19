extends Polygon2D

func _ready():
	seed(15)
	random_detail()
	#random_detail()
	randomize()
	
	set_up_collision()
	set_up_occluder()

func random_detail():
	var new_polygon = PackedVector2Array()
	for i in range(0, polygon.size() - 1):
		new_polygon.append(polygon[i])
		var new_point = (polygon[i] + polygon[i + 1]) * 0.5
		var perp_direction = (polygon[i] - polygon[i + 1]).rotated(PI / 2.0)
		new_polygon.append(new_point + perp_direction * randf_range(-0.05, 0.05))
	polygon = new_polygon

func set_up_collision():
	var collision = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = ConcavePolygonShape2D.new()
	
	var segments = PackedVector2Array()
	for i in range(0, polygon.size() - 1):
		segments.append(polygon[i])
		segments.append(polygon[i + 1])
	shape.shape.segments = segments
	
	collision.add_child(shape)
	collision.collision_layer = 1 | 2
	add_child(collision)

func set_up_occluder():
	var occluder = LightOccluder2D.new()
	occluder.occluder = OccluderPolygon2D.new()
	occluder.occluder.polygon = polygon
	add_child(occluder)

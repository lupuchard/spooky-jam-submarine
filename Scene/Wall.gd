extends Polygon2D

func _ready():
	set_up_collision()
	set_up_occluder()

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

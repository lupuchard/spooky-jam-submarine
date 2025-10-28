extends Studyable
class_name Anomaly

const RAYCASTS_NEEDED := 4
const GRAVITY_RANGE := 512.0
const GRAVITY_STRENGTH := 50.0

@onready var collision = $CollisionShape2D

var studied: bool = false:
	set(value):
		if studied != value:
			studied = value
			update_studied()

func _ready():
	create_area_collider()

func _physics_process(delta: float):
	var player := %Player
	
	var dist_sqr = player.global_position.distance_squared_to(global_position)
	if dist_sqr < pow(GRAVITY_RANGE, 2):
		var pull = (1.0 - (sqrt(dist_sqr) / GRAVITY_RANGE)) * GRAVITY_STRENGTH
		player.global_position = player.global_position.move_toward(global_position, delta * pull)

func create_area_collider():
	var area = Area2D.new()
	area.collision_layer = 8 # Layer 4
	area.collision_mask = 8 # Layer 4
	area.add_child(collision.duplicate())
	add_child(area)
	area.position = Vector2.ZERO
	area.body_entered.connect(func(player):
		if player is Player:
			player.anomaly_drain_on = true
	)
	area.body_exited.connect(func(player):
		if player is Player:
			player.anomaly_drain_on = false
	)

func update_studied():
	if studied:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		visible = true
		process_mode = Node.PROCESS_MODE_INHERIT

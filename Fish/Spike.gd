extends Area2D

@export var speed: float = 100.0
@export var damage: float = 3.0
@export var lifespan: float = 10.0

func _ready():
	collision_layer = 1
	collision_mask = 1
	
	body_entered.connect(func(player):
		if player is Player:
			on_collide_with_player(player)
	)

func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation) * speed * delta
	
	lifespan -= delta
	if lifespan < 0.0:
		queue_free()

func on_collide_with_player(player: Player) -> void:
	player.handle_damage(damage, rotation, speed / 20.0)
	queue_free()

extends Area2D

@export var damage: float = 3.0

func _ready():
	collision_layer = 1
	collision_mask = 1
	
	body_entered.connect(func(player):
		if player is Player:
			on_collide_with_player(player)
	)

func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation) * 10.0 * delta

func on_collide_with_player(player: Player) -> void:
	player.handle_damage(damage, rotation, 1.0)

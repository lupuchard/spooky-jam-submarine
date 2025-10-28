extends Area2D

@export var damage: float = 5.0
@export var damage_speed: float = 2.0
@export var attack_cooldown_min: float = 5.0
@export var attack_cooldown_max: float = 15.0
@export var move_range: float = 40.0
@export var attack_range: float = 150.0

@onready var initial_position := position
@onready var attack_timer: Timer = Timer.new()
var tween: Tween = null

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	
	body_entered.connect(func(player):
		if player is Player:
			on_collide_with_player(player)
	)
	
	add_child(attack_timer)
	attack_timer.timeout.connect(tween_attack)
	
	reset_attack_timer()

func _process(_delta: float) -> void:
	if attack_timer.time_left < 1.5:
		if tween != null:
			tween.kill()
			tween = null
		position += Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))

func on_collide_with_player(player: Player) -> void:
	player.handle_damage(damage, rotation, damage_speed)

func tween_movement() -> void:
	if tween != null:
		tween.kill()
	
	var destination = initial_position + Vector2(randf_range(-move_range, move_range), 0)
	tween = create_tween()
	var prop = tween.tween_property(self, "position", destination, 3.0)
	prop.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(tween_movement)

func tween_attack() -> void:
	if tween != null:
		tween.kill()
	
	var destination = position + Vector2(0, -attack_range)
	tween = create_tween()
	var prop = tween.tween_property(self, "position", destination, 1.0)
	prop.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(reset_attack_timer)

func reset_attack_timer() -> void:
	attack_timer.start(randf_range(attack_cooldown_min, attack_cooldown_max))
	tween_movement()

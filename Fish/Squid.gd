extends Fish
class_name Squid

const PROJECTILE_COOLDOWN := 5.0
const STRIKE_COOLDOWN := 8.2
const PROJECTILE = preload("res://Fish/SquidProjectile.tscn")

@export var engagement_range: float = 400.0

@onready var striker := $Striker
@onready var striker_indicator := $Striker/Indicator
@onready var striker_arm := $Striker/Arm

var projectile_cooldown: float = PROJECTILE_COOLDOWN
var strike_cooldown: float = STRIKE_COOLDOWN
var strike_timer := Timer.new()
var striking := false

func _ready():
	%PupilOrigin.player = %Player
	striker_arm.position.y = -10000
	
	add_child(strike_timer)
	strike_timer.one_shot = true
	strike_timer.timeout.connect(func():
		execute_strike()
	)
	
	super._ready()

func _process(delta: float):
	projectile_cooldown -= delta
	strike_cooldown -= delta
	
	if projectile_cooldown < 0.0:
		shoot_projectile()
		projectile_cooldown += PROJECTILE_COOLDOWN
	
	if strike_cooldown < 0.0:
		prepare_strike()
		strike_cooldown += STRIKE_COOLDOWN
	
	if striking:
		Bubbler.spawn_bubbles(striker_arm.position, 1)
	
	super._process(delta)

func is_in_range():
	return global_position.distance_squared_to(%Player.global_position) < pow(engagement_range, 2)

func shoot_projectile():
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		var new_projectile: Node2D = PROJECTILE.instantiate()
		add_child(new_projectile)
		new_projectile.look_at(%Player.global_position)
		Audio.play(preload("res://Assets/Sound/shot.mp3"), self, 0.0, 1.5)
	)
	tween.set_loops(3)
	
func prepare_strike():
	striker.position.x = randf_range(40.0, 160.0)
	striker_indicator.visible = true
	strike_timer.start(2.0)

func execute_strike():
	striking = true
	striker_indicator.visible = false
	striker_arm.position = Vector2(0, 600)
	var tween = create_tween()
	tween.tween_property(striker_arm, "position", Vector2(0, -600), 0.3)
	tween.finished.connect(func():
		striking = false
		striker_arm.position.y = -10000
	)
	Audio.play(preload("res://Assets/Sound/woosh.mp3"), striker)

extends Studyable
class_name Fish

const CONTACT_RESTORE_COOLDOWN: float = 20.0

@export var fish_type: FishStudy.FishType

@export var bob_amount: float = 5.0
@export var is_sprite_facing_left: bool = true
@export var flip: bool = false

@export var contact_damage: float = 0.0
@export var contact_restore: float = 0.0
@export var contact_restore_stat: Player.Stat = Player.Stat.Battery

@export var idle_sound_period := 10.0

@export var behavior: FishBehaviorBase = null
@export var path: Path2D = null

var studied = false
var facing_left: bool
var initial_position: Vector2
var idle_sound_cooldown := 0.0

@onready var body: Node2D = $Body
@onready var light: Node2D = get_node_or_null("%Light")
@onready var movement_sound: AudioStreamPlayer2D = get_node_or_null("MovementSound")
@onready var idle_sound: AudioStreamPlayer2D = get_node_or_null("IdleSound")
@onready var prepare_sound: AudioStreamPlayer2D = get_node_or_null("PrepareSound")
@onready var unstudied_sound: AudioStreamPlayer2D = get_node_or_null("UnstudiedSound")

var prev_position: Vector2

var contact_restore_cooldown: float = 0.0

func _ready():
	idle_sound_cooldown = idle_sound_period
	
	facing_left = is_sprite_facing_left
	if flip: set_facing(!facing_left)
	initial_position = global_position
	
	collision_layer = 2
	
	if contact_damage > 0.0 or contact_restore > 0.0:
		create_area_collider()
	
	if behavior != null:
		behavior = behavior.duplicate()
		behavior.fish = self
		behavior.player = %Player

func create_area_collider():
	var area = Area2D.new()
	var shapes = find_children("*", "CollisionShape2D", false, false)
	area.collision_layer = 1
	area.collision_mask = 1
	for shape in shapes:
		area.add_child(shape.duplicate())
	add_child(area)
	area.position = Vector2.ZERO
	area.body_entered.connect(func(player):
		if player is Player:
			on_collide_with_player(player)
	)

var time_passed = 0
func _process(delta: float):
	time_passed += delta
	body.position.y = sin(time_passed) * bob_amount
	
	prev_position = global_position
	if behavior != null:
		behavior._behave(delta)
	
	idle_sound_cooldown -= delta
	if idle_sound_cooldown <= 0 and idle_sound != null:
		idle_sound.play()
		idle_sound_cooldown = randf_range(idle_sound_period, idle_sound_period * 3)
	
	contact_restore_cooldown -= delta
	if contact_restore_cooldown < 0.0 and light != null and light.visible == false:
		%Light.visible = true
		behavior._return()
	
	if unstudied_sound:
		if studied and unstudied_sound.playing:
			unstudied_sound.stop()
		elif !studied and !unstudied_sound.playing:
			unstudied_sound.play()

func set_facing(left: bool) -> void:
	if left != facing_left:
		facing_left = !facing_left
		scale.x = -scale.x

func update_facing(dir: Vector2, flipped: bool = false) -> void:
	if dir.x < -1.0:
		set_facing(!flipped)
	elif dir.x > 1.0:
		set_facing(flipped)

func on_collide_with_player(player: Player) -> void:
	if contact_damage > 0.0:
		var angle = (global_position - prev_position).angle()
		var speed = (global_position - prev_position).length()
		player.handle_fish_collision(self, angle, speed)
		
	if contact_restore > 0.0 and contact_restore_cooldown <= 0.0:
		if player.restore_stat(contact_restore_stat, contact_restore):
			contact_restore_cooldown = CONTACT_RESTORE_COOLDOWN
			behavior._retreat()
			light.visible = false
			Audio.play(preload("res://Assets/Sound/surge.mp3"), self)
			Audio.play(preload("res://Assets/Sound/taser.mp3"), self)

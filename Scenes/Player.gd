extends CharacterBody2D
class_name Player

enum Stat {
	Health,
	Power,
	DashPower,
	NUM_STATS
}

enum Res {
	Knowledge,
	NUM_RESOURCES
}

const HORZ_ACCEL = 6.0
const HORZ_TOP_SPEED = 1.5
const DASH_SPEED = 3.0

const DESC_ACCEL = 4.0
const DESC_TOP_SPEED = 1.2

const ASC_ACCEL = 4.0
const ASC_TOP_SPEED = 1.2

const DASH_COOLDOWN = 1.5

const COLLISION_THRESH := 0.1
const COLLISION_DAMAGE_MOD := 1.0

const NUM_RAYCASTS := 8
const RAYCAST_ANGLE := PI / 3
const RAYCAST_LENGTH := 240

var vel := Vector2.ZERO
var dash_direction := 1.0

var stats: Array[float] = []
var maxStats: Array[float] = []
var resources: Array[int] = []

var engines_on := false
var pumps_on := false
var idle_power_drain := 0.1
var engine_power_drain := 0.3
var pump_power_drain := 0.2

var studying: Fish = null
var study_speed: float = 0.2

func _ready():
	maxStats.resize(Stat.NUM_STATS)
	maxStats[Stat.Health] = 10.0
	maxStats[Stat.Power] = 100.0
	maxStats[Stat.DashPower] = DASH_COOLDOWN
	
	stats.resize(Stat.NUM_STATS)
	for i in range(0, Stat.NUM_STATS):
		stats[i] = maxStats[i]
	
	resources.resize(Res.NUM_RESOURCES)
	for i in range(0, Res.NUM_RESOURCES):
		resources[i] = 0
	
	generate_raycasts()

func generate_raycasts():
	var raycast_spacing = RAYCAST_ANGLE / (NUM_RAYCASTS + 2)
	for i in range(0, NUM_RAYCASTS):
		var angle = raycast_spacing * (i + 1) - RAYCAST_ANGLE / 2
		var raycast := RayCast2D.new()
		raycast.target_position = Vector2.from_angle(angle) * RAYCAST_LENGTH
		raycast.collision_mask = 2
		$Spotlight.add_child(raycast)

func _process(delta: float):
	stats[Stat.Power] -= idle_power_drain * delta
	if engines_on:
		stats[Stat.Power] -= engine_power_drain * delta
	if pumps_on:
		stats[Stat.Power] -= pump_power_drain * delta
	
	stats[Stat.DashPower] += delta
	
	$Spotlight.rotation = Vector2.LEFT.angle_to(position - get_parent().get_local_mouse_position())
	
	check_raycasts()
	
	if studying != null:
		$StudyIndicator.visible = true
		$StudyIndicator.update_to(studying)
		if !studying.studied:
			studying.study_progress += delta * studying.study_speed * study_speed
			if studying.study_progress >= 1.0:
				var reward = Study.add_studied(studying)
				notify("+%s Knowledge" % reward)
				resources[Res.Knowledge] += reward
	else:
		$StudyIndicator.visible = false

func notify(text: String):
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	label.material = preload("res://Scenes/IgnoreLight.tres")
	add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position", Vector2(randf_range(-4, 4), -50), 4)
	tween.finished.connect(func():
		label.queue_free()
	)

func check_raycasts():
	var casted: Dictionary[Fish, int] = {}
	for child in $Spotlight.get_children():
		if child is RayCast2D and child.is_colliding():
			var collider = child.get_collider()
			if collider is Fish:
				casted.set(collider, casted.get(collider, 0) + 1)
	
	if studying != null and is_fish_in_range(studying, casted.get(studying, 0)):
		return
	
	studying = null
	for fish in casted:
		if is_fish_in_range(fish, casted[fish]):
			studying = fish
			break

func is_fish_in_range(fish: Fish, raycasts: int) -> bool:
	if raycasts < fish.raycasts_needed: return false
	var distance_sqr = fish.global_position.distance_squared_to(global_position)
	return distance_sqr < pow(RAYCAST_LENGTH - fish.size, 2)

func _physics_process(delta: float):
	var prev_vel = vel
	engines_on = true
	if Input.is_action_pressed("right"):
		vel.x = move_toward(vel.x, HORZ_TOP_SPEED, delta * HORZ_ACCEL)
		dash_direction = 1.0
	elif Input.is_action_pressed("left"):
		vel.x = move_toward(vel.x, -HORZ_TOP_SPEED, delta * HORZ_ACCEL)
		dash_direction = -1.0
	else:
		engines_on = false
		vel.x = move_toward(vel.x, 0, delta * HORZ_ACCEL)
	
	pumps_on = true
	if Input.is_action_pressed("ascend"):
		vel.y = move_toward(vel.y, -ASC_TOP_SPEED, delta * ASC_ACCEL)
	elif Input.is_action_pressed("descend"):
		vel.y = move_toward(vel.y, DESC_TOP_SPEED, delta * DESC_ACCEL)
	else:
		pumps_on = false
		vel.y = move_toward(vel.y, 0, delta * max(ASC_ACCEL, DESC_ACCEL))
	
	if stats[Stat.DashPower] >= DASH_COOLDOWN and Input.is_action_just_pressed("dash"):
		vel.x += dash_direction * DASH_SPEED
		stats[Stat.DashPower] = 0
	
	var collision = move_and_collide(vel)
	if collision != null:
		var collision_direction = Vector2.from_angle(collision.get_angle() + PI / 2)
		var collision_speed = abs(collision_direction.dot(prev_vel))
		if collision_speed > COLLISION_THRESH:
			stats[Stat.Health] -= collision_speed * COLLISION_DAMAGE_MOD
			Audio.play(preload("res://Assets/Sound/crash.mp3"), self, linear_to_db(collision_speed), 0.4, 0.6)
		vel = Vector2.ZERO
		

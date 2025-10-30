extends CharacterBody2D
class_name Player

enum Stat {
	Health,
	MaxDepth,
	Battery,
	Speed,
	DashPower,
	DashSpeed,
	Light,
	StudySpeed,
	NUM_STATS
}

enum Res {
	Research,
	Anomalies,
	NUM_RESOURCES
}

enum UpgradeType {
	Hull,
	Battery,
	Speed,
	Light,
	Dash,
	Scanner,
	NUM_UPGRADES
}

const HORZ_ACCEL = 6.0
const HORZ_TOP_SPEED = 1.5
const BACKWARD_SPEED_FACTOR = 0.5

const DESC_ACCEL = 4.0
const DESC_TOP_SPEED = 1.2
const POWER_CONSUMPTION = 0.5
const PROPELLER_BUBBLE_COOLDOWN = 0.5

const ASC_ACCEL = 4.0
const ASC_TOP_SPEED = 1.2

const DASH_COOLDOWN = 1.5

const COLLISION_THRESH := 0.1
const COLLISION_DAMAGE_MOD := 1.0
const KNOCKBACK_STRENGTH := 0.5
const MAX_KNOCKBACK := 6.0
const FISH_CONTACT_COOLDOWN := 1.0

const NUM_RAYCASTS := 10
const RAYCAST_ANGLE := PI / 3
const BASE_RAYCAST_LENGTH := 120

const DEPTH_DAMAGE := 0.5
const DEPTH_DAMAGE_DELAY := 1.0
const MAX_VEHICLE_AMBIENCE_DEPTH := 1200

const CRASH_SOUND = preload("res://Assets/Sound/crash.mp3")
const DASH_SOUND = preload("res://Assets/Sound/underwater_splash.mp3")
const CLICK_SOUND = preload("res://Assets/Sound/click.ogg")
const ANOMALY_COLLECT_SOUND = preload("res://Assets/Sound/anomaly_collect.mp3")
const DEATH_SOUND_METAL = preload("res://Assets/Sound/metal_wobble.mp3")
const TOGGLE_LIGHT_SOUND = preload("res://Assets/Sound/switch.wav")

@export var flicker_texture: NoiseTexture2D
var flicker_level = 0.1

@onready var camera: Camera2D = $Camera2D
@onready var spotlight: Node2D = $Spotlight
@onready var spotlight1: PointLight2D = $Spotlight/Spotlight1
@onready var spotlight2: PointLight2D = $Spotlight/Spotlight2
@onready var body := $Body
@onready var vehicle_ambience := $VehicleAmbience
@onready var hull_creak := $HullCreak
var vel := Vector2.ZERO
var time_passed := 0.0

var stats: Array[float] = []
var max_stats: Array[float] = []
var resources: Array[int] = []
var resource_totals: Array[int] = []

class Upgrade:
	func _init(_name: String, _stats: Array[Stat], _cost_resource: Res = Res.Research) -> void:
		self.name = _name
		self.stats = _stats
		self.cost_resource = _cost_resource
	var name: String
	var stats: Array[Stat]
	var costs: PackedInt32Array = []
	var cost_resource: Res = Res.Research
	var values: Array[PackedFloat64Array] = []
var upgrades: Array[Upgrade]
var upgrade_levels: Array[int]

var engines_on := false
var pumps_on := false
var anomaly_drain_on := false
var base_power_drain := 0.5
var propeller_bubble_cooldown := PROPELLER_BUBBLE_COOLDOWN

var fish_contact_cooldown := 0.0

var studying: Studyable = null
var studying_mod: float = 1.0

var too_deep: bool = false
var depth_damage_delay: float = 0.0
var hull_creak_tween: Tween = null

func _ready():
	max_stats.resize(Stat.NUM_STATS)
	max_stats[Stat.DashPower] = DASH_COOLDOWN
	
	stats.resize(Stat.NUM_STATS)
	for i in range(0, Stat.NUM_STATS):
		stats[i] = max_stats[i]
	
	resources.resize(Res.NUM_RESOURCES)
	resource_totals.resize(Res.NUM_RESOURCES)
	
	upgrades.resize(UpgradeType.NUM_UPGRADES)
	upgrade_levels.resize(UpgradeType.NUM_UPGRADES)
	
	var hull_upgrade := Upgrade.new("Hull", [Stat.Health, Stat.MaxDepth])
	hull_upgrade.costs = [0, 20, 50, 80]
	hull_upgrade.values.append(PackedFloat64Array([10.0, 15.0, 20.0, 30.0])) # Health
	hull_upgrade.values.append(PackedFloat64Array([10000.0, 2000.0, 3000.0, 4000.0])) # Max Depth
	upgrades[UpgradeType.Hull] = hull_upgrade
	
	var speed_upgrade := Upgrade.new("Speed", [Stat.Speed])
	speed_upgrade.costs = [0, 30, 60]
	speed_upgrade.values = [[1.0, 1.16, 1.35]]
	upgrades[UpgradeType.Speed] = speed_upgrade
	
	var battery_upgrade := Upgrade.new("Battery", [Stat.Battery])
	battery_upgrade.costs = [0, 20, 50, 80]
	battery_upgrade.values = [[100.0, 150.0, 200.0, 300.0]]
	upgrades[UpgradeType.Battery] = battery_upgrade
	
	var dash_upgrade := Upgrade.new("Dash Speed", [Stat.DashSpeed], Res.Anomalies)
	dash_upgrade.costs = [0, 1]
	dash_upgrade.values = [[2.8, 3.5]]
	upgrades[UpgradeType.Dash] = dash_upgrade
	
	var light_upgrade := Upgrade.new("Light", [Stat.Light], Res.Anomalies)
	light_upgrade.costs = [0, 1]
	light_upgrade.values = [[1.0, 1.25]]
	upgrades[UpgradeType.Light] = light_upgrade
	
	var scanner_upgrade := Upgrade.new("Scanner", [Stat.StudySpeed], Res.Anomalies)
	scanner_upgrade.costs = [0, 1]
	scanner_upgrade.values = [[0.2, 0.4]]
	upgrades[UpgradeType.Scanner] = scanner_upgrade
	
	for i in range(0, UpgradeType.NUM_UPGRADES):
		set_upgrade_level(i, 0)
	
	generate_raycasts()

func set_upgrade_level(upgrade_type: UpgradeType, level: int) -> void:
	var upgrade := upgrades[upgrade_type]
	for i in range(0, upgrade.stats.size()):
		var stat = upgrade.stats[i]
		var value_arr := upgrade.values[i]
		max_stats[stat] = value_arr[min(level, value_arr.size() - 1)]
		stats[stat] = max_stats[stat]
	upgrade_levels[upgrade_type] = level

func raycast_length() -> float:
	return BASE_RAYCAST_LENGTH * stats[Stat.Light]

# Raycasts are used to detect if fish are in the player's light cone
func generate_raycasts() -> void:
	for child in spotlight.get_children():
		if child is RayCast2D:
			child.queue_free()
	
	var num_raycasts = NUM_RAYCASTS if spotlight1.visible else NUM_RAYCASTS + 4
	var raycast_spacing = RAYCAST_ANGLE / (num_raycasts + 1)
	for i in range(0, num_raycasts):
		var angle = raycast_spacing * (i + 1) - RAYCAST_ANGLE / 2
		var raycast := RayCast2D.new()
		raycast.target_position = Vector2.from_angle(angle) * raycast_length()
		raycast.collision_mask = 2
		spotlight.add_child(raycast)

func get_current_power_drain() -> int:
	var total = 0
	if is_light_on(): total += 1
	if engines_on: total += 1
	if pumps_on: total += 1
	if anomaly_drain_on: total += 3
	if stats[Stat.DashPower] < max_stats[Stat.DashPower]: total += 2
	return total

func check_light_upgrade() -> void:
	if upgrade_levels[UpgradeType.Light] == 1 and spotlight1.visible:
		spotlight1.visible = false
		spotlight2.visible = true
		generate_raycasts()
	elif upgrade_levels[UpgradeType.Light] == 0 and !spotlight1.visible:
		spotlight1.visible = true
		spotlight2.visible = false
		generate_raycasts()

func _input(input: InputEvent) -> void:
	var look_vector := Vector2.ZERO
	if input is InputEventMouseMotion:
		look_vector = get_parent().get_local_mouse_position() - position
	else:
		look_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	if look_vector != Vector2.ZERO:
		spotlight.rotation = Vector2.RIGHT.angle_to(look_vector)
		body.scale.x = 1 if look_vector.x < 0 else -1

func _process(delta: float):
	check_light_upgrade()
	
	fish_contact_cooldown -= delta
	stats[Stat.Battery] -= get_current_power_drain() * base_power_drain * delta
	stats[Stat.DashPower] += delta
	
	if Input.is_action_just_pressed("toggle_light"):
		if spotlight.visible:
			Audio.play(TOGGLE_LIGHT_SOUND, null, -5.0, 0.85)
			spotlight.visible = false
		else:
			Audio.play(TOGGLE_LIGHT_SOUND, null, -5.0)
			spotlight.visible = true
	
	if spotlight.visible:
		check_raycasts()
	else:
		studying = null
	
	time_passed += delta
	var flicker = sqrt(abs(flicker_texture.noise.get_noise_1d(time_passed))) * 0.5
	flicker = lerp(0.2, flicker, flicker_level)
	spotlight1.energy = flicker
	spotlight2.energy = flicker
	
	if studying != null:
		%StudyIndicator.visible = true
		%StudyIndicator.update_to(studying)
		if !studying.studied:
			var study_speed = studying.study_speed * stats[Stat.StudySpeed] * studying_mod
			studying.study_progress += delta * study_speed
			if studying.study_progress >= 1.0:
				if studying.study_reward == Player.Res.Research:
					var reward = Study.add_studied(studying)
					notify("+%s Research Points" % reward)
					Audio.play(CLICK_SOUND)
					gain_resource(Res.Research, reward)
					
					if studying is Fish and studying.fish_type == FishStudy.FishType.Squid:
						%YouWinPanel.visible = true
						%World.process_mode = Node.PROCESS_MODE_DISABLED
						Audio.play(preload("res://Assets/Sound/glissando.mp3"))
				elif studying.study_reward == Player.Res.Anomalies:
					studying.studied = true
					notify("+1 Anomaly")
					Audio.play(ANOMALY_COLLECT_SOUND)
					gain_resource(Res.Anomalies, 1)
					anomaly_drain_on = false
					spotlight.visible = false
	else:
		%StudyIndicator.visible = false
	
	if global_position.y > stats[Stat.MaxDepth] and !too_deep:
		too_deep = true
		depth_damage_delay = DEPTH_DAMAGE_DELAY
		start_hull_creak()
	elif global_position.y < stats[Stat.MaxDepth] and too_deep:
		too_deep = false
		end_hull_creak()
	
	if too_deep:
		depth_damage_delay -= delta
		if depth_damage_delay < 0:
			stats[Stat.Health] -= DEPTH_DAMAGE * delta
	
	if stats[Stat.Health] < 0:
		die("You died.")
	
	if stats[Stat.Battery] < 0:
		die("You ran out of battery. And died.")
	
	vehicle_ambience.volume_db = min(global_position.y / MAX_VEHICLE_AMBIENCE_DEPTH, 1.0) * 80.0 - 80.0

func gain_resource(resource: Res, amount: int) -> void:
	resources[resource] += amount
	resource_totals[resource] += amount

func restore_stat(stat: Stat, amount: float) -> bool:
	if stats[stat] == max_stats[stat]: return false
	stats[stat] = min(stats[stat] + amount, max_stats[stat])
	notify("+%s %s" % [format_stat_value(stat, amount), get_stat_name(stat)])
	return true

func is_light_on() -> bool:
	return spotlight.visible

func is_facing_left() -> bool:
	return body.scale.x > 0

func notify(text: String):
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	label.material = preload("res://Scene/IgnoreLight.tres")
	get_parent().add_child(label)
	label.position = position
	var tween = create_tween()
	tween.tween_property(label, "position", position + Vector2(randf_range(-4, 4), -50), 4)
	tween.finished.connect(func():
		label.queue_free()
	)

func check_raycasts():
	var casted_studyables: Dictionary[Studyable, int] = {}
	var casted_shapes: Dictionary[CollisionShape2D, int] = {}
	for child in spotlight.get_children():
		if child is RayCast2D and child.is_colliding():
			var collider = child.get_collider()
			if collider is Studyable:
				var shape_id = child.get_collider_shape()
				var shape = collider.shape_owner_get_owner(collider.shape_find_owner(shape_id))
				casted_studyables.set(collider, casted_studyables.get(collider, 0) + 1)
				casted_shapes.set(shape, casted_shapes.get(shape, 0) + 1)
	
	# Prioritize currently studying
	if studying != null and !studying.studied:
		if is_target_in_range(studying, casted_studyables.get(studying, 0)):
			return
	
	# Then prioritize unstudied
	studying = null
	for shape in casted_shapes:
		var studyable = shape.get_parent()
		if is_target_in_range(studyable, casted_shapes[shape]) and !studyable.studied:
			studying = studyable
			studying_mod = shape.get_meta("study_mod", 1.0)
			return
	
	for shape in casted_shapes:
		var studyable = shape.get_parent()
		if is_target_in_range(studyable, casted_shapes[shape]):
			studying = studyable
			studying_mod = shape.get_meta("study_mod", 1.0)
			return

func is_target_in_range(studyable: Studyable, raycasts: int) -> bool:
	if raycasts < studyable.raycasts_needed: return false
	var distance_sqr = studyable.global_position.distance_squared_to(global_position)
	return distance_sqr < pow(raycast_length() - studyable.size, 2)

func _physics_process(delta: float):
	var speed = stats[Player.Stat.Speed]
	var is_moving_forward: bool = false
	var prev_vel = vel
	engines_on = true
	if Input.is_action_pressed("right"):
		is_moving_forward = !is_facing_left()
		var mod_speed = speed * (BACKWARD_SPEED_FACTOR if !is_moving_forward else 1.0)
		vel.x = move_toward(vel.x, HORZ_TOP_SPEED * mod_speed, delta * HORZ_ACCEL * mod_speed)
	elif Input.is_action_pressed("left"):
		is_moving_forward = is_facing_left()
		var mod_speed = speed * (BACKWARD_SPEED_FACTOR if !is_moving_forward else 1.0)
		vel.x = move_toward(vel.x, -HORZ_TOP_SPEED * mod_speed, delta * HORZ_ACCEL * mod_speed)
	else:
		engines_on = false
		vel.x = move_toward(vel.x, 0, delta * HORZ_ACCEL)
	
	pumps_on = true
	if Input.is_action_pressed("ascend"):
		vel.y = move_toward(vel.y, -ASC_TOP_SPEED * speed, delta * ASC_ACCEL * speed)
	elif Input.is_action_pressed("descend"):
		vel.y = move_toward(vel.y, DESC_TOP_SPEED * speed, delta * DESC_ACCEL * speed)
	else:
		pumps_on = false
		vel.y = move_toward(vel.y, 0, delta * max(ASC_ACCEL, DESC_ACCEL))
	
	if is_moving_forward:
		propeller_bubble_cooldown -= delta
		if propeller_bubble_cooldown <= 0.0:
			propeller_bubble_cooldown += PROPELLER_BUBBLE_COOLDOWN
			Bubbler.spawn_bubbles(%PropellerLocation.global_position, 1, 2)
	
	if stats[Stat.DashPower] >= DASH_COOLDOWN and Input.is_action_just_pressed("dash"):
		vel.x += (-1 if is_facing_left() else 1) * stats[Stat.DashSpeed] * speed
		stats[Stat.DashPower] = 0
		Audio.play(DASH_SOUND, null, 0.0, 0.9, 1.1)
		Bubbler.spawn_bubbles(global_position, 3)
	
	var collision = move_and_collide(vel)
	if collision != null:
		var collision_direction = Vector2.from_angle(collision.get_angle() + PI / 2)
		var collision_speed = abs(collision_direction.dot(prev_vel))
		if collision_speed > COLLISION_THRESH:
			stats[Stat.Health] -= collision_speed * COLLISION_DAMAGE_MOD
			Audio.play(CRASH_SOUND, null, linear_to_db(collision_speed / 4), 0.4, 0.6)
		vel = Vector2.ZERO
	
	camera.global_position.y = max(global_position.y, get_viewport().size.y / 4)

func start_hull_creak():
	if hull_creak_tween == null:
		hull_creak.play()
	else:
		hull_creak_tween.kill()
		hull_creak_tween = create_tween()
		hull_creak_tween.tween_property(hull_creak, "volume_db", 0, 3.0)

func end_hull_creak():
	if hull_creak_tween != null:
		hull_creak_tween.kill()
	hull_creak_tween = create_tween()
	hull_creak_tween.tween_property(hull_creak, "volume_db", -80, 3.0)
	hull_creak_tween.finished.connect(func():
		hull_creak.stop()
		hull_creak_tween = null
	)

func die(death_text: String):
	Bubbler.spawn_bubbles(global_position, 16)
	process_mode = Node.PROCESS_MODE_DISABLED
	body.visible = false
	spotlight.visible = false
	%StudyIndicator.visible = false
	%DeathPanel.visible = true
	%DeathText.text = death_text
	%DeathRecoverButton.pressed.connect(recover)
	Audio.play(DEATH_SOUND_METAL, null, 0, 0.5)

func recover():
	body.visible = true
	spotlight.visible = true
	%DeathPanel.visible = false
	global_position = %StartPosition.global_position
	process_mode = Node.PROCESS_MODE_INHERIT
	Save.load_state(self, %Fish, %Anomalies)

func handle_fish_collision(fish: Fish, angle: float, speed: float):
	if fish_contact_cooldown < 0.0:
		var hit_direction = global_position - fish.global_position
		var knockback_angle = lerp_angle(angle, hit_direction.angle(), 0.5)
		handle_damage(fish.contact_damage, knockback_angle, fish.size * speed)

func handle_damage(damage: float, angle: float, speed: float):
	if fish_contact_cooldown < 0.0:
		stats[Stat.Health] -= damage
		Audio.play(CRASH_SOUND, null, linear_to_db(damage / 10.0), 0.4, 0.6)
		
		var knockback_strength = speed * KNOCKBACK_STRENGTH
		vel += Vector2.from_angle(angle) * min(knockback_strength, MAX_KNOCKBACK)
		
		fish_contact_cooldown = FISH_CONTACT_COOLDOWN

static func get_stat_name(stat: Player.Stat) -> String:
	match stat:
		Player.Stat.Health: return "Health"
		Player.Stat.MaxDepth: return "Max Depth"
		Player.Stat.Battery: return "Battery"
		Player.Stat.Speed: return "Speed"
		Player.Stat.Light: return "Light Radius"
		Player.Stat.StudySpeed: return "Scanning Speed"
		Player.Stat.DashSpeed: return "Dash"
	return "Unknown"

static func format_stat_value(stat: Player.Stat, value: float) -> String:
	match stat:
		Player.Stat.Health:     return str(int(value))
		Player.Stat.MaxDepth:   return World.format_depth(value, 0)
		Player.Stat.Battery:    return str(int(value))
		Player.Stat.Speed:      return str(int(value * 100)) + "%"
		Player.Stat.Light:      return "+" + str(int((value - 1.0) * 100)) + "%"
		Player.Stat.StudySpeed: return "+" + str(int((value * 5.0 - 1.0) * 100)) + "%"
		Player.Stat.DashSpeed:  return "+" + str(int((value / 2.8 - 1.0) * 200)) + "%"
	return "Unknown"

extends CharacterBody2D
class_name Player

enum Stat {
	Health,
	MaxDepth,
	Battery,
	Speed,
	DashPower,
	NUM_STATS
}

enum Res {
	Research,
	NUM_RESOURCES
}

enum UpgradeType {
	Hull,
	Battery,
	Speed,
	NUM_UPGRADES
}

const HORZ_ACCEL = 6.0
const HORZ_TOP_SPEED = 1.5
const DASH_SPEED = 3.0

const DESC_ACCEL = 4.0
const DESC_TOP_SPEED = 1.2
const DASH_POWER_CONSUMPTION = 1.0

const ASC_ACCEL = 4.0
const ASC_TOP_SPEED = 1.2

const DASH_COOLDOWN = 1.5

const COLLISION_THRESH := 0.1
const COLLISION_DAMAGE_MOD := 1.0
const FISH_CONTACT_COOLDOWN := 0.5

const NUM_RAYCASTS := 8
const RAYCAST_ANGLE := PI / 3
const RAYCAST_LENGTH := 120

const DEPTH_DAMAGE := 0.5
const DEPTH_DAMAGE_DELAY := 1.0
const MAX_VEHICLE_AMBIENCE_DEPTH := 1200

const CRASH_SOUND = preload("res://Assets/Sound/crash.mp3")
const DASH_SOUND = preload("res://Assets/Sound/underwater_splash.mp3")
const CLICK_SOUND = preload("res://Assets/Sound/click.ogg")
const DEATH_SOUND_METAL = preload("res://Assets/Sound/metal_wobble.mp3")

var vel := Vector2.ZERO
var dash_direction := 1.0
var camera: Camera2D

var stats: Array[float] = []
var max_stats: Array[float] = []
var resources: Array[int] = []
var total_research: int = 0

class Upgrade:
	func _init(init_name: String, init_stats: Array[Stat]) -> void:
		self.name = init_name
		self.stats = init_stats
	var name: String
	var stats: Array[Stat]
	var costs: PackedInt32Array = []
	var values: Array[PackedFloat64Array] = []
var upgrades: Array[Upgrade]
var upgrade_levels: Array[int]

var engines_on := false
var pumps_on := false
var idle_power_drain := 0.1
var engine_power_drain := 0.3
var pump_power_drain := 0.2

var fish_contact_cooldown := 0.0

var studying: Fish = null
var study_speed: float = 0.2

var too_deep: bool = false
var depth_damage_delay: float = 0.0
var hull_creak_tween: Tween = null

func _ready():
	camera = $Camera2D
	generate_raycasts()
	
	max_stats.resize(Stat.NUM_STATS)
	max_stats[Stat.DashPower] = DASH_COOLDOWN
	
	stats.resize(Stat.NUM_STATS)
	for i in range(0, Stat.NUM_STATS):
		stats[i] = max_stats[i]
	
	resources.resize(Res.NUM_RESOURCES)
	for i in range(0, Res.NUM_RESOURCES):
		resources[i] = 0
	
	upgrades.resize(UpgradeType.NUM_UPGRADES)
	upgrade_levels.resize(UpgradeType.NUM_UPGRADES)
	
	var hull_upgrade := Upgrade.new("Hull", [Stat.Health, Stat.MaxDepth])
	hull_upgrade.costs = [0, 20, 50, 100]
	hull_upgrade.values.append(PackedFloat64Array([10.0, 15.0, 20.0, 30.0])) # Health
	hull_upgrade.values.append(PackedFloat64Array([5000.0, 2400.0, 3600.0, 5000.0])) # Max Depth
	upgrades[UpgradeType.Hull] = hull_upgrade
	
	var speed_upgrade := Upgrade.new("Speed", [Stat.Speed])
	speed_upgrade.costs = [0, 20, 50, 100]
	speed_upgrade.values = [[1.0, 1.2, 1.5, 2.0]]
	upgrades[UpgradeType.Speed] = speed_upgrade
	
	var battery_upgrade := Upgrade.new("Battery", [Stat.Battery])
	battery_upgrade.costs = [0, 20, 50, 100]
	battery_upgrade.values = [[100.0, 150.0, 200.0, 300.0]]
	upgrades[UpgradeType.Battery] = battery_upgrade
	
	for i in range(0, UpgradeType.NUM_UPGRADES):
		set_upgrade_level(i, 0)

func set_upgrade_level(upgrade_type: UpgradeType, level: int) -> void:
	var upgrade := upgrades[upgrade_type]
	for i in range(0, upgrade.stats.size()):
		var stat = upgrade.stats[i]
		var value_arr := upgrade.values[i]
		max_stats[stat] = value_arr[min(level, value_arr.size() - 1)]
		stats[stat] = max_stats[stat]
	upgrade_levels[upgrade_type] = level

# Raycasts are used to detect if fish are in the player's light cone
func generate_raycasts() -> void:
	var raycast_spacing = RAYCAST_ANGLE / (NUM_RAYCASTS + 1)
	for i in range(0, NUM_RAYCASTS):
		var angle = raycast_spacing * (i + 1) - RAYCAST_ANGLE / 2
		var raycast := RayCast2D.new()
		raycast.target_position = Vector2.from_angle(angle) * RAYCAST_LENGTH
		raycast.collision_mask = 2
		$Spotlight.add_child(raycast)

func _process(delta: float):
	fish_contact_cooldown -= delta
	
	stats[Stat.Battery] -= idle_power_drain * delta
	if engines_on:
		stats[Stat.Battery] -= engine_power_drain * delta
	if pumps_on:
		stats[Stat.Battery] -= pump_power_drain * delta
	
	stats[Stat.DashPower] += delta
	
	$Spotlight.rotation = Vector2.LEFT.angle_to(position - get_parent().get_local_mouse_position())
	
	check_raycasts()
	
	if studying != null:
		%StudyIndicator.visible = true
		%StudyIndicator.update_to(studying)
		if !studying.studied:
			studying.study_progress += delta * studying.study_speed * study_speed
			if studying.study_progress >= 1.0:
				var reward = Study.add_studied(studying)
				notify("+%s Research Points" % reward)
				Audio.play(CLICK_SOUND)
				resources[Res.Research] += reward
				total_research += reward
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
	
	$VehicleAmbience.volume_db = min(global_position.y / MAX_VEHICLE_AMBIENCE_DEPTH, 1.0) * 80.0 - 80.0

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
	var casted: Dictionary[Fish, int] = {}
	for child in $Spotlight.get_children():
		if child is RayCast2D and child.is_colliding():
			var collider = child.get_collider()
			if collider is Fish:
				casted.set(collider, casted.get(collider, 0) + 1)
	
	# Prioritize currently studying
	if studying != null and !studying.studied and is_fish_in_range(studying, casted.get(studying, 0)):
		return
	
	# Then prioritize unstudied
	studying = null
	for fish in casted:
		if is_fish_in_range(fish, casted[fish]) and !fish.studied:
			studying = fish
			return
	
	for fish in casted:
		if is_fish_in_range(fish, casted[fish]):
			studying = fish
			return

func is_fish_in_range(fish: Fish, raycasts: int) -> bool:
	if raycasts < fish.raycasts_needed: return false
	var distance_sqr = fish.global_position.distance_squared_to(global_position)
	return distance_sqr < pow(RAYCAST_LENGTH - fish.size, 2)

func _physics_process(delta: float):
	var speed = stats[Player.Stat.Speed]
	var prev_vel = vel
	engines_on = true
	if Input.is_action_pressed("right"):
		vel.x = move_toward(vel.x, HORZ_TOP_SPEED * speed, delta * HORZ_ACCEL * speed)
		dash_direction = 1.0
	elif Input.is_action_pressed("left"):
		vel.x = move_toward(vel.x, -HORZ_TOP_SPEED * speed, delta * HORZ_ACCEL * speed)
		dash_direction = -1.0
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
	
	if stats[Stat.DashPower] >= DASH_COOLDOWN and Input.is_action_just_pressed("dash"):
		vel.x += dash_direction * DASH_SPEED * speed
		stats[Stat.DashPower] = 0
		stats[Stat.Battery] -= DASH_POWER_CONSUMPTION
		Audio.play(DASH_SOUND, null, 0.0, 0.9, 1.1)
		Bubbler.spawn_bubbles(self.global_position, 3)
	
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
		$HullCreak.play()
	else:
		hull_creak_tween.kill()
		hull_creak_tween = create_tween()
		hull_creak_tween.tween_property($HullCreak, "volume_db", 0, 3.0)

func end_hull_creak():
	if hull_creak_tween != null:
		hull_creak_tween.kill()
	hull_creak_tween = create_tween()
	hull_creak_tween.tween_property($HullCreak, "volume_db", -80, 3.0)
	hull_creak_tween.finished.connect(func():
		$HullCreak.stop()
		hull_creak_tween = null
	)

func die(death_text: String):
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	%DeathPanel.visible = true
	%DeathText.text = death_text
	%DeathRecoverButton.pressed.connect(recover)
	Audio.play(DEATH_SOUND_METAL, null, 0, 0.5)

func recover():
	visible = true
	%DeathPanel.visible = false
	global_position = %StartPosition.global_position
	process_mode = Node.PROCESS_MODE_INHERIT
	Save.load_state(self, %Fish)

func handle_fish_collision(fish: Fish):
	if fish_contact_cooldown < 0.0:
		stats[Stat.Health] -= fish.contact_damage
		Audio.play(CRASH_SOUND, null, linear_to_db(fish.contact_damage / 10.0), 0.4, 0.6)
		fish_contact_cooldown = FISH_CONTACT_COOLDOWN

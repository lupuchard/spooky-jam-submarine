extends Node2D
class_name World

const SPLASH_SOUND = preload("res://Assets/Sound/underwater_splash.mp3")
const DEACTIVATION_DISTANCE := 2000.0

var player: Player
var fishes: Array[Node]
var cur_fish_check_index = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	player = %Player
	Bubbler.world = self
	
	var fish_bodies = get_tree().get_nodes_in_group("fish_body")
	for fish in fish_bodies:
		fish.material = preload("res://Fish/FishBody.tres")
	fishes = %Fish.get_children()
	
	%UpgradePanel/CloseButton.pressed.connect(exit_surface)
	
	await get_tree().process_frame
	Save.save_state(player, %Fish)

func _process(_delta: float) -> void:
	if player.global_position.y < 0:
		return_to_surface()
	
	cur_fish_check_index += 1
	if cur_fish_check_index >= fishes.size():
		cur_fish_check_index = 0
	var fish = fishes[cur_fish_check_index]
	var fish_distance_sqr = fish.global_position.distance_squared_to(player.global_position)
	if fish_distance_sqr > pow(DEACTIVATION_DISTANCE, 2):
		fish.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		fish.process_mode = Node.PROCESS_MODE_INHERIT
		

func return_to_surface() -> void:
	for option in get_tree().get_nodes_in_group("upgrade_option"):
		option.update()
	
	pause_world()
	%Beastiary.update()
	%UpgradePanel.visible = true
	player.visible = false
	Save.save_state(player, %Fish)
	Save.save_to_file()

func exit_surface() -> void:
	%UpgradePanel.visible = false
	resume_world()
	player.vel.y = 3
	player.global_position.y = 1
	player.stats[Player.Stat.Health] = player.max_stats[Player.Stat.Health]
	player.stats[Player.Stat.Battery] = player.max_stats[Player.Stat.Battery]
	Audio.play(SPLASH_SOUND, player)
	Save.save_state(player, %Fish)
	Save.save_to_file()

func pause_world():
	process_mode = Node.PROCESS_MODE_DISABLED

func resume_world():
	process_mode = Node.PROCESS_MODE_INHERIT
	player.visible = true

static func format_depth(depth: float, decimals: int = 1) -> String:
	return str(depth / 20.0).pad_decimals(decimals) + "m"

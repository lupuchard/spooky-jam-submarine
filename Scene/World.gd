extends Node2D
class_name World

const SPLASH_SOUND = preload("res://Assets/Sound/underwater_splash.mp3")

func _ready() -> void:
	var fishies = get_tree().get_nodes_in_group("fish_body")
	for fish in fishies:
		fish.material = preload("res://Fish/FishBody.tres")
	
	%UpgradePanel/CloseButton.pressed.connect(exit_surface)
	
	await get_tree().process_frame
	Save.save_state(%Player, %Fish)

func _process(_delta: float) -> void:
	if %Player.global_position.y < 0:
		return_to_surface()

func return_to_surface() -> void:
	for option in get_tree().get_nodes_in_group("upgrade_option"):
		option.update()
	
	process_mode = Node.PROCESS_MODE_DISABLED
	%UpgradePanel.visible = true
	%Player.visible = false
	Save.save_state(%Player, %Fish)

func exit_surface() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	%UpgradePanel.visible = false
	
	%Player.visible = true
	%Player.vel.y = 3
	%Player.global_position.y = 1
	%Player.stats[Player.Stat.Health] = %Player.max_stats[Player.Stat.Health]
	%Player.stats[Player.Stat.Battery] = %Player.max_stats[Player.Stat.Battery]
	Audio.play(SPLASH_SOUND, %Player)
	Save.save_state(%Player, %Fish)

static func format_depth(depth: float, decimals: int = 1) -> String:
	return str(depth / 20.0).pad_decimals(decimals) + "m"

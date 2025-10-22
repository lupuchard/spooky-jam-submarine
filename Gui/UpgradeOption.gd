extends HBoxContainer

const UPGRADE_SOUND = preload("res://Assets/Sound/upgrade.mp3")

@export var player: Player
@export var upgrade_type: Player.UpgradeType

func _ready():
	%Button.pressed.connect(on_button_press)
	update()

func get_stat_name(stat: Player.Stat) -> String:
	match stat:
		Player.Stat.Health: return "Health"
		Player.Stat.MaxDepth: return "Max Depth"
		Player.Stat.Battery: return "Battery"
		Player.Stat.Speed: return "Speed"
	return "Unknown"

func format_stat_value(stat: Player.Stat, value: float) -> String:
	match stat:
		Player.Stat.Health:   return str(int(value))
		Player.Stat.MaxDepth: return World.format_depth(value, 0)
		Player.Stat.Battery:  return str(int(value))
		Player.Stat.Speed:    return str(int(value * 100)) + "%"
	return "Unknown"

func update() -> void:
	var upgrade = player.upgrades[upgrade_type]
	var level = player.upgrade_levels[upgrade_type]
	var max_level = upgrade.costs.size() - 1
	
	if level >= max_level:
		%CostLabel.text = ""
		%Button.text = "Fully upgraded"
		%Button.disabled = true
	else:
		var cost = upgrade.costs[level + 1]
		%CostLabel.text = "%s Points:" % cost
		%Button.disabled = player.resources[Player.Res.Research] < cost
		var stat_text: Array[String] = []
		for i in range(0, upgrade.stats.size()):
			var stat = upgrade.stats[i]
			stat_text.append("%s %s→%s" % [
				get_stat_name(stat), 
				format_stat_value(stat, upgrade.values[i][level]), 
				format_stat_value(stat, upgrade.values[i][level + 1])
			])
		%Button.text = "Upgrade " + ", ".join(stat_text)
	
	%ProgressLabel.text = "%s/%s" % [level, max_level]

func on_button_press():
	var upgrade = player.upgrades[upgrade_type]
	var level = player.upgrade_levels[upgrade_type]
	player.resources[Player.Res.Research] -= upgrade.costs[level + 1]
	player.set_upgrade_level(upgrade_type, level + 1)
	Audio.play(UPGRADE_SOUND, null, -10.0)
	
	for option in get_tree().get_nodes_in_group("upgrade_option"):
		option.update()

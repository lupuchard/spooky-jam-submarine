extends Label

const alarm_sound = preload("res://Assets/Sound/alarm.mp3")

@export var player: Player
@onready var low_battery_warning := $LowPowerWarning

func _process(_delta: float):
	text = "<".repeat(player.get_current_power_drain())
	
	var low_battery = player.stats[Player.Stat.Battery] < player.max_stats[Player.Stat.Battery] / 2
	if low_battery and !low_battery_warning.visible:
		low_battery_warning.visible = true
		Audio.play(alarm_sound)
	elif !low_battery:
		low_battery_warning.visible = false

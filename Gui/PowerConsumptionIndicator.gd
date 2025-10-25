extends Label

const alarm_sound = preload("res://Assets/Sound/alarm.mp3")

@export var player: Player

func _process(_delta: float):
	text = "<".repeat(player.get_current_power_drain())
	
	var low_battery = player.stats[Player.Stat.Battery] < player.max_stats[Player.Stat.Battery] / 2
	if low_battery and !$LowPowerWarning.visible:
		$LowPowerWarning.visible = true
		Audio.play(alarm_sound)
	elif !low_battery:
		$LowPowerWarning.visible = false

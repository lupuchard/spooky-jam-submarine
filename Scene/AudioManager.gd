extends Node

func play(sound: AudioStream, target: Node2D = null, volume = 0.0, min_pitch = 1.0, max_pitch = -1.0):
	if max_pitch < 0:
		max_pitch = min_pitch
	
	var player = create_player(sound, target, volume)
		
	if min_pitch != max_pitch:
		player.pitch_scale = randf_range(min_pitch, max_pitch)
	else:
		player.pitch_scale = min_pitch
		
	player.play()
	player.finished.connect(func(): player.queue_free())

func create_player(sound: AudioStream, target: Node2D, volume):
	var player
	if target == null:
		player = AudioStreamPlayer.new()
		add_child(player)
	else:
		player = AudioStreamPlayer2D.new()
		target.add_child(player)
	player.volume_db = volume
	player.stream = sound
	return player

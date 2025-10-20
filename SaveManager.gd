extends Node

var new_slot_saved_state = null
var saved_state: Dictionary
var current_slot: int = -1

func get_filename() -> String:
	return "user://slot%s.save" % current_slot

func save_to_file() -> void:
	var save_file = FileAccess.open(get_filename(), FileAccess.WRITE)
	var json_string = JSON.stringify(saved_state)
	save_file.store_line(json_string)

func load_from_file() -> void:
	if not FileAccess.file_exists(get_filename()):
		saved_state = new_slot_saved_state
		return
	var save_file = FileAccess.open(get_filename(), FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		saved_state = new_slot_saved_state
	else:
		saved_state = json.data

func delete_slot(slot: int):
	DirAccess.remove_absolute("user://slot%s.save" % slot)

func save_state(player: Player, fish: Node2D):
	saved_state = {
		"player": save_player(player),
		"fish": save_fish(fish),
		"fish_study": save_fish_study()
	}
	
	if new_slot_saved_state == null:
		new_slot_saved_state = saved_state

func load_state(player: Player, fish: Node2D) -> void:
	load_player(saved_state["player"], player)
	load_fish(saved_state["fish"], fish)
	load_fish_study(saved_state["fish_study"])

func save_player(player: Player) -> Dictionary:
	return {
		"stats": player.stats.duplicate(),
		"max_stats": player.max_stats.duplicate(),
		"resources": player.resources.duplicate(),
		"total_research": player.total_research,
		"upgrade_levels": player.upgrade_levels.duplicate()
	}

func load_player(data: Dictionary, player: Player) -> void:
	player.stats.assign(data["stats"].duplicate())
	player.max_stats.assign(data["max_stats"].duplicate())
	player.resources.assign(data["resources"].duplicate())
	player.total_research = int(data["total_research"])
	player.upgrade_levels.assign(data["upgrade_levels"].duplicate())

func save_fish(fish_node: Node2D) -> Array[Dictionary]:
	var fish_data: Array[Dictionary] = []
	for fish: Fish in fish_node.get_children():
		fish_data.append({
			"name": fish.name,
			"studied": fish.studied,
			"study_progress": fish.study_progress,
			"facing_left": fish.facing_left,
			"position": var_to_str(fish.position)
		})
	return fish_data

func load_fish(data: Array, fish_node: Node2D) -> void:
	for fish_data in data:
		var fish = fish_node.find_child(fish_data["name"])
		fish.studied = fish_data["studied"]
		fish.study_progress = fish_data["study_progress"]
		fish.facing_left = fish_data["facing_left"]
		fish.position = str_to_var(fish_data["position"])

func save_fish_study() -> Dictionary:
	return {
		"times_studied": Study.times_studied.duplicate()
	}

func load_fish_study(data: Dictionary):
	Study.times_studied.assign(data["times_studied"].duplicate())

extends Node

var new_slot_saved_state = null
var saved_state: Dictionary
var current_slot: int = -1
var slot_progress: Array[float] = []
var options: Dictionary[String, float] = {}
var max_total_research_points := -1

func _ready() -> void:
	if FileAccess.file_exists("user://misc.save"):
		load_meta_from_file()
	else:
		slot_progress.resize(3)

func get_slot_progress(slot: int) -> float:
	return slot_progress[slot]

func get_filename(slot: int) -> String:
	return "user://slot%s.save" % slot

func save_to_file() -> void:
	var save_file = FileAccess.open(get_filename(current_slot), FileAccess.WRITE)
	var json_string = JSON.stringify(saved_state)
	save_file.store_line(json_string)
	
	var player_research = saved_state["player"]["resource_totals"][Player.Res.Research]
	slot_progress[current_slot] = float(player_research) / max_total_research_points
	save_meta_to_file()

func save_meta_to_file() -> void:
	var save_file = FileAccess.open("user://misc.save", FileAccess.WRITE)
	var json_string = JSON.stringify({
		"progress": slot_progress,
		"options": options
	})
	save_file.store_line(json_string)

func load_meta_from_file() -> void:
	var save_file = FileAccess.open("user://misc.save", FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	json.parse(json_string)
	slot_progress.assign(json.data["progress"])
	options.assign(json.data.get("options", {}))

func load_from_file() -> void:
	if not FileAccess.file_exists(get_filename(current_slot)):
		saved_state = new_slot_saved_state
		return
	var save_file = FileAccess.open(get_filename(current_slot), FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		saved_state = new_slot_saved_state
	else:
		saved_state = json.data

func delete_slot(slot: int):
	DirAccess.remove_absolute(get_filename(slot))
	slot_progress[slot] = 0.0
	save_meta_to_file()

func save_state(player: Player, fish: Node2D):
	saved_state = {
		"player": save_player(player),
		"fish": save_fish(fish),
		"fish_study": save_fish_study()
	}
	
	if new_slot_saved_state == null:
		new_slot_saved_state = saved_state
	
	if max_total_research_points == -1:
		calc_total_research_points(fish)

func load_state(player: Player, fish: Node2D) -> void:
	load_player(saved_state["player"], player)
	load_fish(saved_state["fish"], fish)
	load_fish_study(saved_state["fish_study"])

func save_player(player: Player) -> Dictionary:
	return {
		"stats": player.stats.duplicate(),
		"max_stats": player.max_stats.duplicate(),
		"resources": player.resources.duplicate(),
		"resource_totals": player.resource_totals.duplicate(),
		"upgrade_levels": player.upgrade_levels.duplicate()
	}

func load_player(data: Dictionary, player: Player) -> void:
	player.stats.assign(data["stats"].duplicate())
	player.max_stats.assign(data["max_stats"].duplicate())
	player.resources.assign(data["resources"].duplicate())
	player.resource_totals.assign(data["resource_totals"].duplicate())
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
	Study.times_studied = {}
	for key in data["times_studied"]:
		Study.times_studied[int(key)] = int(data["times_studied"][key])

func calc_total_research_points(fish_node: Node2D):
	max_total_research_points = 0
	var times_studied: Dictionary[FishStudy.FishType, int] = {}
	for fish: Fish in fish_node.get_children():
		times_studied.set(fish.fish_type, times_studied.get(fish.fish_type, 0) + 1)
		max_total_research_points += FishStudy.get_study_reward(fish, times_studied[fish.fish_type])

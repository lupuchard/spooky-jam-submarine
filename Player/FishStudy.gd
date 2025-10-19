extends Node
class_name FishStudy

enum FishType {
	CaveAngler,
	Guppo,
	Crab
}

var names: Dictionary[FishType, String] = {}
var times_studied: Dictionary[FishType, int] = {}

func _ready():
	names[FishType.CaveAngler] = "Cave Angler"
	names[FishType.Guppo] = "Guppo"
	names[FishType.Crab] = "Crab"

func add_studied(fish: Fish) -> int:
	if !fish.studied:
		fish.studied = true
		var new_times_studied = times_studied.get(fish.fish_type, 0) + 1
		times_studied.set(fish.fish_type, new_times_studied)
		match new_times_studied:
			1: return fish.study_reward_factor * 10
			2: return fish.study_reward_factor * 5
			3: return fish.study_reward_factor * 4
			4: return fish.study_reward_factor * 3
			5: return fish.study_reward_factor * 2
			_: return fish.study_reward_factor * 1
	return 0

func get_times_studied(fish: Fish) -> int:
	return times_studied.get(fish.fish_type, 0)

func get_fish_name(fish: Fish) -> String:
	return names[fish.fish_type]

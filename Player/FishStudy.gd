extends Node
class_name FishStudy

enum FishType {
	CaveAngler,
	Guppo,
	PaleCrab,
	CrystalJelly,
	Viperfish,
	BigFish,
	NUM_FISH_TYPES
}

var names: Dictionary[FishType, String] = {}
var description_one: Dictionary[FishType, String] = {}
var description_two: Dictionary[FishType, String] = {}
var times_studied: Dictionary[FishType, int] = {}

func _ready():
	names[FishType.CaveAngler] = "Cave Angler"
	description_one[FishType.CaveAngler] = "Anglerfish use a modified dorsal fin ray as a lure for prey."
	description_two[FishType.CaveAngler] = "The cave angler lives in caves."
	
	names[FishType.Guppo] = "Guppo"
	description_one[FishType.Guppo] = "Bigger than a guppy."
	description_two[FishType.Guppo] = "TODO"
	
	names[FishType.PaleCrab] = "Pale Crab"
	description_one[FishType.PaleCrab] = "A depigmented troglobite."
	description_two[FishType.PaleCrab] = "TODO"
	
	names[FishType.CrystalJelly] = "Crystal Jelly"
	description_one[FishType.CrystalJelly] = "A transparent, bioluminescent jellyfish."
	description_two[FishType.CrystalJelly] = "This species is best known as the source of aequorin, a protein involved in bioluminescense."
	
	names[FishType.Viperfish] = "Viperfish"
	description_one[FishType.Viperfish] = "A bioluminescent fish with long, needle-like teeth and hinged lower jaws."
	description_two[FishType.Viperfish] = "TODO"
	
	names[FishType.BigFish] = "Blargh"
	description_one[FishType.BigFish] = "Blargh."
	description_two[FishType.BigFish] = "TODO"
	

func add_studied(fish: Fish) -> int:
	if !fish.studied:
		fish.studied = true
		var new_times_studied = times_studied.get(fish.fish_type, 0) + 1
		times_studied.set(fish.fish_type, new_times_studied)
		return get_study_reward(fish, new_times_studied)
	return 0

static func get_study_reward(fish: Fish, num_times_studied: int):
	match num_times_studied:
		1: return fish.study_reward_factor * 10
		2: return fish.study_reward_factor * 5
		3: return fish.study_reward_factor * 4
		4: return fish.study_reward_factor * 3
		5: return fish.study_reward_factor * 2
		_: return fish.study_reward_factor * 1

func get_times_studied(fish_type: FishType) -> int:
	return times_studied.get(fish_type, 0)

func get_fish_name(fish_type: FishType) -> String:
	return names[fish_type]

func get_fish_description_one(fish_type: FishType) -> String:
	return description_one[fish_type]

func get_fish_description_two(fish_type: FishType) -> String:
	return description_two[fish_type]
	

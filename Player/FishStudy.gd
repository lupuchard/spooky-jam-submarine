extends Node
class_name FishStudy

enum FishType {
	CaveAngler,
	Guppo,
	PaleCrab,
	CrystalJelly,
	Viperfish,
	Krait,
	EvilFish,
	ElectricEel,
	Goldfish,
	RubyCrab,
	Puffer,
	Squid,
	NUM_FISH_TYPES
}

const BEASTIARY_ORDER := [
	FishType.Goldfish, FishType.Guppo, FishType.Viperfish,
	FishType.RubyCrab, FishType.PaleCrab,
	FishType.CaveAngler, FishType.ElectricEel, FishType.Krait,
	FishType.Puffer, FishType.EvilFish, FishType.CrystalJelly
]

var names: Dictionary[FishType, String] = {}
var description_one: Dictionary[FishType, String] = {}
var description_two: Dictionary[FishType, String] = {}
var times_studied: Dictionary[FishType, int] = {}

func _ready():
	names[FishType.CaveAngler] = "Cave Angler"
	description_one[FishType.CaveAngler] = "Anglerfish use a modified dorsal fin ray as a lure for prey."
	description_two[FishType.CaveAngler] = "The cave angler will initially retreat if you get too close, but may attack if provoked."
	
	names[FishType.Guppo] = "Red Guppo"
	description_one[FishType.Guppo] = "A striking fish with bright red scales that shine even in the dark."
	description_two[FishType.Guppo] = "TODO"
	
	names[FishType.PaleCrab] = "Pale Crab"
	description_one[FishType.PaleCrab] = "A relative of the ruby crab, the pale crab has become depigmented due to a lack of sunlight."
	description_two[FishType.PaleCrab] = "TODO"
	
	names[FishType.CrystalJelly] = "Crystal Jelly"
	description_one[FishType.CrystalJelly] = "A transparent, bioluminescent jellyfish."
	description_two[FishType.CrystalJelly] = "This species is best known as the source of aequorin, a protein involved in bioluminescense."
	
	names[FishType.Viperfish] = "Viperfish"
	description_one[FishType.Viperfish] = "A bioluminescent fish with long, needle-like teeth and hinged lower jaws."
	description_two[FishType.Viperfish] = "Viperfish attack with little provocation. Maintain your distance when studying."
	
	names[FishType.Krait] = "Giant Krait"
	description_one[FishType.Krait] = "The giant sea krait is a species of venomous sea snake."
	description_two[FishType.Krait] = "Unlike the common sea krait, the giant sea krait's stripes are bioluminescent in order to attract prey."
	
	names[FishType.EvilFish] = "Chompler"
	description_one[FishType.EvilFish] = "Chompler."
	description_two[FishType.EvilFish] = "TODO"
	
	names[FishType.ElectricEel] = "Electric Eel"
	description_one[FishType.ElectricEel] = "A cave-dwelling electric eel that like to hide in narrow crevices in the wall, much like a Moray."
	description_two[FishType.ElectricEel] = "While famous for their ability to electrocute prey, your submarine will actually absorb the energy to recharge your battery."
	
	names[FishType.Goldfish] = "Goldfish"
	description_one[FishType.Goldfish] = "A small, yellow fish in the carp family."
	description_two[FishType.Goldfish] = "Prefers shallower waters. May retreat when approached."
	
	names[FishType.RubyCrab] = "Ruby Crab"
	description_one[FishType.RubyCrab] = "An unusually large red crab that prefers shallower waters."
	description_two[FishType.RubyCrab] = "TODO"
	
	names[FishType.Puffer] = "Big Puffer"
	description_one[FishType.Puffer] = "TODO."
	description_two[FishType.Puffer] = "TODO"
	
	names[FishType.Squid] = "Colossal Squid"
	description_one[FishType.Squid] = "TODO."
	description_two[FishType.Squid] = "TODO"

func add_studied(fish: Fish) -> int:
	if !fish.studied:
		fish.studied = true
		var new_times_studied = times_studied.get(fish.fish_type, 0) + 1
		times_studied.set(fish.fish_type, new_times_studied)
		return get_study_reward(fish, new_times_studied)
	return 0

static func get_study_reward(fish: Fish, num_times_studied: int):
	match num_times_studied:
		1: return int(fish.study_reward_factor * 10)
		2: return int(fish.study_reward_factor * 5)
		3: return int(fish.study_reward_factor * 4)
		4: return int(fish.study_reward_factor * 3)
		5: return int(fish.study_reward_factor * 2)
		_: return int(fish.study_reward_factor * 1)

func get_times_studied(fish_type: FishType) -> int:
	return times_studied.get(fish_type, 0)

func get_fish_name(fish_type: FishType) -> String:
	return names[fish_type]

func get_fish_description_one(fish_type: FishType) -> String:
	return description_one[fish_type]

func get_fish_description_two(fish_type: FishType) -> String:
	return description_two[fish_type]
	

extends ScrollContainer

const BEASTIARY_ENTRY := preload("res://Gui/BeastiaryEntry.tscn")

func _ready():
	for i in range(0, FishStudy.FishType.NUM_FISH_TYPES):
		var entry = BEASTIARY_ENTRY.instantiate()
		entry.fish_type = i
		entry.update()
		$BeastiaryEntryList.add_child(entry)

func update():
	for child in $BeastiaryEntryList.get_children():
		child.update()

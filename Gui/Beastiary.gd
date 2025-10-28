extends ScrollContainer

@onready var beastiary_entry_list = $BeastiaryEntryList

const BEASTIARY_ENTRY := preload("res://Gui/BeastiaryEntry.tscn")

func _ready():
	for fish_type in FishStudy.BEASTIARY_ORDER:
		var entry = BEASTIARY_ENTRY.instantiate()
		entry.fish_type = fish_type
		entry.update()
		beastiary_entry_list.add_child(entry)

func update():
	for child in beastiary_entry_list.get_children():
		child.update()

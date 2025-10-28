extends HBoxContainer
class_name SaveSlotRow

signal slot_pressed(slot)
signal delete_pressed(slot)

@export var slot: int

@onready var slot_button := $SlotButton
@onready var delete_button := $DeleteButton

func _ready():
	slot_button.pressed.connect(func():
		slot_pressed.emit(slot)
	)
	
	delete_button.pressed.connect(func():
		delete_pressed.emit(slot)
	)
	
	update()

func update():
	slot_button.text = "Play " + get_slot_text(slot)

static func get_slot_text(slott: int) -> String:
	var slot_progress = Save.get_slot_progress(slott)
	var progress_text = (" (%s%%)" % int(slot_progress * 100)) if slot_progress >= 0.0 else ""
	return ("Save Slot %s" % (slott + 1)) + progress_text

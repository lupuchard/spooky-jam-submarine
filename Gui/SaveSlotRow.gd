extends HBoxContainer
class_name SaveSlotRow

signal slot_pressed(slot)
signal delete_pressed(slot)

@export var slot: int

func _ready():
	$SlotButton.pressed.connect(func():
		slot_pressed.emit(slot)
	)
	
	$DeleteButton.pressed.connect(func():
		delete_pressed.emit(slot)
	)
	
	update()

func update():
	$SlotButton.text = "Play " + get_slot_text(slot)

static func get_slot_text(slott: int) -> String:
	var slot_progress = Save.get_slot_progress(slott)
	var progress_text = (" (%s%%)" % int(slot_progress * 100)) if slot_progress > 0.0 else ""
	return ("Save Slot %s" % (slott + 1)) + progress_text

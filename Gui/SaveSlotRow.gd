extends HBoxContainer

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
	var slot_progress = Save.get_slot_progress(slot)
	var progress_text = (" (%s%%)" % int(slot_progress * 100)) if slot_progress > 0.0 else ""
	$SlotButton.text = ("Play Save Slot %s" % (slot + 1)) + progress_text

extends HBoxContainer

signal slot_pressed(slot)
signal delete_pressed(slot)

@export var slot: int

func _ready():
	$SlotButton.text = "Play Save Slot %s" % (slot + 1)
	$SlotButton.pressed.connect(func():
		slot_pressed.emit(slot)
	)
	
	$DeleteButton.pressed.connect(func():
		delete_pressed.emit(slot)
	)

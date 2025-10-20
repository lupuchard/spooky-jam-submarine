extends PanelContainer

var slot_deleting: int

func _ready() -> void:
	%ExitButton.pressed.connect(func():
		get_tree().quit()
	)
	
	for i in range(0, 3):
		var slot_row = [%SaveSlotRow1, %SaveSlotRow2, %SaveSlotRow3][i]
		slot_row.slot_pressed.connect(on_slot_pressed)
		slot_row.delete_pressed.connect(on_slot_delete_pressed)
	
	%CancelDeleteButton.pressed.connect(func():
		$SaveSlotsMenu.visible = true
		$DeleteConfirmMenu.visible = false
	)
	
	%ConfirmDeleteButton.pressed.connect(func():
		Save.delete_slot(slot_deleting)
		$SaveSlotsMenu.visible = true
		$DeleteConfirmMenu.visible = false
	)

func _input(_input_event: InputEvent) -> void:
	if Input.is_action_just_pressed("open_menu"):
		if !visible:
			%World.pause_world()
			visible = true
			%UpgradePanel.process_mode = PROCESS_MODE_DISABLED
		elif Save.current_slot != -1:
			%World.resume_world()
			visible = false
			%UpgradePanel.process_mode = PROCESS_MODE_INHERIT

func on_slot_pressed(slot: int) -> void:
	Save.current_slot = slot
	Save.load_from_file()
	Save.load_state(%Player, %Fish)
	visible = false
	%World.resume_world()

func on_slot_delete_pressed(slot: int) -> void:
	slot_deleting = slot
	$SaveSlotsMenu.visible = false
	$DeleteConfirmMenu.visible = true

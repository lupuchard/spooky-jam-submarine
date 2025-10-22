extends PanelContainer

const OPTION_SAVE_DELAY := 0.5
const OPTION_DEFAULTS := {
	"sounds": 1.0,
	"ambience": 1.0,
	"gamma": 0.5
}

@onready var option_sliders := {
	"sounds": %SoundSlider,
	"ambience": %AmbienceSlider,
	"gamma": %GammaSlider
}

@onready var slot_rows := [%SaveSlotRow1, %SaveSlotRow2, %SaveSlotRow3]
var slot_deleting: int

var option_save_timer: Timer

func _ready() -> void:
	%ExitButton.pressed.connect(func():
		get_tree().quit()
	)
	
	for i in range(0, 3):
		var slot_row = slot_rows[i]
		slot_row.slot_pressed.connect(on_slot_pressed)
		slot_row.delete_pressed.connect(on_slot_delete_pressed)
	
	%CancelDeleteButton.pressed.connect(func():
		$SaveSlotsMenu.visible = true
		$DeleteConfirmMenu.visible = false
	)
	
	%ConfirmDeleteButton.pressed.connect(func():
		Save.delete_slot(slot_deleting)
		slot_rows[slot_deleting].update()
		$SaveSlotsMenu.visible = true
		$DeleteConfirmMenu.visible = false
	)
	
	%OptionsButton.pressed.connect(func():
		for slider_key in option_sliders:
			var value = Save.options.get(slider_key, OPTION_DEFAULTS[slider_key])
			option_sliders[slider_key].value = value
		
		$OptionsMenu.visible = true
		$SaveSlotsMenu.visible = false
	)
	
	%OptionsExitButton.pressed.connect(func():
		$OptionsMenu.visible = false
		$SaveSlotsMenu.visible = true
	)
	
	option_save_timer = Timer.new()
	option_save_timer.wait_time = OPTION_SAVE_DELAY
	option_save_timer.one_shot = true
	add_child(option_save_timer)
	option_save_timer.timeout.connect(func():
		Save.save_meta_to_file()
	)
	
	for slider_key in option_sliders:
		option_sliders[slider_key].value_changed.connect(func(new_value: float):
			Save.options[slider_key] = new_value
			option_save_timer.start()
			update_setting(slider_key, new_value)
		)
	
	await get_tree().process_frame
	for slider_key in option_sliders:
		update_setting(slider_key, Save.options.get(slider_key, OPTION_DEFAULTS[slider_key]))

func _input(_input_event: InputEvent) -> void:
	if Input.is_action_just_pressed("open_menu"):
		if !visible:
			%World.pause_world()
			visible = true
			%UpgradePanel.process_mode = PROCESS_MODE_DISABLED
			for slot_row in slot_rows:
				slot_row.update()
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

func update_setting(setting: String, value: float) -> void:
	match setting:
		"sounds":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), pow(value, 2))
		"ambience":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Ambience"), pow(value, 2))
		"gamma":
			%WorldEnvironment.environment.tonemap_exposure = pow((value * 2), 2)

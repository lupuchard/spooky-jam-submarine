extends HBoxContainer

signal value_changed(value: float)

@export var title: String

var value: float:
	set(new_value):
		if value != new_value:
			value = new_value
			update()

func _ready():
	$OptionLabel.text = title + ":"
	$Slider.value_changed.connect(func(new_value: float):
		if value != new_value:
			value_changed.emit(new_value)
			value = new_value
	)

func update():
	$Slider.value = value
	$Percentage.text = "%s%%" % int(value * 100.0)

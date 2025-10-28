extends HBoxContainer

signal value_changed(value: float)

@export var title: String

@onready var option_label := $OptionLabel
@onready var slider := $Slider
@onready var percentage := $Percentage

var value: float:
	set(new_value):
		if value != new_value:
			value = new_value
			update()

func _ready():
	option_label.text = title + ":"
	slider.value_changed.connect(func(new_value: float):
		if value != new_value:
			value_changed.emit(new_value)
			value = new_value
	)

func update():
	slider.value = value
	percentage.text = "%s%%" % int(value * 100.0)

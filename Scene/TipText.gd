extends Label
class_name TipText

const WHEN_DASH_HINT: float = 120.0
const WHEN_SPOTLIGHT_HINT: float = 240.0

var time_passed: float = 0.0
var dash_pressed: bool = false
var toggle_spotlight_pressed: bool = false

func _process(delta: float):
	time_passed += delta
	
	if time_passed > WHEN_DASH_HINT and !dash_pressed:
		text = "Tip: Press space or RB to dash."
	elif time_passed > WHEN_SPOTLIGHT_HINT and !toggle_spotlight_pressed:
		text = "Tip: Right click or press the right analog stick to toggle spotlight."
	else:
		text = ""

func _input(event: InputEvent):
	if event.is_action_pressed("dash"):
		dash_pressed = true
	elif event.is_action_pressed("toggle_light"):
		toggle_spotlight_pressed = true

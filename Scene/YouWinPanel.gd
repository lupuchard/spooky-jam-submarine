extends PanelContainer

func _ready():
	%YouWinExitButton.pressed.connect(func():
		get_tree().quit()
	)
	
	%YouWinContinueButton.pressed.connect(func():
		visible = false
		%World.process_mode = Node.PROCESS_MODE_INHERIT
	)

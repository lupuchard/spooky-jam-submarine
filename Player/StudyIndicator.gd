extends Node2D

func set_name_text(text: String):
	$NameLabel.text = text

func update_to(fish: Studyable):
	#global_position = fish.global_position
	transform = fish.get_screen_transform()
	
	if fish is Anomaly:
		$NameLabel.text = AnomalyText.TEXT
	elif fish.studied or Study.get_times_studied(fish.fish_type) > 0:
		$NameLabel.text = Study.get_fish_name(fish.fish_type)
	else:
		$NameLabel.text = "???"
	
	if fish.studied:
		$ProgressLabel.visible = true
		$ColorRect.visible = false
	else:
		$ProgressLabel.visible = false
		$ColorRect.visible = true
		$ColorRect.size.x = round(fish.study_progress * 48)

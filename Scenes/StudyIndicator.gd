extends Node2D

func set_name_text(text: String):
	$NameLabel.text = text

func update_to(fish: Fish):
	global_position = fish.global_position
	
	if fish.studied or Study.get_times_studied(fish) > 0:
		$NameLabel.text = Study.get_fish_name(fish)
	else:
		$NameLabel.text = "???"
	
	if fish.studied:
		$ProgressLabel.visible = true
		$ColorRect.visible = false
	else:
		$ProgressLabel.visible = false
		$ColorRect.visible = true
		$ColorRect.size.x = round(fish.study_progress * 48)

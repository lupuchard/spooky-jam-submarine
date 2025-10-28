extends Node2D

@onready var name_label := $NameLabel
@onready var progress_label := $ProgressLabel
@onready var color_rect := $ColorRect

func set_name_text(text: String):
	name_label.text = text

func update_to(fish: Studyable):
	global_position = fish.get_screen_transform().get_origin()
	
	if fish is Anomaly:
		name_label.text = AnomalyText.TEXT
	elif fish.studied or Study.get_times_studied(fish.fish_type) > 0:
		name_label.text = Study.get_fish_name(fish.fish_type)
	else:
		name_label.text = "???"
	
	if fish.studied:
		progress_label.visible = true
		color_rect.visible = false
	else:
		progress_label.visible = false
		color_rect.visible = true
		color_rect.size.x = round(fish.study_progress * 48)

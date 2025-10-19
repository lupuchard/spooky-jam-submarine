extends HBoxContainer

var fish_type: FishStudy.FishType

func update():
	var times_studied = Study.get_times_studied(fish_type)
	if times_studied == 0:
		%NameLabel.text = "???:"
	else:
		%NameLabel.text = Study.get_fish_name(fish_type) + ":"
	
	var text = "%s specimens studied." % times_studied
	if times_studied >= 2:
		text += " " + Study.get_fish_description_one(fish_type)
	if times_studied >= 3:
		text += " " + Study.get_fish_description_two(fish_type)
	
	%DescriptionLabel.text = text

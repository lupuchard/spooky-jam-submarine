extends FishBehaviorBase
class_name ShyFishBehavior

const PATIENCE_COOLDOWN = 30.0
const ACTION_COOLDOWN = 0.8
const MOVE_SOUND = preload("res://Assets/Sound/underwater_move.mp3")

@export var patience: int = 999
@export var retreat_range: float = 20.0
@export var retreat_distance: float = 50.0

var player: Player
var retreats := 0
var tween: Tween

var patience_cooldown := 30.0
var action_cooldown := 0.0

func _behave(delta: float, fish: Fish) -> void:
	if action_cooldown <= 0:
		print("%s vs %s" % [fish.global_position,  player.global_position])
		var dist_sqr = fish.global_position.distance_squared_to(player.global_position)
		print("%s vs %s" % [sqrt(dist_sqr), max_distance(fish)])
		if dist_sqr < pow(max_distance(fish), 2):
			if retreats < patience:
				retreat(delta, fish)
				retreats += 1
			else:
				attack(delta, fish)
				retreats = 0
			action_cooldown = ACTION_COOLDOWN
			Audio.play(MOVE_SOUND, fish, 0.0, 0.9, 1.1)
	
	patience_cooldown -= delta
	if patience_cooldown <= 0:
		retreats = max(0, retreats - 1)
		patience_cooldown = PATIENCE_COOLDOWN
	
	action_cooldown -= delta

func max_distance(fish: Fish):
	return Player.RAYCAST_LENGTH - retreat_range - fish.size

func retreat(_delta: float, fish: Fish):
	var distance = fish.global_position.distance_to(player.global_position)
	var direction = (fish.global_position - player.global_position).normalized()
	var destination = fish.position + direction * (max_distance(fish) - distance + retreat_distance)
	if tween:
		tween.kill()
	tween = fish.create_tween()
	var tweener = tween.tween_property(fish, "position", destination, 1.0)
	tweener.set_ease(Tween.EASE_OUT)
	tweener.set_trans(Tween.TRANS_CUBIC)

func attack(_delta: float, fish: Fish):
	var direction = (fish.global_position - player.global_position).normalized()
	var destination = player.global_position - direction * retreat_distance / 2.0
	if tween:
		tween.kill()
	tween = fish.create_tween()
	var tweener = tween.tween_property(fish, "global_position", destination, 1.0)
	tweener.set_ease(Tween.EASE_OUT)
	tweener.set_trans(Tween.TRANS_QUART)

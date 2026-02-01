extends Node

# Game Data Singleton - Persists game state and high scores

const SAVE_PATH = "user://game_data.save"

var current_shots: int = 0
var current_level: int = 1
var high_scores: Array = []
var settings: Dictionary = {
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"fullscreen": false
}

signal score_updated(shots: int)

func _ready() -> void:
	load_data()

func reset_game() -> void:
	current_shots = 0
	score_updated.emit(current_shots)

func add_shot() -> void:
	current_shots += 1
	score_updated.emit(current_shots)
	
func get_current_shots() -> int:
	return current_shots

func get_high_scores() -> Array:
	return high_scores

func add_high_score(player_name: String, shots: int) -> int:
	# Add new score and sort
	var new_score = {"name": player_name, "shots": shots, "level": current_level}
	high_scores.append(new_score)
	
	# Sort by shots (ascending - fewer is better)
	high_scores.sort_custom(func(a, b): return a.shots < b.shots)
	
	# Keep only top 10
	if high_scores.size() > 10:
		high_scores.resize(10)
	
	# Find rank of new score
	var rank = high_scores.find(new_score) + 1
	
	save_data()
	return rank

func is_high_score(shots: int) -> bool:
	if high_scores.size() < 10:
		return true
	return shots < high_scores[-1].shots

func save_data() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var data = {
			"high_scores": high_scores,
			"settings": settings
		}
		save_file.store_var(data)
		save_file.close()
		print("Game data saved")

func load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var data = save_file.get_var()
			save_file.close()
			
			if data is Dictionary:
				if data.has("high_scores"):
					high_scores = data.high_scores
				if data.has("settings"):
					settings.merge(data.settings, true)
			print("Game data loaded")
	else:
		# Initialize with default high scores
		high_scores = [
			{"name": "ACE", "shots": 3, "level": 1},
			{"name": "PRO", "shots": 5, "level": 1},
			{"name": "GOLF", "shots": 7, "level": 1},
		]
		print("No save file found, using defaults")

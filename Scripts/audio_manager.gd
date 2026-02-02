extends Node

# Audio Manager Singleton - Handles all game sound effects

# Volume settings
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

# Audio players
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

# Sound effect paths (these would normally be loaded from actual audio files)
# For now, we'll create procedural sounds or load when files exist
var sounds: Dictionary = {}

func _ready() -> void:
	# Create audio stream players
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	# Load sound effects if they exist
	_load_sounds()

func _load_sounds() -> void:
	# Attempt to load sound files from Assets/Sounds
	var sound_files = {
		"hit": "res://Assets/Sounds/ball_hit.wav",
		"ghost_activate_1": "res://Assets/Sounds/ghost_activate_1.wav",
		"ghost_activate_2": "res://Assets/Sounds/ghost_activate_2.wav",
		"ghost_place_1": "res://Assets/Sounds/ghost_place_1.wav",
		"ghost_place_2": "res://Assets/Sounds/ghost_place_2.wav",
		"win": "res://Assets/Sounds/win.wav",
		"lose": "res://Assets/Sounds/lose.wav",
		"ui_click": "res://Assets/Sounds/ui_click.wav",
	}
	
	for key in sound_files:
		var path = sound_files[key]
		if ResourceLoader.exists(path):
			sounds[key] = load(path)
			print("Loaded sound: ", key)
		else:
			# Sound file doesn't exist yet - that's okay, we'll handle gracefully
			print("Sound file not found (optional): ", path)

func play_sfx(sound_name: String) -> void:
	if sounds.has(sound_name) and sounds[sound_name] != null:
		sfx_player.stream = sounds[sound_name]
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)
		sfx_player.play()
	else:
		# Generate a simple procedural beep for missing sounds
		_play_procedural_sound(sound_name)

func _play_procedural_sound(sound_name: String) -> void:
	# Create simple procedural sounds as placeholders
	# This ensures the game has audio feedback even without sound files
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.1
	
	sfx_player.stream = generator
	sfx_player.play()
	
	var playback: AudioStreamGeneratorPlayback = sfx_player.get_stream_playback()
	if playback:
		# Generate a simple tone based on sound type
		var frequency = 440.0  # Default A4
		match sound_name:
			"hit":
				frequency = 220.0  # Low tone
			"ghost":
				frequency = 330.0  # Medium tone
			"win":
				frequency = 523.25  # C5 - happy sound
			"lose":
				frequency = 196.0  # G3 - sad sound
			"ui_click":
				frequency = 880.0  # A5 - crisp click
		
		var sample_rate = generator.mix_rate
		var num_samples = int(sample_rate * 0.1)  # 100ms

		for i in range(num_samples):
			var t = float(i) / sample_rate
			var envelope = 1.0 - (float(i) / num_samples)  # Fade out
			var sample = sin(TAU * frequency * t) * 0.3 * envelope
			playback.push_frame(Vector2(sample, sample))

func play_hit() -> void:
	play_sfx("hit")

func play_ghost() -> void:
	# Randomly choose between ghost_activate_1 and ghost_activate_2
	var variant = randi_range(1, 2)
	play_sfx("ghost_activate_%d" % variant)

func play_win() -> void:
	play_sfx("win")

func play_lose() -> void:
	play_sfx("lose")

func play_ui_click() -> void:
	play_sfx("ui_click")

func play_ghost_place() -> void:
	# Randomly choose between ghost_place_1 and ghost_place_2
	var variant = randi_range(1, 2)
	play_sfx("ghost_place_%d" % variant)

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player.playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

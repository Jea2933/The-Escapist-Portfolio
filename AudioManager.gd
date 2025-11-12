extends Node


#var musicPlayer: AudioStreamPlayer
var current_track_path: String = ""
var current_track_paths := {}

var music_players := {}

var music_triggers := {} # Dictionary to track timed callbacks for each music player


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#musicPlayer = AudioStreamPlayer.new()
	#musicPlayer.name = "MusicPlayer"
	#add_child(musicPlayer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for player_name in music_triggers.keys():
		if not music_players.has(player_name):
			continue
		var player = music_players[player_name]
		if not is_instance_valid(player) or not player.playing:
			continue
		var current_time = player.get_playback_position()
		
		for trigger in music_triggers[player_name]:
			if trigger["fired"]:
				continue
			if current_time >= trigger["time"]:
				trigger["callback"].call()
				trigger["fired"] = true 
	


func addMusicTrigger(player_name: String, trigger_time: float, callback: Callable):
	if not music_triggers.has(player_name):
		music_triggers[player_name] = []
		
	music_triggers[player_name].append({
		"time": trigger_time,
		"callback": callback,
		"fired": false
	})



func playMusic(
	music_player_name: String,
	stream_path: String,
	loop := true,
	start_time := 0.0,
	pitch := 1.0
):
	if not music_players.has(music_player_name):
		var new_player = AudioStreamPlayer.new()
		new_player.name = music_player_name
		add_child(new_player)
		music_players[music_player_name] = new_player
		current_track_paths[music_player_name] = ""
		
	var musicplayer = music_players[music_player_name]
	
	if current_track_paths[music_player_name] == stream_path:
		# Already playing the same track. Just make sure volume is up.
		if musicplayer.volume_db < 0:
			musicplayer.volume_db = 0
		
		return #already playing
		
	if musicplayer.playing:
		musicplayer.stop()
		
	var stream = load(stream_path)
	if stream:
		#if stream is AudioStream:
			#stream.loop = loop
		#musicplayer.loop = loop
		if stream is AudioStreamOggVorbis:
			stream.loop = loop
		musicplayer.stream = stream
		musicplayer.pitch_scale = pitch
		musicplayer.play()
		if start_time > 0.0:
			musicplayer.seek(start_time)
		current_track_paths[music_player_name] = stream_path
	else:
		push_error("Failed to load music: " + stream_path)
	
	
func setPitch(music_player_name: String, new_pitch: float):
	if music_players.has(music_player_name) and is_instance_valid(music_players[music_player_name]):
		music_players[music_player_name].pitch_scale = new_pitch
	
func stopMusic(music_player_name: String):
	if music_players.has(music_player_name):
		var player = music_players[music_player_name]
		if player.playing:
			player.stop()
func setVolume(music_player_name: String, volume_db: float):
	if music_players.has(music_player_name):
		var player = music_players[music_player_name]
		player.volume_db = volume_db

func playSound(stream_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	var sfx_player = AudioStreamPlayer.new()
	var stream = load(stream_path)
	
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = pitch_scale
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
	
	# Wait for the sound to finish, then free the player
	await get_tree().create_timer(stream.get_length() / pitch_scale).timeout
	sfx_player.queue_free()

#Inherits from base_scene.gd
extends BaseScene

@onready var SceneTransitionAnimation = $SceneTransitionAnimation/AnimationPlayer

@onready var dialogue_resource: DialogueResource
@onready var dialogue_start: String 


#@onready var Player1Scene = preload("res://RPG-Scenes/Player_1_Scene.tscn")
#@onready var Player2Scene = preload("res://RPG-Scenes/Player_2_Scene.tscn")
#@onready var Player3Scene = preload("res://RPG-Scenes/Player_3_Scene.tscn")
#var player_pool = []
#var current_player_index = 0


@onready var time_label = $CanvasLayer/TimeLabel
@onready var healthLabel = $CanvasLayer/HealthLabel



@onready var Player1Balloon = $player1Balloon

@onready var gameover3 = $CanvasLayer2/Player3GameOver

@onready var overworldAudio = $overworldAudio
@onready var gameover1Audio = $GameOver1
@onready var gameover2Audio = $GameOver2
@onready var gameover3Audio = $GameOver3

signal Player3healthChanged


var palette = [
	Color("ff595e"), # punchy red
	Color("ffca3a"), # warm yellow
	Color("8ac926"), # bright green
	Color("1982c4"), # strong blue
	Color("6a4c93")  # deep violet
]


var has_entered_area = false

var timer_delay = 5.0

var balloon_scene = preload("res://addons/dialogue_manager/example_balloon/small_example_balloon.tscn")
var balloon_scene_2 = preload("res://addons/dialogue_manager/example_balloon/small_example_balloon2.tscn")
#var battle_scene = preload("res://RPG-Scenes/battle (outdated).tscn")

@onready var borders = $Player2/Camera2D/Control

@onready var black_background = $Black_Background
	
#func game_manager():
	#GameManager.IsPlayer2 = true
	#print ("game manager function switched to player 2")

# Called when the node enters the scene tree for the first time.
@onready var ThinkingTimer = $ThinkingTimer

func _ready() -> void:
	black_background.visible = true
	#AudioManager.addMusicTrigger("BT", 109, Callable(self, "level1_BT_borders"))
	#AudioManager.addMusicTrigger("BT", 129, Callable(self, "level1_BT_borders_close"))
	$Player2/Camera2D.make_current()
	#$CanvasLayer.hide()
	Player1.fps = 12
	Player2.fps = 12
	Player3.fps = 12
	#If you have more than one song playing in a level, just write a script saying "if (this) song is playing, fps = x"
	super()
		
	
	
	GDManager.player_reference = $Player1
	#time_label.text = "Time Left: %d" % round(player.timer_delay.time_left)
	dialogue_resource = preload("res://Dialogue/Intro.dialogue")
	dialogue_start = "begin"
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	$CanvasLayer.hide()
	DialogueManager.connect("dialogue_ended", self.on_intro_dialogue_finished)
	
	ThinkingTimer.timeout.connect(think)
	#start_intro()
	#if not overworldAudio.playing:
		#overworldAudio.play()
		#await get_tree().create_timer(0.1).timeout
		#overworldAudio.seek(8.0)
		
	#DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
#func _unhandled_input(event: InputEvent) -> void:
#func test():
	#Player1.animated1.play("idle_all")
	#print("working!")

func level1_BT_borders():
	borders.visible = true
	
	#pick a softer pastel tone
	var hue = randf() # 1.1 - 1.0 random color
	var sat = randf_range(0.2, .4)
	var val = randf_range(0.8, 1.0)
	
	
	
	
	var color = Color.from_hsv(hue, sat, val)
	#var color = palette[randi() % palette.size()]
	color.a = 0.0
	borders.modulate = color
	
	
	# Create tween to fade alpha from 0 to 1 over 0.5 seconds
	var tween = get_tree().create_tween()
	tween.tween_property(borders, "modulate:a", 1.0, 2.0) # duration = 0.5s

func level1_BT_borders_close():
	var tween = get_tree().create_tween()
	tween.tween_property(borders, "modulate:a", 0.0, 2.0) # 0.5s fade
	
	# Optional: hide after fade completes
	tween.tween_callback(func():
		borders.visible = false
	)

func think():
	return
	dialogue_resource = preload("res://Dialogue/Intro.dialogue")
	var label = GDManager.player1_thoughts.pick_random()
	dialogue_start = label
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
		
#func start_intro():
	#$CanvasLayer.hide()
	#var balloon = DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	
	#balloon.connect("finished", self, "_on_intro_dialogue_finished")
	
func on_intro_dialogue_finished():
	
	dialogue_resource = preload("res://Dialogue/Intro.dialogue")
	dialogue_start = "begin2"
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	DialogueManager.disconnect("dialogue_ended", self.on_intro_dialogue_finished)
	DialogueManager.connect("dialogue_ended", self.on_intro_dialogue_finished_2)
		
		
func on_intro_dialogue_finished_2():
	$CanvasLayer.show()
	black_background.visible = false
	#AudioManager.playMusic("BT", "res://Art/Music/Bedside-Traveler.ogg", true, 108.0, 1.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	#time_label.text = "Time Left: %d" % round(player.timer_delay.time_left)
	
	
	
	
	match GameManager.current_player_index:
		0:
			#$ColorRect.visible = true
			healthLabel.text = "Player 1 Health: %d" % GDManager.player1currentHealth
			#LevelAnimation.play("change_world")
			
			
		1:
			healthLabel.text = "Player 2 Health: %d" % GDManager.player2currentHealth
		2:
			healthLabel.text = "Player 3 Health: %d" % GDManager.player3currentHealth
	
	#match GameManager.current_player_index:
		#0:
			#shield.position = Player1.position
			#shield.visible = !Player1.visible  # Shield visible when player hidden
		#1:
			#shield.position = Player2.position
			#shield.visible = !Player2.visible
		#2:
			#shield.position = Player3.position
			#shield.visible = !Player3.visible	
	#if Input.is_action_just_pressed("ui_q"):
		
		
	
		
		
func _input(event):
	super(event)
	change_worlds_randomly(event)
		
		#get_tree().change_scene_to_file("res://RPG-Scenes/battle (outdated).tscn")

func change_worlds_randomly(event):
	if event.is_action_pressed("ui_y"):
		var random_number = randi() % 3
		GameManager.current_world_index = random_number
		GameManager.current_player_index = random_number

func _on_area_2d_area_entered(area) -> void:
	if area.is_in_group("Player1"):
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/Entered.dialogue"), "")
		print("Player 1 entered the area!")
		if has_entered_area == false:
			DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/Entered.dialogue"), "start")
			has_entered_area = true
			return
	#PlayerManager._inputBlocked = false;


func _on_timer_timeout() -> void:
	$Timer.stop()
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/Intro.dialogue"), "start")

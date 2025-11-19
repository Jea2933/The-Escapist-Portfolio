#The base level class script that most levels inherit from. It comes with most of the basic necessities to create a level in my game, including heart (lives) instantiation, player 3's super-speed mechanics, world switching animations, game over screens, and more!

# creates a class for other levels to use as a base structure
class_name BaseScene extends Node

# player variables using Nodes placed in the scene tree- all levels must have these!
@onready var Player1: Player = $Player1
@onready var Player2: Player = $Player2
@onready var Player3: Player = $Player3
# @onready var PlayerScript = $CharacterBody2D (used for testing)

# Preloaded Heart GUI icons 
var hearts = preload("res://Useful Stuff/2D RPG Tutorial/Heart GUI/heartGui.tscn")
var heartscontainer = preload("res://Useful Stuff/2D RPG Tutorial/Heart GUI/heartsContainer.tscn")

# animation player used for level switching animations
@onready var LevelAnimation = $AnimationPlayer

# bullet instantiation for enemy attacks
@onready var bullet_scene = preload("res://Bullet.tscn")
@onready var bullet = bullet_scene.instantiate()

# timer used for limiting super-speed (for game balance)
var cancel_timer := false

#@onready var heartsContainer = $CanvasLayer/heartsContainer
#@onready var heartsContainer2 = $CanvasLayer/heartsContainer2
#@onready var heartsContainer3 = $CanvasLayer/heartsContainer3

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	
	GDManager.teleport_limit_current = GDManager.teleport_limit_max
	# Sets the player heart container variables in GDManager to their respective nodes in the scene tree
	GDManager.heartsContainer = $CanvasLayer/heartsContainer # heart containers for Player 1
	GDManager.heartsContainer2 = $CanvasLayer/heartsContainer2 # heart containers for Player 2
	GDManager.heartsContainer3 = $CanvasLayer/heartsContainer3 # heart containers for Player 3
	
	GDManager.player1currentHealth = GDManager.player1currentHealth  
	GDManager.player2currentHealth = GDManager.player2currentHealth  
	GDManager.player3currentHealth = GDManager.player3currentHealth  

	# Set max hearts for each player (including added hearts via player upgrades)
	GDManager.heartsContainer.setMaxHearts(GDManager.player1maxHealth)
	GDManager.heartsContainer2.setMaxHearts(GDManager.player2maxHealth)
	GDManager.heartsContainer3.setMaxHearts(GDManager.player3maxHealth)

	# A deferred call to ensure GUI updates happen after the scene is fully initialized
	call_deferred("update_health_gui")

	# Connect the healthChanged signals to update the GUI when health changes
	Player1.healthChanged.connect(GDManager.heartsContainer.updateHearts)
	Player2.healthChanged2.connect(GDManager.heartsContainer2.updateHearts2)
	Player3.healthChanged3.connect(GDManager.heartsContainer3.updateHearts3)

	# $Timer.start(timer_delay) #placeholder timer used in other inherited level scripts
	
	# Ensures that Player 3 is never slowing down time when entering a new scene
	if GDManager.timeSlowed == true:
		GDManager.timeSlowed = false
	
# Function to update the health GUI after scene is loaded
func update_health_gui():
	GDManager.heartsContainer.updateHearts(GDManager.player1currentHealth)
	GDManager.heartsContainer2.updateHearts2(GDManager.player2currentHealth)
	GDManager.heartsContainer3.updateHearts3(GDManager.player3currentHealth)

# Function for initiating Player 3's super-speed. 
# Toggles "timeSlowed()" with space bar
func _input(event):
	if event.is_action_pressed("ui_space"):
		if !GDManager.synced: # the main code that will be used
			timeSlowed()
		if GDManager.synced: # only used conditionally
			timeSlowed_Synced()	

# Creates a blinking animation when the player transitions from one world to another
func change():
		$ColorRect.visible = true
		LevelAnimation.play("change_world")
		await LevelAnimation.animation_finished
		$ColorRect.visible = false

# The main function used for super-speed, or slowing down time; the function speeds up the player while slowing down enemies
func timeSlowed():
	# Always sets to Player 3 and World 3 (their respective world)
	GameManager.current_player_index = 2
	GameManager.current_world_index = 2
	# If player 3 is dead, then the player cannot use super-speed and the code stops here
	if GameManager.player3dead:
		return
	#toggles the ability on and off by toggling "timeSlowed" to be true or false
	GDManager.timeSlowed = !GDManager.timeSlowed
	print("timeSlowed: ", GDManager.timeSlowed)
	if GDManager.timeSlowed:
		# commented code used for design testing
		#if !GameManager.current_player_index == 2:
			#GameManager.current_player_index = 2
			#GameManager.current_world_index = 2
		# increases the walking speed of all players greatly; characters are now using "super-speed"
		Player1.speed = 300
		Player2.speed = 300
		Player3.speed = 300
		# sets the collision masks and layers of all players to 0
		# this allows players to use super-speed without bumping into things constantly
		Player1.set_collision_layer(0)
		Player1.set_collision_mask(0)
		Player2.set_collision_layer(0)
		Player2.set_collision_mask(0)
		Player3.set_collision_layer(0)
		Player3.set_collision_mask(0)
		# slows down the currently selected music by 10%; creates an audible slowdown effect
		AudioManager.setPitch("BT", .90) # "BT" is the name of the song being used (placeholder), while .90 is the song's new slowed tempo
		# slows down the speed and animation speed of all enemies and objects with the tag "Slowable"
		# creates an illusion of super-speed by slowing everything else down significantly
		for Slowable in get_tree().get_nodes_in_group("Slowable"):
				if Slowable.has_node("AnimationPlayer"):
					Slowable.get_node("AnimationPlayer").speed_scale = 0.05
				if "speed" in Slowable:
					Slowable.speed = .30 #was .30
					
		# placeholder timer for debugging
		# var timer := get_tree().create_timer(8.0)
		
		GDManager.speed_timer.start() # this variable connects to the UI that tells you how long super-speed will last
		while GDManager.speed_timer.time_left > 0: # while there's still time left on your timer
			if GDManager.timeSlowed == false: # and IF you press space while time is slowed, which sets the timer back to its initial state...
				cancel_timer = true # Then the timer is cancelled
				
			if cancel_timer: # If the timer is cancelled, the cancel_timer variable will set to false again, and time goes back to normal
				GDManager.speed_timer.stop() #resets the UI circle if you press space while time is slowed (and reset things back to normal)
				cancel_timer = false
				AudioManager.setPitch("BT", 1.0)
				for Slowable in get_tree().get_nodes_in_group("Slowable"):
						if Slowable.has_node("AnimationPlayer"):
							Slowable.get_node("AnimationPlayer").speed_scale = 1.0
						if "speed" in Slowable:
							Slowable.speed = 20 #was 20
				Player1.speed = 75
				Player2.speed = 75
				Player3.speed = 75
				Player1.set_collision_layer(1)
				Player1.set_collision_mask(1)
				Player2.set_collision_layer(1)
				Player2.set_collision_mask(1)
				Player3.set_collision_layer(1)
				Player3.set_collision_mask(1)
				return
				
				
			await get_tree().process_frame
		#await get_tree().create_timer(8.0).timeout
		timeSlowed()
	if !GDManager.timeSlowed: #IF, after Q is pressed, your speed goes back to normal:
		#GDManager.speed_timer.stop()
		AudioManager.setPitch("BT", 1.0)
		for Slowable in get_tree().get_nodes_in_group("Slowable"):
				if Slowable.has_node("AnimationPlayer"):
					Slowable.get_node("AnimationPlayer").speed_scale = 1.0
				if "speed" in Slowable:
					Slowable.speed = 20
				if is_instance_valid(bullet):
						bullet.speed = 100
		Player1.speed = 75
		Player2.speed = 75
		Player3.speed = 75
		Player1.set_collision_layer(1)
		Player1.set_collision_mask(1)
		Player2.set_collision_layer(1)
		Player2.set_collision_mask(1)
		Player3.set_collision_layer(1)
		Player3.set_collision_mask(1)


func timeSlowed_Synced():
	
	if GameManager.player3dead:
		return
	GDManager.timeSlowed = !GDManager.timeSlowed
	print("timeSlowed: ", GDManager.timeSlowed)
	if GDManager.timeSlowed:
		GameManager.current_player_index = 2
		GameManager.current_world_index = 2
		#if !GameManager.current_player_index == 2:
			#GameManager.current_player_index = 2
			#GameManager.current_world_index = 2
		Player1.speed = 250
		Player2.speed = 250
		Player3.speed = 250
		Player1.set_collision_layer(0)
		Player1.set_collision_mask(0)
		Player2.set_collision_layer(0)
		Player2.set_collision_mask(0)
		Player3.set_collision_layer(0)
		Player3.set_collision_mask(0)
		AudioManager.setPitch("BT", .90)
		for Slowable in get_tree().get_nodes_in_group("Slowable"):
				if Slowable.has_node("AnimationPlayer"):
					Slowable.get_node("AnimationPlayer").speed_scale = 0.05
				if "speed" in Slowable:
					Slowable.speed = .30 #was .30
		
	if !GDManager.timeSlowed: #IF, after Q is pressed, your speed goes back to normal:
		#GDManager.speed_timer.stop()
		AudioManager.setPitch("BT", 1.0)
		for Slowable in get_tree().get_nodes_in_group("Slowable"):
				if Slowable.has_node("AnimationPlayer"):
					Slowable.get_node("AnimationPlayer").speed_scale = 1.0
				if "speed" in Slowable:
					Slowable.speed = 20
				if is_instance_valid(bullet):
						bullet.speed = 100
		Player1.speed = 75
		Player2.speed = 75
		Player3.speed = 75
		Player1.set_collision_layer(1)
		Player1.set_collision_mask(1)
		Player2.set_collision_layer(1)
		Player2.set_collision_mask(1)
		Player3.set_collision_layer(1)
		Player3.set_collision_mask(1)




func _process(delta: float) -> void:	
	#print(GDManager.is_teleporting)
	
	
	if Input.is_action_just_pressed("ui_1") && GameManager.current_world_index != 0:
		$ColorRect.visible = true
		LevelAnimation.play("change_world")
		await LevelAnimation.animation_finished
		$ColorRect.visible = false
	if Input.is_action_just_pressed("ui_2") && GameManager.current_world_index != 1:
		$ColorRect.visible = true
		LevelAnimation.play("change_world")
		await LevelAnimation.animation_finished
		$ColorRect.visible = false
	if Input.is_action_just_pressed("ui_3") && GameManager.current_world_index != 2:
		$ColorRect.visible = true
		LevelAnimation.play("change_world")
		await LevelAnimation.animation_finished
		$ColorRect.visible = false
	
	if GameManager.current_player_index != GDManager.previous_player_index:
		GDManager.previous_player_index = GameManager.current_player_index
		$ColorRect.visible = true
		if LevelAnimation:
			LevelAnimation.play("change_world")
		await LevelAnimation.animation_finished
		$ColorRect.visible = false
	
	#this line of code was causing the Canvas Layer displaying hearts and abilities to not appear for a few seconds after teleporting back into Player 2's world from another world.
	#if GDManager.is_teleporting == true:
		#await get_tree().create_timer(5.0).timeout
		#GDManager.is_teleporting = false
	
	var icon1 = $CanvasLayer/Player1Icon
	if icon1 and GDManager.shield_active:
		icon1.position = Vector2(13,29)
		icon1.scale = Vector2(.750,.750)
	if icon1 and !GDManager.shield_active:
		icon1.position = Vector2(13,29)
		icon1.scale = Vector2(.625,.625)
	
	var icon2 = $CanvasLayer/Player2Icon4
	var icon2_1 = $CanvasLayer/Player2IconHighlighted
	if icon2 and GDManager.is_teleporting == true:
		icon2.position = Vector2(39,29)
		icon2.scale = Vector2(.750,.750)
	if icon2 and GDManager.is_teleporting == false:
		icon2.position = Vector2(39,29)
		icon2.scale = Vector2(.625,.625)
		
	var icon3 = $CanvasLayer/Player3Icon3
	if icon3 and GDManager.timeSlowed:
		icon3.position = Vector2(65,29)
		icon3.scale = Vector2(.750,.750)
	if icon3 and !GDManager.timeSlowed:
		icon3.position = Vector2(65,29)
		icon3.scale = Vector2(.625,.625)
	#elif GameManager.current_player_index == 1:
		#if Input.is_action_just_pressed("ui_space") or Input.is_action_just_pressed("ui_q"):
			#$ColorRect.visible = true
			#LevelAnimation.play("change_world")
			#await LevelAnimation.animation_finished
			#$ColorRect.visible = false
	#elif GameManager.current_player_index == 2:
		#if Input.is_action_just_pressed("mouse_click") or Input.is_action_just_pressed("ui_q"):
			#$ColorRect.visible = true
			#LevelAnimation.play("change_world")
			#await LevelAnimation.animation_finished
			#$ColorRect.visible = false
		
	
			

	
	if GameManager.current_world_index != 0:
		GDManager.heartsContainer.hide()
	if GameManager.current_world_index == 0:
		GDManager.heartsContainer.show()
	if GameManager.current_world_index != 1:
		GDManager.heartsContainer2.hide()
	if GameManager.current_world_index == 1:
		GDManager.heartsContainer2.show()
	if GameManager.current_world_index != 2:
		GDManager.heartsContainer3.hide()
	if GameManager.current_world_index == 2:
		GDManager.heartsContainer3.show()
	if GameManager.player1dead:
		GDManager.heartsContainer.hide()
	if GameManager.player2dead:
		GDManager.heartsContainer2.hide()
	if GameManager.player3dead:
		GDManager.heartsContainer3.hide()
		#if GameManager.player3dead:
	
	#Overworld Audio
	#Player 1
	if GameManager.current_world_index == 0:
		if !GameManager.player1dead:
			if GameManager.player2dead:  
				AudioManager.setVolume("trapped", 0)
			if GameManager.player3dead:  
				AudioManager.setVolume("trapped", 0)
			if GameManager.player2dead && GameManager.player3dead:
				AudioManager.setVolume("trapped", 0)
		if GameManager.player1dead:
			AudioManager.setVolume("trapped", -80)
		if !GameManager.player1dead:
			AudioManager.setVolume("trapped", 0)
	#Player 2
	if GameManager.current_world_index == 1:
		if !GameManager.player2dead:
			if GameManager.player1dead:  
				AudioManager.setVolume("trapped", 0)
			if GameManager.player3dead:  
				AudioManager.setVolume("trapped", 0)
			if GameManager.player1dead && GameManager.player3dead:
				AudioManager.setVolume("trapped", 0)
		if GameManager.player2dead:
			AudioManager.setVolume("trapped", -80)
		if !GameManager.player2dead:
			AudioManager.setVolume("trapped", 0)
	#Player 3
	if GameManager.current_world_index == 2:
		if !GameManager.player3dead:
			if GameManager.player1dead:  
				AudioManager.setVolume("trapped", 0)
			if GameManager.player2dead:  
				AudioManager.setVolume("trapped", 0)
			if GameManager.player1dead && GameManager.player2dead:
				AudioManager.setVolume("trapped", 0)
		if GameManager.player3dead:
			AudioManager.setVolume("trapped", -80)
		if !GameManager.player3dead:
			AudioManager.setVolume("trapped", 0)
	
	
	#GAME OVER FUNCTIONS
	#PLAYER 1
	if GameManager.player1dead && GameManager.current_world_index == 0:
		GDManager.heartsContainer.hide()
		$CanvasLayer.hide()
		AudioManager.playMusic("KIA", "res://Audio/KIA.ogg", true, 0.0, 1.0) 
		if GDManager.timeSlowed:
			AudioManager.setPitch("KIA", .90)
		else:
			AudioManager.setPitch("KIA", 1.0)
	if  GameManager.player1dead && GameManager.current_world_index != 0:
		AudioManager.setVolume("KIA", -80)
		$CanvasLayer.show()
	
	if !GameManager.player1dead && GameManager.current_world_index == 0:
		AudioManager.setVolume("KIA", -80)
	
	
	#PLAYER 2
	if GameManager.player2dead && GameManager.current_world_index == 1:
		GDManager.heartsContainer2.hide()
		$CanvasLayer.hide()
		AudioManager.playMusic("Bad Dream", "res://Audio/A bad dream.wav", true, 0.0, 1.0) 
	if GameManager.player2dead && GameManager.current_world_index != 1:
		$CanvasLayer.show()
		AudioManager.setVolume("Bad Dream", -80)
	if !GameManager.player2dead && GameManager.current_world_index == 1:
		AudioManager.setVolume("Bad Dream", -80) 
	
	
	#PLAYER 3
	if GameManager.player3dead:
		if GameManager.current_world_index == 2:
			GDManager.heartsContainer3.hide()
			$CanvasLayer.hide()
			AudioManager.playMusic("Better Tomorrow", "res://Audio/A better tomorrow.wav", true, 0.0, 1.0) 
		if GameManager.current_world_index != 2:
			AudioManager.setVolume("Better Tomorrow", -80)
			$CanvasLayer.show()
	if !GameManager.player3dead:
		if GameManager.current_world_index == 2:
			AudioManager.setVolume("Better Tomorrow", -80)
		#if GameManager.current_world_index == 2: #&& gameover3Audio.playing && GameManager.timesplayer3died >= 1:
			#AudioManager.setVolume("Better Tomorrow", -80)
	
	if GameManager.player1dead && GameManager.player2dead && GameManager.player3dead:
		$CanvasLayer.hide()
	
	
	
	
	
	#Overworld Audio
	#Player 1
	#if GameManager.current_world_index == 0:
		#if !GameManager.player1dead:
			#if GameManager.player2dead:  
				#overworldAudio.volume_db = 0
			#if GameManager.player3dead:  
				#overworldAudio.volume_db = 0
			#if GameManager.player2dead && GameManager.player3dead:
				#overworldAudio.volume_db = 0
		#if GameManager.player1dead:
			#overworldAudio.volume_db = -80
		#if !GameManager.player1dead:
			#overworldAudio.volume_db = 0
	##Player 2
	#if GameManager.current_world_index == 1:
		#if !GameManager.player2dead:
			#if GameManager.player1dead:  
				#overworldAudio.volume_db = 0
			#if GameManager.player3dead:  
				#overworldAudio.volume_db = 0
			#if GameManager.player1dead && GameManager.player3dead:
				#overworldAudio.volume_db = 0
		#if GameManager.player2dead:
			#overworldAudio.volume_db = -80
		#if !GameManager.player2dead:
			#overworldAudio.volume_db = 0
	##Player 3
	#if GameManager.current_world_index == 2:
		#if !GameManager.player3dead:
			#if GameManager.player1dead:  
				#overworldAudio.volume_db = 0
			#if GameManager.player2dead:  
				#overworldAudio.volume_db = 0
			#if GameManager.player1dead && GameManager.player2dead:
				#overworldAudio.volume_db = 0
		#if GameManager.player3dead:
			#overworldAudio.volume_db = -80
		#if !GameManager.player3dead:
			#overworldAudio.volume_db = 0
	
	
	
	

		
	
	
		
	#GAME OVER FUNCTIONS
	#PLAYER 1
	#if GameManager.player1dead && GameManager.current_world_index == 0:
		#heartsContainer.hide()
		#if not gameover1Audio.playing:
			#gameover1Audio.play()
		#if gameover1Audio.playing:
			#gameover1Audio.volume_db = 0 
	#if  GameManager.player1dead && GameManager.current_world_index != 0:
			#gameover1Audio.volume_db = -80
	#
	#if !GameManager.player1dead && GameManager.current_world_index == 0 && gameover1Audio.playing:
		#gameover1Audio.volume_db = -80
	#
	#
	##PLAYER 2
	#if GameManager.player2dead && GameManager.current_world_index == 1:
		#heartsContainer2.hide()
		#if not gameover2Audio.playing:
			#gameover2Audio.play()
		#if gameover2Audio.playing:
			#gameover2Audio.volume_db = 0 
	#if GameManager.player2dead && GameManager.current_world_index != 1:
		#gameover2Audio.volume_db = -80
	#if !GameManager.player2dead && GameManager.current_world_index == 1 && gameover2Audio.playing:
		#gameover2Audio.volume_db = -80 
	#
	#
	##PLAYER 3
	#if GameManager.player3dead && GameManager.current_world_index == 2:
		#heartsContainer3.hide()
		#if not gameover3Audio.playing:
			#gameover3Audio.play() 
		#if gameover3Audio.playing:
			#gameover3Audio.volume_db = 0
	#if GameManager.player3dead && GameManager.current_world_index != 2:
		#gameover3Audio.volume_db = -80
	#if !GameManager.player3dead && GameManager.current_world_index == 2 && gameover3Audio.playing:
		#gameover3Audio.volume_db = -80
	#if !GameManager.player3dead && GameManager.current_world_index == 2 && gameover3Audio.playing && GameManager.timesplayer3died >= 1:
		#gameover3Audio.play()
			
	if GameManager.player1revived:
		GDManager.heartsContainer.updateHearts(Player1.player1maxHealth)
	if GameManager.player2revived:
		GDManager.heartsContainer2.updateHearts2(Player2.player2maxHealth)
	if GameManager.player3revived:
		GDManager.heartsContainer3.updateHearts3(3)
		

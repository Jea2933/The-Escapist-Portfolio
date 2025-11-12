#the parent script for player 1, 2, and 3. Contains state machines for player movement.
extends CharacterBody2D

class_name Player

@onready var speed: int = 85
#@onready var animations = $AnimationPlayer
@onready var animated = $AnimatedSprite2D
@onready var animated_d = $"AnimatedSprite2D [Dark]"
@onready var Player2 = "res://Scenes/Player_2_Scene.tscn"

var last_direction := "front" #default to facing towards the camera

var main_sm: LimboHSM
@onready var Level1 = get_node("/root/Control")

@onready var collision_shape = $CollisionShape2D #for collision manipulation when teleporting

var fps : float = 2.0

var is_changing = false




@onready var sprite = $AnimatedSprite2D 
var animation_speed = 1.0


var timer_delay_int = 1.0 #the time it takes before Player 2 teleports after a mouse click. Insert this variable name into "$Timer.start(here)"
var timer_delay: Timer = null

var teleportation_set_mouse_position: bool = true
var teleportation_unset_mouse_position: bool = false


var time_scale_for_player = 1

@onready var AnimationPlayer2 = $AnimationPlayer2 #animation player for Player 2

var delayed_teleport_timer: Timer = null

var label_node : Label
var right_click_mouse_timer_label : Label

#Player 2 Teleportation variables

var teleport_timer: Timer = null
var times_teleported: int = 0


var active_player: Node2D = null

var manager : Node = null

func _ready():
	# Connect the mouse button event
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	initiate_state_machine()
	
	AudioManager.addMusicTrigger("BT", 118.0, Callable(self, "level1_BT").bind(.7, 12))
	AudioManager.addMusicTrigger("BT", 123.1, Callable(self, "level1_BT").bind(.7, 12))
	AudioManager.addMusicTrigger("BT", 113, Callable(self, "level1_BT").bind(.6, 12))
	
	
	
	set_process(true)
	#TIMERS
	timer_delay = Timer.new()
	add_child(timer_delay)
	timer_delay.one_shot = true 
	timer_delay.wait_time = 5
	#timer_delay.timeout.connect(self._on_timer_timeout)
	
	
	manager = get_parent().get_node("PlayerManager")
	if manager:
		var active_player = manager.activePlayer
		if active_player != null:
			print("Active Player is:", active_player.name)
		else:
			print("activePlayer is null.")
			
		print(manager.number)	
	
	
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	var parent = get_parent()
	
	
	add_child(GDManager.teleport_timer)
	GDManager.teleport_timer.one_shot = true
	GDManager.teleport_timer.wait_time = GDManager.teleport_wait_time
	
	#sprite.speed_scale = animation_speed
	
func level1_BT(timer_duration : float, fps_value : float):
	fps_value = fps
	is_changing = true
	match last_direction:
		"right":
			if animated.animation == "moveRight":
				animated.sprite_frames.set_animation_speed("moveRight_all", fps)
				animated.play("moveRight_all")
			if animated.animation == "idleRight":
				animated.sprite_frames.set_animation_speed("idleRight_all", fps)
				animated.play("idleRight_all")
			#animated.play("idleRight_all")
		"left":
			if animated.animation == "moveLeft":
				animated.sprite_frames.set_animation_speed("moveLeft_all", fps)
				animated.play("moveLeft_all")
			if animated.animation == "idleLeft":
				animated.sprite_frames.set_animation_speed("idleLeft_all", fps)
				animated.play("idleLeft_all")
		"up":
			if animated.animation == "moveUp":
				animated.sprite_frames.set_animation_speed("moveUp_all", fps)
				animated.play("moveUp_all")
			if animated.animation == "idleUp":
				animated.sprite_frames.set_animation_speed("idleUp_all", fps)
				animated.play("idleUp_all")
		"down":
			if animated.animation == "moveDown":
				animated.sprite_frames.set_animation_speed("moveDown_all", fps)
				animated.play("moveDown_all")
			if animated.animation == "idle":
				animated.sprite_frames.set_animation_speed("idle_all", fps)
				animated.play("idle_all")
		_:
			animated.play("idle_all")
	print("working!")
	await get_tree().create_timer(timer_duration).timeout
	is_changing = false
	if animated.animation == "moveRight_all":
		animated.play("moveRight")
	if animated.animation == "moveLeft_all":
		animated.play("moveLeft")
	if animated.animation == "moveUp_all":
		animated.play("moveUp")
	if animated.animation == "moveDown_all":
		animated.play("moveDown")
	if animated.animation == "idleLeft_all":
		animated.play("idleLeft")
	if animated.animation == "idleRight_all":
		animated.play("idleRight")
	if animated.animation == "idleDown_all":
		animated.play("idleDown")
	if animated.animation == "idleUp_all":
		animated.play("idleUp")
	if animated.animation == "idle_all":
		animated.play("idle")
#func _unhandled_input(event: InputEvent) -> void: #main code for teleportation. Also works with colliders for keeping player from teleporting into walls
	# Check if the left mouse button is pressed





func _process(delta: float) -> void:
	pass
	#if active_player != null:
			#print("Active Player is:", active_player.name)
	#else:
			#print("activePlayer is null.")
		
	
	
	
	
	
								
	#if Input.is_action_just_pressed("ui_accept"):
		#print("ui_accept from current player")
		##if timer_delay.time_left > 0:
			#timer_delay.stop()
			#timer_delay.start()
		#get_tree().paused = true
		#Engine.time_scale = 0.03
		#timer_delay.wait_time = 5.0 * (1.0 / time_scale_for_player)
	#
	#if Engine.time_scale < 1.0:
		#sprite.speed_scale = animation_speed / Engine.time_scale
	#else:
		#sprite.speed_scale = animation_speed

		
		


func _input(event):
	
	if event is InputEventKey and event.pressed and not event.echo:
		if InputMap.event_is_action(event, "ui_u"):
			toggle_set_or_delayed_teleportation()
	#if event.is_action_pressed("ui_space"):
		#if GDManager.synced == true:
				#slowTime()
	



func toggle_set_or_delayed_teleportation():
		teleportation_set_mouse_position = !teleportation_set_mouse_position
		teleportation_unset_mouse_position = !teleportation_unset_mouse_position
		print("Teleportation Set:", teleportation_set_mouse_position)
	
	


	
func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection*speed
	var adjusted_speed = speed / Engine.time_scale
	velocity = moveDirection * adjusted_speed

func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var _collider = collision.get_collider()
		
func _physics_process(delta: float) -> void:
	handleInput()
	handleCollision()
	#updateAnimation()
	#_check_player_collision()
	move_and_slide()



		
					
			
#func slowTime(): #NOT BEING USED
	#
	#GDManager.timeSlowed = !GDManager.timeSlowed
	#print("timeSlowed: ", GDManager.timeSlowed)
	#if GDManager.timeSlowed: #if time slows down when space bar is pressed
		#if !GameManager.current_player_index == 2: #if you aren't on player 3 when you press space bar, go to player 3
				#
			#GameManager.current_player_index = 2
			#GameManager.current_world_index = 2	
			#speed = 500
					#
		#AudioManager.setPitch("trapped", .90)
		#speed = 500
		#for Slowable in get_tree().get_nodes_in_group("Slowable"):
				#if Slowable.has_node("AnimationPlayer"):
					#Slowable.get_node("AnimationPlayer").speed_scale = 0.05
				#if "speed" in Slowable:
					#Slowable.speed = .30
		###await get_tree().create_timer(8.0).timeout
		###slowTime()
		##
	#if !GDManager.timeSlowed: #if time goes back to normal when space bar is pressed
		##code that makes everything go really fast at the last second, like that scene with QuickSiler that we like
		##speed = 185
		##AudioManager.setPitch("trapped", 1.2)
		##for Slowable in get_tree().get_nodes_in_group("Slowable"):
				##if Slowable.has_node("AnimationPlayer"):
					##Slowable.get_node("AnimationPlayer").speed_scale = 3.0
				##if "speed" in Slowable:
					##Slowable.speed = 50
		##await get_tree().create_timer(1.0).timeout
		##end of the code
		#
		#
		#AudioManager.setPitch("trapped", 1.0)
		#speed = 75
		#for Slowable in get_tree().get_nodes_in_group("Slowable"):
				#if Slowable.has_node("AnimationPlayer"):
					#Slowable.get_node("AnimationPlayer").speed_scale = 1.0
				#if "speed" in Slowable:
					#Slowable.speed = 20
	##can_teleport = true
	##print("Player 2 Teleported with a delay of", timer_delay_int, " second.")
	

func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	#var idleRight_state = LimboState.new().named("idleRight").call_on_enter(idleRight_start).call_on_update(idleRight_update)
	var walkRight_state = LimboState.new().named("walkRight").call_on_enter(walkRight_start).call_on_update(walkRight_update)
	var walkLeft_state = LimboState.new().named("walkLeft").call_on_enter(walkLeft_start).call_on_update(walkLeft_update)
	var walkUp_state = LimboState.new().named("walkUp").call_on_enter(walkUp_start).call_on_update(walkUp_update)
	var walkDown_state = LimboState.new().named("walkDown").call_on_enter(walkDown_start).call_on_update(walkDown_update)
	
	
	main_sm.add_child(idle_state)
	#main_sm.add_child(idleRight_state)
	main_sm.add_child(walkRight_state)
	main_sm.add_child(walkLeft_state)
	main_sm.add_child(walkUp_state)
	main_sm.add_child(walkDown_state)
	
	main_sm.initial_state = idle_state
	
	main_sm.add_transition(idle_state, walkRight_state, &"to_walk_right")
	#main_sm.add_transition(idleRight_state, walkRight_state, &"to_walk_right")
	#main_sm.add_transition(walkRight_state, idleRight_state, &"to_idle_right")
	main_sm.add_transition(idle_state, walkLeft_state, &"to_walk_left")
	main_sm.add_transition(idle_state, walkUp_state, &"to_walk_up")
	main_sm.add_transition(idle_state, walkDown_state, &"to_walk_down")
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
func idle_start():
	match last_direction:
		"right":
			if animated.animation != "idleRight_all":
				animated.play("idleRight")
		"left":
			if animated.animation != "idleLeft_all":
				animated.play("idleLeft")
		"up":
			if animated.animation != "idleUp_all":
				animated.play("idleUp")
		"down":
			if animated.animation != "idleDown_all":
				animated.play("idleDown")
				if !GDManager.dark:
					animated.play("idle")
				if GDManager.dark:
					animated.play("idle_d") 
		_:
			if animated:
				if animated.animation != "idle_all":
					if !GDManager.dark:
						animated.play("idle")
					if GDManager.dark:
						animated.play("idle_d") 
	
	
	
func idle_update(delta:float):
	if velocity.x < 0: 
		main_sm.dispatch(&"to_walk_left")
	if velocity.x > 0: 
		main_sm.dispatch(&"to_walk_right")
	if velocity.y < 0: 
		main_sm.dispatch(&"to_walk_up")
	if velocity.y > 0: 
		main_sm.dispatch(&"to_walk_down")

#func idleRight_start():
	#animated.play("idleRight")
#func idleRight_update():
	#if velocity.x < 0: 
		#main_sm.dispatch(&"to_walk_left")
	#if velocity.x > 0: 
		#main_sm.dispatch(&"to_walk_right")
	#if velocity.y < 0: 
		#main_sm.dispatch(&"to_walk_up")
	#if velocity.y > 0: 
		#main_sm.dispatch(&"to_walk_down")
	
func walkRight_start():	
	last_direction = "right"
	if is_changing == false:
		animated.play("moveRight")
	if is_changing == true:
		animated.sprite_frames.set_animation_speed("moveRight_all", fps)
		animated.play("moveRight_all")
	if GDManager.dark:
		animated.play("moveRight_d")
	
	
func walkRight_update(delta:float):
	if velocity.x == 0: 
		main_sm.dispatch(&"state_ended")
			
#plays the animation for walking left. also ends the state if the player stops moving in that direction	   
func walkLeft_start():
	last_direction = "left"
	if is_changing == false:
		animated.play("moveLeft")
	if is_changing == true:
		animated.sprite_frames.set_animation_speed("moveLeft_all", fps)
		animated.play("moveLeft_all")
	if GDManager.dark:
		animated.play("moveLeft_d")
func walkLeft_update(delta:float):
	if velocity.x == 0: 
		main_sm.dispatch(&"state_ended")
		

func walkUp_start():
	last_direction = "up"
	if is_changing == false:
		animated.play("moveUp")
	if is_changing == true:
		animated.sprite_frames.set_animation_speed("moveUp_all", fps)
		animated.play("moveUp_all")
	if GDManager.dark:
		animated.play("moveUp_d")
func walkUp_update(delta:float):
	if velocity.y == 0: 
		main_sm.dispatch(&"state_ended")


func walkDown_start(): 
	last_direction = "down"
	if is_changing == false:
		animated.play("moveDown")
	if is_changing == true:
		animated.sprite_frames.set_animation_speed("moveDown_all", fps)
		animated.play("moveDown_all")
	if GDManager.dark:
		animated.play("moveDown_d")
func walkDown_update(delta:float):
	if velocity.y == 0: 
		main_sm.dispatch(&"state_ended")	


		

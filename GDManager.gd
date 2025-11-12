extends Node



#@onready var shield = $Shield


@onready var timeSlowed := false

var flower_status : String = ""
var interacted_with_flower : bool = false

var dialogue_level: int = 0
var interaction_log: Dictionary = {}
var detail_level: int = 0

var previous_player_index: int = -1

var dark = false #this will decide if the other characters are blackend out or not. true = characters are black (meaning it's not really them)


var last_position: Vector2 = Vector2.ZERO
var player_reference: Node = null

#PLAYER HEALTH VARIABLES
@onready var player1maxHealth = 8
@onready var player1currentHealth: int
 
@onready var player2maxHealth = 5
@onready var player2currentHealth: int 

@onready var player3maxHealth = 8
@onready var player3currentHealth: int 


var heartsContainer: Node = null
var heartsContainer2: Node = null
var heartsContainer3: Node = null 

#Probably won't use these anymore 
var shared_teleportation_custom_timer = 0.0
var shared_teleportation_timer_running = false

#Used for generating random thoughts that can appear for characters
var player1_thoughts = ["thought1", "thought2", "thought3", "thought4", "thought5"]


#GAME OVER VARIABLES
var gameover1_instance: Node = null
var gameover1scene = preload("res://Scenes/Game Over Screens/Player 1 Game Over.tscn")

var gameover2_instance: Node = null
var gameover2scene = preload("res://Scenes/Game Over Screens/Player 2 Game Over.tscn")

var gameover3_instance: Node = null
var gameover3scene = preload("res://Scenes/Game Over Screens/Player 3 Game Over.tscn")

#TIMER FOR THE SHIELD
var shield_timer: Timer = null
var shield_time: int = 5
var shield_timer_stopped = false
var shield_timer_short: Timer = null
var shield_timer_long: Timer = null
var longer_shield_timer = false

#Shield Variables
@onready var shield = GameManager.shieldInstance as Node2D #this is the actual shield; it's imported from GameManager.cs
var shield_active : bool = false
@onready var limited_shield: bool = true

#Player 2 teleportation variables
var teleport_limit_current: int = 5
var teleport_limit_max: int = 3 #this is the default
var teleport_wait_time: int = 5
var is_teleporting = false
var limited_teleportation = true

var teleport_timer = Timer.new()

#Speedster Timer Variables
var speed_timer = Timer.new()
var speed_time: int = 6




#Variable for deciding if the characters will be able to use powers without limitations (synced) or not (not synced). 
#In most cases, synced will be false and is only true conditionally during certain sequences
var synced = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #makes the mouse visible in game
	
	shield.get_node("StaticBody2D/CollisionShape2D").disabled = true 
	
	GDManager.player1currentHealth = GDManager.player1maxHealth
	GDManager.player2currentHealth = GDManager.player2maxHealth
	GDManager.player3currentHealth = GDManager.player3maxHealth
	
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#print(shield2.global_position)
	if GameManager.shieldInstance:
		print("Shield exists!")
		
	#SHIELD TIMER
	shield_timer = Timer.new()
	add_child(shield_timer)
	shield_timer.one_shot = true
	shield_timer.wait_time = shield_time
	shield_timer.timeout.connect(self._on_timer_timeout)  # Connect the timeout signal
	
	add_child(speed_timer)
	speed_timer.one_shot = true
	speed_timer.wait_time = speed_time
	
	shield_timer_short = Timer.new()
	add_child(shield_timer_short)
	shield_timer_short.one_shot = true
	shield_timer_short.wait_time = 1
	shield_timer_short.timeout.connect(self._on_short_timer_timeout)
	
	shield_timer_long = Timer.new()
	add_child(shield_timer_long)
	shield_timer_long.one_shot = true
	shield_timer_long.wait_time = 1
	shield_timer_long.timeout.connect(self._on_short_timer_timeout)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print("Player:", GameManager.current_player_index)
	#print("World:", GameManager.current_world_index)
	#old shield code. Save just incase
				#var shield_node = get_shield()
				#if shield_node:
					#shield_active = !shield_active
					#shield_node.visible = shield_active
					#if shield_active:
						#print("Player 1's shield is ", "on" if shield_active else "off")
						#await get_tree().create_timer(5.0).timeout
						#shield_active = false
						##shield2.visible = false
						#print("Player 1's shield is ", "on" if shield_active else "off")
	#print("timeSlowed: ", timeSlowed)
	
	if GameManager.player1dead:
		gameover1()
		
	if GameManager.player2dead: 
		gameover2()
		
	if GameManager.player3dead: 
		gameover3()
		

func _input(event):
	use_shield(event)
	
	

func use_shield(event): #activates character 1's shield
	if event.is_action_pressed("ui_q"): #switch to Character 1, World 1
		GameManager.current_world_index = 0
		GameManager.current_player_index = 0
		if GameManager.player1dead: #if Player 1 is dead, then the shield will not activate
			return
		if shield_timer_stopped: 
			return
		if synced == false: #this is what happens more often than not. It makes the shield only last a few seconds for natural game balance.
			if GameManager.current_player_index == 0: #if you are on the player that can teleport (player 1)
				if !limited_shield: #if the shield lasts indefinitely (for debugging- not the default)	
					if !GameManager.current_player_index == 0: #if the game is not set to player 1
						pass #if the game isn't on player 1 when q is pressed, do nothing
					shield_active = !shield_active
					if !shield_active:
						AudioManager.playSound("res://Audio/shield_gone.ogg")
					#shield2.visible = shield_active
					print("Player 1's shield is ", "on" if shield_active else "off")
				else:#if synced is false and the shield is limited in duration. This should be the code that runs more often than not. 
					shield_active = !shield_active
					shield.visible = shield_active
					if shield_active: #If the shield gets turned on
						shield.get_node("StaticBody2D/CollisionShape2D").disabled = false
						AudioManager.playSound("res://Audio/shield_ring.mp3")
						shield_timer.start()
						print("Player 1's shield is on")
						#print("Player 1's shield is ", "on" if shield_active else "off")
					else: #if the shield gets turned off by the timer
						shield.get_node("StaticBody2D/CollisionShape2D").disabled = true
						AudioManager.playSound("res://Audio/shield_gone.ogg")
						print("Player 1's shield is deactivated (from button press)")
						shield_timer.stop()
		if synced == true: #Only used conditionally when the characters are in "the zone" makes the shield infinitely active without a timer. 
			#It is essentially the same code above but without a timer.
			shield_active = !shield_active
			shield.visible = shield_active
			
			if shield_active == true: #if the shield turns on when Q is pressed
				shield.get_node("StaticBody2D/CollisionShape2D").disabled = false
				shield_timer.start()
				if GameManager.current_player_index != 0:
					GameManager.current_player_index = 0
					GameManager.current_world_index = 0			
			if shield_active == false: #if the shield becomes inactive on Q press
				shield.get_node("StaticBody2D/CollisionShape2D").disabled = true
				shield_timer.stop()			
				shield_timer_stopped = true
				shield_timer_short.start()

func _on_timer_timeout():
	if shield_active:
		shield_active = false
		shield.get_node("StaticBody2D/CollisionShape2D").disabled = true
		AudioManager.playSound("res://Audio/shield_gone.ogg")
		shield.visible = false
		print("Player 1's shield is off from timer")
		#longer_shield_timer = true
		shield_timer_stopped = true
		shield_timer_long.start()

func _on_short_timer_timeout():
	shield_timer_stopped = false
				
			
		
func addWholeHeart(): #adds a whole heart to the player while also filling up "currentHealth" to its max. Like getting a heart container in Zelda. 
	GDManager.player1currentHealth = GDManager.player1maxHealth
	heartsContainer.updateHearts(GDManager.player1currentHealth)
	heartsContainer.setMaxHearts(1)
	GDManager.player1currentHealth += 1
	GDManager.player1maxHealth += 1
	print("Player 1 Health: ", GDManager.player1currentHealth)		
func addWholeHeart2(): #adds a whole heart to the player while also filling up "currentHealth" to its max. Like getting a heart container in Zelda. 
	GDManager.player2currentHealth = GDManager.player2maxHealth
	heartsContainer2.updateHearts(GDManager.player2currentHealth)
	heartsContainer2.setMaxHearts(1)
	GDManager.player2currentHealth += 1
	GDManager.player2maxHealth += 1
	print("Player 2 Health: ", GDManager.player2currentHealth)
func addWholeHeart3(): #adds a whole heart to the player while also filling up "currentHealth" to its max. Like getting a heart container in Zelda. 
	GDManager.player3currentHealth = GDManager.player3maxHealth
	heartsContainer3.updateHearts(GDManager.player3currentHealth)
	heartsContainer3.setMaxHearts(1)
	GDManager.player3currentHealth += 1
	GDManager.player3maxHealth += 1
	print("Player 3 Health: ", GDManager.player3currentHealth)

func loseHeart1(): #empties one full heart. Use it when the player loses a heart from damage. 
	GDManager.player1currentHealth -= 1
	heartsContainer.updateHearts(GDManager.player1currentHealth)
func loseHeart2(): #empties one full heart. Use it when the player loses a heart from damage. 
	GDManager.player2currentHealth -= 1
	heartsContainer2.updateHearts(GDManager.player2currentHealth)	
func loseHeart3(): #empties one full heart. Use it when the player loses a heart from damage. 
	GDManager.player3currentHealth -= 1
	heartsContainer3.updateHearts(GDManager.player3currentHealth)
		
func restoreLostHeart1(): #retores a heart that was lost. Use it when the player "heals" with items. 
	GDManager.player1currentHealth += 1
	heartsContainer.updateHearts(GDManager.player1currentHealth)
func restoreLostHeart2(): #retores a heart that was lost. Use it when the player "heals" with items. 
	GDManager.player2currentHealth += 1
	heartsContainer2.updateHearts(GDManager.player2currentHealth)
func restoreLostHeart3(): #retores a heart that was lost. Use it when the player "heals" with items. 
	GDManager.player3currentHealth += 1
	heartsContainer3.updateHearts(GDManager.player3currentHealth)


func register_detailed_interaction(object_id: String) -> void:
	if not interaction_log.has(object_id):
		interaction_log[object_id] = true
		detail_level += 1
		print("New interaction! Detail level is now ", detail_level)
	else:
		print("Already interacted with ", object_id)		

func register_dialogue(object_id: String) -> void:
	if not interaction_log.has(object_id):
		interaction_log[object_id] = true
		dialogue_level += 1
		print("New dialogue!")
	else:
		print("Already queued ", object_id)		
		

func gameover1():
	if gameover1_instance == null or not is_instance_valid(gameover1_instance):
		gameover1_instance = gameover1scene.instantiate()
		add_child(gameover1_instance)
	if gameover1_instance != null and is_instance_valid(gameover1_instance):
		if GameManager.current_world_index != 0:
			gameover1_instance.get_node("CanvasLayer/Node2D").visible = false
			
		if GameManager.current_world_index == 0:
			gameover1_instance.get_node("CanvasLayer/Node2D").visible = true
	
	else:
		print("Failed to Load GameOver 1 UI")
		
func gameover1_music():
	
	if GameManager.current_player_index == 0:
		AudioManager.setVolume("trapped", -80)
		AudioManager.setVolume("gameover1", 0)
		
	if GameManager.current_player_index != 0:
		AudioManager.setVolume("trapped", 0)
		AudioManager.setVolume("gameover1", -80)

func gameover2():
	if gameover2_instance == null or not is_instance_valid(gameover2_instance):
		gameover2_instance = gameover2scene.instantiate()
		add_child(gameover2_instance)
	if gameover2_instance != null and is_instance_valid(gameover2_instance):
		if GameManager.current_world_index != 1:
			gameover2_instance.get_node("CanvasLayer/Node2D").visible = false
			
		if GameManager.current_world_index == 1:
			gameover2_instance.get_node("CanvasLayer/Node2D").visible = true
	
	else:
		print("Failed to Load GameOver 2 UI")
		
func gameover2_music():
	 
	if GameManager.current_player_index == 1:
		AudioManager.setVolume("trapped", -80)
		AudioManager.setVolume("gameover2", 0)
		
	if GameManager.current_player_index != 1:
		AudioManager.setVolume("trapped", 0)
		AudioManager.setVolume("gameover2", -80)


func gameover3():
	if gameover3_instance == null or not is_instance_valid(gameover3_instance):
		gameover3_instance = gameover3scene.instantiate()
		add_child(gameover3_instance)
	if gameover3_instance != null and is_instance_valid(gameover3_instance):
		if GameManager.current_world_index != 2:
			gameover3_instance.get_node("CanvasLayer/Node2D").visible = false
			
		if GameManager.current_world_index == 2:
			gameover3_instance.get_node("CanvasLayer/Node2D").visible = true
	
	else:
		print("Failed to Load GameOver 3 UI")

func gameover3_music():
	 
	if GameManager.current_player_index == 2:
		AudioManager.setVolume("trapped", -80)
		AudioManager.setVolume("gameover3", 0)
		
	if GameManager.current_player_index != 2:
		AudioManager.setVolume("trapped", 0)
		AudioManager.setVolume("gameover3", -80)

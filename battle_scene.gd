#currently under heavy development. This is the base script for future battle scenes with bullet hell style enemy attack patterns
extends BaseScene 


@onready var Camera = $Camera2D

@onready var is_boxing = false

var intro = preload("res://Dialogue/Intro.dialogue")

var current_attack_index = 0
var attack_functions = [
	"play_attack_string_1",
	"play_attack_string_2",
	"play_attack_string_3"
]





@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	Camera.make_current()
	DialogueManager.connect("dialogue_ended", self.on_dialogue_ended)
	#these lines dictate what lines of dialogue are actually shown
	dialogue_resource = preload("res://Dialogue/Intro.dialogue")
	dialogue_start = "begin2"
	#this line is what brings up the dialogue balloon when the scene starts
	await get_tree().create_timer(.5).timeout
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	
	

func on_dialogue_ended():
	if current_attack_index < attack_functions.size():
		var function_name = attack_functions[current_attack_index]
		if has_method(function_name):
			call(function_name)
			current_attack_index += 1
		else:
			print("Error, Function %s not found" % function_name)
	else:
		print("All attack strings played")
	#DialogueManager.disconnect("dialogue_ended", self.on_dialogue_ended)
	#DialogueManager.connect("dialogue_ended", self.on_intro_dialogue_finished_2)
	#$bullet.go = true


func spawn_bullets(positions: Array, directions: Array, speeds: Array):
	pass
	
func get_next_destroyed_bullet(bullets: Array[Node]) -> Node:
	for bullet in bullets:
		if is_instance_valid(bullet):
			var result = await bullet.bullet_destroyed
			return result
	return null
	
	
func wait_for_bullets_destroyed(bullets: Array[Node]) -> void:
	while not bullets.is_empty():
		var destroyed_bullet = await get_next_destroyed_bullet(bullets)
		bullets.erase(destroyed_bullet)
		
func on_bullet_destroyed(bullet: Node) -> void:
	print("BaseScene noticed bullet destroyed:", bullet)
		
		
func play_attack_string_1():
	var positions = [
		Vector2(111, 26),
		Vector2(120, 40),
		Vector2(130, 60),
		Vector2(254,38),
		Vector2(317,161)
	]
	var directions = [
		Vector2.DOWN,
		Vector2(1, -0.5).normalized(),
		Vector2(1, 0.5).normalized(),
		Vector2(-1, 1).normalized(),
		Vector2(-1, -1).normalized()
	]
	var speeds = [100, 100, 100, 100, 100]
	#Spawn first wave of bullets
	var bullet_count = 0
	var bullets: Array[Node] = []
	
	#spawn the first wave of bullets:
	for i in range(positions.size()):
		bullet = bullet_scene.instantiate()
		bullet.position = positions[i]
		bullet.direction = directions[i]
		bullet.speed = speeds[i]
		bullet.connect("bullet_destroyed", Callable(self, "on_bullet_destroyed"))
		bullets.append(bullet)
		#bullet.get_node("Sprite2D").modulate = Color.from_hsv(randf(), 1.0, 1.0)
		add_child(bullet)
		bullet_count += 1
	
	print("Spawned ", bullet_count, " bullets")
	
	# Wait for all bullets to be destroyed
	while bullets.size() > 0:
		await get_tree().create_timer(0.1).timeout  # Small delay to prevent tight loop
		bullets = bullets.filter(func(b): return is_instance_valid(b))  # Remove invalid (freed) bullets
	
	
	# Wait for all bullets to be destroyed
	#await wait_for_bullets_destroyed(bullets)
	
	#await get_tree().create_timer(3).timeout
	bullet_count = 0
	for i in range(positions.size()):
		var bullet = bullet_scene.instantiate()
		bullet.position = positions[i]
		bullet.direction = directions[i]
		bullet.speed = speeds[i]
		bullet.connect("bullet_destroyed", Callable(self, "on_bullet_destroyed"))
		bullets.append(bullet)
		add_child(bullet)
		bullet_count += 1
	print("Spawned ", bullet_count, " bullets")
	
	while bullets.size() > 0:
		await get_tree().create_timer(.1).timeout
		bullets = bullets.filter(func(b): return is_instance_valid(b))
	
	#await wait_for_bullets_destroyed(bullets)
	
	#await get_tree().create_timer(3).timeout
	
	#print("play dialogue")
	DialogueManager.show_example_dialogue_balloon(intro, "dialogue1")
	
	

	
func play_attack_string_2():
	var positions = [
		Vector2(50, 26),
		Vector2(50, 40),
		Vector2(50, 60)
	]
	var directions = [
		Vector2.DOWN,
		Vector2(1, -0.5).normalized(),
		Vector2(1, 0.5).normalized()
	]
	var speeds = [100, 100, 100]
	
	var bullets: Array[Node] = []
	for i in range(positions.size()):
		var bullet = bullet_scene.instantiate()
		bullet.position = positions[i]
		bullet.direction = directions[i]
		bullet.speed = speeds[i]
		bullet.connect("bullet_destroyed", Callable(self, "on_bullet_destroyed"))
		bullets.append(bullet)
		add_child(bullet)
	await get_tree().create_timer(3).timeout
	for i in range(positions.size()):
		var bullet = bullet_scene.instantiate()
		bullet.position = positions[i]
		bullet.direction = directions[i]
		bullet.speed = speeds[i]
		bullet.connect("bullet_destroyed", Callable(self, "on_bullet_destroyed"))
		bullets.append(bullet)
		add_child(bullet)
	
	await get_tree().create_timer(3).timeout
	DialogueManager.show_example_dialogue_balloon(intro, "dialogue2")

func play_attack_string_3():
	var positions = [
		Vector2(20, 26),
		Vector2(20, 40),
		Vector2(20, 60)
	]
	var directions = [
		Vector2.DOWN,
		Vector2(1, -0.5).normalized(),
		Vector2(1, 0.5).normalized()
	]
	var speeds = [150, 150, 150]
	#spawn_bullets(positions, directions, speeds)
	for i in range(positions.size()):
		var bullet = bullet_scene.instantiate()
		bullet.position = positions[i]
		bullet.direction = directions[i]
		bullet.speed = speeds[i]
		add_child(bullet)
	await get_tree().create_timer(3).timeout
	DialogueManager.show_example_dialogue_balloon(intro, "dialogue3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("ui_e") && is_boxing == false:
		Camera.position = Vector2(170, 40)
		is_boxing = true
		Player1.position = Vector2(167,65)
		Player2.position = Vector2(167,55)
		Player3.position = Vector2(167,65)
		Player1.last_direction = "up"
		Player1.animated.play("idleUp")
		Player2.last_direction = "up"
		Player2.animated.play("idleUp")
		Player3.last_direction = "up"
		Player3.animated.play("idleUp")
	if Input.is_action_just_pressed("ui_q") && is_boxing == true:
		Camera.position = Vector2(170,80)
		is_boxing = false
		Player1.position = Vector2(167,145)
		Player2.position = Vector2(167,145)
		Player3.position = Vector2(167,145)
	
	if Input.is_action_just_pressed("ui_r"):
		on_dialogue_ended()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Something got deleted?")

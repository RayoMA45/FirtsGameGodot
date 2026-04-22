extends CharacterBody2D

@onready var tile_marker = $AnimatedSprite2D/Marker2D
@onready var anim = $AnimatedSprite2D

var startFishing = false
var waitForFish = false
const speed = 100
var current_dir = "none"

#variables para sistema minijuego
var bite_timer := 0.0
var bite_time := 0.0
var fish_on_hook := false

var current_fish = null

func _physics_process(delta):
	if startFishing: _fishing_state()
	else: player_movement(delta)
	
func _fishing_state(): 
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("ui_cancel"):
		_stop_fishing()
		return 
		
	if waitForFish and not fish_on_hook:
		_handle_bite_timer(get_process_delta_time())

func _handle_bite_timer(delta):
	bite_timer += delta
	if bite_timer >= bite_time:
		_trigger_bite()

func _trigger_bite():	
	fish_on_hook = true
	print("pesca")
	current_fish = _get_random_fish()
	_start_minigame(current_fish)

func _get_random_fish():
	var rand = randf()
	var cumulative = 0.0
	
	for fish in fish_list:
		cumulative += fish["chance"]
		if rand <= cumulative:
			return fish
	return fish_list[0]

func _start_minigame(fish_data):
	var minigame = preload("res://MiniGame/fishing_minigame.tscn").instantiate()
	minigame.connect("fish_caught", Callable(self, "_on_fish_caught"))
	minigame.connect("fish_escaped", Callable(self, "_on_fish_escaped"))
	minigame.setup_fish(fish_data)
	get_tree().root.add_child(minigame)
	#get_tree().paused = true
	
func _on_fish_caught():
	print("Ganaste")
	get_tree().paused = false
	_stop_fishing()
	
func _on_fish_escaped():
	print("Perdiste")
	get_tree().paused = false
	_stop_fishing()

func _stop_fishing():
	waitForFish = false
	match current_dir:
		"right":
			anim.flip_h = false
			anim.play("Fish_End_Side")
		"left":
			anim.flip_h = true
			anim.play("Fish_End_Side")
		"down":
			anim.play("Fish_End_Front")
		"up":
			anim.play("Fish_End_Back")
	#anim.play("Fish_End_Side")
	await anim.animation_finished
	startFishing = false
	move_and_slide()

func player_movement(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_start_fishing()
		return
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	move_and_slide()

func _start_fishing():
	if not _get_tile_data() == "water": return
	startFishing = true
	waitForFish = false
	match current_dir:
		"right":
			anim.flip_h = false
			anim.play("Fish_Start_Side")
		"left":
			anim.flip_h = true
			anim.play("Fish_Start_Side")
		"down":
			anim.play("Fish_Start_Front")
		"up":
			anim.play("Fish_Start_Back")

func _get_tile_data():
	var tileMap = get_parent().find_child("Mar")
	var searchPosition = tileMap.local_to_map(tile_marker.global_position)
	var data = tileMap.get_cell_tile_data(searchPosition)
	if data: return data.get_custom_data("type")

func play_anim(movement):
	var dir = current_dir	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("Side_Walk")
		elif movement == 0:
			anim.play("Side_Idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("Side_Walk")
		elif movement == 0:
			anim.play("Side_Idle")
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("Front_Walk")
		elif movement == 0:
			anim.play("Front_Idle")
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("Back_Walk")
		elif movement == 0:
			anim.play("Back_Idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Fish_Start_Side" or anim.animation == "Fish_Start_Front" or anim.animation == "Fish_Start_Back":
		waitForFish = true
		bite_timer = 0.0
		bite_time = randf_range(2.0, 5.0)
		fish_on_hook = false
		match current_dir:
			"right":
				anim.flip_h = false
				anim.play("Fish_Wait_Side")
			"left":
				anim.flip_h = true
				anim.play("Fish_Wait_Side")
			"down":
				anim.play("Fish_Wait_Front")
			"up":
				anim.play("Fish_Wait_Back")
	elif anim.animation == "Fish_End":
		startFishing = false

#Elegir peces aleatorios
var fish_list = [
	{
		"name": "Pez Payaso",
		"texture": preload("res://Assets/Fish/Pez_Payaso.png"),
		"speed": 100,
		"chance": 0.2
	},
	{
		"name": "Salmón",
		"texture": preload("res://Assets/Fish/Salmon.png"),
		"speed": 60,
		"chance": 0.3
	},
	{
		"name": "Medusa",
		"texture": preload("res://Assets/Fish/Medusa.png"),
		"speed": 80,
		"chance": 0.2
	},
	{
		"name": "Pez Amarillo",
		"texture": preload("res://Assets/Fish/Pez_Amarillo.png"),
		"speed": 45,
		"chance": 0.3
	}
]

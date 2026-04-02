extends CharacterBody2D

@onready var tile_marker = $AnimatedSprite2D/Marker2D
@onready var anim = $AnimatedSprite2D

var startFishing = false
var waitForFish = false
const speed = 100
var current_dir = "none"

func _physics_process(delta):
	if startFishing: _fishing_state()
	else: player_movement(delta)
	
func _fishing_state(): 
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("ui_cancel"):
		_stop_fishing()
	if waitForFish: print("waiting for fish")

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
	#anim.play("Fish_Start_Side")
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
	var tileMap = get_parent().find_child("TileMapLayer")
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

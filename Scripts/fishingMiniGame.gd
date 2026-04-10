extends CanvasLayer

signal fish_caught
signal fish_escaped

@onready var panel = $Control/Panel
@onready var bar = $Control/Panel/Bar
@onready var fish = $Control/Panel/Fish
@onready var progress = $Control/Panel/ProgressBar

var bar_velocity := 0.0
var gravity := 800.0
var lift := -600.0
var fish_data = null
var fish_speed := 85.0
var fish_target := 0.0

var catch_progress := 50.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if fish_data:
		fish.texture = fish_data["texture"]
		fish_speed = fish_data["speed"]
	randomize()
	fish_target = randf_range(0, panel.size.y)

func _process(delta: float) -> void:
	_move_bar(delta)
	_move_fish(delta)
	_check_catch(delta)

func _move_bar(delta):
	if Input.is_action_pressed("ui_accept"):
		bar_velocity += lift * delta
	else:
		bar_velocity += gravity * delta

	bar_velocity *= 0.9
	bar.position.y += bar_velocity * delta
	bar.position.y = clamp(bar.position.y, 0, panel.size.y - bar.size.y)

func _move_fish(delta):
	if abs(fish.position.y - fish_target) < 10:
		fish_target = randf_range(0, panel.size.y)
	
	fish.position.y = move_toward(
		fish.position.y,
		fish_target,
		fish_speed * delta
	)

func _check_catch(delta):
	var top = bar.position.y
	var bottom = bar.position.y + bar.size.y
	
	if fish.position.y > top and fish.position.y < bottom:
		catch_progress += 40 * delta
	else:
		catch_progress -= 30 * delta
	
	catch_progress = clamp(catch_progress, 0, 100)
	progress.value = catch_progress
	
	if catch_progress >= 100:
		emit_signal("fish_caught")
		queue_free()
	elif catch_progress <= 0:
		emit_signal("fish_escaped")
		queue_free()

func setup_fish(data):
	fish_data = data

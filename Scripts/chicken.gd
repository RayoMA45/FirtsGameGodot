extends CharacterBody2D

const SPEED = 20.0
var direccion := Vector2.ZERO
var tiempo_cambio := 0.0
var tiempo_siguiente_sonido := 0.0

@onready var sonido_gallina = $chicken_sound
@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	anim.play("Idle")
	tiempo_siguiente_sonido = randf_range(5.0, 12.0)

func _physics_process(delta: float) -> void:
	tiempo_cambio -= delta
	if tiempo_cambio <= 0:
		tiempo_cambio = randf_range(2.0, 4.0)
		if randf() > 0.5:
			direccion = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			direccion = Vector2.ZERO
			
	velocity = direccion * SPEED
	move_and_slide()

	if velocity.length() > 0.1:
		anim.play("Walk")
		if velocity.x > 0:
			anim.flip_h = true
		elif velocity.x < 0:
			anim.flip_h = false
	else:
		anim.play("Idle")
	tiempo_siguiente_sonido -= delta
	if tiempo_siguiente_sonido <= 0:
		if not sonido_gallina.playing:
			sonido_gallina.play()
		tiempo_siguiente_sonido = randf_range(7.0, 15.0)

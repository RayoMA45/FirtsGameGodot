extends Area2D

@export_file("*.tscn") var escena_destino: String
@export var nombre_spawn: String 

# Variable para saber si el jugador está pisando el portal
var jugador_dentro : bool = false

# Referencia al texto flotante
@onready var texto_interaccion = $Label

func _ready() -> void:
	# Nos aseguramos de que el texto empiece oculto
	texto_interaccion.visible = false

func _process(_delta: float) -> void:
	# Si el jugador está dentro Y presiona la tecla de interactuar...
	if jugador_dentro and Input.is_action_just_pressed("interact"):
		if escena_destino != "":
			Global.puerta_destino = nombre_spawn
			get_tree().call_deferred("change_scene_to_file", escena_destino)

# === SEÑALES DEL PORTAL ===

# Cuando el jugador ENTRA a la zona
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_dentro = true
		texto_interaccion.visible = true # Mostramos el mensaje

# Cuando el jugador SALE de la zona
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_dentro = false
		texto_interaccion.visible = false # Ocultamos el mensaje

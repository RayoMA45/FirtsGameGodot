extends CharacterBody2D

var jugador_cerca : bool = false
var dialogo_activo : bool = false
const DIALOGO_MOM = preload("res://Dialog/Test.dialogue")

@onready var icono_tecla = $IconoTecla

func _ready() -> void:
	icono_tecla.visible = false

func _process(_delta: float) -> void:
	# Solo dejamos interactuar si el jugador está cerca Y NO hay un diálogo abierto
	if jugador_cerca and not dialogo_activo:
		if Input.is_action_just_pressed("interact"):
			dialogo_activo = true # Bloqueamos nuevas interacciones
			icono_tecla.visible = false # Ocultamos la "E" mientras habla
			
			# Creamos y lanzamos tu globo personalizado
			var balloon = preload("res://Dialog/balloon.tscn").instantiate()
			get_tree().current_scene.add_child(balloon)
			balloon.start(DIALOGO_MOM, "inicio_mom")
			
			# Le avisamos a este script cuándo se cierra el diálogo para liberar el candado
			await balloon.tree_exited
			dialogo_activo = false
			if jugador_cerca:
				icono_tecla.visible = true # Reaparece la "E" al terminar

# === SEÑALES DE LA ZONA DE INTERACCIÓN ===

# Cuando el jugador entra al círculo del NPC
func _on_zona_interaccion_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = true
		icono_tecla.visible = true # Mostramos la tecla flotante

# Cuando el jugador se aleja del NPC
func _on_zona_interaccion_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_cerca = false
		icono_tecla.visible = false # Ocultamos la tecla flotante

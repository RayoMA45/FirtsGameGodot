extends Area2D

@export_file("*.tscn") var escena_destino: String

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if escena_destino != "":
			# Usamos call_deferred para cambiar de escena de forma segura sin romper las físicas
			get_tree().call_deferred("change_scene_to_file", escena_destino)

extends Area2D

signal saiu

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jogador"):
		saiu.emit()
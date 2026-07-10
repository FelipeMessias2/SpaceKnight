extends Area2D
## Zona de fim de fase. Antes ela trocava de cena diretamente (pulava a
## Fase 3 e quebrava o fluxo do cenaP); agora só emite um sinal e o script
## da fase decide o que fazer.

signal saiu

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jogador"):
		saiu.emit()
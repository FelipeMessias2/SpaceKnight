extends Control
## Menu principal. "Iniciar" começa uma nova run pela introdução;
## "Sair" fecha o jogo.

func _ready() -> void:
	$Botoes/Iniciar.grab_focus() # menu navegável pelo teclado
	Musica.tocar("menu")

func _on_iniciar_pressed() -> void:
	Sfx.tocar("ui", -6.0)
	Global.novo_jogo()
	get_tree().change_scene_to_file("res://IntroCrawl.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()

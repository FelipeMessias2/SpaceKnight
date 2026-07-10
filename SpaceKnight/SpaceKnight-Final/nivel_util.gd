class_name NivelUtil

static func bloco(pai: Node, rect: Rect2, tex_corpo: Texture2D, tex_topo: Texture2D = null) -> StaticBody2D:
	var corpo := StaticBody2D.new()
	corpo.collision_layer = 1
	corpo.position = rect.position
	var forma := CollisionShape2D.new()
	var ret := RectangleShape2D.new()
	ret.size = rect.size
	forma.shape = ret
	forma.position = rect.size / 2.0
	corpo.add_child(forma)
	var sp := Sprite2D.new()
	sp.texture = tex_corpo
	sp.centered = false
	sp.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sp.region_enabled = true
	sp.region_rect = Rect2(Vector2.ZERO, rect.size)
	corpo.add_child(sp)
	if tex_topo != null:
		var topo := Sprite2D.new()
		topo.texture = tex_topo
		topo.centered = false
		topo.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		topo.region_enabled = true
		topo.region_rect = Rect2(0, 0, rect.size.x, tex_topo.get_height())
		corpo.add_child(topo)
	pai.add_child(corpo)
	return corpo

static func decor(pai: Node, tex: Texture2D, pos: Vector2, z := -1, escala := Vector2.ONE) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.position = pos
	sp.z_index = z
	sp.scale = escala
	pai.add_child(sp)
	return sp

static func instanciar(pai: Node, cena: PackedScene, pos: Vector2, props := {}) -> Node:
	var no := cena.instantiate()
	no.position = pos
	for chave in props:
		no.set(chave, props[chave])
	pai.add_child(no)
	return no

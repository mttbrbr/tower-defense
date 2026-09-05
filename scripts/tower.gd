class_name Tower
extends Node2D

var type_id := 0
var level := 0
var invested := 0
var cell := Vector2i.ZERO
var angle := -PI / 2.0
var cd := 0.0
var firing := 0.0
var anim := 0.0
var world: Node2D = null


func def_() -> Dictionary:
	return Balance.TOWERS[type_id]


func st() -> Dictionary:
	return def_().levels[level]


func setup(tid: int, w: Node2D, c: Vector2i) -> void:
	type_id = tid
	invested = int(def_().cost)
	world = w
	cell = c


func upgrade_cost() -> int:
	if level >= 2:
		return 0
	return int(st().up)


func can_upgrade() -> bool:
	return level < 2


func sell_value() -> int:
	return int(invested * Balance.SELL_RATIO)


func do_upgrade() -> void:
	invested += upgrade_cost()
	level += 1
	queue_redraw()


func _process(delta: float) -> void:
	anim += delta
	cd -= delta
	firing = maxf(0.0, firing - delta)
	if cd <= 0.0:
		var tgt := _find_target()
		if tgt != null:
			angle = (tgt.position - position).angle()
			_fire(tgt)
			var rate: float = st().rate * (1.6 if world.frenzy_t > 0.0 else 1.0)
			cd = 1.0 / rate
	queue_redraw()


func _find_target() -> Node2D:
	var best: Node2D = null
	var best_p := -1.0
	var r: float = st().range
	for n in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(n) or n.hp <= 0:
			continue
		if position.distance_to(n.position) <= r and n.progress > best_p:
			best_p = n.progress
			best = n
	return best


func _fire(tgt: Node2D) -> void:
	var b := Bullet.new()
	b.setup(tgt, float(st().dmg), float(def_().bullet_speed), float(st().splash), bool(st().pierce), def_().bullet, world)
	world.place(b)
	b.position = position + Vector2.from_angle(angle) * 22.0
	firing = 0.1
	world.play_sfx(["mg", "sniper", "mortar"][type_id])


func _draw() -> void:
	var col: Color = def_().color
	var hot: bool = world != null and world.frenzy_t > 0.0
	var line := col.lightened(0.3) if hot else col
	# pedina: quadrato scuro con bordo bianco debole
	draw_rect(Rect2(-16, -16, 32, 32), Color(0.06, 0.07, 0.09))
	draw_rect(Rect2(-16, -16, 32, 32), Color(1, 1, 1, 0.18))
	# corpo geometrico per tipo + canna orientata
	draw_set_transform(Vector2.ZERO, angle, Vector2.ONE)
	match type_id:
		0:
			draw_circle(Vector2.ZERO, 9, Color(0, 0, 0, 0))
			draw_arc(Vector2.ZERO, 9, 0, TAU, 24, line, 2.0)
			draw_line(Vector2(4, 0), Vector2(22, 0), line, 2.0)
			draw_line(Vector2(4, 4), Vector2(20, 4), line, 1.0)
		1:
			draw_polyline(PackedVector2Array([Vector2(0, -9), Vector2(9, 0), Vector2(0, 9), Vector2(-9, 0), Vector2(0, -9)]), line, 2.0)
			draw_line(Vector2(6, 0), Vector2(30, 0), line, 1.5)
			draw_rect(Rect2(10, -3, 4, 2), line)
		2:
			draw_rect(Rect2(-8, -8, 16, 16), Color(0, 0, 0, 0))
			draw_rect(Rect2(-8, -8, 16, 16), line)
			draw_rect(Rect2(4, -4, 14, 8), Color(line.r, line.g, line.b, 0.35))
			draw_line(Vector2(4, 0), Vector2(18, 0), line, 2.0)
	if firing > 0.0:
		var mflash := Color(1, 1, 1, firing * 8.0)
		draw_circle(Vector2(26 if type_id == 1 else 20, 0), 5, mflash)
		draw_arc(Vector2(26 if type_id == 1 else 20, 0), 9, 0, TAU, 16, Color(mflash.r, mflash.g, mflash.b, firing * 4.0), 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# indicatori livello: puntini sotto
	for i in level + 1:
		draw_circle(Vector2(-6 + i * 6, 22), 2.0, col)

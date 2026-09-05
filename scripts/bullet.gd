class_name Bullet
extends Node2D

var target: Node2D = null
var dmg := 10.0
var speed := 600.0
var splash := 0.0
var pierce := false
var color := Color.WHITE
var last := Vector2.ZERO
var game: Node2D = null
var prev := Vector2.ZERO


func setup(t: Node2D, d: float, s: float, sp: float, p: bool, c: Color, g: Node2D) -> void:
	target = t
	dmg = d
	speed = s
	splash = sp
	pierce = p
	color = c
	game = g
	if t:
		last = t.position


func _process(delta: float) -> void:
	prev = position
	var dest := last
	if is_instance_valid(target) and target.hp > 0:
		dest = target.position
		last = dest
	var to := dest - position
	var step := speed * delta
	if to.length() <= step + 5.0:
		_hit(dest)
	else:
		position += to.normalized() * step
	queue_redraw()


func _hit(p: Vector2) -> void:
	if splash > 0.0:
		for e in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(e) and e.hp > 0 and e.position.distance_to(p) <= splash:
				e.take_damage(dmg, pierce)
		if game and game.has_method("add_fx"):
			game.add_fx(p, color, splash)
			game.play_sfx("boom", 0, randf_range(0.9, 1.15))
	elif is_instance_valid(target) and target.hp > 0:
		target.take_damage(dmg, pierce)
	queue_free()


func _draw() -> void:
	var r := 6.0 if splash > 0 else 4.0
	var tp := (prev - position)
	var mid := tp * 0.5
	draw_rect(Rect2(mid - Vector2(r * 0.35, r * 0.35), Vector2(r * 0.7, r * 0.7)), Color(color.r, color.g, color.b, 0.35))
	draw_rect(Rect2(-r, -r, r * 2, r * 2), color)

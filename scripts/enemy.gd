class_name Enemy
extends Node2D

signal died(e)
signal reached(e)
signal summon(pos, e)
signal hurt(e, amount)

const COLORS := {
	"base": Color("ff5f6d"),
	"fast": Color("ffd166"),
	"swarm": Color("7ce38b"),
	"armored": Color("6ec1ff"),
	"boss": Color("b388ff"),
	"behemoth": Color("ff3d5e"),
	"necro": Color("9d7bff"),
}
const SIZES := {"base": 13.0, "fast": 11.0, "swarm": 6.0, "armored": 14.0, "boss": 21.0, "behemoth": 27.0, "necro": 17.0}
const BOSSES := ["boss", "behemoth", "necro"]

var tipo := "base"
var hp := 1.0
var max_hp := 1.0
var speed := 50.0
var reward := 5
var dmg := 1
var armor := 0.0
var radius := 12.0
var color := Color.WHITE
var path: Array = []
var seg := 0
var progress := 0.0
var dir := Vector2.RIGHT
var flash := 0.0
var anim := 0.0
var summon_t := 2.4
var game = null


func setup(t: String, path_px: Array, mult: float) -> void:
	tipo = t
	var b: Dictionary = Balance.ENEMIES[t]
	max_hp = ceilf(float(b.hp) * mult)
	hp = max_hp
	speed = float(b.speed) * (1.0 + (mult - 1.0) * 0.06)
	reward = int(b.reward)
	dmg = int(b.dmg)
	armor = float(b.armor)
	radius = float(SIZES[t])
	color = COLORS[t]
	path = path_px
	if path.size() >= 2:
		position = path[0]
		dir = (path[1] - path[0]).normalized()
	add_to_group("enemies")


func _process(delta: float) -> void:
	if seg >= path.size() - 1:
		return
	flash = maxf(0.0, flash - delta)
	anim += delta * 3.0
	var frozen: bool = game != null and game.freeze_t > 0.0
	if tipo == "necro" and not frozen:
		summon_t -= delta
		if summon_t <= 0.0:
			summon_t = 2.5
			summon.emit(global_position, self)
	if frozen:
		queue_redraw()
		return
	var remaining := speed * delta
	while remaining > 0.0 and seg < path.size() - 1:
		var target: Vector2 = path[seg + 1]
		var to := target - position
		var d := to.length()
		if d <= remaining:
			position = target
			progress += d
			remaining -= d
			seg += 1
			if seg >= path.size() - 1:
				reached.emit(self)
				return
		else:
			dir = to / d
			position += dir * remaining
			progress += remaining
			remaining = 0.0
	queue_redraw()


func take_damage(d: float, pierce := false) -> void:
	if hp <= 0:
		return
	var eff := d if pierce else maxf(d - armor, 1.0)
	eff = maxf(eff, 1.0)
	hp -= eff
	if eff >= 18.0 or tipo in BOSSES:
		hurt.emit(self, eff)
	flash = 0.1
	if hp <= 0:
		died.emit(self)
	queue_redraw()


func _poly(pts: PackedVector2Array, fill: Color, line: Color, w: float) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_colored_polygon(pts, fill)
	draw_polyline(closed, line, w)


func _draw() -> void:
	var r: float = radius
	var pulse := 1.0 if tipo not in BOSSES else 1.0 + 0.06 * sin(anim * 2.0)
	var fill := color.darkened(0.55)
	var line := color
	if flash > 0.0:
		fill = Color(1, 1, 1, 0.9)
		line = Color.WHITE
	elif game != null and game.freeze_t > 0.0:
		fill = Color(0.1, 0.2, 0.35)
		line = Color("9fdcff")
	# alone/glow
	draw_circle(Vector2.ZERO, r * 1.9 * pulse, Color(color.r, color.g, color.b, 0.07))
	match tipo:
		"fast":
			var t := PackedVector2Array([dir * r * 1.5, dir.rotated(2.35) * r, dir.rotated(-2.35) * r])
			_poly(t, fill, line, 1.5)
		"armored":
			_poly(PackedVector2Array([Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)]), fill, line, 1.5)
			draw_rect(Rect2(-r * 0.4, -r * 0.4, r * 0.8, r * 0.8), line)
		"boss":
			var pts := PackedVector2Array()
			for i in 5:
				pts.append(Vector2.from_angle(-PI / 2.0 + TAU * i / 5.0) * r * pulse)
			_poly(pts, fill, line, 2.0)
			draw_circle(Vector2.ZERO, r * 0.32, line)
		"behemoth":
			var pts2 := PackedVector2Array()
			for i in 6:
				pts2.append(Vector2.from_angle(TAU * i / 6.0) * r * pulse)
			_poly(pts2, fill, line, 2.5)
			draw_circle(Vector2.ZERO, r * 0.45, Color(0, 0, 0, 0.6))
			draw_circle(Vector2.ZERO, r * 0.25, line)
		"necro":
			_poly(PackedVector2Array([Vector2(0, -r), Vector2(r, 0), Vector2(0, r), Vector2(-r, 0)]), fill, line, 2.0)
			draw_circle(Vector2.ZERO, 3.0, Color(0.61, 1.0, 0.65, 0.6 + 0.4 * sin(anim * 3.0)))
		"swarm":
			draw_circle(Vector2.ZERO, r, fill)
			draw_arc(Vector2.ZERO, r, 0, TAU, 12, line, 1.5)
		_:
			draw_circle(Vector2.ZERO, r, fill)
			draw_arc(Vector2.ZERO, r, 0, TAU, 24, line, 1.5)
	# barra salute
	var w := 40.0 if tipo not in BOSSES else 56.0
	var pct := clampf(hp / max_hp, 0.0, 1.0)
	var top := -r - 10.0
	draw_rect(Rect2(-w / 2, top, w, 3), Color(1, 1, 1, 0.12))
	draw_rect(Rect2(-w / 2, top, w * pct, 3), Color(1, 1, 1, 0.85) if tipo not in BOSSES else color)

extends Node2D

const CELL := 64
var ORIGIN := Vector2(128, 96)

const SFX := {
	"mg": preload("res://assets/sfx/mg.wav"),
	"sniper": preload("res://assets/sfx/sniper.wav"),
	"mortar": preload("res://assets/sfx/mortar.wav"),
	"boom": preload("res://assets/sfx/boom.wav"),
	"coin": preload("res://assets/sfx/coin.wav"),
	"splat": preload("res://assets/sfx/splat.wav"),
	"leak": preload("res://assets/sfx/leak.wav"),
	"power": preload("res://assets/sfx/power.wav"),
	"roar": preload("res://assets/sfx/roar.wav"),
	"click": preload("res://assets/sfx/click.wav"),
	"win": preload("res://assets/sfx/win.wav"),
	"lose": preload("res://assets/sfx/lose.wav"),
}
const SFX_DB := {"mg": -18, "sniper": -12, "mortar": -13, "boom": -7, "coin": -10, "splat": -11, "leak": -6, "power": -7, "roar": -3, "click": -12, "win": -4, "lose": -4}

const PATH_FILL := Color(0.055, 0.065, 0.085)
const EDGE_WHITE := Color(1, 1, 1, 0.28)
const DOT_WHITE := Color(1, 1, 1, 0.07)

var def := {}
var paths_px := []
var path_cells := {}
var occupied := {}
var towers := []
var wave_events := []
var wave_idx := -1
var wave_running := false
var wave_timer := 0.0
var alive := 0
var selected_shop := -1
var pending_cell := Vector2i(-1, -1)
var hover_cell := Vector2i(-1, -1)
var popup_tower: Tower = null
var fx := []
var game_over := false
var speed_idx := 0
var paused := false
var freeze_t := 0.0
var frenzy_t := 0.0
var anim_t := 0.0
var shake_t := 0.0
var shake_m := 0.0
var endless := false
var waves_done := 0
var pixel_font: Font = preload("res://fonts/jersey10.ttf")
var hud: CanvasLayer
var sfx_players := []
var sfx_i := 0


func _ready() -> void:
	Engine.time_scale = 1.0
	ORIGIN.y = 72.0 if DisplayServer.is_touchscreen_available() else 64.0
	position = _world_offset()
	get_viewport().size_changed.connect(func(): position = _world_offset())
	GameState.reset_level()
	for i in 12:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	endless = GameState.is_endless()
	if endless:
		def = Levels.ENDLESS.duplicate(true)
		Music.play_track("infinito")
	else:
		def = Levels.get_level(GameState.level_id)
		Music.play_track(str(def.name).to_lower())
	_build_paths()
	hud = preload("res://scripts/hud.gd").new()
	add_child(hud)
	hud.shop_pick.connect(_on_shop_pick)
	hud.wave_start.connect(_on_wave_start)
	hud.speed_toggle.connect(_on_speed_cycle)
	hud.pause_toggle.connect(_on_pause_toggle)
	hud.upgrade.connect(_on_upgrade)
	hud.sell.connect(_on_sell)
	hud.close_popup.connect(_hide_popup)
	hud.power_pressed.connect(_on_power)
	hud.pause_open.connect(_open_pause)
	hud.resume.connect(_close_pause)
	hud.restart.connect(func(): get_tree().reload_current_scene())
	hud.next_level.connect(_on_next_level)
	hud.to_menu.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	hud.set_level_name(GameState.level_id, def.name, 999 if endless else def.waves.size())
	_next_wave_hint()


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func place(node: Node) -> void:
	add_child(node)


func play_sfx(snd: String, extra_db := 0.0, pitch := 1.0) -> void:
	var p: AudioStreamPlayer = sfx_players[sfx_i]
	sfx_i = (sfx_i + 1) % sfx_players.size()
	if p.playing:
		return
	p.stream = SFX[snd]
	p.volume_db = SFX_DB[snd] + extra_db
	p.pitch_scale = pitch * randf_range(0.94, 1.06)
	p.play()


func _build_paths() -> void:
	paths_px.clear()
	path_cells.clear()
	for p in def.paths:
		var pts := []
		for c in p:
			pts.append(_cell_center(c))
		paths_px.append(pts)
		for i in p.size() - 1:
			var a: Vector2i = p[i]
			var b: Vector2i = p[i + 1]
			var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
			var c := a
			while c != b:
				path_cells[c] = true
				c += step
			path_cells[b] = true


func _cell_center(c: Vector2i) -> Vector2:
	return ORIGIN + (Vector2(c) + Vector2(0.5, 0.5)) * CELL


func _cell_at(gp: Vector2) -> Vector2i:
	var f := ((gp - ORIGIN) / CELL).floor()
	return Vector2i(int(f.x), int(f.y))


func _in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < Levels.GRID_W and c.y < Levels.GRID_H


func _world_offset() -> Vector2:
	var vs := get_viewport().get_visible_rect().size
	return ((vs - Vector2(1280, 720)) * 0.5).max(Vector2.ZERO)


func _to_world(screen: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen - _world_offset()


# ------- ondate -------

func _on_wave_start() -> void:
	if wave_running or game_over:
		return
	wave_idx += 1
	var groups: Array
	if endless:
		def.mult = 4.6 + wave_idx * 0.3
		if wave_idx % 8 == 0 and wave_idx > 0:
			var keys := ["andromeda", "vortice", "sirio", "vega", "betelgeuse"]
			Music.play_track(keys[(wave_idx / 8) % keys.size()])
		groups = Levels.endless_wave(wave_idx + 1)
	else:
		groups = def.waves[wave_idx]
	wave_events.clear()
	for g in groups:
		for i in int(g.n):
			wave_events.append({"t": float(g.delay) + i * float(g.gap), "tipo": g.tipo, "path": int(g.path)})
	wave_events.sort_custom(func(a, b): return a.t < b.t)
	wave_running = true
	wave_timer = 0.0
	if endless:
		hud.wave_state("Wave %d in progress" % (wave_idx + 1), false)
	else:
		hud.wave_state("Wave %d/%d in progress" % [wave_idx + 1, def.waves.size()], false)
	var bossy := false
	for g in groups:
		if String(g.tipo) in Enemy.BOSSES:
			bossy = true
	if bossy:
		hud.show_banner("WARNING: BOSS!", Color("ff5f6d"))
		play_sfx("roar")
	elif not endless:
		hud.show_banner("WAVE %d" % (wave_idx + 1), Color.WHITE)


func _next_wave_hint() -> void:
	if endless:
		hud.wave_state("Ready: wave %d" % (wave_idx + 2), not game_over)
		return
	var nxt := mini(wave_idx + 2, def.waves.size())
	hud.wave_state("Ready: wave %d/%d" % [nxt, def.waves.size()], not game_over)


func _process(delta: float) -> void:
	if game_over:
		return
	var real_delta := delta * Engine.time_scale
	if freeze_t > 0.0:
		freeze_t = maxf(0.0, freeze_t - real_delta)
	if frenzy_t > 0.0:
		frenzy_t = maxf(0.0, frenzy_t - real_delta)
	if wave_running:
		wave_timer += delta
		while not wave_events.is_empty() and wave_events[0].t <= wave_timer:
			var ev: Dictionary = wave_events.pop_front()
			_spawn_enemy(ev.tipo, ev.path)
		if wave_events.is_empty() and alive == 0:
			_wave_finished()
	if not fx.is_empty():
		var keep := []
		for e in fx:
			e.t += delta
			if e.kind == "puff":
				e.pos += e.vel * delta
				e.vel += Vector2(0, 160) * delta
			elif e.kind == "text":
				e.pos += Vector2(0, -42) * delta
			if e.t < e.dur:
				keep.append(e)
		fx = keep
	anim_t += delta
	queue_redraw()
	if shake_t > 0.0:
		shake_t = maxf(0.0, shake_t - real_delta)
		var f := shake_t * shake_m * 6.0
		position = _world_offset() + (Vector2(randf_range(-f, f), randf_range(-f, f)) if shake_t > 0 else Vector2.ZERO)


func _wave_finished() -> void:
	wave_running = false
	waves_done += 1
	GameState.add_coins(Balance.wave_bonus(mini(wave_idx, 12), 4 if endless else GameState.level_id))
	if endless:
		_next_wave_hint()
		return
	if wave_idx >= def.waves.size() - 1:
		game_over = true
		var st := GameState.win_level()
		Music.play_track("menu")
		hud.show_result(true, GameState.level_id < Levels.LIST.size(), st)
	else:
		_next_wave_hint()


func _spawn_enemy(tipo: String, path_idx: int) -> void:
	var e := Enemy.new()
	e.game = self
	place(e)
	e.setup(tipo, paths_px[path_idx], float(def.mult))
	e.died.connect(_on_enemy_died)
	e.reached.connect(_on_enemy_reached)
	e.summon.connect(_on_summon)
	e.hurt.connect(_on_enemy_hurt)
	alive += 1


func _on_enemy_hurt(e: Enemy, dmg: float) -> void:
	add_text(e.position + Vector2(0, -14), "-%d" % int(dmg), Color("ffd166") if dmg >= 60.0 else Color(1, 1, 1, 0.7), 12 if e.tipo not in Enemy.BOSSES else 16)


func _on_enemy_died(e: Enemy) -> void:
	alive -= 1
	GameState.add_coins(e.reward)
	GameState.register_kill(e.tipo in Enemy.BOSSES)
	add_puff(e.position, e.color, 8)
	add_text(e.position, "+%d" % e.reward, Color("ffd166"), 16 if e.tipo in Enemy.BOSSES else 12)
	play_sfx("splat", 0, 0.8 if e.tipo in Enemy.BOSSES else 1.2)
	if e.tipo in Enemy.BOSSES:
		play_sfx("roar", -3, 1.1)
	play_sfx("coin")
	if e.tipo == "behemoth":
		shake(7, 0.4)
		add_fx(e.position, Color("ff5f6d"), 60)
	e.queue_free()


func _on_enemy_reached(e: Enemy) -> void:
	alive -= 1
	add_fx(e.position, Color("ff5f6d"), 26.0)
	e.queue_free()
	GameState.damage(e.dmg)
	play_sfx("leak")
	shake(1.5 + e.dmg * 0.4, 0.15)
	if GameState.lives <= 0 and not game_over:
		game_over = true
		wave_running = false
		wave_events.clear()
		hud.wave_state("Defeated!", false)
		play_sfx("lose")
		Music.play_track("menu")
		if endless:
			GameState.record_endless(waves_done)
			hud.show_result_endless(waves_done, GameState.endless_best)
		else:
			hud.show_result(false, false)


func add_fx(pos: Vector2, color: Color, r: float) -> void:
	fx.append({"kind": "ring", "pos": pos, "color": color, "r": r, "t": 0.0, "dur": 0.35})


func add_puff(pos: Vector2, color: Color, n: int) -> void:
	for i in n:
		var ang := TAU * i / n + randf()
		fx.append({"kind": "puff", "pos": pos, "vel": Vector2.from_angle(ang) * randf_range(60, 150), "color": color, "t": 0.0, "dur": 0.45})


func add_text(pos: Vector2, txt: String, color: Color, size := 14) -> void:
	fx.append({"kind": "text", "pos": pos, "text": txt, "color": color, "size": size, "t": 0.0, "dur": 0.9})


func shake(mag: float, dur := 0.25) -> void:
	shake_m = maxf(shake_m, mag)
	shake_t = maxf(shake_t, dur)


# ------- input e piazzamento -------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_2, KEY_3:
				_select_shop(event.keycode - KEY_1)
			KEY_4, KEY_5, KEY_6, KEY_7, KEY_8:
				_set_speed(event.keycode - KEY_4)
			KEY_Q, KEY_W, KEY_E:
				_on_power(event.keycode - KEY_Q)
			KEY_F11:
				var w := get_window()
				w.mode = Window.MODE_WINDOWED if w.mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
			KEY_ESCAPE:
				_select_shop(-1)
				_hide_popup()
			KEY_SPACE:
				if not wave_running and not game_over:
					_on_wave_start()
			KEY_P:
				_on_pause_toggle()
			KEY_M:
				var mm := Music.toggle_mute()
				hud.toast("Audio " + ("OFF" if mm else "ON"))
	elif event is InputEventMouseMotion:
		var c := _cell_at(_to_world(event.position))
		var nc := c if _in_grid(c) else Vector2i(-1, -1)
		if nc != hover_cell:
			hover_cell = nc
	elif event is InputEventScreenTouch:
		var c := _cell_at(_to_world(event.position))
		if event.pressed:
			_hide_popup()
			if occupied.has(c):
				popup_tower = occupied[c]
				hud.show_tower(popup_tower)
			elif _in_grid(c) and selected_shop >= 0:
				hover_cell = c
				pending_cell = c
		else:
			if pending_cell != Vector2i(-1, -1) and c == pending_cell:
				if path_cells.has(c):
					hud.toast("You can't build on the path!")
				else:
					_try_place(c)
			pending_cell = Vector2i(-1, -1)
			hover_cell = Vector2i(-1, -1)
	elif event is InputEventScreenDrag:
		var c := _cell_at(_to_world(event.position))
		if _in_grid(c):
			hover_cell = c
			if pending_cell != Vector2i(-1, -1):
				pending_cell = c
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_select_shop(-1)
			_hide_popup()
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			pending_cell = Vector2i(-1, -1)
			_click(_cell_at(_to_world(event.position)))


func _click(c: Vector2i) -> void:
	if not _in_grid(c):
		_hide_popup()
		return
	if occupied.has(c):
		popup_tower = occupied[c]
		hud.show_tower(popup_tower)
		return
	_hide_popup()
	if path_cells.has(c):
		hud.toast("You can't build on the path!")
		return
	if selected_shop >= 0:
		_try_place(c)


func _try_place(c: Vector2i) -> void:
	if occupied.has(c):
		return
	var cost := int(Balance.TOWERS[selected_shop].cost)
	if GameState.spend(cost):
		var t := Tower.new()
		place(t)
		t.setup(selected_shop, self, c)
		t.position = _cell_center(c)
		occupied[c] = t
		towers.append(t)
	else:
		hud.toast("Not enough coins!")


func _on_upgrade() -> void:
	if popup_tower and popup_tower.can_upgrade():
		var cost := popup_tower.upgrade_cost()
		if GameState.spend(cost):
			popup_tower.do_upgrade()
			hud.show_tower(popup_tower)
		else:
			hud.toast("Not enough coins!")


func _on_sell() -> void:
	if popup_tower:
		GameState.add_coins(popup_tower.sell_value())
		occupied.erase(popup_tower.cell)
		towers.erase(popup_tower)
		popup_tower.queue_free()
		popup_tower = null
		hud.hide_popup()


func _hide_popup() -> void:
	popup_tower = null
	hud.hide_popup()


func _on_shop_pick(i: int) -> void:
	_select_shop(-1 if i < 0 else i)


func _select_shop(i: int) -> void:
	if i == selected_shop:
		i = -1
	if i >= Balance.TOWERS.size():
		return
	selected_shop = i
	pending_cell = Vector2i(-1, -1)
	play_sfx("click")
	hud.set_shop_sel(i)
	if i >= 0:
		_hide_popup()
		if DisplayServer.is_touchscreen_available():
			hud.toast("Hold and drag; release to place")
		else:
			hud.toast("Click a tile to build (ESC cancels)")


func _on_speed_cycle() -> void:
	_set_speed((speed_idx + 1) % Balance.SPEEDS.size())


func _set_speed(i: int) -> void:
	speed_idx = clampi(i, 0, Balance.SPEEDS.size() - 1)
	if paused:
		paused = false
		hud.set_pause(false)
	Engine.time_scale = float(Balance.SPEEDS[speed_idx])
	hud.set_speed(Balance.SPEEDS[speed_idx])


func _on_pause_toggle() -> void:
	paused = not paused
	Engine.time_scale = 0.0 if paused else float(Balance.SPEEDS[speed_idx])
	hud.set_pause(paused)


func _open_pause() -> void:
	paused = true
	Engine.time_scale = 0.0
	hud.set_pause(true)


func _close_pause() -> void:
	paused = false
	Engine.time_scale = float(Balance.SPEEDS[speed_idx])
	hud.set_pause(false)


func _on_power(i: int) -> void:
	if game_over or i >= Balance.POWERS.size():
		return
	var p: Dictionary = Balance.POWERS[i]
	if not GameState.spend(int(p.cost)):
		hud.toast("Not enough coins!")
		return
	match p.kind:
		"meteor":
			for e in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(e) and e.hp > 0:
					add_fx(e.position, Color("ff5f6d"), 30.0)
					e.take_damage(300.0, true)
			hud.flash(Color("ff5f6d"))
			shake(7, 0.45)
			play_sfx("boom", -2, 0.9)
		"blizzard":
			freeze_t = 4.0
			hud.flash(Color("6ec1ff"))
		"overclock":
			frenzy_t = 10.0
			hud.flash(Color("ffd166"))
	hud.toast("%s activated!" % p.name)
	play_sfx("power", 0, 0.9 if p.kind == "blizzard" else 1.1)


func _on_summon(pos: Vector2, e: Enemy) -> void:
	if game_over:
		return
	for k in 2:
		var s := Enemy.new()
		place(s)
		s.setup("swarm", e.path, float(def.mult))
		s.seg = e.seg
		s.position = pos + Vector2(k * 14 - 7, 0)
		s.progress = e.progress
		s.game = self
		s.died.connect(_on_enemy_died)
		s.reached.connect(_on_enemy_reached)
		s.hurt.connect(_on_enemy_hurt)
		alive += 1
	add_fx(pos, Color("7ce38b"), 26.0)


func _on_next_level() -> void:
	GameState.start_level(GameState.level_id + 1)


# ------- disegno -------

func _draw() -> void:
	# griglia: solo puntini
	for y in Levels.GRID_H + 1:
		for x in Levels.GRID_W + 1:
			draw_rect(Rect2(ORIGIN + Vector2(x, y) * CELL - Vector2(1, 1), Vector2(2, 2)), DOT_WHITE)
	# percorso: riempimento scuro + bordo bianco leggero
	for c in path_cells:
		draw_rect(Rect2(ORIGIN + Vector2(c) * CELL, Vector2(CELL, CELL)), PATH_FILL)
	for c in path_cells:
		var rp := ORIGIN + Vector2(c) * CELL
		if not path_cells.has(c + Vector2i(0, -1)):
			draw_rect(Rect2(rp, Vector2(CELL, 1)), EDGE_WHITE)
		if not path_cells.has(c + Vector2i(0, 1)):
			draw_rect(Rect2(rp + Vector2(0, CELL - 1), Vector2(CELL, 1)), EDGE_WHITE)
		if not path_cells.has(c + Vector2i(-1, 0)):
			draw_rect(Rect2(rp, Vector2(1, CELL)), EDGE_WHITE)
		if not path_cells.has(c + Vector2i(1, 0)):
			draw_rect(Rect2(rp + Vector2(CELL - 1, 0), Vector2(1, CELL)), EDGE_WHITE)
	# portali minimali
	for p in paths_px:
		var pulse := 0.5 + 0.35 * sin(anim_t * 3.0)
		draw_arc(p[0], 12, 0, TAU, 24, Color(1, 1, 1, pulse), 1.5)
		draw_circle(p[0], 3, Color(1, 1, 1, pulse))
		var end: Vector2 = p[p.size() - 1]
		var pts := PackedVector2Array([end + Vector2(0, -12), end + Vector2(12, 0), end + Vector2(0, 12), end + Vector2(-12, 0), end + Vector2(0, -12)])
		draw_polyline(pts, Color(1, 0.35, 0.4, pulse + 0.2), 1.5)
	# overlay raggio di tutte le torrette piazzate
	for t in towers:
		draw_circle(t.position, float(t.st().range), Color(1, 1, 1, 0.02))
		draw_arc(t.position, float(t.st().range), 0, TAU, 48, Color(1, 1, 1, 0.08), 1.0)
	# raggio torretta mostrata (hover o selezionata): piu acceso
	var shown: Tower = null
	if popup_tower:
		shown = popup_tower
	elif selected_shop < 0 and hover_cell != Vector2i(-1, -1) and occupied.has(hover_cell):
		shown = occupied[hover_cell]
	if shown:
		draw_circle(shown.position, float(shown.st().range), Color(1, 1, 1, 0.05))
		draw_arc(shown.position, float(shown.st().range), 0, TAU, 64, Color(1, 1, 1, 0.4), 1.5)
		draw_rect(Rect2(ORIGIN + Vector2(shown.cell) * CELL, Vector2(CELL, CELL)), Color(1, 1, 1, 0.06))
	# cella in attesa di conferma (touch): anello + ghost pulsante
	if selected_shop >= 0 and pending_cell != Vector2i(-1, -1):
		var prng := float(Balance.TOWERS[selected_shop].levels[0].range)
		var ppulse := 0.5 + 0.3 * sin(anim_t * 5.0)
		draw_circle(_cell_center(pending_cell), prng, Color(1, 1, 1, 0.05))
		draw_arc(_cell_center(pending_cell), prng, 0, TAU, 64, Color(1, 1, 1, ppulse), 2.0)
		draw_rect(Rect2(ORIGIN + Vector2(pending_cell) * CELL, Vector2(CELL, CELL)), Color(1, 1, 1, 0.1))
		var pcol: Color = Balance.TOWERS[selected_shop].color
		draw_circle(_cell_center(pending_cell), 10, Color(pcol.r, pcol.g, pcol.b, 0.4))
	# anteprima piazzamento / anteprima dal negozio
	var pshop := selected_shop
	if pshop >= 0 and hover_cell != Vector2i(-1, -1) and hover_cell != pending_cell:
		var ok: bool = not path_cells.has(hover_cell) and not occupied.has(hover_cell)
		var col := Color(1, 1, 1, 0.10) if ok else Color(1, 0.3, 0.35, 0.10)
		var rcol := Color(1, 1, 1, 0.85) if ok else Color(1, 0.3, 0.35, 0.85)
		var rng := float(Balance.TOWERS[pshop].levels[0].range)
		draw_rect(Rect2(ORIGIN + Vector2(hover_cell) * CELL, Vector2(CELL, CELL)), col)
		draw_circle(_cell_center(hover_cell), rng, col)
		draw_arc(_cell_center(hover_cell), rng, 0, TAU, 64, rcol, 2.0)
		var ghost: Color = Balance.TOWERS[pshop].color
		draw_circle(_cell_center(hover_cell), 10, Color(ghost.r, ghost.g, ghost.b, 0.35))
		draw_arc(_cell_center(hover_cell), 10, 0, TAU, 24, Color(ghost.r, ghost.g, ghost.b, 0.9), 2.0)
	# effetti
	for e in fx:
		var pct: float = e.t / e.dur
		var alpha := 1.0 - pct
		match e.kind:
			"ring":
				draw_arc(e.pos, e.r * (0.4 + pct), 0, TAU, 32, Color(e.color.r, e.color.g, e.color.b, alpha * 0.8), 2.0)
			"puff":
				var s := 5.0 * (1.0 - pct * 0.6)
				draw_rect(Rect2(e.pos - Vector2(s / 2, s / 2), Vector2(s, s)), Color(e.color.r, e.color.g, e.color.b, alpha))
			"text":
				draw_string(pixel_font, e.pos, e.text, HORIZONTAL_ALIGNMENT_CENTER, 120, e.size, Color(e.color.r, e.color.g, e.color.b, alpha))
	if freeze_t > 0.0:
		draw_rect(Rect2(ORIGIN, Vector2(Levels.GRID_W * CELL, Levels.GRID_H * CELL)), Color(0.43, 0.76, 1.0, 0.06))

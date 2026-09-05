extends CanvasLayer

signal shop_pick(i)
signal wave_start()
signal speed_toggle()
signal pause_toggle()
signal upgrade()
signal sell()
signal close_popup()
signal power_pressed(i)
signal restart()
signal next_level()
signal to_menu()
signal pause_open()
signal resume()

const GRID_RIGHT := Levels.GRID_W * 64 + 128
var TOUCH := DisplayServer.is_touchscreen_available()
var UI_SCALE := 1.55 if TOUCH else 1.0
var TOP_H := 72 if TOUCH else 64

var coins_lbl: Label
var lives_lbl: Label
var info_lbl: Label
var wave_lbl: Label
var start_btn: Button
var speed_btn: Button
var pause_btn: Button
var next_btn: Button
var shop_btn: Button
var sel_lbl: Label
var cancel_btn: Button
var shop_overlay: Control
var card_btns := []
var power_btns := []

var popup: PanelContainer
var popup_title: Label
var popup_grid: GridContainer
var popup_note: Label
var up_btn: Button
var sell_btn: Button
var overlay: Control
var res_title: Label
var res_stars: Label
var banner: Label
var flash_rect: ColorRect
var pause_overlay: Control
var tower_ref: Tower = null
var _top_vb: VBoxContainer


func _ready() -> void:
	layer = 10
	_build_top()
	_build_shop_overlay()
	_build_popup()
	_build_overlay()
	_build_flash()
	_build_banner()
	_build_pause()
	GameState.coins_changed.connect(refresh)
	GameState.lives_changed.connect(refresh)
	refresh()
	toast("SHOP for towers | 1-2-3 and Q-W-E shortcuts")


func _fs(size: int) -> int:
	return int(size * UI_SCALE)


static func _style_btn(b: Button, col: Color, size := 20) -> void:
	b.add_theme_font_size_override("font_size", int(size * (1.55 if DisplayServer.is_touchscreen_available() else 1.0)))
	for s in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxFlat.new()
		match s:
			"normal":
				sb.bg_color = Color(0.045, 0.052, 0.068)
			"hover":
				sb.bg_color = Color(0.09, 0.1, 0.13)
			"pressed":
				sb.bg_color = Color(0.14, 0.16, 0.2)
			_:
				sb.bg_color = Color(0.025, 0.03, 0.04)
		sb.border_color = Color(col.r, col.g, col.b, 0.75 if s != "disabled" else 0.15)
		sb.border_width_left = 1
		sb.border_width_right = 1
		sb.border_width_top = 1
		sb.border_width_bottom = 1
		sb.corner_radius_top_left = 4
		sb.corner_radius_top_right = 4
		sb.corner_radius_bottom_left = 4
		sb.corner_radius_bottom_right = 4
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		b.add_theme_stylebox_override(s, sb)
	b.add_theme_color_override("font_color", Color(0.92, 0.94, 0.97))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(0.35, 0.37, 0.42))


static func _icon_tex(col: Color) -> ImageTexture:
	var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(col)
	return ImageTexture.create_from_image(img)


func _panel(color: Color, radius := 0) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = Color(1, 1, 1, 0.16)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	p.add_theme_stylebox_override("panel", sb)
	return p


func _label(parent: Control, txt: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", _fs(size))
	l.modulate = col
	parent.add_child(l)
	return l


func _world_offset() -> Vector2:
	var vs := get_viewport().get_visible_rect().size
	return ((vs - Vector2(1280, 720)) * 0.5).max(Vector2.ZERO)


func _build_top() -> void:
	var p := _panel(Color(0.015, 0.017, 0.022, 0.96))
	p.set_anchors_preset(Control.PRESET_TOP_WIDE)
	p.offset_bottom = TOP_H
	add_child(p)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", int(14 * UI_SCALE))
	p.add_child(hb)
	coins_lbl = _label(hb, "", 18, Color("ffd166"))
	lives_lbl = _label(hb, "", 18, Color("ff5f6d"))
	info_lbl = _label(hb, "", 15, Color(0.7, 0.75, 0.82))
	wave_lbl = _label(hb, "", 13, Color(0.8, 0.84, 0.9))
	sel_lbl = _label(hb, "", 13, Color("7ee787"))
	sel_lbl.visible = false
	cancel_btn = Button.new()
	cancel_btn.text = "CANCEL"
	_style_btn(cancel_btn, Color("ff5f6d"), 11)
	cancel_btn.visible = false
	cancel_btn.pressed.connect(func(): shop_pick.emit(-2))
	hb.add_child(cancel_btn)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(sp)
	var top_btn := Vector2(int(112 * UI_SCALE), int(46 * UI_SCALE))
	shop_btn = Button.new()
	shop_btn.text = "SHOP"
	_style_btn(shop_btn, Color("7ee787"), 14)
	shop_btn.custom_minimum_size = top_btn
	shop_btn.pressed.connect(func(): shop_overlay.visible = true)
	hb.add_child(shop_btn)
	start_btn = Button.new()
	start_btn.text = "START WAVE" if not TOUCH else "START"
	_style_btn(start_btn, Color("e0a63f"), 14)
	start_btn.custom_minimum_size = top_btn
	start_btn.pressed.connect(func(): wave_start.emit())
	hb.add_child(start_btn)
	pause_btn = Button.new()
	pause_btn.text = "Pause"
	_style_btn(pause_btn, Color(0.5, 0.55, 0.65), 14)
	pause_btn.custom_minimum_size = top_btn
	pause_btn.pressed.connect(func(): pause_toggle.emit())
	hb.add_child(pause_btn)
	speed_btn = Button.new()
	speed_btn.text = "1x"
	_style_btn(speed_btn, Color(0.3, 0.5, 0.9), 14)
	speed_btn.custom_minimum_size = Vector2(int(64 * UI_SCALE), int(46 * UI_SCALE))
	speed_btn.pressed.connect(func(): speed_toggle.emit())
	hb.add_child(speed_btn)
	var menu_btn := Button.new()
	menu_btn.text = "Menu"
	_style_btn(menu_btn, Color(0.5, 0.55, 0.65), 14)
	menu_btn.custom_minimum_size = top_btn
	menu_btn.pressed.connect(func(): open_pause())
	hb.add_child(menu_btn)


func _build_shop_overlay() -> void:
	shop_overlay = Control.new()
	shop_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_overlay.visible = false
	add_child(shop_overlay)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.82)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.gui_input.connect(func(ev: InputEvent):
		if (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and ev.pressed):
			shop_overlay.visible = false)
	shop_overlay.add_child(bg)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_overlay.add_child(cc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", int(14 * UI_SCALE))
	cc.add_child(vb)
	var t := _label(vb, "CHOOSE A DEFENSE", 26, Color.WHITE)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in Balance.TOWERS.size():
		var td: Dictionary = Balance.TOWERS[i]
		var lv: Dictionary = td.levels[0]
		var b := Button.new()
		var tratto := "high fire rate"
		if lv.pierce:
			tratto = "ignores armor"
		elif lv.splash > 0:
			tratto = "area damage"
		b.text = "[%d]  %s    %d monete\n%d dmg · %.1f colpi/s · raggio %.1f celle · %s" % [i + 1, td.name, int(td.cost), int(lv.dmg), lv.rate, lv.range / 64.0, tratto]
		b.icon = _icon_tex(td.color)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(int(620 * UI_SCALE), int(96 * UI_SCALE))
		_style_btn(b, td.color, 18)
		var idx := i
		b.pressed.connect(func():
			shop_overlay.visible = false
			shop_pick.emit(idx))
		vb.add_child(b)
		card_btns.append(b)
	var pt := _label(vb, "SPECIAL POWERS", 18, Color(0.7, 0.75, 0.82))
	pt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var prow := HBoxContainer.new()
	prow.add_theme_constant_override("separation", int(12 * UI_SCALE))
	prow.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(prow)
	for i in Balance.POWERS.size():
		var pw: Dictionary = Balance.POWERS[i]
		var pb := Button.new()
		pb.text = "[%s] %s\n%d" % ["QWE"[i], pw.name, int(pw.cost)]
		pb.icon = _icon_tex(pw.flash)
		pb.custom_minimum_size = Vector2(int(190 * UI_SCALE), int(84 * UI_SCALE))
		pb.tooltip_text = pw.desc
		_style_btn(pb, pw.flash, 15)
		var pidx := i
		pb.pressed.connect(func():
			shop_overlay.visible = false
			power_pressed.emit(pidx))
		prow.add_child(pb)
		power_btns.append(pb)
	var close := Button.new()
	close.text = "CLOSE"
	close.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_btn(close, Color(0.5, 0.55, 0.65), 16)
	close.custom_minimum_size = Vector2(int(620 * UI_SCALE), int(56 * UI_SCALE))
	close.pressed.connect(func(): shop_overlay.visible = false)
	vb.add_child(close)


func _build_popup() -> void:
	popup = _panel(Color(0.02, 0.022, 0.03, 0.98), 8)
	popup.visible = false
	popup.custom_minimum_size = Vector2(int(360 * UI_SCALE), 0)
	add_child(popup)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	popup.add_child(vb)
	popup_title = _label(vb, "", 22, Color.WHITE)
	popup_grid = GridContainer.new()
	popup_grid.columns = 3
	popup_grid.add_theme_constant_override("h_separation", 22)
	popup_grid.add_theme_constant_override("v_separation", 5)
	vb.add_child(popup_grid)
	popup_note = _label(vb, "", 14, Color(0.65, 0.7, 0.78))
	popup_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_note.custom_minimum_size = Vector2(int(330 * UI_SCALE), 0)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	vb.add_child(hb)
	up_btn = Button.new()
	up_btn.text = "Upgrade"
	_style_btn(up_btn, Color("3fbf6f"), 17)
	up_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	up_btn.pressed.connect(func(): upgrade.emit())
	hb.add_child(up_btn)
	sell_btn = Button.new()
	sell_btn.text = "Sell"
	_style_btn(sell_btn, Color("d96a5f"), 17)
	sell_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_btn.pressed.connect(func(): sell.emit())
	hb.add_child(sell_btn)
	var close_btn := Button.new()
	close_btn.text = "X"
	_style_btn(close_btn, Color(0.5, 0.55, 0.65), 17)
	close_btn.pressed.connect(func(): close_popup.emit())
	hb.add_child(close_btn)


func _build_overlay() -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	add_child(overlay)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.78)
	overlay.add_child(bg)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(cc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", int(20 * UI_SCALE))
	cc.add_child(vb)
	res_title = _label(vb, "", 54, Color.WHITE)
	res_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	res_stars = _label(vb, "", 20, Color(0.85, 0.88, 0.95))
	res_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(16 * UI_SCALE))
	vb.add_child(row)
	var retry := Button.new()
	retry.text = "Retry"
	_style_btn(retry, Color(0.5, 0.55, 0.65), 20)
	retry.custom_minimum_size = Vector2(int(180 * UI_SCALE), int(60 * UI_SCALE))
	retry.pressed.connect(func(): restart.emit())
	row.add_child(retry)
	next_btn = Button.new()
	next_btn.text = "Next level"
	_style_btn(next_btn, Color("3fbf6f"), 20)
	next_btn.custom_minimum_size = Vector2(int(220 * UI_SCALE), int(60 * UI_SCALE))
	next_btn.pressed.connect(func(): next_level.emit())
	row.add_child(next_btn)
	var m := Button.new()
	m.text = "Menu"
	_style_btn(m, Color(0.5, 0.55, 0.65), 20)
	m.custom_minimum_size = Vector2(int(140 * UI_SCALE), int(60 * UI_SCALE))
	m.pressed.connect(func(): to_menu.emit())
	row.add_child(m)


func _build_flash() -> void:
	flash_rect = ColorRect.new()
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1, 1, 1, 0)
	add_child(flash_rect)


func flash(color: Color) -> void:
	flash_rect.color = Color(color.r, color.g, color.b, 0.35)
	var tw := create_tween()
	tw.tween_property(flash_rect, "color:a", 0.0, 0.5)


func _build_banner() -> void:
	banner = Label.new()
	banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = TOP_H + 40
	banner.offset_bottom = TOP_H + 120
	banner.add_theme_font_size_override("font_size", _fs(40))
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.visible = false
	add_child(banner)


func show_banner(txt: String, col: Color) -> void:
	banner.text = txt
	banner.modulate = col
	banner.visible = true
	var tw := create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(banner, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): banner.visible = false)


func _build_pause() -> void:
	pause_overlay = Control.new()
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_overlay.visible = false
	add_child(pause_overlay)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	pause_overlay.add_child(bg)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(cc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", int(16 * UI_SCALE))
	cc.add_child(vb)
	var t := _label(vb, "PAUSED", 40, Color.WHITE)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rip := Button.new()
	rip.text = "RESUME"
	_style_btn(rip, Color("7ee787"), 20)
	rip.custom_minimum_size = Vector2(int(260 * UI_SCALE), int(56 * UI_SCALE))
	rip.pressed.connect(func(): close_pause())
	vb.add_child(rip)
	var ric := Button.new()
	ric.text = "RESTART"
	_style_btn(ric, Color("e0a63f"), 20)
	ric.custom_minimum_size = Vector2(int(260 * UI_SCALE), int(56 * UI_SCALE))
	ric.pressed.connect(func(): restart.emit())
	vb.add_child(ric)
	var men := Button.new()
	men.text = "MAIN MENU"
	_style_btn(men, Color(0.5, 0.55, 0.65), 20)
	men.custom_minimum_size = Vector2(int(260 * UI_SCALE), int(56 * UI_SCALE))
	men.pressed.connect(func(): to_menu.emit())
	vb.add_child(men)


func open_pause() -> void:
	pause_overlay.visible = true
	pause_open.emit()


func close_pause() -> void:
	pause_overlay.visible = false
	resume.emit()


func refresh() -> void:
	coins_lbl.text = "Coins %d" % GameState.coins
	lives_lbl.text = "Lives %d" % GameState.lives
	for i in card_btns.size():
		card_btns[i].disabled = GameState.coins < int(Balance.TOWERS[i].cost)
	for i in power_btns.size():
		power_btns[i].disabled = GameState.coins < int(Balance.POWERS[i].cost)

	if tower_ref and popup.visible:
		show_tower(tower_ref)


func set_level_name(idx: int, lname: String, n: int) -> void:
	if n >= 999:
		info_lbl.text = "ENDLESS - best: %d waves" % GameState.endless_best
	else:
		info_lbl.text = "Lv %d - %s (%d waves)" % [idx + 1, lname, n]


func wave_state(txt: String, can_start: bool) -> void:
	wave_lbl.text = txt
	wave_lbl.modulate = Color(0.8, 0.84, 0.9)
	start_btn.disabled = not can_start


func toast(msg: String) -> void:
	wave_lbl.text = msg
	wave_lbl.modulate = Color("ffd166")


func set_shop_sel(i: int) -> void:
	for k in card_btns.size():
		card_btns[k].set_pressed_no_signal(k == i)

	if i >= 0:
		sel_lbl.text = "%s selezionata (%d)" % [Balance.TOWERS[i].name, int(Balance.TOWERS[i].cost)]
		sel_lbl.modulate = Balance.TOWERS[i].color
		sel_lbl.visible = true
		cancel_btn.visible = true
	else:
		sel_lbl.visible = false
		cancel_btn.visible = false


func set_speed(mult: int) -> void:
	speed_btn.text = "%dx" % mult


func set_pause(is_paused: bool) -> void:
	pause_btn.text = "Resume" if is_paused else "Pause"


func _grid_add(rows: Array) -> void:
	for c in popup_grid.get_children():
		popup_grid.remove_child(c)
		c.queue_free()
	for r in rows:
		var name_lbl := Label.new()
		name_lbl.text = r[0]
		name_lbl.add_theme_font_size_override("font_size", _fs(16))
		name_lbl.modulate = Color(0.65, 0.7, 0.78)
		popup_grid.add_child(name_lbl)
		var cur := Label.new()
		cur.text = str(r[1])
		cur.add_theme_font_size_override("font_size", _fs(16))
		cur.modulate = Color(0.95, 0.96, 0.98)
		popup_grid.add_child(cur)
		var nxt := Label.new()
		nxt.text = str(r[2]) if r.size() > 2 else ""
		nxt.add_theme_font_size_override("font_size", _fs(16))
		nxt.modulate = Color("7ee787")
		popup_grid.add_child(nxt)


func show_tower(t: Tower) -> void:
	tower_ref = t
	var s: Dictionary = t.st()
	var td: Dictionary = Balance.TOWERS[t.type_id]
	var rows := []
	if t.can_upgrade():
		var n: Dictionary = td.levels[t.level + 1]
		rows = [
			["Damage", int(s.dmg), "-> %d" % int(n.dmg)],
			["Fire rate", "%.1f/s" % s.rate, "-> %.1f/s" % n.rate],
			["Range", "%.1f" % (s.range / 64.0), "-> %.1f" % (n.range / 64.0)],
		]
		if s.splash > 0:
			rows.append(["Area", int(s.splash), "-> %d" % int(n.splash)])
	else:
		rows = [
			["Damage", int(s.dmg), "MAX"],
			["Fire rate", "%.1f/s" % s.rate, ""],
			["Range", "%.1f" % (s.range / 64.0), ""],
		]
		if s.splash > 0:
			rows.append(["Area", int(s.splash), ""])
	popup_title.text = "%s - Lv %d" % [td.name, t.level + 1]
	popup_title.modulate = td.color
	popup_note.text = ("Trait: ignores armor" if s.pierce else ("Trait: area damage" if s.splash > 0 else "Trait: anti-swarm")) + " | Sell: %d" % t.sell_value()
	_grid_add(rows)
	if t.can_upgrade():
		var cost := t.upgrade_cost()
		up_btn.text = "Upgrade (%d)" % cost
		up_btn.disabled = GameState.coins < cost
	else:
		up_btn.text = "Max level"
		up_btn.disabled = true
	sell_btn.text = "Sell +%d" % t.sell_value()
	popup.visible = true
	popup.reset_size()
	await get_tree().process_frame
	popup.reset_size()
	var wo := _world_offset()
	var pos := wo + t.position + Vector2(40, -popup.size.y - 12)
	pos.x = clampf(pos.x, wo.x + 8, wo.x + GRID_RIGHT - popup.size.x - 8)
	pos.y = clampf(pos.y, wo.y + TOP_H + 8, wo.y + TOP_H + 576 - popup.size.y - 8)
	popup.position = pos


func hide_popup() -> void:
	popup.visible = false
	tower_ref = null


func show_result(win: bool, has_next: bool, stars_got := 0) -> void:
	banner.visible = false
	shop_overlay.visible = false
	pause_overlay.visible = false
	res_title.text = "VICTORY!" if win else "DEFEAT"
	res_title.modulate = Color("7ee787") if win else Color("ff5f6d")
	res_stars.text = ("Stars earned: %d/3" % stars_got) if win else "Try again with more towers!"
	next_btn.visible = win and has_next
	if win and has_next:
		next_btn.text = "ENDLESS MODE" if GameState.level_id == Levels.LIST.size() - 1 else "Next level"
	start_btn.disabled = true
	overlay.visible = true


func show_result_endless(waves: int, best: int) -> void:
	banner.visible = false
	shop_overlay.visible = false
	pause_overlay.visible = false
	res_title.text = "WAVES CLEARED: %d" % waves
	res_title.modulate = Color("ffd166")
	res_stars.text = "BEST: %d waves" % best
	next_btn.visible = false
	start_btn.disabled = true
	overlay.visible = true

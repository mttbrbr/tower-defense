extends Control

var stats_panel: PanelContainer
var toggle_btn: Button


func _ready() -> void:
	Music.play_track("menu")
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0)
	add_child(bg)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(cc)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	cc.add_child(vb)
	var title := Label.new()
	title.text = "TOWER DEFENSE"
	title.add_theme_font_size_override("font_size", 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = Color(1, 1, 1, 0.95)
	vb.add_child(title)
	var sub := Label.new()
	sub.text = "Defend the galaxy: build towers and stop the invaders"
	sub.add_theme_font_size_override("font_size", 16)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate = Color(0.6, 0.65, 0.72)
	vb.add_child(sub)
	var play := Button.new()
	play.text = "PLAY"
	play.add_theme_font_size_override("font_size", 24)
	play.custom_minimum_size = Vector2(320, 64)
	play.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/level_select.tscn"))
	vb.add_child(play)
	var stats := Button.new()
	stats.text = "STATS"
	stats.add_theme_font_size_override("font_size", 16)
	stats.custom_minimum_size = Vector2(320, 44)
	stats.pressed.connect(_toggle_stats)
	vb.add_child(stats)
	var quit := Button.new()
	quit.text = "Quit"
	quit.add_theme_font_size_override("font_size", 16)
	quit.custom_minimum_size = Vector2(320, 44)
	quit.pressed.connect(func(): get_tree().quit())
	vb.add_child(quit)
	_build_stats(vb)


func _build_stats(parent: Control) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.022, 0.03, 0.97)
	sb.border_color = Color(1, 1, 1, 0.2)
	sb.border_width_left = 3
	sb.border_width_right = 3
	sb.border_width_top = 3
	sb.border_width_bottom = 3
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 30
	sb.content_margin_right = 30
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	stats_panel = PanelContainer.new()
	stats_panel.add_theme_stylebox_override("panel", sb)
	stats_panel.visible = false
	parent.add_child(stats_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	stats_panel.add_child(vb)
	var t := Label.new()
	t.text = "STATS"
	t.add_theme_font_size_override("font_size", 22)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.modulate = Color(1, 1, 1, 0.9)
	vb.add_child(t)
	var tot_stars := 0
	for i in Levels.LIST.size():
		tot_stars += GameState.stars_for(i)
	var lines := [
		"Games played: %d" % GameState.play_count,
		"Enemies defeated: %d" % GameState.total_kills,
		"Bosses defeated: %d" % GameState.bosses_killed,
		"Stars collected: %d/%d" % [tot_stars, Levels.LIST.size() * 3],
		"Endless best: %d waves" % GameState.endless_best,
	]
	for l in lines:
		var lb := Label.new()
		lb.text = l
		lb.add_theme_font_size_override("font_size", 16)
		lb.modulate = Color(0.75, 0.8, 0.86)
		vb.add_child(lb)


func _toggle_stats() -> void:
	stats_panel.visible = not stats_panel.visible

extends Control


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
	vb.add_theme_constant_override("separation", 12)
	cc.add_child(vb)
	var title := Label.new()
	title.text = "CHOOSE A DESTINATION"
	title.add_theme_font_size_override("font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = Color(1, 1, 1, 0.9)
	vb.add_child(title)
	for i in Levels.LIST.size():
		var d: Dictionary = Levels.LIST[i]
		var b := Button.new()
		if i + 1 > GameState.unlocked:
			b.text = "Level %d - ???" % (i + 1)
			b.disabled = true
		else:
			var st := GameState.stars_for(i)
			var marks := ""
			for k in 3:
				marks += "[x]" if k < st else "[ ]"
			b.text = "Level %d - %s (%s)   %s" % [i + 1, d.name, d.tag, marks]
		b.add_theme_font_size_override("font_size", 20)
		b.custom_minimum_size = Vector2(600, 56)
		var idx := i
		b.pressed.connect(func(): GameState.start_level(idx))
		vb.add_child(b)
	if GameState.is_completed(Levels.LIST.size() - 1):
		var e := Button.new()
		e.text = "ENDLESS   (best: %d waves)" % GameState.endless_best
		e.add_theme_font_size_override("font_size", 20)
		e.custom_minimum_size = Vector2(600, 56)
		e.modulate = Color("ff9f6b")
		e.pressed.connect(func(): GameState.start_level(Levels.LIST.size()))
		vb.add_child(e)
	var back := Button.new()
	back.text = "Back"
	back.add_theme_font_size_override("font_size", 16)
	back.custom_minimum_size = Vector2(600, 40)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	vb.add_child(back)

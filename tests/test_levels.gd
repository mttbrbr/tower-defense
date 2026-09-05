extends SceneTree

var frames := 0
var gs = null
var main = null
var cur := -1
var next_switch := 0


func _process(_d: float) -> bool:
	frames += 1
	if frames > 60000:
		print("TIMEOUT")
		return true
	if gs == null:
		gs = root.get_node_or_null("GameState")
		return false
	if main != null and cur == 0 and main.game_over:
		print("SCONFITTA: game_over=", main.game_over, " vite=", gs.lives, " overlay_vittoria=", main.hud.res_title.text)
		main.queue_free()
		main = null
	elif main != null and cur > 0 and frames == next_switch:
		if cur == 0:
			print("SCONFITTA: game_over=", main.game_over, " vite=", gs.lives)
		else:
			print("livello ", cur + 1, " smoke ok (vivi=", main.alive, " in coda=", main.wave_events.size() + 0, ")")
		main.queue_free()
		main = null
	if main == null:
		cur += 1
		if cur > 4:
			print("SMOKE DONE")
			return true
		gs.level_id = cur
		main = load("res://scenes/main.tscn").instantiate()
		root.add_child(main)
		if cur == 0:
			gs.lives = 2
		main._on_wave_start()
		next_switch = frames + (2300 if cur == 0 else 100)
	return false

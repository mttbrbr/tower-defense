extends SceneTree

var main = null
var gs = null
var frames := 0
var placed := false


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 3:
		gs = root.get_node_or_null("GameState")
		main = load("res://scenes/main.tscn").instantiate()
		root.add_child(main)
	if frames == 8 and not placed:
		Engine.time_scale = 8.0
		placed = true
		gs.coins = 5000
		var n := 0
		for c in [Vector2i(3, 3), Vector2i(5, 2), Vector2i(8, 2), Vector2i(2, 3), Vector2i(11, 3), Vector2i(11, 5), Vector2i(12, 2), Vector2i(9, 4), Vector2i(12, 6), Vector2i(6, 2), Vector2i(7, 3), Vector2i(3, 5), Vector2i(4, 6), Vector2i(13, 3), Vector2i(12, 5), Vector2i(13, 6), Vector2i(9, 5), Vector2i(3, 2)]:
			main.selected_shop = n % 3
			n += 1
			main._click(c)
		print("torrette: ", main.towers.size())
	if frames > 30 and not main.game_over and not main.wave_running and main.wave_idx < main.def.waves.size() - 1:
		main._on_wave_start()
	if main.game_over:
		if gs.is_completed(0):
			print("VITTORIA SIM OK (vite=", gs.lives, " monete=", gs.coins, ")")
		else:
			print("VITTORIA SIM FAIL wave=", main.wave_idx, " vite=", gs.lives)
		return true
	if frames > 90000:
		print("TIMEOUT wave=", main.wave_idx, " running=", main.wave_running, " alive=", main.alive, " coda=", main.wave_events.size())
		return true
	return false

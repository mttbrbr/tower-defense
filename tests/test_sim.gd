extends SceneTree

var main = null
var gs = null
var frames := 0
var placed := false
var started := false


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 3:
		gs = root.get_node_or_null("GameState")
		if gs == null:
			print("Nessun autoload GameState")
			return true
		main = load("res://scenes/main.tscn").instantiate()
		root.add_child(main)
	if frames == 8 and not placed:
		placed = true
		for c in [Vector2i(3, 3), Vector2i(5, 2), Vector2i(8, 2), Vector2i(11, 5)]:
			main.selected_shop = 0
			main._click(c)
		print("torrette piazate: ", main.towers.size(), " monete: ", gs.coins)
	if frames == 12 and not started:
		started = true
		main._on_wave_start()
	if started and main.wave_idx == 0 and not main.wave_running:
		print("RISULTATO ondata: vivi=", main.alive, " monete=", gs.coins, " vite=", gs.lives)
		print("SIM OK" if main.alive == 0 and gs.lives >= 15 else "SIM FAIL")
		return true
	if frames > 6000:
		print("SIM TIMEOUT wave_running=", main.wave_running, " alive=", main.alive, " coda=", main.wave_events.size())
		return true
	return false

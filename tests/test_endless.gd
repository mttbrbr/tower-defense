extends SceneTree

var frames := 0
var gs = null
var main = null
var fase := 0


func _process(_d: float) -> bool:
	frames += 1
	if gs == null:
		gs = root.get_node_or_null("GameState")
		if gs == null:
			return false
	if frames == 3:
		gs.level_id = 5
		main = load("res://scenes/main.tscn").instantiate()
		root.add_child(main)
	if frames == 6:
		main._on_wave_start()
	if frames == 40 and fase == 0:
		fase = 1
		main.wave_running = false
		main.wave_events.clear()
		main.alive = 0
		main.wave_idx = 7
		main._on_wave_start()
	if fase == 1 and frames > 60:
		print("endless: wave=", main.wave_idx, " biome=", main.def.biome, " mult=", main.def.mult, " coda=", main.wave_events.size(), " -> ", "ENDLESS OK" if main.wave_events.size() > 0 else "ENDLESS FAIL")
		return true
	if frames > 400:
		print("ENDLESS TIMEOUT")
		return true
	return false

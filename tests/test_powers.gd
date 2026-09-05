extends SceneTree

var frames := 0
var gs = null
var main = null


func _process(_d: float) -> bool:
	frames += 1
	if gs == null:
		gs = root.get_node_or_null("GameState")
		if gs == null:
			return false
	if frames == 3:
		gs.level_id = 2
		main = load("res://scenes/main.tscn").instantiate()
		root.add_child(main)
	if frames == 10:
		gs.coins = 10000
		main._spawn_enemy("necro", 0)
		for n in get_nodes_in_group("enemies"):
			if n.tipo == "necro":
				print("DEBUG necro trovo:", n.get_index())
		main._spawn_enemy("behemoth", 0)
		main._spawn_enemy("base", 0)
	if frames == 60:
		main._on_power(0)
		var ecount := get_nodes_in_group("enemies").size()
		var dead := ecount < 4
		print("meteora: nemici rimasti=", ecount, " -> ", "METEORA OK" if dead else "METEORA FAIL")
	if frames == 70:
		main._on_power(1)
		print("blizzard: freeze_t=", main.freeze_t, " -> ", "BLIZZARD OK" if main.freeze_t > 3.5 else "BLIZZARD FAIL")
	if frames == 80:
		main._on_power(2)
		print("overclock: frenzy_t=", main.frenzy_t, " -> ", "OVERCLOCK OK" if main.frenzy_t > 9 else "OVERCLOCK FAIL")
	if frames % 500 == 0 and frames < 3000:
		for n in get_nodes_in_group("enemies"):
			if n.tipo == "necro" and is_instance_valid(n):
				print("t=%d summon_t=%.2f seg=%d" % [frames, n.summon_t, n.seg])
	if frames == 3000:
		var nec := get_nodes_in_group("enemies")
		var swarms := nec.filter(func(e): return e.tipo == "swarm").size()
		print("evocazioni necromante: sciami=", swarms, " -> ", "SUMMON OK" if swarms > 0 else "SUMMON FAIL")
		return true
	return false

class_name Levels

const GRID_W := 16
const GRID_H := 9

const LIST := [
	{
		"name": "Sirius", "tag": "star", "mult": 1.25,
		"paths": [
			[Vector2i(0, 4), Vector2i(4, 4), Vector2i(4, 1), Vector2i(10, 1), Vector2i(10, 7), Vector2i(15, 7)],
		],
		"waves": [
			[{"tipo": "base", "n": 14, "gap": 0.68, "delay": 0.0, "path": 0}],
			[{"tipo": "base", "n": 19, "gap": 0.59, "delay": 0.0, "path": 0}],
			[{"tipo": "base", "n": 17, "gap": 0.59, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 9, "gap": 0.50, "delay": 5.0, "path": 0}],
			[{"tipo": "swarm", "n": 21, "gap": 0.36, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 19, "gap": 0.50, "delay": 4.0, "path": 0}],
			[{"tipo": "base", "n": 24, "gap": 0.45, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 14, "gap": 0.41, "delay": 5.0, "path": 0}],
			[{"tipo": "base", "n": 28, "gap": 0.41, "delay": 0.0, "path": 0}, {"tipo": "armored", "n": 7, "gap": 1.08, "delay": 8.0, "path": 0}, {"tipo": "boss", "n": 1, "gap": 0.90, "delay": 16.0, "path": 0}],
		],
	},
	{
		"name": "Vega", "tag": "star", "mult": 1.9,
		"paths": [
			[Vector2i(0, 0), Vector2i(13, 0), Vector2i(13, 2), Vector2i(2, 2), Vector2i(2, 4), Vector2i(13, 4), Vector2i(13, 6), Vector2i(2, 6), Vector2i(2, 8), Vector2i(15, 8)],
		],
		"waves": [
			[{"tipo": "base", "n": 17, "gap": 0.59, "delay": 0.0, "path": 0}],
			[{"tipo": "swarm", "n": 28, "gap": 0.27, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 9, "gap": 0.50, "delay": 5.0, "path": 0}],
			[{"tipo": "base", "n": 21, "gap": 0.50, "delay": 0.0, "path": 0}, {"tipo": "armored", "n": 5, "gap": 1.26, "delay": 7.0, "path": 0}],
			[{"tipo": "fast", "n": 21, "gap": 0.36, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 19, "gap": 0.50, "delay": 4.0, "path": 0}],
			[{"tipo": "armored", "n": 12, "gap": 0.90, "delay": 0.0, "path": 0}, {"tipo": "swarm", "n": 33, "gap": 0.25, "delay": 6.0, "path": 0}],
			[{"tipo": "base", "n": 26, "gap": 0.41, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 19, "gap": 0.36, "delay": 5.0, "path": 0}, {"tipo": "armored", "n": 6, "gap": 1.17, "delay": 10.0, "path": 0}],
			[{"tipo": "boss", "n": 2, "gap": 5.40, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 28, "gap": 0.38, "delay": 3.0, "path": 0}, {"tipo": "armored", "n": 8, "gap": 1.03, "delay": 8.0, "path": 0}, {"tipo": "fast", "n": 17, "gap": 0.41, "delay": 12.0, "path": 0}],
		],
	},
	{
		"name": "Betelgeuse", "tag": "star", "mult": 2.7,
		"paths": [
			[Vector2i(0, 8), Vector2i(3, 8), Vector2i(3, 3), Vector2i(7, 3), Vector2i(7, 7), Vector2i(11, 7), Vector2i(11, 1), Vector2i(14, 1), Vector2i(14, 5), Vector2i(5, 5), Vector2i(5, 0), Vector2i(15, 0)],
		],
		"waves": [
			[{"tipo": "base", "n": 19, "gap": 0.50, "delay": 0.0, "path": 0}],
			[{"tipo": "swarm", "n": 40, "gap": 0.20, "delay": 0.0, "path": 0}],
			[{"tipo": "fast", "n": 24, "gap": 0.36, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 21, "gap": 0.45, "delay": 4.0, "path": 0}],
			[{"tipo": "armored", "n": 14, "gap": 0.81, "delay": 0.0, "path": 0}, {"tipo": "swarm", "n": 35, "gap": 0.22, "delay": 6.0, "path": 0}],
			[{"tipo": "necro", "n": 1, "gap": 0.90, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 24, "gap": 0.43, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 21, "gap": 0.36, "delay": 5.0, "path": 0}],
			[{"tipo": "swarm", "n": 52, "gap": 0.18, "delay": 0.0, "path": 0}, {"tipo": "armored", "n": 9, "gap": 0.95, "delay": 8.0, "path": 0}, {"tipo": "base", "n": 21, "gap": 0.45, "delay": 4.0, "path": 0}],
			[{"tipo": "fast", "n": 28, "gap": 0.34, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 28, "gap": 0.41, "delay": 5.0, "path": 0}, {"tipo": "armored", "n": 9, "gap": 0.90, "delay": 10.0, "path": 0}],
			[{"tipo": "boss", "n": 2, "gap": 4.95, "delay": 0.0, "path": 0}, {"tipo": "behemoth", "n": 1, "gap": 0.90, "delay": 4.0, "path": 0}, {"tipo": "armored", "n": 14, "gap": 0.90, "delay": 6.0, "path": 0}, {"tipo": "fast", "n": 24, "gap": 0.36, "delay": 4.0, "path": 0}, {"tipo": "swarm", "n": 35, "gap": 0.23, "delay": 12.0, "path": 0}],
		],
	},
	{
		"name": "Andromeda", "tag": "galaxy", "mult": 3.1,
		"paths": [
			[Vector2i(0, 1), Vector2i(4, 1), Vector2i(4, 5), Vector2i(7, 5), Vector2i(7, 2), Vector2i(11, 2), Vector2i(11, 4), Vector2i(15, 4)],
			[Vector2i(0, 7), Vector2i(2, 7), Vector2i(2, 3), Vector2i(6, 3), Vector2i(6, 6), Vector2i(9, 6), Vector2i(9, 4), Vector2i(11, 4), Vector2i(15, 4)],
		],
		"waves": [
			[{"tipo": "base", "n": 12, "gap": 0.65, "delay": 0.0, "path": 0}],
			[{"tipo": "swarm", "n": 18, "gap": 0.32, "delay": 0.0, "path": 1}, {"tipo": "fast", "n": 8, "gap": 0.5, "delay": 4.0, "path": 0}],
			[{"tipo": "base", "n": 14, "gap": 0.55, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 14, "gap": 0.55, "delay": 0.0, "path": 1}],
			[{"tipo": "fast", "n": 14, "gap": 0.45, "delay": 0.0, "path": 1}, {"tipo": "armored", "n": 5, "gap": 1.1, "delay": 5.0, "path": 0}],
			[{"tipo": "boss", "n": 2, "gap": 5.40, "delay": 0.0, "path": 0}, {"tipo": "swarm", "n": 33, "gap": 0.23, "delay": 3.0, "path": 1}],
			[{"tipo": "necro", "n": 1, "gap": 0.90, "delay": 0.0, "path": 1}, {"tipo": "armored", "n": 12, "gap": 0.85, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 21, "gap": 0.45, "delay": 3.0, "path": 1}, {"tipo": "fast", "n": 17, "gap": 0.41, "delay": 7.0, "path": 1}],
			[{"tipo": "swarm", "n": 40, "gap": 0.20, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 24, "gap": 0.36, "delay": 4.0, "path": 1}, {"tipo": "armored", "n": 9, "gap": 0.95, "delay": 8.0, "path": 0}],
			[{"tipo": "boss", "n": 2, "gap": 4.95, "delay": 0.0, "path": 1}, {"tipo": "necro", "n": 1, "gap": 0.90, "delay": 6.0, "path": 0}, {"tipo": "base", "n": 24, "gap": 0.41, "delay": 2.0, "path": 0}, {"tipo": "fast", "n": 21, "gap": 0.38, "delay": 6.0, "path": 1}, {"tipo": "armored", "n": 7, "gap": 0.99, "delay": 10.0, "path": 0}],
		],
	},
	{
		"name": "Vortex", "tag": "galaxy", "mult": 4.6,
		"paths": [
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 7), Vector2i(3, 7), Vector2i(3, 2), Vector2i(5, 2), Vector2i(5, 8), Vector2i(7, 8), Vector2i(7, 1), Vector2i(9, 1), Vector2i(9, 6), Vector2i(11, 6), Vector2i(11, 4), Vector2i(13, 4), Vector2i(13, 7), Vector2i(15, 7)],
			[Vector2i(0, 4), Vector2i(2, 4), Vector2i(2, 2), Vector2i(4, 2), Vector2i(4, 5), Vector2i(6, 5), Vector2i(6, 3), Vector2i(8, 3), Vector2i(8, 5), Vector2i(10, 5), Vector2i(10, 3), Vector2i(12, 3), Vector2i(12, 5), Vector2i(14, 5), Vector2i(14, 7), Vector2i(15, 7)],
		],
		"waves": [
			[{"tipo": "base", "n": 19, "gap": 0.45, "delay": 0.0, "path": 0}],
			[{"tipo": "swarm", "n": 26, "gap": 0.25, "delay": 0.0, "path": 1}, {"tipo": "fast", "n": 9, "gap": 0.45, "delay": 3.0, "path": 0}],
			[{"tipo": "armored", "n": 8, "gap": 0.90, "delay": 0.0, "path": 1}, {"tipo": "base", "n": 19, "gap": 0.45, "delay": 3.0, "path": 0}],
			[{"tipo": "fast", "n": 21, "gap": 0.38, "delay": 0.0, "path": 0}, {"tipo": "swarm", "n": 31, "gap": 0.23, "delay": 4.0, "path": 1}],
			[{"tipo": "base", "n": 21, "gap": 0.43, "delay": 0.0, "path": 1}, {"tipo": "armored", "n": 9, "gap": 0.90, "delay": 3.0, "path": 0}],
			[{"tipo": "boss", "n": 2, "gap": 5.40, "delay": 0.0, "path": 0}, {"tipo": "necro", "n": 1, "gap": 0.90, "delay": 4.0, "path": 1}, {"tipo": "fast", "n": 19, "gap": 0.36, "delay": 3.0, "path": 1}],
			[{"tipo": "swarm", "n": 38, "gap": 0.20, "delay": 0.0, "path": 0}, {"tipo": "armored", "n": 12, "gap": 0.85, "delay": 5.0, "path": 1}, {"tipo": "base", "n": 19, "gap": 0.43, "delay": 7.0, "path": 0}],
			[{"tipo": "behemoth", "n": 1, "gap": 0.90, "delay": 0.0, "path": 0}, {"tipo": "fast", "n": 26, "gap": 0.34, "delay": 0.0, "path": 0}, {"tipo": "base", "n": 24, "gap": 0.41, "delay": 3.0, "path": 1}, {"tipo": "swarm", "n": 35, "gap": 0.20, "delay": 8.0, "path": 1}],
			[{"tipo": "boss", "n": 2, "gap": 4.50, "delay": 0.0, "path": 0}, {"tipo": "behemoth", "n": 2, "gap": 6.30, "delay": 3.0, "path": 1}, {"tipo": "necro", "n": 2, "gap": 5.40, "delay": 5.0, "path": 0}, {"tipo": "swarm", "n": 42, "gap": 0.18, "delay": 2.0, "path": 1}, {"tipo": "fast", "n": 24, "gap": 0.36, "delay": 5.0, "path": 0}, {"tipo": "armored", "n": 9, "gap": 0.90, "delay": 9.0, "path": 1}],
		],
	},
]

static func get_level(i: int) -> Dictionary:
	return LIST[clampi(i, 0, LIST.size() - 1)]

# ---------------- modalita infinita (sbloccata dopo Etna) ----------------

const ENDLESS := {
	"name": "Endless", "tag": "beyond every boundary", "mult": 4.6,
	"paths": [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 7), Vector2i(3, 7), Vector2i(3, 2), Vector2i(5, 2), Vector2i(5, 8), Vector2i(7, 8), Vector2i(7, 1), Vector2i(9, 1), Vector2i(9, 6), Vector2i(11, 6), Vector2i(11, 4), Vector2i(13, 4), Vector2i(13, 7), Vector2i(15, 7)],
		[Vector2i(0, 4), Vector2i(2, 4), Vector2i(2, 2), Vector2i(4, 2), Vector2i(4, 5), Vector2i(6, 5), Vector2i(6, 3), Vector2i(8, 3), Vector2i(8, 5), Vector2i(10, 5), Vector2i(10, 3), Vector2i(12, 3), Vector2i(12, 5), Vector2i(14, 5), Vector2i(14, 7), Vector2i(15, 7)],
	],
	"waves": [],
}


static func endless_wave(w: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000 + w * 7919
	var groups := []
	var budget := 12 + w * 4
	var pool := ["base", "base", "fast", "swarm", "armored"]
	if w >= 4:
		pool.append("armored")
	if w >= 7:
		pool.append("necro")
	if w >= 10:
		pool.append("behemoth")
	var n_groups := rng.randi_range(1, mini(1 + w / 3, 4))
	for i in n_groups:
		var tipo: String = pool[rng.randi() % pool.size()]
		var n: int = int(budget / n_groups)
		if tipo == "swarm":
			n = int(n * 1.8)
		elif tipo == "armored":
			n = maxi(int(n * 0.5), 2)
		elif tipo in ["necro", "behemoth"]:
			n = clampi(int(n * 0.12), 1, 4)
		groups.append({
			"tipo": tipo, "n": maxi(n, 1),
			"gap": maxf(0.6 - w * 0.02, 0.22),
			"delay": rng.randf_range(0.0, 7.0),
			"path": rng.randi() % 2,
		})
	if w % 6 == 5:
		groups.append({"tipo": "boss", "n": 1 + w / 12, "gap": 5.0, "delay": 2.0, "path": rng.randi() % 2})
	return groups

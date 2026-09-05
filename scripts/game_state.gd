extends Node

signal coins_changed
signal lives_changed

const SAVE_PATH := "user://progresso.cfg"

var coins := Balance.START_COINS
var lives := Balance.START_LIVES
var level_id := 0
var unlocked := 1
var completed := []
var stars := []
var play_count := 0
var total_kills := 0
var bosses_killed := 0
var endless_best := 0
var pending_level := 0


func _ready() -> void:
	_load()


func reset_level() -> void:
	coins = Balance.START_COINS
	lives = Balance.START_LIVES
	coins_changed.emit()
	lives_changed.emit()


func add_coins(n: int) -> void:
	coins = maxi(0, coins + n)
	coins_changed.emit()


func spend(n: int) -> bool:
	if coins < n:
		return false
	coins -= n
	coins_changed.emit()
	return true


func damage(n: int) -> void:
	lives = maxi(0, lives - n)
	lives_changed.emit()


func start_level(i: int) -> void:
	level_id = clampi(i, 0, Levels.LIST.size())
	play_count += 1
	_save()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func is_endless() -> bool:
	return level_id >= Levels.LIST.size()


func win_level() -> int:
	var s := 1
	if lives >= 15:
		s = 3
	elif lives >= 8:
		s = 2
	while completed.size() <= level_id:
		completed.append(0)
		stars.append(0)
	completed[level_id] = 1
	stars[level_id] = maxi(int(stars[level_id]), s)
	unlocked = maxi(unlocked, level_id + 2)
	_save()
	return s


func stars_for(i: int) -> int:
	if i < 0 or i >= stars.size():
		return 0
	return int(stars[i])


func is_completed(i: int) -> bool:
	return i >= 0 and i < completed.size() and int(completed[i]) == 1


func register_kill(boss: bool) -> void:
	total_kills += 1
	if boss:
		bosses_killed += 1


func record_endless(waves: int) -> void:
	if waves > endless_best:
		endless_best = waves
	_save()


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) == OK:
		unlocked = int(cf.get_value("progresso", "unlocked", 1))
		var c = cf.get_value("progresso", "completed", [])
		if c is Array:
			completed = c
		var s = cf.get_value("progresso", "stars", [])
		if s is Array:
			stars = s
		play_count = int(cf.get_value("stats", "play_count", 0))
		total_kills = int(cf.get_value("stats", "total_kills", 0))
		bosses_killed = int(cf.get_value("stats", "bosses_killed", 0))
		endless_best = int(cf.get_value("stats", "endless_best", 0))


func _save() -> void:
	var cf := ConfigFile.new()
	cf.set_value("progresso", "unlocked", unlocked)
	cf.set_value("progresso", "completed", completed)
	cf.set_value("progresso", "stars", stars)
	cf.set_value("stats", "play_count", play_count)
	cf.set_value("stats", "total_kills", total_kills)
	cf.set_value("stats", "bosses_killed", bosses_killed)
	cf.set_value("stats", "endless_best", endless_best)
	cf.save(SAVE_PATH)

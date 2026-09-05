extends Node

# Sintetizzatore chiptune procedurale: genera musica in tempo reale, niente file, zero copyright.

const RATE := 22050.0
const REST := -200
const CHUNK := 512

# scale in semitoni (pentatoniche e modali, atmosfere cosmiche)
const TRACKS := {
	"menu":    {"bpm": 92,  "root": 220.0, "scale": [0, 2, 4, 7, 9],         "mel": 0.50, "bass": 0.8, "hat": 0.25, "octaves": 2},
	"sirio":   {"bpm": 100, "root": 262.0, "scale": [0, 2, 4, 7, 9],         "mel": 0.55, "bass": 0.9, "hat": 0.30, "octaves": 2},
	"vega":    {"bpm": 94,  "root": 294.0, "scale": [0, 2, 3, 5, 7, 9, 10],  "mel": 0.45, "bass": 0.8, "hat": 0.20, "octaves": 2},
	"betelgeuse": {"bpm": 80, "root": 247.0, "scale": [0, 2, 3, 5, 7, 8, 10], "mel": 0.40, "bass": 0.8, "hat": 0.15, "octaves": 2},
	"andromeda": {"bpm": 106, "root": 220.0, "scale": [0, 2, 4, 6, 7, 9, 11], "mel": 0.58, "bass": 1.0, "hat": 0.35, "octaves": 2},
	"vortice": {"bpm": 114, "root": 196.0, "scale": [0, 1, 5, 7, 8, 10],     "mel": 0.65, "bass": 1.1, "hat": 0.50, "octaves": 2},
	"infinito": {"bpm": 124, "root": 247.0, "scale": [0, 2, 4, 6, 8, 10],    "mel": 0.70, "bass": 1.2, "hat": 0.55, "octaves": 2},
}

var player: AudioStreamPlayer
var gen: AudioStreamGenerator
var cfg := TRACKS["menu"]
var track_name := "menu"
var rng := RandomNumberGenerator.new()

var step := 0
var step_t := 0.0
var melody_note := 0.0
var bass_note := 0.0
var note_env := 0.0
var bass_env := 0.0
var hat_env := 0.0
var kick_env := 0.0
var phase_m := 0.0
var phase_b := 0.0
var muted := false


func _ready() -> void:
	gen = AudioStreamGenerator.new()
	gen.mix_rate = RATE
	gen.buffer_length = 60
	player = AudioStreamPlayer.new()
	player.stream = gen
	player.volume_db = -13
	add_child(player)
	player.play()
	cfg = (TRACKS["menu"] as Dictionary).duplicate(true)
	rng.seed = 999
	_next_step(true)


func play_track(name: String) -> void:
	if not TRACKS.has(name) or name == track_name:
		return
	if muted:
		track_name = name
		cfg = (TRACKS[name] as Dictionary).duplicate(true)
		return
	track_name = name
	cfg = (TRACKS[name] as Dictionary).duplicate(true)
	step = 0
	step_t = 0.0
	rng.seed = hash(name) + Time.get_ticks_msec()
	_next_step(true)


func toggle_mute() -> bool:
	muted = not muted
	player.volume_db = -100.0 if muted else -13.0
	return muted


func _freq(semis: float) -> float:
	return cfg.root * pow(2.0, semis / 12.0)


func _pick_note() -> float:
	var s: Array = cfg.scale
	var idx := rng.randi_range(0, s.size() * int(cfg.octaves) - 1)
	var oct := idx / s.size()
	return float(s[idx % s.size()]) + 12.0 * oct


func _next_step(looped: bool) -> void:
	var in_bar := step % 16
	if in_bar % 4 == 0:
		bass_note = _freq(0.0 if in_bar != 8 else float(cfg.scale[3 % cfg.scale.size()]))
		bass_env = 1.0
	if in_bar == 0 or in_bar == 6 or in_bar == 11:
		kick_env = 1.0
	if rng.randf() < cfg.hat and in_bar % 2 == 0:
		hat_env = 1.0
	if rng.randf() < float(cfg.mel):
		melody_note = _freq(_pick_note())
		if rng.randf() < 0.2:
			melody_note = REST
		note_env = 1.0
	step += 1
	if step >= 64:
		step = 0
		rng.seed = rng.seed * 6364136223846793005 % 4611686018427387903
		cfg["mel"] = clampf(float(cfg["mel"]) + rng.randf_range(-0.1, 0.12), 0.25, 0.8)


func _process(_delta: float) -> void:
	if not gen or not player:
		return
	var pb := player.get_stream_playback()
	if pb == null:
		return
	var step_dur := 60.0 / float(cfg["bpm"]) / 4.0
	var dt := 1.0 / RATE
	while pb.get_frames_available() >= CHUNK:
		var buf := PackedVector2Array()
		buf.resize(CHUNK)
		for i in CHUNK:
			if step_t >= step_dur:
				step_t -= step_dur
				_next_step(false)
			var f := step_t / step_dur
			note_env = maxf(0.0, note_env - dt * 5.5)
			bass_env = maxf(0.0, bass_env - dt * 4.0)
			hat_env = maxf(0.0, hat_env - dt * 30.0)
			kick_env = maxf(0.0, kick_env - dt * 9.0)
			var v := 0.0
			if melody_note > -100.0 and note_env > 0.0:
				phase_m = fmod(phase_m + melody_note * dt, 1.0)
				v += (0.30 if phase_m < 0.25 else -0.12) * note_env * (1.0 - f * 0.35)
			if bass_env > 0.0:
				phase_b = fmod(phase_b + bass_note * dt, 1.0)
				v += (2.0 * phase_b - 1.0) * 0.16 * bass_env
			if hat_env > 0.0:
				v += (rng.randf() * 2.0 - 1.0) * 0.05 * hat_env
			if kick_env > 0.0:
				v += sin(2.0 * PI * 55.0 * step_t) * 0.28 * kick_env * kick_env
			buf[i] = Vector2(v, v)
			step_t += dt
		pb.push_buffer(buf)

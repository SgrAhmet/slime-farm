extends Node
## Autoload "Sfx": ses efektlerini çalar (assets/sfx, tools/generate_sounds.gd üretir).
##  - play(name): konumsuz (arayüz, oyuncunun kendi sesleri).
##  - play_at(name, pos): dünyada konumlu; ekrandan uzaklaştıkça kısılır.
## Aynı ses çok sık tetiklenirse (ör. onlarca slime zıplaması) seyreltilir.

const DIR: String = "res://assets/sfx/"
## Ses adı -> ses seviyesi (dB). Sık çalanlar daha kısık.
const VOLUMES: Dictionary = {
	"vacuum_pop": -5.0, "vacuum_shoot": -5.0,
	"slime_hop": -16.0, "slime_eat": -8.0, "slime_happy": -6.0, "slime_transform": -3.0,
	"gem": -8.0, "coin": -6.0, "chicken": -10.0, "chick": -12.0,
	"ui_click": -8.0, "save_jingle": -4.0,
}
## Aynı sesin iki çalınması arasındaki en kısa süre (saniye).
const MIN_GAP: float = 0.06
const MAX_ACTIVE: int = 14
const MAX_DISTANCE: float = 300.0

var _streams: Dictionary = {}
var _last_played: Dictionary = {}
var _active: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound_name: String in VOLUMES:
		_streams[sound_name] = load(DIR + sound_name + ".wav")
	# Oyundaki her buton tıklanınca "tık"
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		(node as BaseButton).pressed.connect(play.bind("ui_click", 0.02))


## Döngülü çalınacak sesin (vakum) kopyası.
func loop_stream(sound_name: String) -> AudioStream:
	var wav: AudioStreamWAV = (load(DIR + sound_name + ".wav") as AudioStreamWAV).duplicate()
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = int(wav.get_length() * wav.mix_rate)
	return wav


func play(sound_name: String, pitch_jitter: float = 0.04) -> void:
	if not _can_play(sound_name):
		return
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	_setup(p, sound_name, pitch_jitter)
	add_child(p)
	p.play()


func play_at(sound_name: String, pos: Vector2, pitch_jitter: float = 0.08) -> void:
	if not _can_play(sound_name):
		return
	var parent: Node = get_tree().current_scene
	if parent == null:
		return
	var p: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	_setup(p, sound_name, pitch_jitter)
	p.max_distance = MAX_DISTANCE
	p.attenuation = 1.5
	parent.add_child(p)
	p.global_position = pos
	p.play()


func _can_play(sound_name: String) -> bool:
	if not _streams.has(sound_name) or _active >= MAX_ACTIVE:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - float(_last_played.get(sound_name, -1.0)) < MIN_GAP:
		return false
	_last_played[sound_name] = now
	return true


func _setup(p: Node, sound_name: String, pitch_jitter: float) -> void:
	p.set(&"stream", _streams[sound_name])
	p.set(&"volume_db", VOLUMES[sound_name])
	p.set(&"pitch_scale", 1.0 + randf_range(-pitch_jitter, pitch_jitter))
	_active += 1
	p.connect(&"finished", p.queue_free)
	# Sahne değişince yarıda silinse de sayaç düşsün
	p.connect(&"tree_exited", func() -> void: _active = maxi(_active - 1, 0))

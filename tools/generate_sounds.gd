extends SceneTree
## Retro ses efektlerini koddan sentezler (res://assets/sfx/*.wav).
## Çalıştırma: godot --headless --path . -s res://tools/generate_sounds.gd

const RATE: int = 22050
const OUT_DIR: String = "res://assets/sfx"

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _initialize() -> void:
	_rng.seed = 7
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_save("vacuum_loop", _vacuum_loop())
	_save("vacuum_pop", _pop())
	_save("vacuum_shoot", _shoot())
	_save("slime_hop", _hop())
	_save("slime_eat", _eat())
	_save("slime_happy", _happy())
	_save("slime_transform", _transform())
	_save("gem", _gem())
	_save("coin", _coin())
	_save("chicken", _chicken())
	_save("chick", _chick())
	_save("ui_click", _click())
	_save("save_jingle", _jingle())
	quit()


# ---------------------------------------------------------------- Sesler

## Vakum uğultusu: alçak titreşimli ton + süzülmüş hışırtı (döngüye uygun).
func _vacuum_loop() -> PackedFloat32Array:
	var n: int = int(RATE * 1.5)
	var out: PackedFloat32Array = _silence(1.5)
	var lp: float = 0.0
	for i: int in n:
		var t: float = float(i) / RATE
		var hum: float = _osc("saw", 95.0 * t) * 0.18 + _osc("square", 190.0 * t) * 0.05
		var wobble: float = 1.0 + 0.15 * sin(TAU * 6.0 * t)
		lp += (_rng.randf_range(-1, 1) - lp) * 0.25
		out[i] = (hum + lp * 0.5) * wobble * 0.6
	_fade_edges(out, 0.02)
	return out


## Nesne vakumun ağzına girince "plop": hızla yükselen kısa sinüs.
func _pop() -> PackedFloat32Array:
	return _tone(0.12, 300.0, 900.0, "sine", 0.005, 0.7)


## Fırlatma "fup": düşen ton + hava hışırtısı.
func _shoot() -> PackedFloat32Array:
	var out: PackedFloat32Array = _tone(0.18, 520.0, 160.0, "triangle", 0.003, 0.6)
	_mix(out, _noise(0.15, 0.5, 0.35), 0)
	return out


## Slime zıplaması "boing": yükselip titreyen sinüs.
func _hop() -> PackedFloat32Array:
	var dur: float = 0.25
	var out: PackedFloat32Array = _silence(dur)
	var phase: float = 0.0
	for i: int in out.size():
		var t: float = float(i) / RATE
		var k: float = t / dur
		var f: float = lerpf(180.0, 420.0, sqrt(k)) * (1.0 + 0.06 * sin(TAU * 28.0 * t))
		phase += f / RATE
		out[i] = sin(TAU * phase) * _env(k, 0.02) * 0.7
	return out


## Çiğneme: iki kısa "nom" (alçak kare + gürültü).
func _eat() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(0.45)
	for start: float in [0.0, 0.2]:
		var bite: PackedFloat32Array = _tone(0.11, 220.0, 140.0, "square", 0.004, 0.35)
		_mix(bite, _noise(0.06, 0.3, 0.4), 0)
		_mix(out, bite, int(start * RATE))
	return out


## Mutlu cıvıltı: hızlı yükselen üç nota.
func _happy() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(0.4)
	var notes: Array = [784.0, 988.0, 1319.0]
	for i: int in notes.size():
		_mix(out, _tone(0.12, notes[i], notes[i] * 1.02, "triangle", 0.004, 0.5), int(i * 0.08 * RATE))
	return out


## Büyük slime'a dönüşüm: titreyen, hızlanan yükseliş + parıltı.
func _transform() -> PackedFloat32Array:
	var dur: float = 1.1
	var out: PackedFloat32Array = _silence(dur)
	var phase: float = 0.0
	for i: int in out.size():
		var t: float = float(i) / RATE
		var k: float = t / dur
		var f: float = lerpf(200.0, 900.0, k * k) * (1.0 + 0.08 * sin(TAU * lerpf(6.0, 30.0, k) * t))
		phase += f / RATE
		out[i] = _osc("square", phase) * 0.18 * _env(k, 0.05)
	var sparkle: Array = [1568.0, 2093.0, 2637.0, 3136.0]
	for j: int in sparkle.size():
		_mix(out, _bell(0.3, sparkle[j], 0.25), int((0.65 + j * 0.07) * RATE))
	return out


## Gem pırıltısı: iki notalı çan.
func _gem() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(0.6)
	_mix(out, _bell(0.45, 1760.0, 0.5), 0)
	_mix(out, _bell(0.5, 2637.0, 0.45), int(0.07 * RATE))
	return out


## Satış / para: klasik iki notalı kare dalga "ding-ding".
func _coin() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(0.4)
	_mix(out, _tone(0.07, 988.0, 988.0, "square", 0.002, 0.3), 0)
	_mix(out, _tone(0.3, 1319.0, 1319.0, "square", 0.002, 0.3), int(0.07 * RATE))
	return out


## Tavuk gıdaklaması: üç kısa, perdesi düşen burunsu ses.
func _chicken() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(0.7)
	var starts: Array = [0.0, 0.16, 0.3]
	var pitches: Array = [620.0, 560.0, 700.0]
	for i: int in starts.size():
		var cluck: PackedFloat32Array = _tone(0.1, pitches[i], pitches[i] * 0.7, "pulse", 0.003, 0.35)
		_mix(cluck, _tone(0.1, pitches[i] * 2.0, pitches[i] * 1.4, "sine", 0.003, 0.12), 0)
		_mix(out, cluck, int(starts[i] * RATE))
	return out


## Civciv "cik cik": iki tiz, yukarı kayan cıvıltı.
func _chick() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(0.35)
	for start: float in [0.0, 0.17]:
		_mix(out, _tone(0.09, 2200.0, 3000.0, "sine", 0.003, 0.4), int(start * RATE))
	return out


## Arayüz tıklaması.
func _click() -> PackedFloat32Array:
	return _tone(0.04, 1200.0, 900.0, "square", 0.001, 0.25)


## Kayıt / uyku melodisi: yumuşak üçgen arpej (Do-Mi-Sol-Do).
func _jingle() -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(1.4)
	var notes: Array = [523.25, 659.25, 783.99, 1046.5]
	for i: int in notes.size():
		var dur: float = 0.8 if i == notes.size() - 1 else 0.3
		_mix(out, _tone(dur, notes[i], notes[i], "triangle", 0.01, 0.4), int(i * 0.15 * RATE))
		_mix(out, _tone(dur, notes[i] * 2.0, notes[i] * 2.0, "sine", 0.01, 0.08), int(i * 0.15 * RATE))
	return out


# ---------------------------------------------------------------- Yapı taşları

func _silence(seconds: float) -> PackedFloat32Array:
	var a: PackedFloat32Array = PackedFloat32Array()
	a.resize(int(RATE * seconds))
	return a


## Dalga biçimi; phase = geçen periyot sayısı.
func _osc(kind: String, phase: float) -> float:
	var p: float = fposmod(phase, 1.0)
	match kind:
		"sine":
			return sin(TAU * p)
		"square":
			return 1.0 if p < 0.5 else -1.0
		"pulse":
			return 1.0 if p < 0.25 else -1.0
		"triangle":
			return 4.0 * absf(p - 0.5) - 1.0
		"saw":
			return 2.0 * p - 1.0
	return 0.0


## Hızlı atak, üstel sönüm.
func _env(k: float, attack_k: float) -> float:
	if k < attack_k:
		return k / attack_k
	return pow(1.0 - (k - attack_k) / (1.0 - attack_k), 2.0)


## Perdesi f0'dan f1'e kayan tek ton.
func _tone(dur: float, f0: float, f1: float, kind: String, attack: float, vol: float) -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(dur)
	var phase: float = 0.0
	for i: int in out.size():
		var k: float = float(i) / out.size()
		phase += lerpf(f0, f1, k) / RATE
		out[i] = _osc(kind, phase) * _env(k, attack / dur) * vol
	return out


## Çan: sinüs + uyumsuz harmonikler, uzun sönüm.
func _bell(dur: float, f: float, vol: float) -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(dur)
	for i: int in out.size():
		var t: float = float(i) / RATE
		var k: float = t / dur
		var s: float = sin(TAU * f * t) + 0.4 * sin(TAU * f * 2.76 * t) + 0.2 * sin(TAU * f * 5.4 * t)
		out[i] = s / 1.6 * exp(-5.0 * k) * minf(1.0, t * 400.0) * vol
	return out


## Süzülmüş gürültü (smooth: 0 = çok boğuk, 1 = ham).
func _noise(dur: float, smooth: float, vol: float) -> PackedFloat32Array:
	var out: PackedFloat32Array = _silence(dur)
	var lp: float = 0.0
	for i: int in out.size():
		var k: float = float(i) / out.size()
		lp += (_rng.randf_range(-1, 1) - lp) * smooth
		out[i] = lp * _env(k, 0.05) * vol
	return out


func _mix(into: PackedFloat32Array, src: PackedFloat32Array, offset: int) -> void:
	for i: int in src.size():
		var j: int = offset + i
		if j >= into.size():
			return
		into[j] += src[i]


func _fade_edges(a: PackedFloat32Array, seconds: float) -> void:
	var n: int = int(RATE * seconds)
	for i: int in n:
		var g: float = float(i) / n
		a[i] *= g
		a[a.size() - 1 - i] *= g


## Tepe seviyesi bu değere ölçeklenir (döngüler daha kısık).
const PEAK: float = 0.7
const LOOP_PEAK: float = 0.22


func _save(name: String, samples: PackedFloat32Array) -> void:
	var raw_peak: float = 0.0
	for v: float in samples:
		raw_peak = maxf(raw_peak, absf(v))
	var gain: float = (LOOP_PEAK if name.ends_with("_loop") else PEAK) / maxf(raw_peak, 0.0001)
	for i: int in samples.size():
		samples[i] *= gain
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples.size() * 2)
	var peak: float = 0.0
	for i: int in samples.size():
		var v: float = clampf(samples[i], -1.0, 1.0)
		peak = maxf(peak, absf(v))
		bytes.encode_s16(i * 2, int(v * 32767.0))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	var path: String = "%s/%s.wav" % [OUT_DIR, name]
	var err: Error = wav.save_to_wav(path)
	print("%s  %.2f sn  tepe %.2f  %s" % [name, samples.size() / float(RATE), peak, "OK" if err == OK else error_string(err)])

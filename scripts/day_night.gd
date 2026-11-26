class_name DayNight
extends CanvasModulate
## Gece-gündüz: dünyanın rengini günün saatine göre sürekli değiştirir.
## Renk bir eğri üzerinde yumuşakça kayar; keskin geçiş yoktur.
## Saat Game.play_time'dan gelir (kayıtla birlikte saklanır). HUD etkilenmez.

const NIGHT: Color = Color(0.34, 0.38, 0.62)
const DAWN: Color = Color(0.95, 0.76, 0.74)
const DAY: Color = Color(1.0, 1.0, 1.0)
const DUSK: Color = Color(0.98, 0.68, 0.52)
## [günün oranı (0 = gece yarısı), renk]
const KEYS: Array = [
	[0.00, NIGHT], [0.17, NIGHT], [0.25, DAWN], [0.34, DAY],
	[0.68, DAY], [0.77, DUSK], [0.86, NIGHT], [1.00, NIGHT],
]
## Ev içi: gece bile sıcak, loş bir lamba ışığı.
const INDOOR_LIGHT: Color = Color(1.0, 0.9, 0.78)
const INDOOR_BLEND: float = 0.6

## Ev içindeyken renk lamba ışığına doğru karıştırılır.
var indoor: bool = false
var _gradient: Gradient = Gradient.new()


func _ready() -> void:
	var offsets: PackedFloat32Array = []
	var colors: PackedColorArray = []
	for key: Array in KEYS:
		offsets.append(key[0])
		colors.append(key[1])
	_gradient.offsets = offsets
	_gradient.colors = colors
	_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	_update()


func _process(_delta: float) -> void:
	_update()


func _update() -> void:
	var c: Color = _gradient.sample(Game.time_of_day())
	if indoor:
		c = c.lerp(INDOOR_LIGHT, INDOOR_BLEND)
	color = c

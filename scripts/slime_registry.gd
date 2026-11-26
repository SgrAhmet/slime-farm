class_name SlimeRegistry
extends RefCounted
## Temel slime türlerini ve gem -> slime eşleşmesini bilir; büyük (melez)
## slime türlerini çalışma anında üretip önbellekler.
## Renk çifti SIRASIZDIR: mavi+gri ile gri+mavi aynı büyük slime'dır. Her çift
## için hep aynı SlimeType örneği döner, böylece envanterde üst üste yığılırlar.

const BASE_TYPE_PATHS: Array[String] = [
	"res://data/slimes/red_slime.tres",
	"res://data/slimes/blue_slime.tres",
	"res://data/slimes/gray_slime.tres",
	"res://data/slimes/pink_slime.tres",
	"res://data/slimes/cat_slime.tres",
	"res://data/slimes/bunny_slime.tres",
	"res://data/slimes/mushroom_slime.tres",
	"res://data/slimes/dragon_slime.tres",
	"res://data/slimes/leaf_slime.tres",
	"res://data/slimes/goat_slime.tres",
	"res://data/slimes/snow_slime.tres",
	"res://data/slimes/feather_slime.tres",
]
const LARGE_ICONS_PATH: String = "res://assets/slimes_large_icons.png"
const LARGE_MAX_STACK: int = 5
const LARGE_SPEED_FACTOR: float = 0.8

static var _base_types: Array[SlimeType] = []
static var _hybrids: Dictionary = {}


static func base_types() -> Array[SlimeType]:
	if _base_types.is_empty():
		for path: String in BASE_TYPE_PATHS:
			_base_types.append(load(path) as SlimeType)
	return _base_types


## Bu gemi düşüren temel slime türü (yoksa null).
static func type_for_gem(gem: ItemType) -> SlimeType:
	for t: SlimeType in base_types():
		if t.gem == gem:
			return t
	return null


## İki türün büyük slime türü. Sıra önemsizdir; gövde rengi daha küçük
## sheet_row'lu türden, benekler ve ek özellikler (kulak, kuyruk …) ikisinden.
static func hybrid(a: SlimeType, b: SlimeType) -> SlimeType:
	var first: SlimeType = a if a.sheet_row <= b.sheet_row else b
	var second: SlimeType = b if first == a else a
	var key: String = "%s_%s" % [first.id, second.id]
	if _hybrids.has(key):
		return _hybrids[key]

	var t: SlimeType = SlimeType.new()
	t.id = StringName("large_" + key)
	t.display_name = "Büyük %s-%s Slime" % [_short_name(first), _short_name(second)]
	t.category = ItemType.Category.SLIME
	t.world_scene = first.world_scene
	t.sheet_row = hybrid_row(first.sheet_row, second.sheet_row)
	t.max_stack = LARGE_MAX_STACK
	t.hop_height = maxf(first.hop_height, second.hop_height)
	t.diet = first.diet | second.diet
	t.favorite = first.favorite  # ikincisi secondary.favorite (SlimeType.favorites)
	t.hop_speed = (first.hop_speed + second.hop_speed) * 0.5 * LARGE_SPEED_FACTOR
	t.idle_time_min = (first.idle_time_min + second.idle_time_min) * 0.5
	t.idle_time_max = (first.idle_time_max + second.idle_time_max) * 0.5
	t.full_duration = first.full_duration
	t.gem = first.gem
	t.secondary = second

	var icon: AtlasTexture = AtlasTexture.new()
	icon.atlas = load(LARGE_ICONS_PATH)
	icon.region = Rect2(0, t.sheet_row * SlimeLooks.ICON_TILE, SlimeLooks.ICON_TILE, SlimeLooks.ICON_TILE)
	t.icon = icon

	_hybrids[key] = t
	return t


static func hybrid_row(row_a: int, row_b: int) -> int:
	return SlimeLooks.hybrid_row(row_a, row_b)


## slimes_large.png satır sayısı.
static func hybrid_count() -> int:
	return SlimeLooks.hybrid_pairs().size()


static func _short_name(t: SlimeType) -> String:
	return t.display_name.get_slice(" ", 0)

class_name ItemDatabase
extends RefCounted
## Kayıt dosyasındaki eşya kimliklerini (id) ItemType'a çevirir.
## Büyük slimelar "large_<renk>_<renk>" kimliğiyle SlimeRegistry'den üretilir.

const ITEM_PATHS: Array[String] = [
	"res://data/items/apple.tres",
	"res://data/items/carrot.tres",
	"res://data/items/red_gem.tres",
	"res://data/items/blue_gem.tres",
	"res://data/items/gray_gem.tres",
	"res://data/items/pink_gem.tres",
	"res://data/items/cat_gem.tres",
	"res://data/items/bunny_gem.tres",
	"res://data/items/mushroom_gem.tres",
	"res://data/items/dragon_gem.tres",
	"res://data/items/leaf_gem.tres",
	"res://data/items/goat_gem.tres",
	"res://data/items/snow_gem.tres",
	"res://data/items/feather_gem.tres",
	"res://data/items/hen.tres",
	"res://data/items/rooster.tres",
	"res://data/items/chick.tres",
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
const LARGE_PREFIX: String = "large_"

static var _by_id: Dictionary = {}


static func get_item(id: String) -> ItemType:
	if _by_id.is_empty():
		for path: String in ITEM_PATHS:
			var item: ItemType = load(path)
			_by_id[String(item.id)] = item
	if _by_id.has(id):
		return _by_id[id]
	if id.begins_with(LARGE_PREFIX):
		var parts: PackedStringArray = id.trim_prefix(LARGE_PREFIX).split("_")
		if parts.size() == 2:
			var a: SlimeType = get_item(parts[0]) as SlimeType
			var b: SlimeType = get_item(parts[1]) as SlimeType
			if a != null and b != null:
				return SlimeRegistry.hybrid(a, b)
	push_warning("Bilinmeyen eşya kimliği: %s" % id)
	return null

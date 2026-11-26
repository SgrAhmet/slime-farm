class_name SlimeLooks
extends RefCounted
## Slime görünüm tablosu: hem görsel üretici (tools/generate_assets.gd) hem
## SlimeRegistry bu sırayı kullanır. Satır = SlimeType.sheet_row.
##
## Büyük slime: gövde ana türün renginde, diğer türün rengi benekler halinde,
## İKİ türün özellikleri (kulak, kuyruk, şapka …) birlikte görünür.

const SMALL_TILE: int = 20
const LARGE_TILE: int = 30
const ICON_TILE: int = 16

## [gövde, kontur, parlama]
const PALETTES: Array = [
	[Color("e04848"), Color("8c2030"), Color("ff9a8a")],  # 0 kırmızı
	[Color("4a90e0"), Color("22508c"), Color("a8d8ff")],  # 1 mavi
	[Color("9a9aa6"), Color("55555f"), Color("dadae4")],  # 2 gri
	[Color("f08cc4"), Color("9a3a6e"), Color("ffd6ec")],  # 3 pembe
	[Color("f2a541"), Color("9a5a16"), Color("ffd9a0")],  # 4 kedi
	[Color("f3eee4"), Color("9a8e7c"), Color("ffffff")],  # 5 tavşan
	[Color("e2c9a0"), Color("8a6a44"), Color("fff0d8")],  # 6 mantar
	[Color("9a6ad8"), Color("4e2a85"), Color("d8c4ff")],  # 7 ejder
	[Color("7ccf52"), Color("2f7a26"), Color("d0f5b8")],  # 8 yaprak
	[Color("c4a882"), Color("6e5638"), Color("eedcc0")],  # 9 keçi
	[Color("bfe3f2"), Color("5a8aa8"), Color("ffffff")],  # 10 kar
	[Color("3fb3a0"), Color("1e6a5e"), Color("b0f0e4")],  # 11 tüy
]

## Türün taşıdığı özellikler (büyük slimeda iki türünkü birleşir).
const FEATURES: Array = [
	[],
	[],
	[],
	[],
	["stripes", "cat_ears", "cat_tail"],
	["bunny_ears", "bunny_tail"],
	["cap"],
	["horns", "dragon_tail"],
	["sprout"],
	["goat_horns", "beard"],
	["snow_cap"],
	["crest", "wings"],
]


static func type_count() -> int:
	return PALETTES.size()


## Büyük slime satırları: tüm sırasız çiftler (i < j), i artan, sonra j artan.
static func hybrid_pairs() -> Array:
	var pairs: Array = []
	for i: int in type_count():
		for j: int in range(i + 1, type_count()):
			pairs.append([i, j])
	return pairs


static func hybrid_row(row_a: int, row_b: int) -> int:
	return hybrid_pairs().find([mini(row_a, row_b), maxi(row_a, row_b)])

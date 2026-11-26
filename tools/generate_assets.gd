extends SceneTree
## Yer tutucu piksel art görsellerini üretir.
## Çalıştırma: godot --headless --path . -s res://tools/generate_assets.gd

const TILE: int = 16

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets"))
	_save(_make_tiles(), "res://assets/tiles.png")
	_save(_make_player(), "res://assets/player.png")
	_save(_make_slimes(), "res://assets/slimes.png")
	_save(_make_slime_icons(), "res://assets/slimes_icons.png")
	_save(_make_shadow(), "res://assets/shadow.png")
	_save(_make_vacuum_gun(), "res://assets/vacuum_gun.png")
	_save(_make_digits(), "res://assets/digits.png")
	_save(_make_items(), "res://assets/items.png")
	_save(_make_heart(), "res://assets/fx_heart.png")
	_save(_make_alert(), "res://assets/fx_alert.png")
	_save(_make_sparkle(), "res://assets/fx_sparkle.png")
	_save(_make_large_slimes(), "res://assets/slimes_large.png")
	_save(_make_large_icons(), "res://assets/slimes_large_icons.png")
	_save(_make_house(), "res://assets/house.png")
	_save(_make_tree(), "res://assets/tree.png")
	_save(_make_rock(), "res://assets/rock.png")
	_save(_make_bush(), "res://assets/bush.png")
	_save(_make_bed(), "res://assets/bed.png")
	_save(_make_table(), "res://assets/table.png")
	_save(_make_plant(), "res://assets/plant.png")
	_save(_make_rug(), "res://assets/rug.png")
	_save(_make_sell_machine(), "res://assets/sell_machine.png")
	_save(_make_coin(), "res://assets/coin.png")
	_save(_make_sign(), "res://assets/sign.png")
	_save(_make_post(), "res://assets/corral_post.png")
	_save(_make_post_tall(), "res://assets/corral_post_tall.png")
	_save(_make_feeder(), "res://assets/feeder.png")
	_save(_make_collector(), "res://assets/collector.png")
	_save(_make_sapling(), "res://assets/sapling.png")
	_save(_make_dirt_mound(), "res://assets/dirt_mound.png")
	_save(_make_chickens(), "res://assets/chickens.png")
	_save(_make_nest(), "res://assets/nest.png")
	_save(_make_rock_nest(), "res://assets/nest_rock.png")
	_save(_make_star_tree(), "res://assets/tree_star.png")
	_save(_make_grape_vine(), "res://assets/grape_vine.png")
	quit()


# ---------------------------------------------------------------- Dekor objeleri

func _blob(img: Image, center: Vector2, radius: Vector2, fill: Color, outline: Color) -> void:
	for y: int in img.get_height():
		for x: int in img.get_width():
			var p: Vector2 = (Vector2(x + 0.5, y + 0.5) - center) / radius
			var d: float = p.length_squared()
			if d <= 1.0:
				var edge_d: float = ((Vector2(x + 0.5, y + 0.5) - center) / (radius - Vector2.ONE)).length_squared()
				img.set_pixel(x, y, outline if edge_d > 1.0 else fill)


func _make_house() -> Image:
	var img: Image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	var outline: Color = Color("3a2516")
	# Baca
	img.fill_rect(Rect2i(44, 0, 8, 14), outline)
	img.fill_rect(Rect2i(45, 1, 6, 13), Color("8a8a96"))
	for y: int in [3, 7, 11]:
		img.fill_rect(Rect2i(45, y, 6, 1), Color("6a6a76"))
	# Duvarlar
	img.fill_rect(Rect2i(4, 32, 56, 32), outline)
	img.fill_rect(Rect2i(5, 33, 54, 30), Color("e8d2a8"))
	for y: int in range(36, 63, 4):
		img.fill_rect(Rect2i(5, y, 54, 1), Color("cdb48a"))
	img.fill_rect(Rect2i(5, 61, 54, 2), Color("a88e64"))
	# Çatı (kiremit sıraları)
	img.fill_rect(Rect2i(0, 6, 64, 30), outline)
	img.fill_rect(Rect2i(1, 7, 62, 28), Color("b5483c"))
	for row: int in 7:
		var y: int = 9 + row * 4
		img.fill_rect(Rect2i(1, y, 62, 1), Color("8e342b"))
		for x: int in range(1 + (row % 2) * 4, 63, 8):
			img.set_pixel(x, y + 1, Color("8e342b"))
			img.set_pixel(x, y + 2, Color("8e342b"))
	img.fill_rect(Rect2i(1, 7, 62, 2), Color("d0685a"))
	img.fill_rect(Rect2i(0, 35, 64, 2), outline)
	# Kapı
	img.fill_rect(Rect2i(25, 43, 14, 21), outline)
	img.fill_rect(Rect2i(26, 44, 12, 20), Color("a86f3c"))
	img.fill_rect(Rect2i(31, 44, 1, 20), Color("8a5a30"))
	img.fill_rect(Rect2i(26, 52, 12, 1), Color("8a5a30"))
	img.set_pixel(35, 55, Color("f2e86d"))
	# Pencereler + çiçek kutuları
	for wx: int in [9, 44]:
		img.fill_rect(Rect2i(wx, 41, 12, 10), outline)
		img.fill_rect(Rect2i(wx + 1, 42, 10, 8), Color("9fd8f0"))
		img.fill_rect(Rect2i(wx + 1, 42, 4, 3), Color("e0f6ff"))
		img.fill_rect(Rect2i(wx + 5, 42, 1, 8), outline)
		img.fill_rect(Rect2i(wx + 1, 45, 10, 1), outline)
		img.fill_rect(Rect2i(wx, 51, 12, 3), Color("6e4524"))
		for fx: int in [wx + 2, wx + 5, wx + 9]:
			img.set_pixel(fx, 50, Color("e04848"))
			img.set_pixel(fx + 1, 50, Color("4caf50"))
	return img


func _make_tree() -> Image:
	return _tree_image(Color("4f9a3a"), Color("2f6b2a"), Color("7cc152"))


## Yıldız meyvesi ağacı: altın sarısı yapraklar.
func _make_star_tree() -> Image:
	return _tree_image(Color("b8b040"), Color("6a6418"), Color("ecdf78"))


func _tree_image(leaf: Color, dark: Color, light: Color) -> Image:
	var img: Image = Image.create_empty(32, 48, false, Image.FORMAT_RGBA8)
	# Gövde
	img.fill_rect(Rect2i(12, 30, 8, 17), Color("3a2516"))
	img.fill_rect(Rect2i(13, 30, 6, 17), Color("7a4e2a"))
	img.fill_rect(Rect2i(14, 32, 1, 12), Color("9a6a3a"))
	img.fill_rect(Rect2i(11, 45, 10, 2), Color("3a2516"))
	# Yaprak kümesi: birkaç üst üste yuvarlak
	_blob(img, Vector2(9, 22), Vector2(9, 8), leaf, dark)
	_blob(img, Vector2(23, 22), Vector2(9, 8), leaf, dark)
	_blob(img, Vector2(16, 14), Vector2(13, 12), leaf, dark)
	# Gölgeli alt kenar ve parlak tepeler
	for x: int in range(3, 29):
		for y: int in range(24, 31):
			if img.get_pixel(x, y) == leaf and img.get_pixel(x, y + 2).a == 0.0:
				img.set_pixel(x, y, dark)
	for p: Vector2i in [Vector2i(10, 7), Vector2i(11, 6), Vector2i(12, 6), Vector2i(9, 8), Vector2i(20, 9), Vector2i(21, 9), Vector2i(5, 18), Vector2i(6, 17)]:
		img.set_pixelv(p, light)
	return img


func _make_rock() -> Image:
	var img: Image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	_blob(img, Vector2(8, 10), Vector2(7, 5.5), Color("8f8f9a"), Color("4a4a55"))
	for p: Vector2i in [Vector2i(5, 7), Vector2i(6, 6), Vector2i(7, 6), Vector2i(5, 8)]:
		img.set_pixelv(p, Color("c4c4ce"))
	for x: int in range(3, 13):
		if img.get_pixel(x, 13) == Color("8f8f9a"):
			img.set_pixel(x, 13, Color("6f6f7a"))
	img.set_pixel(10, 9, Color("6f6f7a"))
	img.set_pixel(11, 10, Color("6f6f7a"))
	return img


func _make_bush() -> Image:
	var img: Image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	_blob(img, Vector2(5, 10), Vector2(5, 4.5), Color("3f8a34"), Color("23561f"))
	_blob(img, Vector2(11, 10), Vector2(5, 4.5), Color("3f8a34"), Color("23561f"))
	_blob(img, Vector2(8, 8), Vector2(5.5, 5), Color("4f9a3a"), Color("23561f"))
	for p: Vector2i in [Vector2i(6, 5), Vector2i(7, 5), Vector2i(4, 8)]:
		img.set_pixelv(p, Color("7cc152"))
	img.set_pixel(10, 9, Color("e04848"))
	img.set_pixel(5, 11, Color("e04848"))
	return img


func _make_bed() -> Image:
	var img: Image = Image.create_empty(16, 28, false, Image.FORMAT_RGBA8)
	var outline: Color = Color("3a2516")
	# Başlık
	img.fill_rect(Rect2i(0, 0, 16, 7), outline)
	img.fill_rect(Rect2i(1, 1, 14, 5), Color("8a5a30"))
	img.fill_rect(Rect2i(1, 1, 14, 1), Color("a86f3c"))
	# Çerçeve + şilte
	img.fill_rect(Rect2i(0, 6, 16, 22), outline)
	img.fill_rect(Rect2i(1, 7, 14, 20), Color("f2efe6"))
	# Yastık
	img.fill_rect(Rect2i(3, 8, 10, 5), Color("c9c3b4"))
	img.fill_rect(Rect2i(3, 8, 10, 4), Color("ffffff"))
	# Yorgan (kareli)
	img.fill_rect(Rect2i(1, 14, 14, 13), Color("3b6fb6"))
	for y: int in range(14, 27, 4):
		for x: int in range(1 + ((y / 4) % 2) * 2, 15, 4):
			img.fill_rect(Rect2i(x, y, 2, 2), Color("5a8fd6"))
	img.fill_rect(Rect2i(1, 14, 14, 1), Color("8fb8ee"))
	img.fill_rect(Rect2i(1, 26, 14, 1), Color("2a5290"))
	return img


func _make_table() -> Image:
	var img: Image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	var outline: Color = Color("3a2516")
	img.fill_rect(Rect2i(1, 3, 14, 8), outline)
	img.fill_rect(Rect2i(2, 4, 12, 6), Color("b07a45"))
	img.fill_rect(Rect2i(2, 4, 12, 1), Color("cf9a62"))
	img.fill_rect(Rect2i(2, 11, 2, 4), outline)
	img.fill_rect(Rect2i(12, 11, 2, 4), outline)
	# Üstünde bir elma
	img.fill_rect(Rect2i(9, 4, 3, 3), Color("e53935"))
	img.set_pixel(10, 3, Color("4caf50"))
	return img


func _make_plant() -> Image:
	var img: Image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	_blob(img, Vector2(8, 6), Vector2(6, 5), Color("4f9a3a"), Color("23561f"))
	img.set_pixel(6, 3, Color("7cc152"))
	img.set_pixel(7, 3, Color("7cc152"))
	img.fill_rect(Rect2i(4, 10, 8, 6), Color("7a3a22"))
	img.fill_rect(Rect2i(5, 10, 6, 5), Color("c0643c"))
	img.fill_rect(Rect2i(4, 10, 8, 1), Color("d97c52"))
	return img


## Gem satış makinesi: üstte huni, önde gem işareti ve jeton çıkışı.
func _make_sell_machine() -> Image:
	var img: Image = Image.create_empty(24, 30, false, Image.FORMAT_RGBA8)
	var outline: Color = Color("23232e")
	# Huni
	img.fill_rect(Rect2i(1, 2, 22, 7), outline)
	img.fill_rect(Rect2i(2, 3, 20, 5), Color("8a93a6"))
	img.fill_rect(Rect2i(4, 4, 16, 3), Color("2a2a38"))
	img.fill_rect(Rect2i(2, 3, 20, 1), Color("c4cad8"))
	# Gövde
	img.fill_rect(Rect2i(3, 8, 18, 21), outline)
	img.fill_rect(Rect2i(4, 9, 16, 19), Color("4f7ac0"))
	img.fill_rect(Rect2i(4, 9, 16, 1), Color("7aa2e0"))
	img.fill_rect(Rect2i(4, 26, 16, 2), Color("3a5a94"))
	# Ekran / gem işareti
	img.fill_rect(Rect2i(7, 11, 10, 8), outline)
	img.fill_rect(Rect2i(8, 12, 8, 6), Color("1c2b3a"))
	for r: Array in [[13, 11, 2], [14, 10, 4], [15, 11, 2], [16, 12, 0]]:
		if r[2] > 0:
			img.fill_rect(Rect2i(r[1], r[0], r[2], 1), Color("f06aaf"))
	img.set_pixel(11, 14, Color("ffc8e6"))
	# Jeton çıkışı + ışıklar
	img.fill_rect(Rect2i(9, 21, 6, 3), outline)
	img.fill_rect(Rect2i(10, 22, 4, 1), Color("f2c94c"))
	img.set_pixel(5, 11, Color("7ee081"))
	img.set_pixel(5, 13, Color("f2c94c"))
	# Ayaklar
	img.fill_rect(Rect2i(4, 28, 3, 2), outline)
	img.fill_rect(Rect2i(17, 28, 3, 2), outline)
	return img


## Satılık arsa tabelası (üstünde jeton işareti).
func _make_sign() -> Image:
	return _make_from_pattern([
		".OOOOOOOOOO.",
		"OWWWWWWWWWWO",
		"OWWWYYYYWWWO",
		"OWWYYDDYYWWO",
		"OWWYDYYYYWWO",
		"OWWYYDDYYWWO",
		"OWWWYYYYWWWO",
		"OWWWWWWWWWWO",
		".OOOOOOOOOO.",
		".....PP.....",
		".....PP.....",
		".....PP.....",
		".....PP.....",
		"....OOOO....",
	], {"O": Color("3a2516"), "W": Color("c9955a"), "Y": Color("f2c94c"), "D": Color("8a5a10"), "P": Color("7a4e2a")})


## Kümes köşe direği.
func _make_post() -> Image:
	return _post_image(11)


## Kümes genişletilince yükselen duvarların direği.
func _make_post_tall() -> Image:
	return _post_image(19)


func _post_image(body_rows: int) -> Image:
	var pattern: Array[String] = [".OO."]
	for i: int in body_rows:
		pattern.append("OLWO")
	pattern.append("OOOO")
	return _make_from_pattern(pattern, {"O": Color("3a2516"), "L": Color("a86f3c"), "W": Color("7a4e2a")})


func _make_post_old() -> Image:
	return _make_from_pattern([
		".OO.",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OLWO",
		"OOOO",
	], {"O": Color("3a2516"), "L": Color("a86f3c"), "W": Color("7a4e2a")})


## Otomatik besleyici: ahşap kutu, üstte huni, önde yem çıkışı.
func _make_feeder() -> Image:
	return _make_from_pattern([
		"..OOOOOOOOOOOO..",
		".OGGGGGGGGGGGGO.",
		".OgDDDDDDDDDDgO.",
		"..OgggggggggO...",
		"..OWWWWWWWWWWO..",
		"..OWLLLLLLLLWO..",
		"..OWLWWWWWWLWO..",
		"..OWLWRRRRWLWO..",
		"..OWLWRRRRWLWO..",
		"..OWLWWWWWWLWO..",
		"..OWLLLLLLLLWO..",
		"..OWWWOOOOWWWO..",
		"..OWWWOkkOWWWO..",
		"..OOOOOOOOOOOO..",
		"..OO........OO..",
	], {"O": Color("3a2516"), "G": Color("8a93a6"), "g": Color("5a6276"), "D": Color("2a2a38"),
		"W": Color("b07a45"), "L": Color("8a5a30"), "R": Color("e53935"), "k": Color("1a1a1a")})


## Otomatik gem toplayıcı: hortumlu küçük vakum makinesi.
func _make_collector() -> Image:
	return _make_from_pattern([
		"......OOOO......",
		".....OkkkkO.....",
		".....OkkkkO.....",
		"......OGGO......",
		"......OGGO......",
		"...OOOOOOOOOO...",
		"..OBBBBBBBBBBO..",
		"..OBbbbbbbbbBO..",
		"..OBbPPPPPPbBO..",
		"..OBbPpPPPPbBO..",
		"..OBbPPPPPPbBO..",
		"..OBbbbbbbbbBO..",
		"..OBBBBBBBBBBO..",
		"..OBByBBBBgBBO..",
		"..OOOOOOOOOOOO..",
		"..OO........OO..",
	], {"O": Color("23232e"), "k": Color("111118"), "G": Color("8a93a6"), "B": Color("6a4fa0"),
		"b": Color("4a3578"), "P": Color("2a1f40"), "p": Color("f06aaf"), "y": Color("f2c94c"), "g": Color("7ee081")})


func _make_sapling() -> Image:
	return _make_from_pattern([
		"................",
		"................",
		"......LL........",
		".....LGGL..LL...",
		"....LGGGL.LGGL..",
		"....LGGGGLGGGL..",
		".....LGGGGGGL...",
		"......LGGGGL....",
		".......LTTL.....",
		"........T.......",
		"........T.......",
		"........T.......",
		"......SSTSS.....",
		".....SSSSSSS....",
		"................",
		"................",
	], {"L": Color("2f6b2a"), "G": Color("6fb04a"), "T": Color("7a4e2a"), "S": Color("4a2c17")})


func _make_coin() -> Image:
	return _make_from_pattern([
		".OOOO.",
		"OYWYYO",
		"OWYDYO",
		"OYYDYO",
		"OYYYYO",
		".OOOO.",
	], {"O": Color("8a5a10"), "Y": Color("f2c94c"), "W": Color("fff3b0"), "D": Color("c99a2e")})


func _make_rug() -> Image:
	var img: Image = Image.create_empty(32, 20, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(0, 0, 32, 20), Color("7a2f3a"))
	img.fill_rect(Rect2i(1, 1, 30, 18), Color("b5483c"))
	img.fill_rect(Rect2i(3, 3, 26, 14), Color("e8c25a"))
	img.fill_rect(Rect2i(4, 4, 24, 12), Color("b5483c"))
	for x: int in range(6, 27, 4):
		img.fill_rect(Rect2i(x, 9, 2, 2), Color("e8c25a"))
	return img


func _save(img: Image, path: String) -> void:
	var err: Error = img.save_png(path)
	if err != OK:
		push_error("Kaydedilemedi: %s (%s)" % [path, error_string(err)])
	else:
		print("Oluşturuldu: ", path)


# Atlas sırası (x): 0 çim, 1 çim varyantı, 2 yol, 3 sürülmüş toprak, 4 çit,
# 5 sarı çiçekler, 6 pembe çiçekler, 7 uzun ot, 8 çakıl, 9 ahşap zemin,
# 10 iç duvar, 11 duvar üstü/kenar, 12 pencereli iç duvar,
# 13 sık orman örtüsü (geçilmez), 14 orman zemini, 15 mantarlar, 16 eğrelti otu,
# 17 dağ zemini, 18 dağ çakılı, 19 kar, 20 kaya duvarı (geçilmez), 21 dağ otu
const TILE_COUNT: int = 22

func _make_tiles() -> Image:
	var img: Image = Image.create_empty(TILE * TILE_COUNT, TILE, false, Image.FORMAT_RGBA8)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1234

	# 0: Çim
	_noise_tile(img, 0, Color("5a9a3c"), [Color("4d8a33"), Color("6aad48")], 0.25, rng)
	# 1: Çim varyantı (ot öbekleri + çiçek)
	_noise_tile(img, 1, Color("5a9a3c"), [Color("4d8a33"), Color("6aad48")], 0.25, rng)
	var ox: int = TILE
	for p: Vector2i in [Vector2i(3, 4), Vector2i(4, 3), Vector2i(5, 4), Vector2i(10, 11), Vector2i(11, 10), Vector2i(12, 11)]:
		img.set_pixel(ox + p.x, p.y, Color("3f7a2a"))
	img.set_pixel(ox + 11, 4, Color("f2e86d"))
	img.set_pixel(ox + 4, 11, Color("f2f2f2"))
	# 2: Yol
	_noise_tile(img, 2, Color("b8925a"), [Color("a8824c"), Color("c8a46a")], 0.3, rng)
	# 3: Sürülmüş toprak (yatay karıklar)
	_noise_tile(img, 3, Color("6b4226"), [Color("5e3920"), Color("774a2c")], 0.2, rng)
	for row: int in [3, 7, 11, 15]:
		for x: int in TILE:
			img.set_pixel(TILE * 3 + x, row, Color("4a2c17"))
	# 4: Çit (şeffaf zemin, orta direk + iki kiriş)
	var fx: int = TILE * 4
	var wood: Color = Color("a86f3c")
	var dark: Color = Color("6e4524")
	img.fill_rect(Rect2i(fx, 5, TILE, 2), wood)
	img.fill_rect(Rect2i(fx, 10, TILE, 2), wood)
	img.fill_rect(Rect2i(fx, 7, TILE, 1), dark)
	img.fill_rect(Rect2i(fx, 12, TILE, 1), dark)
	img.fill_rect(Rect2i(fx + 6, 2, 4, 13), wood)
	img.fill_rect(Rect2i(fx + 5, 2, 1, 13), dark)
	img.fill_rect(Rect2i(fx + 10, 2, 1, 13), dark)
	img.fill_rect(Rect2i(fx + 6, 14, 4, 1), dark)

	var grass: Color = Color("5a9a3c")
	var grass_specks: Array = [Color("4d8a33"), Color("6aad48")]
	# 5-6: Çiçekli çim
	for idx: int in [5, 6]:
		_noise_tile(img, idx, grass, grass_specks, 0.25, rng)
		var petal: Color = Color("f7e26b") if idx == 5 else Color("f29bc2")
		var center: Color = Color("e08a2e") if idx == 5 else Color("fff3f8")
		for c: Vector2i in [Vector2i(4, 4), Vector2i(11, 7), Vector2i(6, 12)]:
			var o: Vector2i = Vector2i(idx * TILE, 0) + c
			for d: Vector2i in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				img.set_pixelv(o + d, petal)
			img.set_pixelv(o, center)
			img.set_pixelv(o + Vector2i(0, 2), Color("3f7a2a"))
	# 7: Uzun ot öbekleri
	_noise_tile(img, 7, grass, grass_specks, 0.25, rng)
	for base: Vector2i in [Vector2i(4, 9), Vector2i(10, 13)]:
		var o7: Vector2i = Vector2i(7 * TILE, 0) + base
		for blade: Array in [[-2, 3], [-1, 5], [0, 6], [1, 4], [2, 3]]:
			for h: int in blade[1]:
				img.set_pixelv(o7 + Vector2i(blade[0], -h), Color("3f7a2a") if h < 2 else Color("7cc152"))
	# 8: Çakıl taşları
	_noise_tile(img, 8, grass, grass_specks, 0.25, rng)
	for s: Rect2i in [Rect2i(3, 4, 3, 2), Rect2i(10, 9, 2, 2), Rect2i(5, 12, 2, 1)]:
		var o8: Vector2i = Vector2i(8 * TILE, 0) + s.position
		img.fill_rect(Rect2i(o8, s.size), Color("9a9a9a"))
		img.set_pixelv(o8, Color("c8c8c8"))
		img.fill_rect(Rect2i(o8 + Vector2i(0, s.size.y), Vector2i(s.size.x, 1)), Color("3f6a2a"))
	# 9: Ahşap zemin (yatay tahtalar, kaydırılmış derzler)
	var fl: int = 9 * TILE
	img.fill_rect(Rect2i(fl, 0, TILE, TILE), Color("c8915a"))
	for row: int in 4:
		img.fill_rect(Rect2i(fl, row * 4 + 3, TILE, 1), Color("8f5f34"))
		var seam: int = 5 if row % 2 == 0 else 12
		img.fill_rect(Rect2i(fl + seam, row * 4, 1, 3), Color("a87443"))
		img.set_pixel(fl + (seam + 6) % TILE, row * 4 + 1, Color("d9a46d"))
	# 10: İç duvar (dikey tahtalar + süpürgelik)
	var wl: int = 10 * TILE
	_draw_wall(img, wl)
	# 11: Duvar üstü / dış kenar
	var wt: int = 11 * TILE
	img.fill_rect(Rect2i(wt, 0, TILE, TILE), Color("4a2f1e"))
	for y: int in range(0, TILE, 4):
		img.fill_rect(Rect2i(wt, y, TILE, 1), Color("5a3a26"))
	# 12: Pencereli iç duvar
	var ww: int = 12 * TILE
	_draw_wall(img, ww)
	img.fill_rect(Rect2i(ww + 3, 2, 10, 9), Color("6e4524"))
	img.fill_rect(Rect2i(ww + 4, 3, 8, 7), Color("9fd8f0"))
	img.fill_rect(Rect2i(ww + 4, 3, 3, 2), Color("e0f6ff"))
	img.fill_rect(Rect2i(ww + 7, 3, 1, 7), Color("6e4524"))
	img.fill_rect(Rect2i(ww + 4, 6, 8, 1), Color("6e4524"))

	# 13: Sık orman örtüsü — üst üste yaprak kümeleri (yan yana döşenebilir)
	var cx: int = 13 * TILE
	img.fill_rect(Rect2i(cx, 0, TILE, TILE), Color("1f4a22"))
	for blob: Array in [[3, 4, 4], [11, 3, 4], [7, 9, 5], [1, 13, 3], [14, 12, 3]]:
		for y: int in TILE:
			for x: int in TILE:
				# Kenarlardan taşan kümeler karşı kenara sarılsın (dikişsiz)
				var dx: float = absf(x - blob[0])
				var dy: float = absf(y - blob[1])
				dx = minf(dx, TILE - dx)
				dy = minf(dy, TILE - dy)
				var d: float = sqrt(dx * dx + dy * dy)
				if d < blob[2]:
					img.set_pixel(cx + x, y, Color("2f6b2a") if d < blob[2] - 1.2 else Color("285c26"))
				if d < 1.2 and dy < 1.0:
					img.set_pixel(cx + x, y, Color("4f8f3a"))
	# 14: Orman zemini (koyu çim)
	var forest_floor: Color = Color("3f7a33")
	var forest_specks: Array = [Color("356a2b"), Color("4a8a3a")]
	_noise_tile(img, 14, forest_floor, forest_specks, 0.3, rng)
	# 15: Mantarlar
	_noise_tile(img, 15, forest_floor, forest_specks, 0.3, rng)
	for m: Vector2i in [Vector2i(4, 9), Vector2i(10, 12)]:
		var o15: Vector2i = Vector2i(15 * TILE, 0) + m
		img.fill_rect(Rect2i(o15 + Vector2i(-2, -2), Vector2i(5, 2)), Color("d23c3c"))
		img.set_pixelv(o15 + Vector2i(-1, -2), Color.WHITE)
		img.set_pixelv(o15 + Vector2i(1, -1), Color.WHITE)
		img.fill_rect(Rect2i(o15 + Vector2i(-1, -3), Vector2i(3, 1)), Color("d23c3c"))
		img.fill_rect(Rect2i(o15 + Vector2i(0, 0), Vector2i(1, 2)), Color("f0e6d2"))
	# 16: Eğrelti otu
	_noise_tile(img, 16, forest_floor, forest_specks, 0.3, rng)
	for f: Vector2i in [Vector2i(5, 11), Vector2i(11, 6)]:
		var o16: Vector2i = Vector2i(16 * TILE, 0) + f
		for i: int in 4:
			img.set_pixelv(o16 + Vector2i(-i - 1, -i), Color("6fb04a"))
			img.set_pixelv(o16 + Vector2i(i + 1, -i), Color("6fb04a"))
			img.set_pixelv(o16 + Vector2i(0, -i - 1), Color("5a9a3c"))
		img.set_pixelv(o16, Color("2f5a22"))

	# 17: Dağ zemini (gri-kahve kaya)
	var rock: Color = Color("8a8172")
	var rock_specks: Array = [Color("7a7264"), Color("9a9282")]
	_noise_tile(img, 17, rock, rock_specks, 0.3, rng)
	# 18: Dağ çakılı
	_noise_tile(img, 18, rock, rock_specks, 0.3, rng)
	for st: Rect2i in [Rect2i(2, 3, 3, 2), Rect2i(9, 5, 2, 2), Rect2i(5, 11, 4, 2), Rect2i(12, 12, 2, 1)]:
		var o18: Vector2i = Vector2i(18 * TILE, 0) + st.position
		img.fill_rect(Rect2i(o18, st.size), Color("b0a898"))
		img.set_pixelv(o18, Color("d0c8b8"))
		img.fill_rect(Rect2i(o18 + Vector2i(0, st.size.y), Vector2i(st.size.x, 1)), Color("5e5648"))
	# 19: Kar
	_noise_tile(img, 19, Color("e8eef5"), [Color("d4deea"), Color("ffffff")], 0.25, rng)
	# 20: Kaya duvarı — koyu kaya blokları (yan yana döşenebilir)
	var cl: int = 20 * TILE
	img.fill_rect(Rect2i(cl, 0, TILE, TILE), Color("4a443c"))
	for blk: Rect2i in [Rect2i(0, 0, 9, 7), Rect2i(9, 0, 7, 9), Rect2i(0, 7, 6, 9), Rect2i(6, 9, 10, 7), Rect2i(6, 7, 3, 2)]:
		img.fill_rect(Rect2i(cl + blk.position.x + 1, blk.position.y + 1, blk.size.x - 1, blk.size.y - 1), Color("6a6256"))
		img.fill_rect(Rect2i(cl + blk.position.x + 1, blk.position.y + 1, blk.size.x - 1, 1), Color("8a8274"))
	# 21: Dağ otu (kaya üstünde seyrek ot)
	_noise_tile(img, 21, rock, rock_specks, 0.3, rng)
	for tuft: Vector2i in [Vector2i(4, 6), Vector2i(11, 12), Vector2i(12, 4)]:
		var o21: Vector2i = Vector2i(21 * TILE, 0) + tuft
		for bl: Array in [[-1, 2], [0, 3], [1, 2]]:
			for hh: int in bl[1]:
				img.set_pixelv(o21 + Vector2i(bl[0], -hh), Color("6a8a3a") if hh < 2 else Color("8aaa4a"))
	return img


func _draw_wall(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("b98b5e"))
	for x: int in range(0, TILE, 4):
		img.fill_rect(Rect2i(ox + x, 0, 1, TILE - 3), Color("9a7048"))
	img.fill_rect(Rect2i(ox, TILE - 3, TILE, 3), Color("6e4524"))
	img.fill_rect(Rect2i(ox, TILE - 3, TILE, 1), Color("8f5f34"))


func _noise_tile(img: Image, index: int, base: Color, specks: Array, chance: float, rng: RandomNumberGenerator) -> void:
	var ox: int = index * TILE
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), base)
	for y: int in TILE:
		for x: int in TILE:
			if rng.randf() < chance:
				img.set_pixel(ox + x, y, specks[rng.randi_range(0, specks.size() - 1)])


const HAT: Color = Color("e8c25a")
const HAT_DARK: Color = Color("b8923a")
const SKIN: Color = Color("f1c27d")
const HAIR: Color = Color("6b3e1f")
const SHIRT: Color = Color("3b6fb6")
const PANTS: Color = Color("2f3e5c")
const PANTS_FAR: Color = Color("232f47")
const BOOTS: Color = Color("3a2516")
const EYE: Color = Color("1e1e1e")

# Satır (y) = yön: 0 aşağı, 1 yukarı, 2 sol, 3 sağ — Player.Facing ile aynı
# Sütun (x) = kare: 0 duruş, 1 adım A, 2 adım B
func _make_player() -> Image:
	var img: Image = Image.create_empty(TILE * 3, TILE * 4, false, Image.FORMAT_RGBA8)
	var steps: Array[int] = [0, 1, -1]
	for dir: int in 4:
		for col: int in 3:
			_draw_farmer(img, Vector2i(col * TILE, dir * TILE), dir, steps[col])
	return img


func _draw_farmer(img: Image, o: Vector2i, dir: int, step: int) -> void:
	var side: bool = dir >= 2
	var bob: int = 1 if step != 0 else 0  # adım karelerinde gövde 1 px aşağı
	var b: Vector2i = o + Vector2i(0, bob)

	# Şapka, kafa, gövde
	img.fill_rect(Rect2i(b + Vector2i(5, 1), Vector2i(6, 2)), HAT)
	img.fill_rect(Rect2i(b + Vector2i(3, 3), Vector2i(10, 1)), HAT_DARK)
	img.fill_rect(Rect2i(b + Vector2i(5, 4), Vector2i(6, 4)), HAIR if dir == 1 else SKIN)
	img.fill_rect(Rect2i(b + Vector2i(4, 8), Vector2i(8, 4)), SHIRT)

	# Yüz
	match dir:
		0:
			img.set_pixelv(b + Vector2i(6, 6), EYE)
			img.set_pixelv(b + Vector2i(9, 6), EYE)
		2:
			img.set_pixelv(b + Vector2i(6, 6), EYE)
			img.fill_rect(Rect2i(b + Vector2i(9, 4), Vector2i(2, 4)), HAIR)
		3:
			img.set_pixelv(b + Vector2i(9, 6), EYE)
			img.fill_rect(Rect2i(b + Vector2i(5, 4), Vector2i(2, 4)), HAIR)

	if not side:
		# Önden/arkadan: kollar zıt yönde sallanır, kalkan bacak 1 px kısalır
		img.fill_rect(Rect2i(b + Vector2i(3, 9 + step), Vector2i(1, 3)), SKIN)
		img.fill_rect(Rect2i(b + Vector2i(12, 9 - step), Vector2i(1, 3)), SKIN)
		_draw_leg(img, o + Vector2i(5, 0), 1 if step == 1 else 0, PANTS)
		_draw_leg(img, o + Vector2i(9, 0), 1 if step == -1 else 0, PANTS)
	else:
		# Yandan: tek kol ileri-geri, bacaklar açılır
		var fwd: int = 1 if dir == 3 else -1
		img.fill_rect(Rect2i(b + Vector2i(7 + step * fwd, 9), Vector2i(2, 3)), SKIN)
		if step == 0:
			img.fill_rect(Rect2i(o + Vector2i(6, 12), Vector2i(4, 2)), PANTS)
			img.fill_rect(Rect2i(o + Vector2i(6, 14), Vector2i(4, 1)), BOOTS)
		else:
			var front_x: int = 10 if dir == 3 else 4
			var back_x: int = 4 if dir == 3 else 10
			var near_x: int = front_x if step == 1 else back_x
			var far_x: int = back_x if step == 1 else front_x
			_draw_leg(img, o + Vector2i(far_x, 0), 0, PANTS_FAR)
			_draw_leg(img, o + Vector2i(near_x, 0), 0, PANTS)


func _draw_leg(img: Image, at: Vector2i, raise: int, color: Color) -> void:
	img.fill_rect(Rect2i(at + Vector2i(0, 12 - raise), Vector2i(2, 2)), color)
	img.fill_rect(Rect2i(at + Vector2i(0, 14 - raise), Vector2i(2, 1)), BOOTS)


# ---------------------------------------------------------------- Slimelar

const Looks = preload("res://scripts/slime_looks.gd")

# Sütun = kare: [genişlik, yükseklik, yüz]
# 0 duruş, 1 nefes, 2 çömelme, 3 uzama (havada), 4-5 korkmuş (vakumda),
# 6 çiğneme (ağız açık), 7 çiğneme (yanaklar şişik), 8 mutlu, 9-10 tok duruş
const SLIME_FRAMES: Array = [
	[12, 9, "normal"], [12, 8, "normal"], [14, 7, "squint"], [10, 12, "normal"],
	[12, 10, "scared"], [12, 10, "scared2"], [12, 9, "chomp_open"], [13, 8, "chomp_closed"],
	[11, 11, "happy"], [12, 9, "content"], [12, 8, "content"],
]
const SLIME_FACE: Color = Color("1e1e1e")
const SLIME_BLUSH: Color = Color("ffb3c6")
const SLIME_MOUTH: Color = Color("c2405a")
const EAR_PINK: Color = Color("ff9fb8")
const HORN: Color = Color("f3e3b0")
const HORN_DARK: Color = Color("8a6a3a")
const CAP: Color = Color("d8433a")
const CAP_DARK: Color = Color("7a1c18")
const SPROUT: Color = Color("4caf50")
const SPROUT_DARK: Color = Color("1f5e22")
const BEARD: Color = Color("f0e8d8")
const GOAT_HORN: Color = Color("9a948a")
const GOAT_HORN_DARK: Color = Color("4a463e")
const SNOW: Color = Color("fbfdff")
const SNOW_DARK: Color = Color("8aa8c0")
const FEATHER: Color = Color("f2c040")
const FEATHER_TIP: Color = Color("e07a2a")
const FEATHER_DARK: Color = Color("8a5a1a")
const WING: Color = Color("f4f4f4")
const WING_DARK: Color = Color("7a8a8a")
const LARGE_SCALE: float = 1.5
const ICON_SCALE_SMALL: float = 1.0
const ICON_SCALE_LARGE: float = 1.15
## Büyük slimede ikinci türün benekleri: [x oranı, y oranı, yarıçap (genişlik oranı)]
const SPOTS: Array = [[0.84, 0.42, 0.13], [0.16, 0.7, 0.12], [0.64, 0.88, 0.1], [0.42, 0.1, 0.1]]


func _make_slimes() -> Image:
	var t: int = Looks.SMALL_TILE
	var img: Image = Image.create_empty(t * SLIME_FRAMES.size(), t * Looks.type_count(), false, Image.FORMAT_RGBA8)
	for row: int in Looks.type_count():
		for col: int in SLIME_FRAMES.size():
			_draw_slime(img, Vector2i(col * t, row * t), row, -1, col, t, 1.0)
	return img


## HUD için 16x16 slime ikonları (satır = tür).
func _make_slime_icons() -> Image:
	var t: int = Looks.ICON_TILE
	var img: Image = Image.create_empty(t, t * Looks.type_count(), false, Image.FORMAT_RGBA8)
	for row: int in Looks.type_count():
		_draw_slime(img, Vector2i(0, row * t), row, -1, 9, t, ICON_SCALE_SMALL)
	return img


## Büyük slimelar: gövde ana tür, benekler ikinci tür, iki türün özellikleri.
func _make_large_slimes() -> Image:
	var t: int = Looks.LARGE_TILE
	var pairs: Array = Looks.hybrid_pairs()
	var img: Image = Image.create_empty(t * SLIME_FRAMES.size(), t * pairs.size(), false, Image.FORMAT_RGBA8)
	for row: int in pairs.size():
		for col: int in SLIME_FRAMES.size():
			_draw_slime(img, Vector2i(col * t, row * t), pairs[row][0], pairs[row][1], col, t, LARGE_SCALE)
	return img


## HUD için 16x16 büyük slime ikonları (satır = Looks.hybrid_pairs() sırası).
func _make_large_icons() -> Image:
	var t: int = Looks.ICON_TILE
	var pairs: Array = Looks.hybrid_pairs()
	var img: Image = Image.create_empty(t, t * pairs.size(), false, Image.FORMAT_RGBA8)
	for row: int in pairs.size():
		_draw_slime(img, Vector2i(0, row * t), pairs[row][0], pairs[row][1], 9, t, ICON_SCALE_LARGE)
	return img


## Bir slime karesi. row_b >= 0 ise büyük slime (row_a gövde, row_b benek).
func _draw_slime(img: Image, o: Vector2i, row_a: int, row_b: int, frame: int, t: int, k: float) -> void:
	var pal: Array = Looks.PALETTES[row_a]
	var w: int = roundi(SLIME_FRAMES[frame][0] * k)
	var h: int = roundi(SLIME_FRAMES[frame][1] * k)
	var left: int = int((t - w) / 2.0)
	var top: int = t - h
	var mid: float = left + w / 2.0
	var cy: float = top + h * 0.55
	var rx: float = w / 2.0
	var ry: float = h * 0.55
	var big: bool = k > 1.2
	var g: Dictionary = {"o": o, "t": t, "left": left, "top": top, "w": w, "h": h, "mid": mid, "big": big}

	# Özellik listesi: [özellik, sahibinin satırı]
	var feats: Array = []
	for r: int in ([row_a] if row_b < 0 else [row_a, row_b]):
		for f: String in Looks.FEATURES[r]:
			feats.append([f, r])

	# Kuyruklar gövdenin arkasında: önce çizilir
	for fe: Array in feats:
		_draw_tail(img, g, fe[0], Looks.PALETTES[fe[1]])

	# Kubbe şeklinde maske: üst yarı elips, alt kısım düz
	var mask: Array[bool] = []
	mask.resize(t * t)
	for y: int in range(top, t):
		for x: int in range(left, left + w):
			var px: float = x + 0.5 - mid
			var py: float = y + 0.5 - cy
			var inside: bool
			if py <= 0.0:
				inside = (px * px) / (rx * rx) + (py * py) / (ry * ry) <= 1.0
			else:
				inside = absf(px) <= rx - (1.0 if y == t - 1 else 0.0)
			mask[y * t + x] = inside

	for y: int in t:
		for x: int in t:
			if not mask[y * t + x]:
				continue
			var edge: bool = false
			for n: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + n.x
				var ny: int = y + n.y
				if nx < 0 or ny < 0 or nx >= t or ny >= t or not mask[ny * t + nx]:
					edge = true
			var base: Color = pal[0]
			if row_b >= 0 and not edge and _in_spot(x + 0.5, y + 0.5, g):
				base = Looks.PALETTES[row_b][0]
			var c: Color = pal[1] if edge else (base.darkened(0.18) if y >= t - 3 else base)
			img.set_pixelv(o + Vector2i(x, y), c)

	# Parlama
	for p: Vector2i in [Vector2i(left + 2, top + 2), Vector2i(left + 3, top + 2), Vector2i(left + 2, top + 3)]:
		img.set_pixelv(o + p, pal[2])

	# Kafa özellikleri: önce şapka/çizgiler (gövdeye yapışık), sonra çıkıntılar
	for name: String in ["stripes", "cap", "snow_cap", "sprout", "crest", "horns", "goat_horns", "cat_ears", "bunny_ears"]:
		for fe: Array in feats:
			if fe[0] == name:
				_draw_head_feature(img, g, name, Looks.PALETTES[fe[1]])

	# Yüz (büyük slimede gözler biraz daha aralıklı)
	var spread: int = 1 if big else 0
	var eye_y: int = top + int(h * 0.45)
	var ex1: int = int(mid) - 3 - spread
	var ex2: int = int(mid) + 2 + spread
	var m: int = int(mid)
	var face: String = SLIME_FRAMES[frame][2]
	match face:
		"scared", "scared2":
			# Kocaman beyaz gözler, titreyen göz bebekleri, "o" ağız
			var look: int = 0 if face == "scared" else -1
			for ex: int in [ex1, ex2]:
				img.fill_rect(Rect2i(o + Vector2i(ex - 1, eye_y - 1), Vector2i(3, 3)), Color.WHITE)
				img.set_pixelv(o + Vector2i(ex + look, eye_y), SLIME_FACE)
			img.fill_rect(Rect2i(o + Vector2i(m - 1, eye_y + 3), Vector2i(2, 2)), SLIME_FACE)
		"squint":
			img.set_pixelv(o + Vector2i(ex1, eye_y), SLIME_FACE)
			img.set_pixelv(o + Vector2i(ex2, eye_y), SLIME_FACE)
		"chomp_open":
			_draw_happy_eyes(img, o, ex1, ex2, eye_y)
			img.fill_rect(Rect2i(o + Vector2i(m - 1, eye_y + 2), Vector2i(3, 2)), SLIME_FACE)
			img.set_pixelv(o + Vector2i(m, eye_y + 3), SLIME_MOUTH)
		"chomp_closed":
			_draw_happy_eyes(img, o, ex1, ex2, eye_y)
			_draw_blush(img, o, ex1, ex2, eye_y)
			img.fill_rect(Rect2i(o + Vector2i(m - 1, eye_y + 2), Vector2i(2, 1)), SLIME_FACE)
		"happy":
			_draw_happy_eyes(img, o, ex1, ex2, eye_y)
			_draw_blush(img, o, ex1, ex2, eye_y)
			for p: Vector2i in [Vector2i(m - 2, eye_y + 2), Vector2i(m - 1, eye_y + 3), Vector2i(m, eye_y + 3), Vector2i(m + 1, eye_y + 2)]:
				img.set_pixelv(o + p, SLIME_FACE)
		"content":
			_draw_happy_eyes(img, o, ex1, ex2, eye_y)
			_draw_blush(img, o, ex1, ex2, eye_y)
			img.fill_rect(Rect2i(o + Vector2i(m - 1, eye_y + 2), Vector2i(2, 1)), SLIME_FACE)
		_:
			for ex: int in [ex1, ex2]:
				img.fill_rect(Rect2i(o + Vector2i(ex, eye_y), Vector2i(1, 2)), SLIME_FACE)
			img.fill_rect(Rect2i(o + Vector2i(m - 1, eye_y + 2), Vector2i(2, 1)), SLIME_FACE)

	# Sakal: ağzın altında açık renkli püskül
	for fe: Array in feats:
		if fe[0] == "beard":
			var bw: int = 3 if big else 2
			var by: int = eye_y + (5 if face.begins_with("scared") else 4)
			for yy: int in range(by, t):
				for xx: int in bw:
					var bx: int = m - 1 + xx - (1 if big else 0)
					img.set_pixelv(o + Vector2i(bx, yy), BEARD if yy - by < 2 or xx != 0 else BEARD.darkened(0.15))


func _in_spot(x: float, y: float, g: Dictionary) -> bool:
	for s: Array in SPOTS:
		var c: Vector2 = Vector2(g.left + g.w * s[0], g.top + g.h * s[1])
		if Vector2(x, y).distance_to(c) <= g.w * s[2]:
			return true
	return false


## Kare içinde sütunun en üstteki dolu pikseli (özellikler buna oturur).
func _surface_y(img: Image, g: Dictionary, x: int) -> int:
	for y: int in g.t:
		if x < 0 or x >= g.t:
			break
		if img.get_pixelv(g.o + Vector2i(x, y)).a > 0.0:
			return y
	return g.top


## Dolgu pikselleri + çevresine (boş yerlere) kontur. Kare dışına taşanı kırpar.
func _shape(img: Image, g: Dictionary, pts: Array, fill: Color, outline: Color, accents: Dictionary = {}) -> void:
	var pset: Dictionary = {}
	for p: Vector2i in pts:
		pset[p] = true
	for p: Vector2i in pts:
		if p.x >= 0 and p.y >= 0 and p.x < g.t and p.y < g.t:
			img.set_pixelv(g.o + p, accents.get(p, fill))
	for p: Vector2i in pts:
		for n: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + n
			if pset.has(q) or q.x < 0 or q.y < 0 or q.x >= g.t or q.y >= g.t:
				continue
			if img.get_pixelv(g.o + q).a == 0.0:
				img.set_pixelv(g.o + q, outline)


func _draw_tail(img: Image, g: Dictionary, feature: String, pal: Array) -> void:
	var big: bool = g.big
	var bottom: int = g.t - 3
	match feature:
		"cat_tail":
			# Sağdan çıkıp yukarı kıvrılan kuyruk, ucu koyu
			var r: int = g.left + g.w - 1
			var rel: Array = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, -1), Vector2i(3, -2), Vector2i(3, -3), Vector2i(2, -4)]
			if big:
				rel = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, -1), Vector2i(4, -2),
						Vector2i(4, -3), Vector2i(4, -4), Vector2i(3, -5), Vector2i(1, -1), Vector2i(2, -1)]
			var pts: Array = []
			for p: Vector2i in rel:
				pts.append(Vector2i(r, bottom) + p)
			_shape(img, g, pts, pal[0], pal[1], {pts[5 if not big else 7]: pal[1].lightened(0.25)})
		"bunny_tail":
			# Solda yuvarlak pamuk kuyruk
			var c: Vector2i = Vector2i(g.left, bottom - 1)
			var pts: Array = [c, c + Vector2i(-1, 0), c + Vector2i(-1, 1), c + Vector2i(0, 1)]
			if big:
				pts.append_array([c + Vector2i(-2, 0), c + Vector2i(-2, 1), c + Vector2i(-1, -1), c + Vector2i(0, -1)])
			_shape(img, g, pts, Color.WHITE, pal[1])
		"dragon_tail":
			# Solda sivri, dikenli kuyruk
			var l: int = g.left
			var rel: Array = [Vector2i(-1, 0), Vector2i(-2, 0), Vector2i(-3, -1), Vector2i(-4, -2)]
			if big:
				rel = [Vector2i(-1, 0), Vector2i(-2, 0), Vector2i(-3, 0), Vector2i(-1, 1), Vector2i(-2, 1),
						Vector2i(-4, -1), Vector2i(-5, -2), Vector2i(-6, -3)]
			var pts: Array = []
			for p: Vector2i in rel:
				pts.append(Vector2i(l, bottom) + p)
			_shape(img, g, pts, pal[0], pal[1])
			# Diken
			var spike: Vector2i = Vector2i(l - (3 if big else 2), bottom - (2 if big else 1))
			_shape(img, g, [spike], HORN, HORN_DARK)
		"wings":
			# Yanlarda küçük beyaz kanatlar
			var wy: int = g.top + int(g.h * 0.5)
			var rel: Array = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(2, -1), Vector2i(2, -2), Vector2i(0, 1)]
			if big:
				rel.append_array([Vector2i(3, -2), Vector2i(3, -3), Vector2i(1, 1), Vector2i(2, 0)])
			for side: int in [-1, 1]:
				var ax: int = g.left + g.w if side > 0 else g.left - 1
				var pts: Array = []
				for p: Vector2i in rel:
					pts.append(Vector2i(ax + p.x * side, wy + p.y))
				_shape(img, g, pts, WING, WING_DARK)


func _draw_head_feature(img: Image, g: Dictionary, feature: String, pal: Array) -> void:
	var big: bool = g.big
	var mid: float = g.mid
	match feature:
		"stripes":
			# Alnında üç kısa koyu çizgi (tekir deseni)
			var c: Color = pal[1].lightened(0.15)
			var n_len: int = 2 if not big else 3
			for dx: int in ([-2, 0, 2] if not big else [-3, 0, 3]):
				var x: int = int(mid) + dx
				var sy: int = _surface_y(img, g, x)
				for i: int in n_len:
					img.set_pixelv(g.o + Vector2i(x, sy + 1 + i), c)
		"cap":
			# Kırmızı, beyaz benekli mantar şapka; gövdenin üstünü örter
			var cap_h: int = roundi(g.h * 0.28)
			var base_y: int = g.top + cap_h
			var crx: float = g.w / 2.0 + 1.0
			var cry: float = cap_h + 2.0
			var pts: Array = []
			for y: int in range(g.top - 3, base_y):
				for x: int in range(g.left - 2, g.left + g.w + 2):
					var px: float = (x + 0.5 - mid) / crx
					var py: float = (y + 0.5 - base_y) / cry
					if px * px + py * py <= 1.0:
						pts.append(Vector2i(x, y))
			var dots: Dictionary = {}
			for d: Vector2 in [Vector2(-0.45, -0.55), Vector2(0.3, -0.75), Vector2(0.62, -0.3), Vector2(-0.05, -0.25)]:
				var p: Vector2i = Vector2i(int(mid + d.x * crx), int(base_y + d.y * cry))
				dots[p] = Color.WHITE
				if big:
					dots[p + Vector2i(1, 0)] = Color.WHITE
			# Alt kenar koyu (şapka gölgesi)
			for p: Vector2i in pts:
				if p.y == base_y - 1 and not dots.has(p):
					dots[p] = CAP.darkened(0.25)
			_shape(img, g, pts, CAP, CAP_DARK, dots)
		"snow_cap":
			# Kubbeye oturan kabarık kar örtüsü, altında buz damlaları
			var cap_h: int = roundi(g.h * 0.22)
			var base_y: int = g.top + cap_h
			var crx: float = g.w / 2.0 - 0.5
			var cry: float = cap_h + 1.5
			var pts: Array = []
			for y: int in range(g.top - 2, base_y + 1):
				for x: int in range(g.left - 1, g.left + g.w + 1):
					var px: float = (x + 0.5 - mid) / crx
					var py: float = (y + 0.5 - base_y) / cry
					if px * px + py * py <= 1.0 and (y < base_y or (x + y) % 3 != 0):
						pts.append(Vector2i(x, y))
			var acc: Dictionary = {}
			for p: Vector2i in pts:
				if p.y == base_y:
					acc[p] = Color("d8ecf8")
			_shape(img, g, pts, SNOW, SNOW_DARK, acc)
		"crest":
			# Tepede üç tüylü ibik
			var x: int = int(mid) - (0 if g.w % 2 == 1 else 1)
			var sy: int = _surface_y(img, g, x)
			var n: int = 3 if not big else 4
			var pts: Array = []
			var acc: Dictionary = {}
			for i: int in n:
				pts.append(Vector2i(x, sy - 1 - i))
				pts.append(Vector2i(x - 1 - i / 2, sy - 1 - i + (1 if i > 0 else 0)))
				pts.append(Vector2i(x + 1 + i / 2, sy - 1 - i + (1 if i > 0 else 0)))
			acc[Vector2i(x, sy - n)] = FEATHER_TIP
			acc[Vector2i(x - 1 - (n - 1) / 2, sy - n + 1)] = FEATHER_TIP
			acc[Vector2i(x + 1 + (n - 1) / 2, sy - n + 1)] = FEATHER_TIP
			_shape(img, g, pts, FEATHER, FEATHER_DARK, acc)
		"goat_horns":
			# Yanlarda dışa ve aşağı kıvrılan koç boynuzları
			for side: int in [-1, 1]:
				var x: int = _side_x(g, 0.3, side)
				var sy: int = _surface_y(img, g, x)
				var rel: Array = [Vector2i(0, -1), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -1), Vector2i(3, 0)]
				if big:
					rel = [Vector2i(0, -1), Vector2i(0, -2), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -2),
							Vector2i(4, -1), Vector2i(4, 0), Vector2i(3, 1), Vector2i(1, -2)]
				var pts: Array = []
				var acc: Dictionary = {}
				for i: int in rel.size():
					var p: Vector2i = Vector2i(x + rel[i].x * side, sy + rel[i].y)
					pts.append(p)
					if i % 2 == 1:
						acc[p] = GOAT_HORN.darkened(0.2)
				_shape(img, g, pts, GOAT_HORN, GOAT_HORN_DARK, acc)
		"sprout":
			# Ortada sap ve iki yaprak
			var x: int = int(mid)
			var sy: int = _surface_y(img, g, x)
			var stem: int = 2 if not big else 3
			var pts: Array = []
			for i: int in stem:
				pts.append(Vector2i(x, sy - 1 - i))
			var ty: int = sy - stem
			pts.append_array([Vector2i(x - 1, ty), Vector2i(x - 2, ty - 1), Vector2i(x + 1, ty - 1), Vector2i(x + 2, ty - 2)])
			if big:
				pts.append_array([Vector2i(x - 3, ty - 1), Vector2i(x - 2, ty - 2), Vector2i(x + 3, ty - 2), Vector2i(x + 2, ty - 3)])
			_shape(img, g, pts, SPROUT, SPROUT_DARK, {Vector2i(x, sy - 1): SPROUT_DARK.lightened(0.2)})
		"horns":
			for side: int in [-1, 1]:
				var x: int = _side_x(g, 0.24, side)
				var sy: int = _surface_y(img, g, x)
				var pts: Array = [Vector2i(x, sy - 1), Vector2i(x + side, sy - 2)]
				if big:
					pts = [Vector2i(x, sy - 1), Vector2i(x + side, sy - 1), Vector2i(x + side, sy - 2), Vector2i(x + 2 * side, sy - 3)]
				_shape(img, g, pts, HORN, HORN_DARK)
		"cat_ears":
			# Dışa bakan üçgen kulaklar, içi pembe
			for side: int in [-1, 1]:
				var x: int = _side_x(g, 0.33, side)
				var sy: int = _surface_y(img, g, x)
				var rows: Array = [[-1, 0, 1], [0, 1], [1]]
				if big:
					rows = [[-1, 0, 1, 2], [0, 1, 2], [1, 2], [2]]
				var pts: Array = []
				for i: int in rows.size():
					for d: int in rows[i]:
						pts.append(Vector2i(x + d * side, sy - 1 - i))
				var inner: Dictionary = {Vector2i(x, sy - 1): EAR_PINK}
				if big:
					inner[Vector2i(x + side, sy - 1)] = EAR_PINK
					inner[Vector2i(x + side, sy - 2)] = EAR_PINK
				_shape(img, g, pts, pal[0], pal[1], inner)
		"bunny_ears":
			# Uzun, uçları dışa yatık kulaklar, ortası pembe
			for side: int in [-1, 1]:
				var x: int = _side_x(g, 0.13, side)
				var sy: int = _surface_y(img, g, x)
				var height: int = 5 if not big else 7
				var width: int = 2 if not big else 3
				var pts: Array = []
				var inner: Dictionary = {}
				for i: int in height:
					var shift: int = side if i >= height - 2 else 0
					for j: int in width:
						var px: int = x + j * side + shift
						pts.append(Vector2i(px, sy - 1 - i))
						if j == (0 if not big else 1) and i >= 1 and i < height - 1:
							inner[Vector2i(px, sy - 1 - i)] = EAR_PINK
				_shape(img, g, pts, pal[0], pal[1], inner)


## Gövde ortasından oranla sağa/sola simetrik sütun.
func _side_x(g: Dictionary, ratio: float, side: int) -> int:
	var right: int = roundi(g.mid + g.w * ratio)
	return right if side > 0 else g.left * 2 + g.w - 1 - right


## "^ ^" şeklinde kapalı mutlu gözler.
func _draw_happy_eyes(img: Image, o: Vector2i, ex1: int, ex2: int, eye_y: int) -> void:
	for ex: int in [ex1, ex2]:
		img.set_pixelv(o + Vector2i(ex - 1, eye_y + 1), SLIME_FACE)
		img.set_pixelv(o + Vector2i(ex, eye_y), SLIME_FACE)
		img.set_pixelv(o + Vector2i(ex + 1, eye_y + 1), SLIME_FACE)


func _draw_blush(img: Image, o: Vector2i, ex1: int, ex2: int, eye_y: int) -> void:
	img.set_pixelv(o + Vector2i(ex1 - 1, eye_y + 2), SLIME_BLUSH)
	img.set_pixelv(o + Vector2i(ex2 + 1, eye_y + 2), SLIME_BLUSH)


# ---------------------------------------------------------------- Eşyalar

# Satır: 0 elma, 1 kırmızı gem, 2 mavi gem, 3 gri gem. Sütun: 0 normal, 1 parıltı
const GEM_PALETTES: Array = [
	[Color("e8364f"), Color("7a1426"), Color("ffa3b1")],
	[Color("3f9cf5"), Color("173f7a"), Color("b8e4ff")],
	[Color("b4b6c8"), Color("4f5163"), Color("ffffff")],
	[Color("f06aaf"), Color("7a1f52"), Color("ffc8e6")],
	[Color("f5a623"), Color("8a5200"), Color("ffe0a0")],  # kedi (kehribar)
	[Color("efe6d2"), Color("8a7a5a"), Color("ffffff")],  # tavşan (inci)
	[Color("c0703a"), Color("5e2e10"), Color("f2c49a")],  # mantar (bakır)
	[Color("9b59e0"), Color("4a2077"), Color("dcc0ff")],  # ejder (ametist)
	[Color("5cc84a"), Color("1f6a1a"), Color("c8f5b0")],  # yaprak (zümrüt)
	[Color("a8865a"), Color("4e3a20"), Color("e8d0a8")],  # keçi (topaz)
	[Color("a8e4ff"), Color("3a7aa8"), Color("ffffff")],  # kar (buz)
	[Color("2fc4b0"), Color("0e5a50"), Color("b0fff0")],  # tüy (turkuaz)
]


# Sütun: 0 normal, 1 parıltı, 2 toprağa gömülü (sadece havuçta)
# Satır: 0 elma, 1-4 gemler, 5 havuç
const CARROT_ROW: int = 5
## Satır 6-13: yeni türlerin gemleri (havuçtan sonra; GEM_PALETTES[4..])
const ITEM_ROWS: int = 18
## Yeni yiyecekler (satır): 14 yıldız meyvesi, 15 ay üzümü, 16 pancar, 17 buz turpu
const STAR_ROW: int = 14
const GRAPE_ROW: int = 15
const BEET_ROW: int = 16
const RADISH_ROW: int = 17


func _gem_row(g: int) -> int:
	return g + 1 if g < 4 else g + 2


func _make_items() -> Image:
	var img: Image = Image.create_empty(TILE * 3, TILE * ITEM_ROWS, false, Image.FORMAT_RGBA8)
	for col: int in 2:
		_draw_apple(img, Vector2i(col * TILE, 0), col == 1)
		for g: int in GEM_PALETTES.size():
			_draw_gem(img, Vector2i(col * TILE, _gem_row(g) * TILE), GEM_PALETTES[g], col == 1)
		_draw_carrot(img, Vector2i(col * TILE, CARROT_ROW * TILE), col == 1)
	_draw_planted_carrot(img, Vector2i(2 * TILE, CARROT_ROW * TILE))
	for col: int in 2:
		var shine: bool = col == 1
		_draw_star_fruit(img, Vector2i(col * TILE, STAR_ROW * TILE), shine)
		_draw_moon_grape(img, Vector2i(col * TILE, GRAPE_ROW * TILE), shine)
		_draw_root(img, Vector2i(col * TILE, BEET_ROW * TILE), BEET_PAL, shine, false)
		_draw_root(img, Vector2i(col * TILE, RADISH_ROW * TILE), RADISH_PAL, shine, false)
	_draw_root(img, Vector2i(2 * TILE, BEET_ROW * TILE), BEET_PAL, false, true)
	_draw_root(img, Vector2i(2 * TILE, RADISH_ROW * TILE), RADISH_PAL, false, true)
	return img


## Kök sebze paleti: [gövde, kontur, parlak, yaprak, koyu yaprak, sap, uzunluk]
const BEET_PAL: Array = [Color("a01e5a"), Color("4e0a2a"), Color("d85a96"), Color("4caf50"), Color("2e7d32"), Color("c0306a"), 3.8]
const RADISH_PAL: Array = [Color("bfe8ff"), Color("3a7aa8"), Color("ffffff"), Color("5ac8b0"), Color("2a7a6a"), Color("8adcd0"), 4.8]


## Kök sebze (pancar / buz turpu). planted: sadece tepesi ve yaprakları görünür.
func _draw_root(img: Image, o: Vector2i, pal: Array, shine: bool, planted: bool) -> void:
	var g: Dictionary = {"o": o, "t": TILE}
	var ry: float = pal[6]
	var center: Vector2 = Vector2(8, 13.5) if planted else Vector2(8, 15.0 - ry - 1.5)
	var pts: Array = []
	for pt: Vector2i in _ellipse_pts(center, Vector2(3.6, ry)):
		if planted and pt.y > 12:
			continue
		pts.append(pt)
	var acc: Dictionary = {}
	if not planted:
		# Sivri kuyruk
		var tail: Vector2i = Vector2i(8, int(center.y + ry) + 1)
		pts.append(tail)
		acc[tail] = pal[1]
	for pt: Vector2i in pts:
		if pt.x <= 6 and pt.y <= center.y - 1:
			acc[pt] = pal[2]
		elif pt.y >= center.y + ry * 0.4:
			acc[pt] = pal[0].darkened(0.15)
	_shape(img, g, pts, pal[0], pal[1], acc)
	if planted:
		img.fill_rect(Rect2i(o + Vector2i(4, 13), Vector2i(9, 1)), Color("5e3920"))
	# Yapraklar
	var top: int = int(center.y - ry) - 1
	for lp: Vector2i in [Vector2i(7, 0), Vector2i(6, -1), Vector2i(5, -2), Vector2i(9, 0), Vector2i(10, -1),
			Vector2i(11, -2), Vector2i(8, -1), Vector2i(8, -2), Vector2i(8, -3), Vector2i(4, -3), Vector2i(12, -3)]:
		img.set_pixelv(o + Vector2i(lp.x, top + lp.y), pal[3])
	for lp: Vector2i in [Vector2i(8, 0), Vector2i(7, -1), Vector2i(9, -1)]:
		img.set_pixelv(o + Vector2i(lp.x, top + lp.y), pal[5])
	img.set_pixelv(o + Vector2i(5, top - 1), pal[4])
	img.set_pixelv(o + Vector2i(11, top - 1), pal[4])
	if shine:
		img.set_pixelv(o + Vector2i(6, int(center.y) - 1), Color.WHITE)


## Yıldız meyvesi: beş köşeli sarı yıldız.
func _draw_star_fruit(img: Image, o: Vector2i, shine: bool) -> void:
	var g: Dictionary = {"o": o, "t": TILE}
	var c: Vector2 = Vector2(8, 9.5)
	var poly: PackedVector2Array = PackedVector2Array()
	for i: int in 10:
		var radius: float = 6.2 if i % 2 == 0 else 2.8
		poly.append(c + Vector2.from_angle(-PI / 2.0 + i * PI / 5.0) * radius)
	var pts: Array = []
	var acc: Dictionary = {}
	for y: int in TILE:
		for x: int in TILE:
			var p: Vector2 = Vector2(x + 0.5, y + 0.5)
			if Geometry2D.is_point_in_polygon(p, poly):
				var pt: Vector2i = Vector2i(x, y)
				pts.append(pt)
				if p.y > c.y + 1.5:
					acc[pt] = Color("e0b020")
				elif p.distance_to(c + Vector2(-1.5, -1.5)) < 1.6:
					acc[pt] = Color("fff3a0")
	_shape(img, g, pts, Color("f5d442"), Color("8a6a10"), acc)
	img.set_pixelv(o + Vector2i(8, 2), Color("6e4524"))
	if shine:
		img.set_pixelv(o + Vector2i(6, 8), Color.WHITE)


## Ay üzümü: soluk mor, parlayan üzüm salkımı.
func _draw_moon_grape(img: Image, o: Vector2i, shine: bool) -> void:
	var g: Dictionary = {"o": o, "t": TILE}
	var pts: Array = []
	var acc: Dictionary = {}
	for gc: Vector2 in [Vector2(6, 7), Vector2(10, 7), Vector2(8, 9.5), Vector2(5, 10), Vector2(11, 10), Vector2(8, 12.5)]:
		for pt: Vector2i in _ellipse_pts(gc, Vector2(2.1, 2.1)):
			if not pts.has(pt):
				pts.append(pt)
		acc[Vector2i(int(gc.x) - 1, int(gc.y) - 1)] = Color("f4f0ff")
	_shape(img, g, pts, Color("b0a0ee"), Color("3e2e80"), acc)
	img.fill_rect(Rect2i(o + Vector2i(8, 2), Vector2i(1, 3)), Color("6e4524"))
	for lp: Vector2i in [Vector2i(9, 3), Vector2i(10, 2), Vector2i(11, 2), Vector2i(10, 3)]:
		img.set_pixelv(o + lp, Color("4caf50"))
	if shine:
		img.set_pixelv(o + Vector2i(7, 9), Color.WHITE)
		img.set_pixelv(o + Vector2i(12, 5), Color(1, 1, 1, 0.7))


## Ay üzümü asması: iki direk + kiriş, koyu yapraklar.
func _make_grape_vine() -> Image:
	var img: Image = Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	var wood: Color = Color("8a5a30")
	var wood_dark: Color = Color("3a2516")
	for x: int in [5, 25]:
		img.fill_rect(Rect2i(x - 1, 8, 4, 24), wood_dark)
		img.fill_rect(Rect2i(x, 8, 2, 23), wood)
	img.fill_rect(Rect2i(3, 7, 26, 4), wood_dark)
	img.fill_rect(Rect2i(4, 8, 24, 2), wood)
	var leaf: Color = Color("3a7a5a")
	var dark: Color = Color("1f4a36")
	_blob(img, Vector2(9, 11), Vector2(7, 5), leaf, dark)
	_blob(img, Vector2(22, 11), Vector2(7, 5), leaf, dark)
	_blob(img, Vector2(16, 8), Vector2(8, 5), Color("4a8a6a"), dark)
	for p: Vector2i in [Vector2i(12, 5), Vector2i(13, 5), Vector2i(19, 6), Vector2i(6, 9)]:
		img.set_pixelv(p, Color("7cc192"))
	return img


## Kaya tavuğu yuvası: taş halka, içinde saman ve benekli yumurtalar.
func _make_rock_nest() -> Image:
	var img: Image = Image.create_empty(24, 14, false, Image.FORMAT_RGBA8)
	_blob(img, Vector2(12, 8), Vector2(10, 4.5), Color("b09858"), Color("6e5020"))
	for sc: Vector2 in [Vector2(3, 8), Vector2(6, 11.5), Vector2(12, 12.5), Vector2(18, 11.5), Vector2(21, 8),
			Vector2(17, 4.5), Vector2(7, 4.5), Vector2(12, 3.5)]:
		_blob(img, sc, Vector2(2.6, 2.1), Color("8a8478"), Color("4a463e"))
		img.set_pixelv(Vector2i(int(sc.x) - 1, int(sc.y) - 1), Color("b8b2a6"))
	for e: Vector2i in [Vector2i(9, 6), Vector2i(13, 7)]:
		img.fill_rect(Rect2i(e, Vector2i(3, 3)), Color("d8d0c0"))
		img.set_pixelv(e + Vector2i(1, 1), Color("7a7064"))
		img.set_pixelv(e, Color("f0ead8"))
	return img


const CARROT_ORANGE: Color = Color("f08a24")
const CARROT_DARK: Color = Color("a8531a")
const CARROT_LIGHT: Color = Color("ffc07a")
const LEAF: Color = Color("4caf50")
const LEAF_DARK: Color = Color("2e7d32")


## Yerde yatan havuç: sağ üstten sol alta çapraz, ucu sivri; tepede yapraklar.
func _draw_carrot(img: Image, o: Vector2i, shine: bool) -> void:
	# Gövde: kalından inceye çapraz şeritler
	var body: Array = [[10, 5, 3], [9, 6, 3], [8, 7, 3], [7, 8, 3], [6, 9, 2], [5, 10, 2], [4, 11, 2], [3, 12, 1]]
	for b: Array in body:
		var x: int = b[0]
		var y: int = b[1]
		var w: int = b[2]
		img.set_pixelv(o + Vector2i(x - 1, y), CARROT_DARK)
		for i: int in w:
			img.set_pixelv(o + Vector2i(x + i, y), CARROT_ORANGE)
		img.set_pixelv(o + Vector2i(x + w, y), CARROT_DARK)
	img.set_pixelv(o + Vector2i(3, 13), CARROT_DARK)
	# Halka çizgileri
	img.set_pixelv(o + Vector2i(9, 7), CARROT_DARK)
	img.set_pixelv(o + Vector2i(7, 9), CARROT_DARK)
	img.set_pixelv(o + Vector2i(10, 6), CARROT_LIGHT)
	# Yapraklar
	for p: Vector2i in [Vector2i(12, 4), Vector2i(13, 3), Vector2i(14, 2), Vector2i(12, 2), Vector2i(12, 1), Vector2i(14, 4), Vector2i(13, 5)]:
		img.set_pixelv(o + p, LEAF)
	img.set_pixelv(o + Vector2i(13, 4), LEAF_DARK)
	if shine:
		img.set_pixelv(o + Vector2i(11, 5), Color.WHITE)


## Toprağa gömülü havuç: sadece turuncu tepe ve yapraklar görünür.
func _draw_planted_carrot(img: Image, o: Vector2i) -> void:
	img.fill_rect(Rect2i(o + Vector2i(6, 11), Vector2i(4, 3)), CARROT_DARK)
	img.fill_rect(Rect2i(o + Vector2i(7, 11), Vector2i(2, 2)), CARROT_ORANGE)
	img.set_pixelv(o + Vector2i(7, 11), CARROT_LIGHT)
	for p: Vector2i in [Vector2i(7, 10), Vector2i(8, 10), Vector2i(6, 9), Vector2i(9, 9), Vector2i(5, 8),
			Vector2i(10, 8), Vector2i(7, 8), Vector2i(8, 7), Vector2i(7, 6), Vector2i(10, 7), Vector2i(5, 7)]:
		img.set_pixelv(o + p, LEAF)
	img.set_pixelv(o + Vector2i(8, 9), LEAF_DARK)
	img.set_pixelv(o + Vector2i(7, 9), LEAF_DARK)


# ---------------------------------------------------------------- Tavuklar

## chickens.png: 16x16, satır 0 tavuk, 1 horoz, 2 civciv, 3 kaya tavuğu, 4 kaya civcivi; sütun 0 duruş,
## 1-2 yürüme, 3 gagalama, 4-5 kanat çırpma (vakumda / uçarken). Sağa bakar.
const CHICKEN_FRAMES: int = 6
const CHICK_OUTLINE: Color = Color("4a3a2a")


func _make_chickens() -> Image:
	var img: Image = Image.create_empty(TILE * CHICKEN_FRAMES, TILE * 5, false, Image.FORMAT_RGBA8)
	for kind: int in 5:
		for f: int in CHICKEN_FRAMES:
			_draw_chicken(img, Vector2i(f * TILE, kind * TILE), kind, f)
	return img


func _ellipse_pts(c: Vector2, r: Vector2) -> Array:
	var pts: Array = []
	for y: int in range(int(c.y - r.y) - 1, int(c.y + r.y) + 2):
		for x: int in range(int(c.x - r.x) - 1, int(c.x + r.x) + 2):
			var d: Vector2 = (Vector2(x + 0.5, y + 0.5) - c) / r
			if d.length_squared() <= 1.0:
				pts.append(Vector2i(x, y))
	return pts


func _draw_chicken(img: Image, o: Vector2i, kind: int, frame: int) -> void:
	var g: Dictionary = {"o": o, "t": TILE}
	var chick: bool = kind == 2 or kind == 4
	var body_c: Color = [Color("f4f0e8"), Color("c8642a"), Color("f5d84a"), Color("8a8478"), Color("b8b2a6")][kind]
	var shade: Color = [Color("d4ccc0"), Color("9a4a1e"), Color("d8b830"), Color("5e5a50"), Color("8a8478")][kind]
	var peck: bool = frame == 3
	var flap: bool = frame >= 4
	var bob: int = 1 if frame == 2 else 0
	var pts: Array = []
	var acc: Dictionary = {}
	var head: Vector2
	if chick:
		pts.append_array(_ellipse_pts(Vector2(7.5, 11.5 + bob), Vector2(3.6, 3.0)))
		head = Vector2(10.5, 11.0) if peck else Vector2(10.0, 8.5 + bob)
		pts.append_array(_ellipse_pts(head, Vector2(2.2, 2.2)))
	else:
		pts.append_array(_ellipse_pts(Vector2(7.0, 10.5 + bob), Vector2(4.6, 3.4)))
		head = Vector2(12.0, 10.0) if peck else Vector2(11.0, 6.0 + bob)
		pts.append_array(_ellipse_pts(head, Vector2(2.2, 2.3)))
		# Boyun
		for i: int in 4:
			var q: Vector2 = Vector2(9.5, 9.0 + bob).lerp(head, i / 3.0)
			pts.append(Vector2i(int(q.x), int(q.y)))
			pts.append(Vector2i(int(q.x) - 1, int(q.y)))
		# Kuyruk
		var tail: Array = [Vector2i(2, 8), Vector2i(2, 9), Vector2i(3, 8), Vector2i(1, 7)]
		if kind == 1:
			tail = [Vector2i(2, 8), Vector2i(2, 9), Vector2i(3, 8), Vector2i(1, 7), Vector2i(1, 6), Vector2i(0, 5),
					Vector2i(2, 6), Vector2i(2, 5), Vector2i(1, 4), Vector2i(3, 7)]
			for tp: Vector2i in tail:
				acc[tp + Vector2i(0, bob)] = Color("2f5a3a") if tp.y < 7 else Color("3f7a4a")
		for tp: Vector2i in tail:
			pts.append(tp + Vector2i(0, bob))
	# Kanat
	if flap:
		var up: bool = frame == 4
		for wp: Vector2i in ([Vector2i(5, 6), Vector2i(6, 6), Vector2i(4, 5), Vector2i(5, 5), Vector2i(3, 4), Vector2i(4, 4)] if up 				else [Vector2i(5, 11), Vector2i(6, 11), Vector2i(4, 12), Vector2i(5, 12), Vector2i(3, 13)]):
			var wpp: Vector2i = wp + (Vector2i(1, 2) if chick else Vector2i.ZERO)
			if not pts.has(wpp):
				pts.append(wpp)
			acc[wpp] = shade
	else:
		for wp: Vector2i in ([Vector2i(6, 11), Vector2i(7, 11), Vector2i(8, 12)] if chick else [Vector2i(5, 10), Vector2i(6, 10), Vector2i(7, 10), Vector2i(6, 11), Vector2i(7, 11), Vector2i(8, 11)]):
			acc[wp + Vector2i(0, bob)] = shade
	# Kaya tavuğu: taş benekleri
	if kind >= 3:
		for sp: Vector2i in [Vector2i(5, 9), Vector2i(8, 12), Vector2i(3, 11), Vector2i(9, 9), Vector2i(6, 13), Vector2i(11, 5)]:
			var spp: Vector2i = sp + Vector2i(0, bob) + (Vector2i(1, 1) if chick else Vector2i.ZERO)
			if pts.has(spp):
				acc[spp] = Color("4a463e") if (sp.x + sp.y) % 2 == 0 else Color("c8c2b6")
	# Bacaklar (gövdeden önce, kontur almasınlar diye sonra çizilir)
	_shape(img, g, pts, body_c, CHICK_OUTLINE, acc)
	var leg: Color = Color("e8902a")
	var lx: Array = [6, 8]
	if frame == 1:
		lx = [5, 9]
	var ly: int = 15
	for x: int in lx:
		if img.get_pixel(o.x + x, o.y + ly - 1).a == 0.0:
			img.set_pixel(o.x + x, o.y + ly - 1, leg)
		img.set_pixel(o.x + x, o.y + ly, leg)
	img.set_pixel(o.x + lx[1] + 1, o.y + ly, leg)
	# Göz, gaga, ibik
	var hx: int = int(head.x)
	var hy: int = int(head.y)
	img.set_pixel(o.x + hx + 1, o.y + hy - (0 if chick else 1), Color("1e1e1e"))
	var beak: Color = Color("f0a020")
	img.set_pixel(o.x + hx + 3, o.y + hy, beak)
	if not chick:
		img.set_pixel(o.x + hx + 3, o.y + hy - 1, beak)
		img.set_pixel(o.x + hx + 4, o.y + hy, beak)
		var comb: Color = Color("e07a2a") if kind == 3 else Color("e03a3a")
		var comb_pts: Array = [Vector2i(0, -3), Vector2i(1, -3)]
		if kind == 1:
			comb_pts = [Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(0, -4), Vector2i(-1, -4), Vector2i(1, -4), Vector2i(2, -3)]
		for cp: Vector2i in comb_pts:
			img.set_pixel(o.x + hx + cp.x, o.y + hy + cp.y, comb)
		img.set_pixel(o.x + hx + 2, o.y + hy + 2, comb)  # sakal (gıdık)


## Tavuk yuvası: saman kase, içinde iki yumurta.
func _make_nest() -> Image:
	var img: Image = Image.create_empty(24, 14, false, Image.FORMAT_RGBA8)
	_blob(img, Vector2(12, 8), Vector2(11.5, 5.5), Color("c8a050"), Color("6e5020"))
	_blob(img, Vector2(12, 7), Vector2(8, 3), Color("8a6a30"), Color("8a6a30"))
	var straw: Color = Color("e8c870")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9
	for i: int in 26:
		var p: Vector2i = Vector2i(rng.randi_range(2, 21), rng.randi_range(4, 12))
		if img.get_pixelv(p) == Color("c8a050"):
			img.set_pixelv(p, straw if i % 2 == 0 else Color("a8823a"))
	for e: Vector2i in [Vector2i(9, 5), Vector2i(13, 6)]:
		img.fill_rect(Rect2i(e, Vector2i(3, 3)), Color("f6efe0"))
		img.set_pixelv(e, Color("fffaf0"))
		img.set_pixelv(e + Vector2i(2, 2), Color("d8cbb0"))
	return img


## Havuç yetişen toprak yığını.
func _make_dirt_mound() -> Image:
	var img: Image = Image.create_empty(28, 14, false, Image.FORMAT_RGBA8)
	_blob(img, Vector2(14, 9), Vector2(13.5, 5.5), Color("7a4e2a"), Color("3a2516"))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	for i: int in 22:
		var p: Vector2i = Vector2i(rng.randi_range(3, 24), rng.randi_range(5, 12))
		if img.get_pixelv(p) == Color("7a4e2a"):
			img.set_pixelv(p, Color("5e3920") if i % 2 == 0 else Color("9a6a3a"))
	for x: int in range(4, 24):
		if img.get_pixel(x, 12) == Color("7a4e2a"):
			img.set_pixel(x, 12, Color("5e3920"))
	return img


func _draw_apple(img: Image, o: Vector2i, shine: bool) -> void:
	var base: Color = Color("e53935")
	var outline: Color = Color("7f1d1d")
	var cx: float = 8.0
	var cy: float = 9.5
	for y: int in range(5, 15):
		for x: int in range(2, 14):
			var px: float = (x + 0.5 - cx) / 4.6
			var py: float = (y + 0.5 - cy) / 4.2
			if px * px + py * py > 1.0:
				continue
			var px2: float = (x + 1.5 - cx) / 4.6
			var px0: float = (x - 0.5 - cx) / 4.6
			var py2: float = (y + 1.5 - cy) / 4.2
			var py0: float = (y - 0.5 - cy) / 4.2
			var edge: bool = px2 * px2 + py * py > 1.0 or px0 * px0 + py * py > 1.0 \
					or px * px + py2 * py2 > 1.0 or px * px + py0 * py0 > 1.0
			img.set_pixelv(o + Vector2i(x, y), outline if edge else (base.darkened(0.2) if y >= 12 else base))
	# Üstteki çukur, sap, yaprak, parlama
	img.set_pixelv(o + Vector2i(8, 5), outline)
	img.fill_rect(Rect2i(o + Vector2i(8, 3), Vector2i(1, 3)), Color("5d3a1a"))
	img.fill_rect(Rect2i(o + Vector2i(9, 3), Vector2i(2, 1)), Color("4caf50"))
	img.set_pixelv(o + Vector2i(10, 2), Color("4caf50"))
	img.set_pixelv(o + Vector2i(5, 7), Color("ffb4a8"))
	img.set_pixelv(o + Vector2i(5, 8), Color("ffb4a8"))
	if shine:
		img.set_pixelv(o + Vector2i(6, 7), Color.WHITE)


func _draw_gem(img: Image, o: Vector2i, pal: Array, sparkle: bool) -> void:
	# Satır satır elmas profili: [y, başlangıç x, genişlik]
	var rows: Array = [[5, 6, 4], [6, 5, 6], [7, 4, 8], [8, 5, 6], [9, 6, 4], [10, 7, 2]]
	for r: Array in rows:
		img.fill_rect(Rect2i(o + Vector2i(r[1], r[0]), Vector2i(r[2], 1)), pal[1])
	# İç dolgu (kontur hariç), üst yüzey açık renk
	var inner: Array = [[5, 7, 2], [6, 6, 4], [7, 5, 6], [8, 6, 4], [9, 7, 2]]
	for r: Array in inner:
		var c: Color = pal[0].lightened(0.25) if r[0] <= 6 else pal[0]
		img.fill_rect(Rect2i(o + Vector2i(r[1], r[0]), Vector2i(r[2], 1)), c)
	img.set_pixelv(o + Vector2i(7, 6), pal[2])
	img.set_pixelv(o + Vector2i(6, 7), pal[2])
	if sparkle:
		var w: Color = Color.WHITE
		img.set_pixelv(o + Vector2i(11, 3), w)
		img.set_pixelv(o + Vector2i(10, 3), Color(1, 1, 1, 0.6))
		img.set_pixelv(o + Vector2i(12, 3), Color(1, 1, 1, 0.6))
		img.set_pixelv(o + Vector2i(11, 2), Color(1, 1, 1, 0.6))
		img.set_pixelv(o + Vector2i(11, 4), Color(1, 1, 1, 0.6))


# ---------------------------------------------------------------- Efektler

func _make_from_pattern(pattern: Array[String], colors: Dictionary) -> Image:
	var img: Image = Image.create_empty(pattern[0].length(), pattern.size(), false, Image.FORMAT_RGBA8)
	for y: int in pattern.size():
		for x: int in pattern[y].length():
			var ch: String = pattern[y][x]
			if colors.has(ch):
				img.set_pixel(x, y, colors[ch])
	return img


func _make_heart() -> Image:
	return _make_from_pattern([
		".OO.OO.",
		"ORWORRO",
		"ORRRRRO",
		".ORRRO.",
		"..ORO..",
		"...O...",
	], {"O": Color("8c1a30"), "R": Color("ff4d6d"), "W": Color("ffd1dc")})


func _make_alert() -> Image:
	return _make_from_pattern([
		"OOO",
		"OYO",
		"OYO",
		"OYO",
		"OOO",
		"OYO",
		"OOO",
	], {"O": Color("1e1e1e"), "Y": Color("f2e86d")})


func _make_sparkle() -> Image:
	return _make_from_pattern([
		"...W...",
		"...Y...",
		"..YWY..",
		"WYWWWYW",
		"..YWY..",
		"...Y...",
		"...W...",
	], {"W": Color.WHITE, "Y": Color("fff3a0")})


func _make_shadow() -> Image:
	var img: Image = Image.create_empty(12, 4, false, Image.FORMAT_RGBA8)
	for y: int in 4:
		for x: int in 12:
			var px: float = (x + 0.5 - 6.0) / 6.0
			var py: float = (y + 0.5 - 2.0) / 2.0
			if px * px + py * py <= 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0.3))
	return img


# ---------------------------------------------------------------- Vakum silahı

func _make_vacuum_gun() -> Image:
	var img: Image = Image.create_empty(16, 8, false, Image.FORMAT_RGBA8)
	# Hazne
	img.fill_rect(Rect2i(0, 1, 6, 6), Color("2e7d32"))
	img.fill_rect(Rect2i(1, 2, 4, 4), Color("4caf50"))
	img.set_pixel(1, 2, Color("a5d6a7"))
	img.set_pixel(2, 2, Color("a5d6a7"))
	# Boru
	img.fill_rect(Rect2i(6, 3, 6, 2), Color("9e9e9e"))
	img.fill_rect(Rect2i(6, 5, 6, 1), Color("616161"))
	# Ağız
	img.fill_rect(Rect2i(12, 1, 4, 6), Color("616161"))
	img.fill_rect(Rect2i(12, 1, 4, 1), Color("9e9e9e"))
	img.fill_rect(Rect2i(15, 2, 1, 4), Color("212121"))
	# Kabza
	img.fill_rect(Rect2i(3, 7, 2, 1), Color("3a2516"))
	return img


# ---------------------------------------------------------------- 3x5 rakamlar

const DIGIT_GLYPHS: Array[String] = [
	"111101101101111", "010110010010111", "111001111100111", "111001111001111", "101101111001001",
	"111100111001111", "111100111101111", "111001010010010", "111101111101111", "111101111001111",
]


func _make_digits() -> Image:
	var img: Image = Image.create_empty(30, 5, false, Image.FORMAT_RGBA8)
	for d: int in 10:
		for i: int in 15:
			if DIGIT_GLYPHS[d][i] == "1":
				img.set_pixel(d * 3 + i % 3, floori(i / 3.0), Color.WHITE)
	return img

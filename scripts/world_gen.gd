class_name WorldGen
extends RefCounted
## Dünya yerleşimi (tek, kesintisiz harita):
##  - FARM: çitli çiftlik (farm.gd çizer), batı çitinde bir kapı.
##  - FOREST: çiftliğin batısındaki orman (pembe + mavi slimelar).
##  - HIGHLANDS: ormanın kuzeyindeki kayalık yayla (gri + pembe slimelar).
##  - MOUNTAINS: çiftliğin doğusundaki geniş dağlık arazi (doğu çitinde kapı);
##    kuzeyi karlı, içinde geçilmez kaya kümeleri. Çevresi kaya duvarı.
## Orman ve yayla gürültüyle bozulmuş elips alanlardır (doğal kenarlı);
## bunları bir yol koridoru bağlar. Bölge dışı her yer sık ağaç örtüsüdür.
## Her şey sabit tohumla üretilir: aynı harita her açılışta aynı çıkar
## (kayıttaki ağaç sırası buna güvenir).

enum Region { NONE, FARM, FOREST, HIGHLANDS, MOUNTAINS }

const BOUNDS: Rect2i = Rect2i(-48, -36, 172, 66)
const FARM_RECT: Rect2i = Rect2i(0, 0, 48, 30)
const WEST_GATE_ROWS: Array[int] = [12, 13]
const EAST_GATE_ROWS: Array[int] = [12, 13]

const FOREST_CENTER: Vector2 = Vector2(-24, 14)
const FOREST_RADII: Vector2 = Vector2(19, 12)
const HIGHLANDS_CENTER: Vector2 = Vector2(-22, -20)
const HIGHLANDS_RADII: Vector2 = Vector2(17, 11)
const MOUNTAIN_CENTER: Vector2 = Vector2(88, -4)
const MOUNTAIN_RADII: Vector2 = Vector2(34, 25)
## Bu satırın kuzeyi karlı (gürültüyle bozulur).
const SNOW_LINE: float = -11.0
## Dağın içindeki geçilmez kaya kümeleri: gürültü bu eşiği aşınca kaya.
const CLIFF_THRESHOLD: float = 0.3
const CLIFF_SEED: int = 4242
## Kenar bozulması: 0 = düzgün elips, büyüdükçe girintili çıkıntılı.
const EDGE_NOISE: float = 0.38
const NOISE_SEED: int = 1337

## Kapıdan ormana, ormandan yaylaya kıvrılan yol (hücre koordinatı).
const ROUTE: Array[Vector2] = [
	Vector2(0.5, 13), Vector2(-6, 13), Vector2(-12, 15), Vector2(-19, 14),
	Vector2(-24, 10), Vector2(-26, 4), Vector2(-22, -2), Vector2(-24, -8), Vector2(-21, -15),
]
## Doğu kapısından dağın içine kıvrılan yol.
const EAST_ROUTE: Array[Vector2] = [
	Vector2(47.5, 13), Vector2(54, 13), Vector2(60, 9), Vector2(68, 6), Vector2(76, 0),
	Vector2(84, -2), Vector2(92, -8), Vector2(98, -16), Vector2(104, -4), Vector2(100, 8),
]
const CORRIDOR_RADIUS: float = 2.6
const PATH_RADIUS: float = 1.0

const SOURCE_ID: int = 0
const TILE_GRASS: Vector2i = Vector2i(0, 0)
const TILE_GRASS_ALT: Vector2i = Vector2i(1, 0)
const TILE_PATH: Vector2i = Vector2i(2, 0)
const TILE_FLOWERS_YELLOW: Vector2i = Vector2i(5, 0)
const TILE_FLOWERS_PINK: Vector2i = Vector2i(6, 0)
const TILE_TALL_GRASS: Vector2i = Vector2i(7, 0)
const TILE_PEBBLES: Vector2i = Vector2i(8, 0)
const TILE_CANOPY: Vector2i = Vector2i(13, 0)
const TILE_FOREST_FLOOR: Vector2i = Vector2i(14, 0)
const TILE_MUSHROOMS: Vector2i = Vector2i(15, 0)
const TILE_FERNS: Vector2i = Vector2i(16, 0)
const TILE_MOUNTAIN: Vector2i = Vector2i(17, 0)
const TILE_SCREE: Vector2i = Vector2i(18, 0)
const TILE_SNOW: Vector2i = Vector2i(19, 0)
const TILE_CLIFF: Vector2i = Vector2i(20, 0)
const TILE_ALPINE_GRASS: Vector2i = Vector2i(21, 0)

var _region: Dictionary = {}           # Vector2i -> Region
var _path: Dictionary = {}             # Vector2i -> true
var _cells_by_region: Dictionary = {}  # Region -> Array[Vector2i]


func _init() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = NOISE_SEED
	noise.frequency = 0.11
	var cliff_noise: FastNoiseLite = FastNoiseLite.new()
	cliff_noise.seed = CLIFF_SEED
	cliff_noise.frequency = 0.13
	for r: int in Region.values():
		_cells_by_region[r] = []

	for y: int in range(BOUNDS.position.y, BOUNDS.end.y):
		for x: int in range(BOUNDS.position.x, BOUNDS.end.x):
			var cell: Vector2i = Vector2i(x, y)
			var p: Vector2 = Vector2(x + 0.5, y + 0.5)
			var route_dist: float = _distance_to_route(p)
			var r: Region = Region.NONE
			if FARM_RECT.has_point(cell):
				r = Region.FARM
			elif _in_blob(p, FOREST_CENTER, FOREST_RADII, noise):
				r = Region.FOREST
			elif _in_blob(p, HIGHLANDS_CENTER, HIGHLANDS_RADII, noise):
				r = Region.HIGHLANDS
			elif route_dist <= CORRIDOR_RADIUS:
				r = Region.FOREST if y >= 2 else Region.HIGHLANDS
			elif x >= FARM_RECT.end.x:
				var east_dist: float = _distance_to(p, EAST_ROUTE)
				if east_dist <= CORRIDOR_RADIUS 						or (_in_blob(p, MOUNTAIN_CENTER, MOUNTAIN_RADII, noise) and cliff_noise.get_noise_2d(p.x, p.y) < CLIFF_THRESHOLD):
					r = Region.MOUNTAINS
				route_dist = east_dist
			_region[cell] = r
			if r != Region.FARM and r != Region.NONE and route_dist <= PATH_RADIUS:
				_path[cell] = true
	_remove_unreachable_pockets()
	for cell: Vector2i in _region:
		_cells_by_region[_region[cell]].append(cell)


## Gürültü ağaç örtüsü içinde küçük kopuk cepler bırakabilir; oraya slime
## doğarsa oyuncu ulaşamaz. Kapıdan taşma ile ulaşılamayan hücreleri örtüye çevir.
func _remove_unreachable_pockets() -> void:
	var start: Vector2i = Vector2i(-1, WEST_GATE_ROWS[0])
	var seen: Dictionary = {start: true}
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var c: Vector2i = stack.pop_back()
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			var r: Region = _region.get(n, Region.NONE)
			if r == Region.FOREST or r == Region.HIGHLANDS:
				seen[n] = true
				stack.append(n)
	# Dağlar doğu kapısından ayrı taşma ile
	var east_start: Vector2i = Vector2i(FARM_RECT.end.x, EAST_GATE_ROWS[0])
	seen[east_start] = true
	stack.append(east_start)
	while not stack.is_empty():
		var c: Vector2i = stack.pop_back()
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if not seen.has(n) and _region.get(n, Region.NONE) == Region.MOUNTAINS:
				seen[n] = true
				stack.append(n)
	for cell: Vector2i in _region:
		var r: Region = _region[cell]
		if (r == Region.FOREST or r == Region.HIGHLANDS or r == Region.MOUNTAINS) and not seen.has(cell):
			_region[cell] = Region.NONE
			_path.erase(cell)


func region_at(cell: Vector2i) -> Region:
	return _region.get(cell, Region.NONE)


func is_path(cell: Vector2i) -> bool:
	return _path.has(cell)


func cells_in(region: Region) -> Array:
	return _cells_by_region[region]


## Hücrenin dibinde, objelerin oturacağı nokta (piksel).
static func cell_to_ground(cell: Vector2i) -> Vector2:
	return Vector2(cell * 16) + Vector2(8, 14)


## Çiftlik dışındaki tüm hücreleri boyar (çiftliği farm.gd boyar).
func paint(ground: TileMapLayer) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 2024
	var snow: FastNoiseLite = FastNoiseLite.new()
	snow.seed = 99
	snow.frequency = 0.15
	for cell: Vector2i in _region:
		var r: Region = _region[cell]
		if r == Region.FARM:
			continue
		var roll: float = rng.randf()
		var tile: Vector2i = TILE_CLIFF if cell.x >= FARM_RECT.end.x else TILE_CANOPY
		match r:
			Region.FOREST:
				tile = TILE_FOREST_FLOOR
				if roll < 0.05:
					tile = TILE_MUSHROOMS
				elif roll < 0.14:
					tile = TILE_FERNS
				elif roll < 0.17:
					tile = TILE_FLOWERS_PINK
			Region.HIGHLANDS:
				tile = TILE_GRASS
				if roll < 0.12:
					tile = TILE_PEBBLES
				elif roll < 0.2:
					tile = TILE_GRASS_ALT
				elif roll < 0.25:
					tile = TILE_TALL_GRASS
				elif roll < 0.28:
					tile = TILE_FLOWERS_YELLOW
			Region.MOUNTAINS:
				if cell.y + snow.get_noise_2d(cell.x, cell.y) * 4.0 < SNOW_LINE:
					tile = TILE_SNOW if roll > 0.1 else TILE_SCREE
				else:
					tile = TILE_MOUNTAIN
					if roll < 0.14:
						tile = TILE_SCREE
					elif roll < 0.26:
						tile = TILE_ALPINE_GRASS
		if _path.has(cell):
			tile = TILE_PATH
		ground.set_cell(cell, SOURCE_ID, tile)


## Ağaç, taş, çalı yerleri (piksel). Sabit tohumlu; sıra her seferinde aynı.
func plan_props() -> Dictionary:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77
	var taken: Array[Vector2i] = []
	var plan: Dictionary = {"fruit_trees": [], "decor_trees": [], "rocks": [], "bushes": [], "carrot_patches": [],
			"mountain_fruit_trees": [], "mountain_carrot_patches": [], "mountain_rocks": [], "nests": []}
	_scatter(plan["fruit_trees"], Region.FOREST, 5, 5.0, 2, rng, taken)
	_scatter(plan["fruit_trees"], Region.HIGHLANDS, 3, 5.0, 2, rng, taken)
	_scatter(plan["decor_trees"], Region.FOREST, 14, 3.5, 1, rng, taken)
	_scatter(plan["decor_trees"], Region.HIGHLANDS, 4, 3.5, 1, rng, taken)
	_scatter(plan["bushes"], Region.FOREST, 7, 2.5, 1, rng, taken)
	_scatter(plan["rocks"], Region.HIGHLANDS, 12, 2.5, 1, rng, taken)
	_scatter(plan["rocks"], Region.FOREST, 3, 2.5, 1, rng, taken)
	# Not: yeni yerleşimleri hep sona ekle; öncekilerin yerleri değişmesin
	_scatter(plan["carrot_patches"], Region.FOREST, 3, 3.0, 1, rng, taken)
	_scatter(plan["carrot_patches"], Region.HIGHLANDS, 3, 3.0, 1, rng, taken)
	_scatter(plan["mountain_fruit_trees"], Region.MOUNTAINS, 3, 5.0, 2, rng, taken)
	_scatter(plan["mountain_carrot_patches"], Region.MOUNTAINS, 4, 3.0, 1, rng, taken)
	_scatter(plan["mountain_rocks"], Region.MOUNTAINS, 18, 2.5, 1, rng, taken)
	_scatter(plan["nests"], Region.FOREST, 2, 4.0, 1, rng, taken)
	_scatter(plan["nests"], Region.HIGHLANDS, 1, 4.0, 1, rng, taken)
	_scatter(plan["nests"], Region.MOUNTAINS, 3, 5.0, 2, rng, taken)
	return plan


func _scatter(out: Array, region: Region, count: int, min_dist: float, margin: int,
		rng: RandomNumberGenerator, taken: Array[Vector2i]) -> void:
	var cells: Array = _cells_by_region[region]
	var placed: int = 0
	for attempt: int in 800:
		if placed >= count:
			return
		var cell: Vector2i = cells[rng.randi() % cells.size()]
		if not _clear_around(cell, margin):
			continue
		var too_close: bool = false
		for t: Vector2i in taken:
			if Vector2(t - cell).length() < min_dist:
				too_close = true
				break
		if too_close:
			continue
		taken.append(cell)
		out.append(cell_to_ground(cell))
		placed += 1


## Etrafı (margin hücre) yürünebilir ve yol değil mi?
func _clear_around(cell: Vector2i, margin: int) -> bool:
	for dy: int in range(-margin, margin + 1):
		for dx: int in range(-margin, margin + 1):
			var c: Vector2i = cell + Vector2i(dx, dy)
			var r: Region = region_at(c)
			if r == Region.NONE or r == Region.FARM or _path.has(c):
				return false
	return true


func _in_blob(p: Vector2, center: Vector2, radii: Vector2, noise: FastNoiseLite) -> bool:
	var d: float = ((p - center) / radii).length()
	return d < 1.0 + noise.get_noise_2d(p.x, p.y) * EDGE_NOISE


func _distance_to_route(p: Vector2) -> float:
	return _distance_to(p, ROUTE)


func _distance_to(p: Vector2, route: Array[Vector2]) -> float:
	var best: float = INF
	for i: int in route.size() - 1:
		var q: Vector2 = Geometry2D.get_closest_point_to_segment(p, route[i], route[i + 1])
		best = minf(best, q.distance_to(p))
	return best

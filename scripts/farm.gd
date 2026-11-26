extends Node2D
## Ana oyun sahnesi: çiftlik haritasını kurar (ev, bahçe arsaları, ağaçlar, doğa),
## etkileşimleri (E), satın almayı, ev giriş/çıkışını, yatakta uyuyup
## kaydetmeyi ve kayıttan yüklemeyi yönetir.

enum Area { FARM, HOUSE }

const MAP_SIZE: Vector2i = Vector2i(48, 30)
const SOURCE_ID: int = 0
const TILE_GRASS: Vector2i = Vector2i(0, 0)
const TILE_GRASS_ALT: Vector2i = Vector2i(1, 0)
const TILE_PATH: Vector2i = Vector2i(2, 0)
const TILE_SOIL: Vector2i = Vector2i(3, 0)
const TILE_FENCE: Vector2i = Vector2i(4, 0)
const TILE_FLOWERS_YELLOW: Vector2i = Vector2i(5, 0)
const TILE_FLOWERS_PINK: Vector2i = Vector2i(6, 0)
const TILE_TALL_GRASS: Vector2i = Vector2i(7, 0)
const TILE_PEBBLES: Vector2i = Vector2i(8, 0)

## Evin alt-orta noktası (piksel). Ev 64x64, kapı alt ortada.
const HOUSE_POS: Vector2 = Vector2(384, 160)
## Evin kapladığı hücreler (slime doğmasın, süs konmasın).
const HOUSE_CELLS: Rect2i = Rect2i(21, 5, 6, 6)
const PATH_COLUMNS: Array[int] = [23, 24]
const PATH_END_ROW: int = 26
const NEW_GAME_SPAWN: Vector2 = Vector2(384, 186)

## Evin önündeki 10 bahçe arsası (hücre). Yolun iki yanında iki sıra;
## üst sıranın dış köşeleri ağaçlara ayrıldı. Sıra kayıtta önemli.
const PLOT_CELLS: Array[Rect2i] = [
	Rect2i(10, 15, 6, 5), Rect2i(17, 15, 6, 5), Rect2i(26, 15, 6, 5), Rect2i(33, 15, 6, 5),
	Rect2i(3, 22, 6, 5), Rect2i(10, 22, 6, 5), Rect2i(17, 22, 6, 5),
	Rect2i(26, 22, 6, 5), Rect2i(33, 22, 6, 5), Rect2i(40, 22, 6, 5),
]

const TREE_POSITIONS: Array[Vector2] = [
	Vector2(88, 128), Vector2(680, 128), Vector2(72, 282),
	Vector2(712, 282), Vector2(200, 72), Vector2(568, 72),
]
const ROCK_POSITIONS: Array[Vector2] = [
	Vector2(248, 88), Vector2(520, 100), Vector2(40, 180),
	Vector2(600, 456), Vector2(296, 456), Vector2(112, 456),
]
const BUSH_POSITIONS: Array[Vector2] = [
	Vector2(330, 156), Vector2(56, 56), Vector2(712, 56),
	Vector2(40, 330), Vector2(740, 248), Vector2(432, 456),
]
## Çiftlikteki havuç yığınları (doğadakiler WorldGen'den gelir).
const CARROT_PATCH_POSITIONS: Array[Vector2] = [Vector2(150, 100), Vector2(608, 204)]
## Çiftlikteki tavuk yuvası (doğadakiler WorldGen'den gelir).
const NEST_POSITIONS: Array[Vector2] = [Vector2(300, 56)]
## Yeni oyunda her yuvada başlayan kuş sayısı.
const NEST_START_BIRDS: int = 2
## Gem satış makinesi: evin sağında.
const SELL_MACHINE_POS: Vector2 = Vector2(446, 160)

## Yeni oyunda bölge başına doğacak slimelar: [bölge, tür indeksi, adet]
## Tür indeksi SlimeRegistry.base_types() sırası: 0 kırmızı, 1 mavi, 2 gri, 3 pembe,
## 4 kedi, 5 tavşan, 6 mantar, 7 ejder, 8 yaprak, 9 keçi, 10 kar, 11 tüy
const INITIAL_SLIMES: Array = [
	[WorldGen.Region.FARM, 0, 4],
	[WorldGen.Region.FARM, 1, 2],
	[WorldGen.Region.FOREST, 3, 4],
	[WorldGen.Region.FOREST, 1, 4],
	[WorldGen.Region.HIGHLANDS, 2, 4],
	[WorldGen.Region.HIGHLANDS, 3, 3],
	[WorldGen.Region.FOREST, 4, 3],
	[WorldGen.Region.FOREST, 6, 3],
	[WorldGen.Region.FOREST, 8, 3],
	[WorldGen.Region.HIGHLANDS, 5, 3],
	[WorldGen.Region.HIGHLANDS, 7, 2],
	[WorldGen.Region.FARM, 8, 1],
	[WorldGen.Region.MOUNTAINS, 9, 4],
	[WorldGen.Region.MOUNTAINS, 10, 4],
	[WorldGen.Region.MOUNTAINS, 11, 3],
	[WorldGen.Region.MOUNTAINS, 2, 2],
]
## Bu alan olmayan (eski) kayıtlarda bu bölgeler zaten doluydu; geri kalanlara
## yüklenince slime doğar (yeni eklenen bölgeler eski kayıtlarda da dolu olsun).
const OLD_SAVE_POPULATED: Array[String] = ["farm", "forest", "highlands"]
const DECOR_TREE_TINT: Color = Color(0.78, 0.9, 0.8)

const HOUSE_SCENE: PackedScene = preload("res://scenes/house.tscn")
const SELL_MACHINE_SCENE: PackedScene = preload("res://scenes/sell_machine.tscn")
const TREE_SCENE: PackedScene = preload("res://scenes/fruit_tree.tscn")
const CARROT_PATCH_SCENE: PackedScene = preload("res://scenes/carrot_patch.tscn")
const ROCK_SCENE: PackedScene = preload("res://scenes/rock.tscn")
const BUSH_SCENE: PackedScene = preload("res://scenes/bush.tscn")
const NEST_SCENE: PackedScene = preload("res://scenes/chicken_nest.tscn")

const FADE_TIME: float = 0.3
const TOAST_TIME: float = 2.0

var area: Area = Area.FARM
var house: House
var sell_machine: SellMachine
var world: WorldGen
var plots: Array[GardenPlot] = []
var _menu_plot: GardenPlot = null
var _trees: Array[FruitTree] = []
var nests: Array[ChickenNest] = []
## Slime doğmasın diye dolu sayılan hücreler.
var _blocked: Dictionary = {}
var _busy: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _toast_tween: Tween
var _last_clock_text: String = ""

@onready var ground: TileMapLayer = $Ground
@onready var day_night: DayNight = $DayNight
@onready var clock: Label = $HUD/Clock
@onready var fences: TileMapLayer = $Fences
@onready var interior: HouseInterior = $HouseInterior
@onready var entities: Node2D = $Entities
@onready var player: Player = $Entities/Player
@onready var hud: InventoryHud = $HUD/InventoryHud
@onready var prompt: Label = $HUD/Prompt
@onready var toast: Label = $HUD/Toast
@onready var fade: ColorRect = $HUD/Fade
@onready var build_menu: BuildMenu = $HUD/BuildMenu


func _ready() -> void:
	Game.in_game = true
	_rng.randomize()
	world = WorldGen.new()
	_build_map()
	world.paint(ground)
	_place_props()

	hud.inventory = player.inventory
	player.vacuum_gun.item_launched.connect(_on_item_launched)
	sell_machine.sold.connect(_on_item_sold)
	house.door_entered.connect(_on_house_door_entered)
	interior.exit_entered.connect(_on_interior_exit_entered)
	build_menu.option_chosen.connect(_on_build_option_chosen)
	build_menu.closed.connect(_on_build_menu_closed)
	var debug: DebugPanel = DebugPanel.new()
	debug.name = "DebugPanel"
	debug.farm = self
	$HUD.add_child(debug)
	$HUD.move_child(debug, fade.get_index())  # karartmanın altında kalsın
	var hint: Label = Label.new()
	hint.text = "F1: Debug"
	hint.add_theme_font_size_override(&"font_size", 8)
	hint.modulate = Color(1, 1, 1, 0.55)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.anchor_left = 1.0
	hint.anchor_right = 1.0
	hint.offset_left = -60.0
	hint.offset_right = -5.0
	hint.offset_top = 17.0
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	$HUD.add_child(hint)
	debug.visibility_changed.connect(func() -> void: hint.visible = not debug.visible)

	var save: Dictionary = Game.take_pending_load()
	if save.is_empty():
		_start_new_game()
	else:
		_apply_save(save)

	fade.color.a = 1.0
	create_tween().tween_property(fade, "color:a", 0.0, FADE_TIME)


func _process(_delta: float) -> void:
	var text: String = Game.clock_text()
	if text != _last_clock_text:
		_last_clock_text = text
		clock.text = text
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"interact") or _busy or build_menu.visible:
		return
	if area == Area.HOUSE:
		if interior.player_near_bed:
			_sleep()
		return
	var plot: GardenPlot = _plot_at(player.global_position)
	if plot == null:
		return
	match plot.interact_action(player.global_position):
		&"menu":
			_menu_plot = plot
			player.input_enabled = false
			build_menu.open(plot.menu_title(), plot.menu_options(), player.inventory.money)
		&"collect":
			var moved: int = plot.take_stored(player.inventory)
			if moved > 0:
				Sfx.play("gem")
				_show_toast("%d gem alındı" % moved)
			elif plot.stored.is_empty():
				_show_toast("Toplayıcı boş")
			else:
				_show_toast("Envanter dolu")


## Ekranın altındaki ipucu: yatak, arsa/kümes/tarla durumu.
func _update_prompt() -> void:
	var text: String = ""
	if not _busy and not build_menu.visible:
		if area == Area.HOUSE:
			if interior.player_near_bed:
				text = "[E] Uyu ve kaydet"
		else:
			var plot: GardenPlot = _plot_at(player.global_position)
			if plot != null:
				text = plot.prompt_text(player.global_position)
	prompt.text = text
	prompt.visible = text != ""


func _plot_at(point: Vector2) -> GardenPlot:
	for plot: GardenPlot in plots:
		if plot.contains(point):
			return plot
	return null


func _on_build_option_chosen(id: StringName) -> void:
	if id == &"remove":
		# Onay penceresi
		var what: String = _menu_plot.menu_title()
		build_menu.open("%s kaldırılsın mı?" % what,
				[{"id": &"remove_confirm", "text": "Evet, kaldır", "price": 0, "enabled": true}],
				player.inventory.money)
		return
	if id == &"remove_confirm":
		var what2: String = _menu_plot.menu_title()
		_menu_plot.remove_building()
		_show_toast("%s kaldırıldı" % what2)
		build_menu.close()
		return
	var price: int = GardenPlot.PRICES[id]
	if player.inventory.money < price:
		_show_toast("Yetersiz para (%d gerekli)" % price)
		return
	player.inventory.add_money(-price)
	Sfx.play("coin")
	_menu_plot.purchase(id)
	_show_toast("%s satın alındı" % GardenPlot.NAMES[id])
	build_menu.close()


func _on_build_menu_closed() -> void:
	_menu_plot = null
	player.input_enabled = true


func spawn_item(item: ItemType, at: Vector2) -> Vacuumable:
	return item.spawn(entities, at)


# ---------------------------------------------------------------- Harita

func _build_map() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42

	# Zemin: çim + doğal süsler (ev ve arsalar dışında)
	for y: int in MAP_SIZE.y:
		for x: int in MAP_SIZE.x:
			var cell: Vector2i = Vector2i(x, y)
			var tile: Vector2i = TILE_GRASS
			if not HOUSE_CELLS.has_point(cell) and not _in_plot(cell):
				var r: float = rng.randf()
				if r < 0.03:
					tile = TILE_FLOWERS_YELLOW
				elif r < 0.06:
					tile = TILE_FLOWERS_PINK
				elif r < 0.12:
					tile = TILE_TALL_GRASS
				elif r < 0.15:
					tile = TILE_PEBBLES
				elif r < 0.25:
					tile = TILE_GRASS_ALT
			ground.set_cell(cell, SOURCE_ID, tile)

	# Evin önünde iki çiçek tarhı
	for x: int in [20, 21, 26, 27]:
		ground.set_cell(Vector2i(x, 10), SOURCE_ID, TILE_FLOWERS_PINK if x % 2 == 0 else TILE_FLOWERS_YELLOW)

	# Dış sınır çiti; batıda ormana açılan kapı ve kapıdan eve uzanan yol
	_fence_rect(Rect2i(Vector2i.ZERO, MAP_SIZE), [])
	for row: int in WorldGen.WEST_GATE_ROWS:
		fences.erase_cell(Vector2i(0, row))
		for x: int in range(0, PATH_COLUMNS[0]):
			ground.set_cell(Vector2i(x, row), SOURCE_ID, TILE_PATH)

	# Doğu çitinde dağlara açılan kapı
	for row: int in WorldGen.EAST_GATE_ROWS:
		fences.erase_cell(Vector2i(MAP_SIZE.x - 1, row))
		for x: int in range(MAP_SIZE.x - 8, MAP_SIZE.x):
			ground.set_cell(Vector2i(x, row), SOURCE_ID, TILE_PATH)

	# Kapıdan arsaların arasından güneye yol
	var door_row: int = int(HOUSE_POS.y / 16.0)
	for y: int in range(door_row, PATH_END_ROW + 1):
		for x: int in PATH_COLUMNS:
			ground.set_cell(Vector2i(x, y), SOURCE_ID, TILE_PATH)

	for rect: Rect2i in _concat([HOUSE_CELLS], PLOT_CELLS):
		for x: int in range(rect.position.x, rect.end.x):
			for y: int in range(rect.position.y, rect.end.y):
				_blocked[Vector2i(x, y)] = true


func _in_plot(cell: Vector2i) -> bool:
	for rect: Rect2i in PLOT_CELLS:
		if rect.has_point(cell):
			return true
	return false


## Dikdörtgenin kenarlarına çit çizer; gate_columns sütunlarında üst ve alt kenar açık kalır.
func _fence_rect(rect: Rect2i, gate_columns: Array[int]) -> void:
	for x: int in range(rect.position.x, rect.end.x):
		if not gate_columns.has(x):
			fences.set_cell(Vector2i(x, rect.position.y), SOURCE_ID, TILE_FENCE)
			fences.set_cell(Vector2i(x, rect.end.y - 1), SOURCE_ID, TILE_FENCE)
	for y: int in range(rect.position.y, rect.end.y):
		fences.set_cell(Vector2i(rect.position.x, y), SOURCE_ID, TILE_FENCE)
		fences.set_cell(Vector2i(rect.end.x - 1, y), SOURCE_ID, TILE_FENCE)


func _place_props() -> void:
	house = _place(HOUSE_SCENE, HOUSE_POS) as House
	sell_machine = _place(SELL_MACHINE_SCENE, SELL_MACHINE_POS) as SellMachine
	for rect: Rect2i in PLOT_CELLS:
		var plot: GardenPlot = GardenPlot.new()
		entities.add_child(plot)
		plot.setup(rect, ground, entities)
		plots.append(plot)
	var plan: Dictionary = world.plan_props()
	# Elma ağaçlarının sırası kayıtta önemli: önce çiftlik, sonra orman/yayla
	for pos: Vector2 in _concat(TREE_POSITIONS, plan["fruit_trees"]):
		_trees.append(_place(TREE_SCENE, pos) as FruitTree)
	# Havuç yığınları ağaç listesinin sonunda (eski kayıtlardaki ağaç sırası bozulmasın)
	for pos: Vector2 in _concat(CARROT_PATCH_POSITIONS, plan["carrot_patches"]):
		_trees.append(_place(CARROT_PATCH_SCENE, pos) as FruitTree)
	# Dağdaki ürün kaynakları da listenin SONUNA (kayıt sırası)
	for pos: Vector2 in plan["mountain_fruit_trees"]:
		_trees.append(_place(TREE_SCENE, pos) as FruitTree)
	for pos: Vector2 in plan["mountain_carrot_patches"]:
		_trees.append(_place(CARROT_PATCH_SCENE, pos) as FruitTree)
	for pos: Vector2 in _concat(NEST_POSITIONS, plan["nests"]):
		nests.append(_place(NEST_SCENE, pos) as ChickenNest)
	for pos: Vector2 in plan["mountain_rocks"]:
		_place(ROCK_SCENE, pos)
	for pos: Vector2 in plan["decor_trees"]:
		var tree: FruitTree = TREE_SCENE.instantiate()
		tree.bears_fruit = false
		tree.modulate = DECOR_TREE_TINT
		tree.position = pos
		entities.add_child(tree)
	for pos: Vector2 in _concat(ROCK_POSITIONS, plan["rocks"]):
		_place(ROCK_SCENE, pos)
	for pos: Vector2 in _concat(BUSH_POSITIONS, plan["bushes"]):
		_place(BUSH_SCENE, pos)


func _concat(a: Array, b: Array) -> Array:
	var result: Array = []
	result.append_array(a)
	result.append_array(b)
	return result


func _place(scene: PackedScene, pos: Vector2) -> Node2D:
	var node: Node2D = scene.instantiate()
	node.position = pos
	entities.add_child(node)
	var cell: Vector2i = ground.local_to_map(pos)
	for dx: int in [-1, 0, 1]:
		for dy: int in [-1, 0]:
			_blocked[cell + Vector2i(dx, dy)] = true
	return node


# ---------------------------------------------------------------- Yeni oyun / yükleme / kaydetme

func _start_new_game() -> void:
	for tree: FruitTree in _trees:
		tree.fill_all()
	for nest: ChickenNest in nests:
		nest.fill(NEST_START_BIRDS)
	_populate_regions([])
	_set_area(Area.FARM)
	player.teleport(NEW_GAME_SPAWN)
	# Slot menüde hemen dolu görünsün
	Game.write_save(_collect_save())


## Henüz slime doğmamış bölgelere başlangıç slimelarını koyar.
func _populate_regions(already: Array) -> void:
	var types: Array[SlimeType] = SlimeRegistry.base_types()
	for spec: Array in INITIAL_SLIMES:
		if already.has(_region_name(spec[0])):
			continue
		for i: int in spec[2]:
			spawn_item(types[spec[1]], ground.map_to_local(_random_free_cell(spec[0])))


func _region_name(region: WorldGen.Region) -> String:
	return String(WorldGen.Region.keys()[region]).to_lower()


func _all_region_names() -> Array:
	var names: Array = []
	for spec: Array in INITIAL_SLIMES:
		var n: String = _region_name(spec[0])
		if not names.has(n):
			names.append(n)
	return names


func _collect_save() -> Dictionary:
	var slimes: Array = []
	var pickups: Array = []
	for node: Node in get_tree().get_nodes_in_group(&"vacuumable"):
		var v: Vacuumable = node as Vacuumable
		if v == null or v.is_queued_for_deletion():
			continue
		if v is Pickup and (v as Pickup).is_hanging():
			continue  # ağaçtaki elmaları ağaç kaydeder
		var entry: Dictionary = {"item": String(v.item.id), "x": v.global_position.x, "y": v.global_position.y}
		if v is Slime:
			entry["data"] = v.get_carry_data()
			slimes.append(entry)
		else:
			var data: Dictionary = v.get_carry_data()
			if not data.is_empty():
				entry["data"] = data  # ör. civcivin büyüme saati
			pickups.append(entry)

	var trees: Array = []
	for tree: FruitTree in _trees:
		trees.append(tree.get_state())

	return {
		"player": {
			"area": "house" if area == Area.HOUSE else "farm",
			"x": player.global_position.x,
			"y": player.global_position.y,
		},
		"inventory": player.inventory.to_dict(),
		"slimes": slimes,
		"pickups": pickups,
		"trees": trees,
		"nests": nests.map(func(n: ChickenNest) -> float: return n.get_state()),
		"populated": _all_region_names(),
		"plots": plots.map(func(p: GardenPlot) -> Dictionary: return p.get_state()),
	}


func _apply_save(data: Dictionary) -> void:
	player.inventory.from_dict(data.get("inventory", {}))

	# Arsalar önce: kümes duvarları slimelar doğmadan yerinde olsun
	var plot_states: Array = data.get("plots", [])
	for i: int in mini(plots.size(), plot_states.size()):
		if plot_states[i] is Dictionary:
			plots[i].set_state(plot_states[i])

	for entry: Dictionary in data.get("slimes", []):
		var kind: ItemType = ItemDatabase.get_item(str(entry.get("item", "")))
		if kind != null:
			var slime: Vacuumable = spawn_item(kind, _entry_pos(entry))
			slime.apply_carry_data(entry.get("data", {}))
	for entry: Dictionary in data.get("pickups", []):
		var item: ItemType = ItemDatabase.get_item(str(entry.get("item", "")))
		if item != null:
			var node: Vacuumable = spawn_item(item, _entry_pos(entry))
			node.apply_carry_data(entry.get("data", {}))

	var tree_states: Array = data.get("trees", [])
	for i: int in _trees.size():
		if i < tree_states.size() and tree_states[i] is Array:
			_trees[i].set_state(tree_states[i])
		else:
			_trees[i].fill_all()

	# Yuvalar: eski kayıtta yoksa yeni oyun gibi doldur
	if data.has("nests"):
		var nest_states: Array = data["nests"]
		for i: int in nests.size():
			if i < nest_states.size():
				nests[i].set_state(float(nest_states[i]))
			else:
				nests[i].fill(NEST_START_BIRDS)
	else:
		for nest: ChickenNest in nests:
			nest.fill(NEST_START_BIRDS)
	_populate_regions(data.get("populated", OLD_SAVE_POPULATED))

	var p: Dictionary = data.get("player", {})
	if p.get("area", "") == "house":
		# Ev içi odası sonradan taşındı (dağlar eklenince); eski koordinata güvenme
		_set_area(Area.HOUSE)
		player.teleport(interior.entry_spawn())
	else:
		_set_area(Area.FARM)
		player.teleport(_entry_pos(p) if p.has("x") else NEW_GAME_SPAWN)


## Debug: bölgeye ışınlan (-1 = çiftlik).
func debug_teleport(region: int) -> void:
	if _busy:
		return
	_set_area(Area.FARM)
	if region < 0:
		player.teleport(NEW_GAME_SPAWN)
	else:
		player.teleport(ground.map_to_local(_random_free_cell(region as WorldGen.Region)))


func debug_save() -> void:
	var ok: bool = Game.write_save(_collect_save())
	_show_toast("Kaydedildi" if ok else "Kayıt başarısız!")


func _entry_pos(entry: Dictionary) -> Vector2:
	return Vector2(float(entry.get("x", 0.0)), float(entry.get("y", 0.0)))


func _sleep() -> void:
	_transition(_save_while_sleeping)


func _save_while_sleeping() -> void:
	var ok: bool = Game.write_save(_collect_save())
	_show_toast("Oyun kaydedildi" if ok else "Kayıt başarısız!")
	if ok:
		Sfx.play("save_jingle")


# ---------------------------------------------------------------- Ev giriş / çıkış

func _on_house_door_entered() -> void:
	if not _busy:
		_transition(_move_into_house)


func _on_interior_exit_entered() -> void:
	if not _busy:
		_transition(_move_out_of_house)


func _move_into_house() -> void:
	_set_area(Area.HOUSE)
	player.teleport(interior.entry_spawn())


func _move_out_of_house() -> void:
	_set_area(Area.FARM)
	player.teleport(house.exit_spawn())


## Ekranı karart, `during`'i çalıştır, aç. Bu sırada oyuncu donar.
func _transition(during: Callable, after: Callable = Callable()) -> void:
	_busy = true
	player.input_enabled = false
	var tween: Tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, FADE_TIME)
	tween.tween_callback(during)
	tween.tween_interval(0.15)
	tween.tween_property(fade, "color:a", 0.0, FADE_TIME)
	tween.tween_callback(_end_transition.bind(after))


func _end_transition(after: Callable) -> void:
	player.input_enabled = true
	_busy = false
	if after.is_valid():
		after.call()


## Kamerayı bulunulan alana sınırla.
func _set_area(new_area: Area) -> void:
	area = new_area
	day_night.indoor = area == Area.HOUSE
	if area == Area.FARM:
		var tile_size: Vector2i = ground.tile_set.tile_size
		player.set_camera_limits(Rect2i(WorldGen.BOUNDS.position * tile_size, WorldGen.BOUNDS.size * tile_size))
	else:
		# Oda ekrandan küçük: kamerayı odanın ortasına sabitle
		var room: Rect2 = interior.room_rect()
		var view: Vector2 = get_viewport_rect().size
		player.set_camera_limits(Rect2i(Rect2(room.get_center() - view * 0.5, view)))


func _show_toast(text: String) -> void:
	toast.text = text
	if _toast_tween:
		_toast_tween.kill()
	toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(TOAST_TIME)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.5)


func _on_item_sold(_item: ItemType, price: int) -> void:
	player.inventory.add_money(price)


func _on_item_launched(entry: Inventory.Entry, at: Vector2, launch_velocity: Vector2) -> void:
	var node: Vacuumable = spawn_item(entry.item, at)
	node.apply_carry_data(entry.data)
	node.launch(launch_velocity)


## Bölgede; çit, ev, obje ve ağaç örtüsünden uzak, oyuncuya yakın olmayan rastgele hücre.
func _random_free_cell(region: WorldGen.Region) -> Vector2i:
	var cells: Array = world.cells_in(region)
	for attempt: int in 300:
		var cell: Vector2i = cells[_rng.randi() % cells.size()]
		if fences.get_cell_source_id(cell) != -1 or _blocked.has(cell):
			continue
		if region == WorldGen.Region.FARM and (cell.x < 1 or cell.y < 1 or cell.x > MAP_SIZE.x - 2 or cell.y > MAP_SIZE.y - 2):
			continue
		if ground.map_to_local(cell).distance_to(NEW_GAME_SPAWN) < 64.0:
			continue
		return cell
	return Vector2i(10, 20)

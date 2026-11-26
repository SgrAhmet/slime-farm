class_name GardenPlot
extends Node2D
## Bahçedeki satın alınabilir arsa. Boşken tabela durur; satın alınınca:
##  - Slime Kümesi: 4 cam duvar + köşe direkleri, tavansız. Oyuncu ve eşyalar
##    geçer; yerdeki slimelar geçemez (Vacuumable.CORRAL_LAYER), fırlatılan
##    slime üstünden uçarak girer. Kapasite aşılınca içerdekiler kaçabilir.
##    Geliştirmeler: otomatik besleyici, otomatik gem toplayıcı, genişletme
##    (kapasite 8 -> 16, duvarlar yükselir).
##  - Tarla: içine yiyecek atılınca fidan büyür, sonra sınırsız ürün veren ağaç olur.
##    Geliştirme: gübre (büyüme ve ürün yenilenmesi 2 kat hızlı).
## İkisi de menüden kaldırılabilir: tarladaki ürünler yere düşer, kümesteki
## slimelara dokunulmaz (duvarlar kalkar, oldukları yerde kalırlar); besleyicideki
## yiyecekler ve toplayıcıdaki gemler yere bırakılır.
## Düğüm konumu arsanın sol üst köşesidir; çocuklar iç içe y-sıralamaya katılır.

enum Kind { EMPTY, CORRAL, FIELD }
enum Crop { NONE, GROWING, GROWN }

const PRICES: Dictionary = {
	&"corral": 300, &"field": 150, &"feeder": 400, &"collector": 600,
	&"expansion": 800, &"fertilizer": 350, &"remove": 0,
}
const NAMES: Dictionary = {
	&"corral": "Slime Kümesi", &"field": "Tarla",
	&"feeder": "Otomatik Besleyici", &"collector": "Otomatik Gem Toplayıcı",
	&"expansion": "Genişletme (16 slime)", &"fertilizer": "Gübre (2x hızlı)",
	&"remove": "Kaldır",
}

const CORRAL_CAPACITY: int = 8
const EXPANDED_CAPACITY: int = 16
const TALL_WALL_HEIGHT: float = 18.0
const LARGE_SLIME_WEIGHT: int = 2
const WALL_HEIGHT: float = 10.0
const WALL_THICKNESS: float = 4.0
const GLASS: Color = Color(0.75, 0.92, 1.0, 0.22)
const GLASS_EDGE: Color = Color(0.9, 0.97, 1.0, 0.8)
const CROWDED_TINT: Color = Color(1.0, 0.5, 0.5)
const POPULATION_INTERVAL: float = 0.5

const FEEDER_POS: Vector2 = Vector2(12, 18)
const FEEDER_MAX: int = 30
const FEEDER_INTERVAL: float = 20.0
const COLLECTOR_INSET: Vector2 = Vector2(12, 18)
const COLLECTOR_INTERACT_RANGE: float = 26.0

## Fidanın ağaç olma süresi ve ağaçta ürünün yenilenme süresi (saniye).
const GROW_TIME: float = 180.0
const CROP_REGROW: float = 90.0
## Gübre: büyüme ve yenilenme bu kat hızlı.
const FERTILIZER_SPEED: float = 2.0
## Yiyecek kimliği -> tarlada yetişen kaynak sahnesi ve adı.
const CROP_TREES: Dictionary = {
	"apple": "res://scenes/fruit_tree.tscn",
	"carrot": "res://scenes/carrot_patch.tscn",
}
const CROP_NAMES: Dictionary = {"apple": "Elma ağacı", "carrot": "Havuç yığını"}
const FIELD_CHECK_INTERVAL: float = 0.5

const SOURCE_ID: int = 0
const TILE_GRASS: Vector2i = Vector2i(0, 0)
const TILE_SOIL: Vector2i = Vector2i(3, 0)
const LABEL_COLOR: Color = Color(1, 0.95, 0.84)

const APPLE: ItemType = preload("res://data/items/apple.tres")
const SIGN_TEX: Texture2D = preload("res://assets/sign.png")
const POST_TEX: Texture2D = preload("res://assets/corral_post.png")
const POST_TALL_TEX: Texture2D = preload("res://assets/corral_post_tall.png")
const FEEDER_TEX: Texture2D = preload("res://assets/feeder.png")
const COLLECTOR_TEX: Texture2D = preload("res://assets/collector.png")
const SAPLING_TEX: Texture2D = preload("res://assets/sapling.png")

var kind: Kind = Kind.EMPTY
var cells: Rect2i
var size_px: Vector2
# Kümes
var has_feeder: bool = false
## Besleyicideki yiyecekler (kimlik), atılış sırasıyla.
var feeder_items: Array[String] = []
var feeder_stock: int:
	get:
		return feeder_items.size()
var has_collector: bool = false
## Toplayıcıdaki gemler: gem kimliği -> adet
var stored: Dictionary = {}
var has_expansion: bool = false
var population: int = 0
var crowded: bool = false
# Tarla
var crop_state: Crop = Crop.NONE
var crop_item: ItemType = null
var grow_left: float = 0.0
var has_fertilizer: bool = false

var _ground: TileMapLayer
var _entities: Node2D
var _parts: Array[Node] = []
var _back: Node2D
var _front: Node2D
var _feeder: Node2D
var _feeder_label: Label
var _collector: Node2D
var _collector_label: Label
var _sapling: Sprite2D
var _tree: FruitTree
var _residents: Array = []
var _pop_timer: float = 0.0
var _feeder_timer: float = FEEDER_INTERVAL
var _field_timer: float = 0.0


func setup(p_cells: Rect2i, ground: TileMapLayer, entities: Node2D) -> void:
	cells = p_cells
	_ground = ground
	_entities = entities
	position = Vector2(cells.position * 16)
	size_px = Vector2(cells.size * 16)
	y_sort_enabled = true
	_rebuild()


func global_rect() -> Rect2:
	return Rect2(global_position, size_px)


func contains(point: Vector2) -> bool:
	return global_rect().grow(4.0).has_point(point)


func capacity() -> int:
	return EXPANDED_CAPACITY if has_expansion else CORRAL_CAPACITY


func _wall_height() -> float:
	return TALL_WALL_HEIGHT if has_expansion else WALL_HEIGHT


func _grow_speed() -> float:
	return FERTILIZER_SPEED if has_fertilizer else 1.0


func _crop_regrow() -> float:
	return CROP_REGROW / _grow_speed()


# ---------------------------------------------------------------- Etkileşim

func prompt_text(player_pos: Vector2) -> String:
	match kind:
		Kind.EMPTY:
			return "[E] Arsa satın al"
		Kind.CORRAL:
			if _near_collector(player_pos):
				return "[E] Gemleri al (%d)" % _stored_total()
			var text: String = "[E] Kümes · %d/%d slime" % [population, capacity()]
			if has_feeder:
				text += " · yem %d" % feeder_stock
			if crowded:
				text += " · KALABALIK!"
			return text
		Kind.FIELD:
			var fert: String = " · gübreli" if has_fertilizer else ""
			match crop_state:
				Crop.NONE:
					return "[E] Tarla: içine elma ya da havuç at" + fert
				Crop.GROWING:
					return "[E] Fidan büyüyor · %dsn%s" % [ceili(grow_left / _grow_speed()), fert]
				Crop.GROWN:
					var crop_id: String = String(crop_item.id) if crop_item != null else "apple"
					return "[E] %s%s" % [CROP_NAMES.get(crop_id, "Ürün"), fert]
	return ""


## E'ye basınca ne olacağı: &"menu", &"collect" ya da &"" (hiçbir şey).
func interact_action(player_pos: Vector2) -> StringName:
	match kind:
		Kind.EMPTY:
			return &"menu"
		Kind.CORRAL:
			return &"collect" if _near_collector(player_pos) else &"menu"
		Kind.FIELD:
			return &"menu"
	return &""


func menu_title() -> String:
	match kind:
		Kind.CORRAL:
			return "Slime Kümesi"
		Kind.FIELD:
			return "Tarla"
	return "Boş Arsa"


## [{id, text, price, enabled}]
func menu_options() -> Array:
	var ids: Array[StringName] = []
	var installed: Dictionary = {}
	if kind == Kind.EMPTY:
		ids = [&"corral", &"field"]
	elif kind == Kind.CORRAL:
		ids = [&"feeder", &"collector", &"expansion"]
		installed = {&"feeder": has_feeder, &"collector": has_collector, &"expansion": has_expansion}
	elif kind == Kind.FIELD:
		ids = [&"fertilizer"]
		installed = {&"fertilizer": has_fertilizer}
	var options: Array = []
	for id: StringName in ids:
		options.append({"id": id, "text": NAMES[id], "price": PRICES[id], "enabled": not installed.get(id, false)})
	if kind != Kind.EMPTY:
		options.append({"id": &"remove", "text": "Kümesi kaldır" if kind == Kind.CORRAL else "Tarlayı kaldır",
				"price": 0, "enabled": true})
	return options


func purchase(id: StringName) -> void:
	match id:
		&"corral":
			kind = Kind.CORRAL
		&"field":
			kind = Kind.FIELD
			crop_state = Crop.NONE
		&"feeder":
			has_feeder = true
		&"collector":
			has_collector = true
		&"expansion":
			has_expansion = true
		&"fertilizer":
			# Ağaç yeniden kurulmasın (üstündeki ürünler kaybolur): sadece hızı güncelle
			has_fertilizer = true
			if _tree != null:
				_tree.regrow_time = _crop_regrow()
			return
	_rebuild()


## Kümesi ya da tarlayı kaldırıp arsayı boşaltır.
##  - Tarla: ağaçtaki ürünler yere düşer; büyüyen fidanın tohumu geri bırakılır.
##  - Kümes: slimelara dokunulmaz; besleyicideki yiyecekler ve toplayıcıdaki
##    gemler yere bırakılır.
func remove_building() -> void:
	match kind:
		Kind.FIELD:
			if _tree != null:
				_tree.drop_all()
			elif crop_state == Crop.GROWING and crop_item != null:
				_drop_items([String(crop_item.id)], global_rect().get_center())
		Kind.CORRAL:
			if _feeder != null:
				_drop_items(feeder_items, _feeder.global_position + Vector2(0, 6))
			if _collector != null:
				var gems: Array[String] = []
				for id: String in stored:
					for i: int in int(stored[id]):
						gems.append(id)
				_drop_items(gems, _collector.global_position + Vector2(0, 6))
	kind = Kind.EMPTY
	has_feeder = false
	feeder_items.clear()
	has_collector = false
	stored = {}
	has_expansion = false
	crowded = false
	population = 0
	crop_state = Crop.NONE
	crop_item = null
	grow_left = 0.0
	has_fertilizer = false
	_rebuild()


func _drop_items(ids: Array, at: Vector2) -> void:
	for id: Variant in ids:
		var item: ItemType = ItemDatabase.get_item(str(id))
		if item == null:
			continue
		var node: Vacuumable = item.spawn(_entities, at)
		node.launch(Vector2.from_angle(randf() * TAU) * randf_range(25.0, 50.0))


## Toplayıcıdaki gemleri envantere aktarır; aktarılan adedi döner.
func take_stored(inventory: Inventory) -> int:
	var moved: int = 0
	for id: String in stored.keys():
		var item: ItemType = ItemDatabase.get_item(id)
		while item != null and stored[id] > 0 and inventory.can_add(item):
			inventory.add(item)
			stored[id] -= 1
			moved += 1
		if stored[id] <= 0:
			stored.erase(id)
	_update_labels()
	return moved


# ---------------------------------------------------------------- Kayıt

func get_state() -> Dictionary:
	var d: Dictionary = {"kind": Kind.keys()[kind].to_lower()}
	match kind:
		Kind.CORRAL:
			d["feeder"] = has_feeder
			d["feeder_items"] = feeder_items.duplicate()
			d["feeder_timer"] = _feeder_timer
			d["collector"] = has_collector
			d["stored"] = stored.duplicate()
			d["expansion"] = has_expansion
		Kind.FIELD:
			d["crop_state"] = crop_state
			d["crop"] = String(crop_item.id) if crop_item != null else ""
			d["grow_left"] = grow_left
			d["fertilizer"] = has_fertilizer
			if _tree != null:
				d["tree"] = _tree.get_state()
	return d


func set_state(d: Dictionary) -> void:
	var kind_name: String = str(d.get("kind", "empty")).to_upper()
	kind = Kind.get(kind_name, Kind.EMPTY) as Kind
	has_feeder = bool(d.get("feeder", false))
	feeder_items.clear()
	for id: Variant in d.get("feeder_items", []):
		feeder_items.append(str(id))
	for i: int in int(d.get("feeder_stock", 0)):  # eski biçim: sadece elma sayısı
		feeder_items.append("apple")
	_feeder_timer = float(d.get("feeder_timer", FEEDER_INTERVAL))
	has_collector = bool(d.get("collector", false))
	has_expansion = bool(d.get("expansion", false))
	has_fertilizer = bool(d.get("fertilizer", false))
	stored = {}
	var saved_stored: Dictionary = d.get("stored", {})
	for id: String in saved_stored:
		stored[id] = int(saved_stored[id])
	crop_state = int(d.get("crop_state", Crop.NONE)) as Crop
	crop_item = ItemDatabase.get_item(str(d["crop"])) if str(d.get("crop", "")) != "" else null
	grow_left = float(d.get("grow_left", 0.0))
	_rebuild()
	if _tree != null and d.get("tree") is Array:
		_tree.set_state(d["tree"])


# ---------------------------------------------------------------- Görünüm

func _rebuild() -> void:
	for node: Node in _parts:
		if is_instance_valid(node):
			node.queue_free()
	_parts.clear()
	_back = null
	_front = null
	_feeder = null
	_collector = null
	_sapling = null
	_tree = null
	for slime: Node in _residents:
		if is_instance_valid(slime):
			(slime as Vacuumable).corral_escape = false
	_residents.clear()

	_paint_ground(TILE_SOIL if kind == Kind.FIELD else TILE_GRASS)
	# Fırlatılan slimelar kümesin içinden atılınca duvara çarpsın diye (Vacuumable.launch)
	if kind == Kind.CORRAL:
		add_to_group(&"corrals")
	elif is_in_group(&"corrals"):
		remove_from_group(&"corrals")
	match kind:
		Kind.EMPTY:
			var sign_sprite: Sprite2D = _add_sprite(self, SIGN_TEX, Vector2(size_px.x * 0.5, size_px.y - 2.0))
			_parts.append(sign_sprite)
		Kind.CORRAL:
			_build_corral()
		Kind.FIELD:
			if crop_state == Crop.GROWING:
				_add_sapling()
			elif crop_state == Crop.GROWN:
				_add_tree()
	_update_labels()
	queue_redraw()


func _draw() -> void:
	if kind != Kind.EMPTY:
		return
	# Boş arsa: kesik çizgili sınır
	var color: Color = Color(1, 1, 1, 0.45)
	var w: float = size_px.x
	var h: float = size_px.y
	for x: int in range(0, int(w), 6):
		draw_rect(Rect2(x, 0, 3, 1), color)
		draw_rect(Rect2(x, h - 1, 3, 1), color)
	for y: int in range(0, int(h), 6):
		draw_rect(Rect2(0, y, 1, 3), color)
		draw_rect(Rect2(w - 1, y, 1, 3), color)


func _paint_ground(tile: Vector2i) -> void:
	for y: int in range(cells.position.y, cells.end.y):
		for x: int in range(cells.position.x, cells.end.x):
			_ground.set_cell(Vector2i(x, y), SOURCE_ID, tile)


func _build_corral() -> void:
	var w: float = size_px.x
	var h: float = size_px.y
	var wall_h: float = _wall_height()
	var post: Texture2D = POST_TALL_TEX if has_expansion else POST_TEX

	# Arka (üst + yan duvarlar) — düğüm üst kenarda, slimeların arkasında sıralanır
	_back = Node2D.new()
	add_child(_back)
	_parts.append(_back)
	_add_glass(_back, Rect2(0, -wall_h, w, wall_h))
	_add_glass(_back, Rect2(-1, -wall_h, 2, h))
	_add_glass(_back, Rect2(w - 1, -wall_h, 2, h))
	_add_sprite(_back, post, Vector2(0, 0))
	_add_sprite(_back, post, Vector2(w, 0))

	# Ön (alt duvar) — düğüm alt kenarda, içerdeki slimeların önünde sıralanır
	_front = Node2D.new()
	_front.position = Vector2(0, h)
	add_child(_front)
	_parts.append(_front)
	_add_glass(_front, Rect2(0, -wall_h, w, wall_h))
	_add_sprite(_front, post, Vector2(0, 0))
	_add_sprite(_front, post, Vector2(w, 0))

	# Çarpışma: sadece CORRAL_LAYER (oyuncu ve eşyalar etkilenmez)
	var walls: StaticBody2D = StaticBody2D.new()
	walls.collision_layer = Vacuumable.CORRAL_LAYER
	walls.collision_mask = 0
	add_child(walls)
	_parts.append(walls)
	var t: float = WALL_THICKNESS
	for r: Rect2 in [Rect2(0, -t * 0.5, w, t), Rect2(0, h - t * 0.5, w, t), Rect2(-t * 0.5, 0, t, h), Rect2(w - t * 0.5, 0, t, h)]:
		var shape: CollisionShape2D = CollisionShape2D.new()
		var rect_shape: RectangleShape2D = RectangleShape2D.new()
		rect_shape.size = r.size
		shape.shape = rect_shape
		shape.position = r.get_center()
		walls.add_child(shape)

	if has_feeder:
		_feeder = Node2D.new()
		_feeder.position = FEEDER_POS
		add_child(_feeder)
		_parts.append(_feeder)
		_add_sprite(_feeder, FEEDER_TEX, Vector2.ZERO)
		var intake: Area2D = Area2D.new()
		intake.collision_layer = 0
		intake.collision_mask = 8
		intake.monitorable = false
		var shape2: CollisionShape2D = CollisionShape2D.new()
		var rect2: RectangleShape2D = RectangleShape2D.new()
		rect2.size = Vector2(22, 18)
		shape2.shape = rect2
		shape2.position = Vector2(0, -6)
		intake.add_child(shape2)
		_feeder.add_child(intake)
		intake.body_entered.connect(_on_feeder_body_entered)
		_feeder_label = _add_label(_feeder, Vector2(0, -24))

	if has_collector:
		_collector = Node2D.new()
		_collector.position = Vector2(w - COLLECTOR_INSET.x, COLLECTOR_INSET.y)
		add_child(_collector)
		_parts.append(_collector)
		_add_sprite(_collector, COLLECTOR_TEX, Vector2.ZERO)
		_collector_label = _add_label(_collector, Vector2(0, -25))
	_update_crowd_tint()


func _add_glass(parent: Node2D, r: Rect2) -> void:
	var glass: Polygon2D = Polygon2D.new()
	glass.polygon = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	glass.color = GLASS
	parent.add_child(glass)
	var edge: Polygon2D = Polygon2D.new()
	edge.polygon = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y),
			Vector2(r.end.x, r.position.y + 1), Vector2(r.position.x, r.position.y + 1)])
	edge.color = GLASS_EDGE
	parent.add_child(edge)


## Alt kenarı `bottom` noktasına oturan sprite.
func _add_sprite(parent: Node2D, tex: Texture2D, bottom: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = tex
	sprite.position = bottom - Vector2(0, roundf(tex.get_height() * 0.5))
	parent.add_child(sprite)
	return sprite


func _add_label(parent: Node2D, center: Vector2) -> Label:
	var label: Label = Label.new()
	label.size = Vector2(40, 12)
	label.position = center - label.size * 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", 10)
	label.add_theme_color_override(&"font_color", LABEL_COLOR)
	label.add_theme_color_override(&"font_outline_color", Color(0.1, 0.07, 0.04))
	label.add_theme_constant_override(&"outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 4
	parent.add_child(label)
	return label


func _update_labels() -> void:
	if _feeder_label != null and is_instance_valid(_feeder_label):
		_feeder_label.text = "%d/%d" % [feeder_stock, FEEDER_MAX]
	if _collector_label != null and is_instance_valid(_collector_label):
		_collector_label.text = str(_stored_total())
		_collector_label.visible = _stored_total() > 0


func _update_crowd_tint() -> void:
	var tint: Color = CROWDED_TINT if crowded else Color.WHITE
	if _back != null:
		_back.modulate = tint
	if _front != null:
		_front.modulate = tint


func _add_sapling() -> void:
	_sapling = _add_sprite(self, SAPLING_TEX, Vector2(size_px.x * 0.5, size_px.y * 0.5 + 10.0))
	_parts.append(_sapling)


func _add_tree() -> void:
	var path: String = CROP_TREES.get(String(crop_item.id) if crop_item != null else "apple", CROP_TREES["apple"])
	_tree = (load(path) as PackedScene).instantiate() as FruitTree
	_tree.regrow_time = _crop_regrow()
	_tree.position = global_position + Vector2(size_px.x * 0.5, size_px.y * 0.5 + 12.0)
	_entities.add_child(_tree)
	_parts.append(_tree)


# ---------------------------------------------------------------- Kümes davranışı

func _physics_process(delta: float) -> void:
	match kind:
		Kind.CORRAL:
			_corral_process(delta)
		Kind.FIELD:
			_field_process(delta)


func _corral_process(delta: float) -> void:
	_pop_timer -= delta
	if _pop_timer <= 0.0:
		_pop_timer = POPULATION_INTERVAL
		_update_population()

	if has_feeder:
		_feeder_timer -= delta
		if _feeder_timer <= 0.0:
			_feeder_timer = FEEDER_INTERVAL
			if feeder_stock > 0 and _any_hungry_inside() and not _food_inside():
				_drop_food()  # sadece içerdeki aç bir slime'ın yiyebileceği yiyecek atılır

	if has_collector:
		var mouth: Vector2 = _collector.global_position + Vector2(0, -12)
		var area: Rect2 = global_rect()
		var changed: bool = false
		for node: Node in get_tree().get_nodes_in_group(&"pickups"):
			var p: Pickup = node as Pickup
			if p == null or p.item.category != ItemType.Category.GEM or not area.has_point(p.global_position):
				continue
			var ours: bool = p.has_meta(&"collector") and p.get_meta(&"collector") == self
			if not ours and not p.is_available():
				continue
			p.set_meta(&"collector", self)
			if p.vacuum_pull(mouth, delta):
				var id: String = String(p.item.id)
				stored[id] = int(stored.get(id, 0)) + 1
				p.queue_free()
				changed = true
		if changed:
			_update_labels()


## İçerdeki slimeları say; kapasite aşıldıysa duvarları onlar için kapat (kaçabilirler).
func _update_population() -> void:
	var area: Rect2 = global_rect()
	var inside: Array = []
	var weight: int = 0
	for node: Node in get_tree().get_nodes_in_group(&"slimes"):
		var s: Slime = node as Slime
		if s == null or s.motion != Vacuumable.Motion.GROUNDED or not area.has_point(s.global_position):
			continue
		inside.append(s)
		weight += LARGE_SLIME_WEIGHT if s.slime_type.is_large() else 1
	population = weight
	var was_crowded: bool = crowded
	crowded = weight > capacity()
	for s: Node in inside:
		(s as Vacuumable).corral_escape = crowded
	for s: Node in _residents:
		if is_instance_valid(s) and not inside.has(s):
			(s as Vacuumable).corral_escape = false  # kaçtı: dışarıda yine duvara çarpsın
	_residents = inside
	if crowded != was_crowded:
		_update_crowd_tint()


func _any_hungry_inside() -> bool:
	for s: Node in _residents:
		if is_instance_valid(s) and (s as Slime).is_hungry():
			return true
	return false


## Kümeste, içerdeki aç bir slime'ın yiyebileceği yiyecek var mı?
func _food_inside() -> bool:
	var area: Rect2 = global_rect()
	for node: Node in get_tree().get_nodes_in_group(&"food"):
		var p: Pickup = node as Pickup
		if p != null and p.is_available() and area.has_point(p.global_position) and _wanted_by_resident(p.item):
			return true
	return false


func _wanted_by_resident(food: ItemType) -> bool:
	for s: Node in _residents:
		if is_instance_valid(s) and (s as Slime).can_eat(food):
			return true
	return false


## Besleyici, sıradaki yiyeceği kümesin ortasına doğru fırlatır.
func _drop_food() -> void:
	# Kuyrukta içerdeki aç slimeların yiyebileceği ilk yiyeceği seç
	var food: ItemType = null
	for i: int in feeder_items.size():
		var candidate: ItemType = ItemDatabase.get_item(feeder_items[i])
		if candidate != null and _wanted_by_resident(candidate):
			food = candidate
			feeder_items.remove_at(i)
			break
	if food == null:
		return
	_update_labels()
	var from: Vector2 = _feeder.global_position + Vector2(8, 4)
	var target: Vector2 = global_rect().get_center() + Vector2(randf_range(-20, 20), randf_range(-12, 12))
	var dropped: Vacuumable = food.spawn(_entities, from)
	dropped.set_meta(&"from_feeder", true)
	# Uçuş ~0.5 sn ve sürtünmeli: hızı mesafeye göre ayarla
	var to_target: Vector2 = target - from
	dropped.launch(to_target.normalized() * to_target.length() * 2.9)


func _on_feeder_body_entered(body: Node2D) -> void:
	var p: Pickup = body as Pickup
	if p == null or p.motion != Vacuumable.Motion.LAUNCHED or p.has_meta(&"from_feeder"):
		return
	if p.item.category != ItemType.Category.FOOD or p.item.food_kind == ItemType.FoodKind.NONE or feeder_stock >= FEEDER_MAX:
		return
	p.consume_into(_feeder)
	feeder_items.append(String(p.item.id))
	Sfx.play_at("vacuum_pop", _feeder.global_position)
	_update_labels()
	Fx.pop_text(_feeder, Vector2(0, -30), "+1", Color(0.5, 0.9, 0.5))


func _near_collector(player_pos: Vector2) -> bool:
	return has_collector and _collector != null \
			and player_pos.distance_to(_collector.global_position) <= COLLECTOR_INTERACT_RANGE


func _stored_total() -> int:
	var total: int = 0
	for id: String in stored:
		total += int(stored[id])
	return total


# ---------------------------------------------------------------- Tarla davranışı

func _field_process(delta: float) -> void:
	match crop_state:
		Crop.NONE:
			_field_timer -= delta
			if _field_timer <= 0.0:
				_field_timer = FIELD_CHECK_INTERVAL
				_try_plant()
		Crop.GROWING:
			grow_left -= delta * _grow_speed()
			if _sapling != null:
				var s: float = lerpf(1.0, 0.55, clampf(grow_left / GROW_TIME, 0.0, 1.0))
				_sapling.scale = Vector2(s, s)
			if grow_left <= 0.0:
				crop_state = Crop.GROWN
				_rebuild()
				# Elmalar sırayla, küçük bir "pop" ile belirsin
				_tree.set_state([0.0, 0.4, 0.8])
				Fx.pop_text(self, Vector2(size_px.x * 0.5, 4), "Ağaç büyüdü!", Color(0.6, 1.0, 0.6))


## Tarlada yerde duran ekilebilir bir yiyecek varsa ek.
func _try_plant() -> void:
	var area: Rect2 = global_rect()
	for node: Node in get_tree().get_nodes_in_group(&"food"):
		var p: Pickup = node as Pickup
		if p == null or not p.is_available() or not area.has_point(p.global_position):
			continue
		if not CROP_TREES.has(String(p.item.id)):
			continue
		crop_item = p.item
		crop_state = Crop.GROWING
		grow_left = GROW_TIME
		_rebuild()
		p.consume_into(_sapling)
		Fx.pop_text(self, Vector2(size_px.x * 0.5, 4), "Ekildi!", Color(0.6, 1.0, 0.6))
		return

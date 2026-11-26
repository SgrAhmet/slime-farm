class_name FruitTree
extends StaticBody2D
## Ürün kaynağı: üzerinde 3 ürün durur (elma ağacında dallarda asılı elmalar,
## havuç yığınında toprağa gömülü havuçlar). Vakumla çekilen ürünün yeri
## regrow_time saniye sonra yeniden ürün verir.

const APPLE: ItemType = preload("res://data/items/apple.tres")
const GROW_POP_TIME: float = 0.25

@export var regrow_time: float = 60.0
## false ise süs ağacıdır: ürün vermez.
@export var bears_fruit: bool = true
## Verdiği ürün (boşsa elma).
@export var produce: ItemType
## Ürün görsellerinin kaynağın dibine göre konumları (x, y = yukarı yükseklik).
@export var slot_offsets: Array[Vector2] = [Vector2(-8, -27), Vector2(7, -31), Vector2(-1, -38)]
## Ürünler toprağa gömülü görünsün mü (havuç).
@export var planted_look: bool = false

var _apples: Array = [null, null, null]
var _has_apple: Array[bool] = [false, false, false]
var _timers: Array[float] = [0.0, 0.0, 0.0]


func _ready() -> void:
	set_physics_process(bears_fruit)


func _physics_process(delta: float) -> void:
	for i: int in slot_offsets.size():
		if _has_apple[i]:
			var apple: Variant = _apples[i]
			if is_instance_valid(apple) and (apple as Pickup).is_hanging():
				continue
			# Elma daldan koptu (vakumlandı): yeniden büyüme sayacını başlat
			_has_apple[i] = false
			_apples[i] = null
			_timers[i] = regrow_time
		else:
			_timers[i] -= delta
			if _timers[i] <= 0.0:
				_grow(i, true)


## Tüm dallara elma koy (yeni oyun).
func fill_all() -> void:
	if not bears_fruit:
		return
	for i: int in slot_offsets.size():
		if not _has_apple[i]:
			_grow(i, false)


## Kayıt için: dal başına -1 (elma var) ya da kalan büyüme süresi.
func get_state() -> Array:
	var state: Array = []
	for i: int in slot_offsets.size():
		state.append(-1.0 if _has_apple[i] else maxf(_timers[i], 0.0))
	return state


func set_state(state: Array) -> void:
	for i: int in slot_offsets.size():
		if _has_apple[i] and is_instance_valid(_apples[i]):
			(_apples[i] as Node).queue_free()
		_has_apple[i] = false
		_apples[i] = null
		var value: float = float(state[i]) if i < state.size() else -1.0
		if value < 0.0:
			_grow(i, false)
		else:
			_timers[i] = value


## Kaynak kaldırılırken üstündeki ürünleri yere düşürür (artık bağlı değiller).
func drop_all() -> void:
	for i: int in slot_offsets.size():
		if _has_apple[i] and is_instance_valid(_apples[i]):
			(_apples[i] as Pickup).drop_from_source()
		_has_apple[i] = false
		_apples[i] = null
	set_physics_process(false)


func _grow(i: int, animate: bool) -> void:
	var offset: Vector2 = slot_offsets[i]
	# Orijin ağaç dibinin hemen önünde: y-sıralamada ağacın üstünde çizilsin
	var apple: Pickup = _produce().spawn(get_parent(), global_position + Vector2(offset.x, 1.0)) as Pickup
	apple.hang(offset.y, planted_look)
	_apples[i] = apple
	_has_apple[i] = true
	if animate:
		apple.sprite.scale = Vector2.ZERO
		apple.create_tween().tween_property(apple.sprite, "scale", Vector2.ONE, GROW_POP_TIME) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _produce() -> ItemType:
	return produce if produce != null else APPLE

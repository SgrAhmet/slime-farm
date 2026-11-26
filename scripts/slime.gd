class_name Slime
extends Vacuumable
## Barışçıl slime: rastgele zıplayarak gezer, oyuncuya saldırmaz.
##
## Beslenme: her tür sadece diyetindeki yiyecekleri yer (SlimeType.diet:
## meyve / sebze / et). Açken yiyecek bulamazsa kafasının üstünde istediği
## yiyeceğin ikonunu gösterir.
## Normal slime:
##  - Açken diyetine uyan yiyeceği yer -> mutlu olur, kendi geminden 1 tane verir, tok olur.
##  - Başka renkte bir gem görünce (aç/tok fark etmez) yer -> büyük slime'a dönüşür.
## Büyük slime (bir türün gövdesi + diğerinin benekleri, iki türün özellikleri):
##  - Gem yemez. Açken elma yer -> kendi geminden ve ikinci renginin geminden
##    birer tane verir, tok olur.

enum State { IDLE, SQUASH, HOP, LAND, EAT, HAPPY, TRANSFORM }

# Sprite sheet sütunları (satır = item.sheet_row)
const FRAME_IDLE: int = 0
const FRAME_IDLE_2: int = 1
const FRAME_SQUASH: int = 2
const FRAME_STRETCH: int = 3
const FRAME_SCARED: int = 4
const FRAME_SCARED_2: int = 5
const FRAME_CHOMP_OPEN: int = 6
const FRAME_CHOMP_CLOSED: int = 7
const FRAME_HAPPY: int = 8
const FRAME_CONTENT: int = 9
const FRAME_CONTENT_2: int = 10
const FRAME_COUNT: int = 11

const SQUASH_TIME: float = 0.12
const LAND_TIME: float = 0.1
const HOP_TIME: float = 0.4

const FOOD_SENSE_RANGE: float = 80.0
const EAT_RANGE: float = 12.0
const LARGE_EAT_RANGE: float = 16.0
const SMALL_BODY_RADIUS: float = 6.0
const LARGE_BODY_RADIUS: float = 9.0
const BONK_TIME: float = 0.2
const EAT_TIME: float = 1.2
const CHOMP_PERIOD: float = 0.24
const HAPPY_TIME: float = 1.0
const TRANSFORM_TIME: float = 1.2
const GEM_POP_SPEED: float = 45.0
## Aç ve yiyecek yokken istediği yiyeceği gösterme aralığı (saniye).
const WANT_INTERVAL: float = 7.0
## Diyet biti -> ikonu gösterilecek yiyecek
const DIET_ICON_ITEMS: Array[String] = ["apple", "carrot", "hen"]

const SMALL_SHEET: Texture2D = preload("res://assets/slimes.png")
const LARGE_SHEET: Texture2D = preload("res://assets/slimes_large.png")
const SMALL_BASE_Y: float = -SlimeLooks.SMALL_TILE / 2.0
const LARGE_BASE_Y: float = -SlimeLooks.LARGE_TILE / 2.0
const LARGE_SHAPE_SIZE: Vector2 = Vector2(16, 6)

const HEART_TEX: Texture2D = preload("res://assets/fx_heart.png")
const ALERT_TEX: Texture2D = preload("res://assets/fx_alert.png")
const SPARKLE_TEX: Texture2D = preload("res://assets/fx_sparkle.png")

var state: State = State.IDLE
var slime_type: SlimeType:
	get:
		return item as SlimeType

var _timer: float = 0.0
## Oyun saati bu değeri geçince (Game.play_time, saniye) slime acıkır.
var _hungry_at: float = 0.0
var _noticed_food: bool = false
## Şu an yenmekte olan eşya (yeme bitince sonucu buna göre belirlenir).
var _eaten: ItemType = null
## Ekranda gösterilen tür; dönüşüm sırasında item'dan bir süre geride kalır.
var _visual_type: SlimeType = null
var _want_timer: float = randf_range(2.0, WANT_INTERVAL)

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var _small_shape: Shape2D = collision.shape
@onready var _small_shape_pos: Vector2 = collision.position


func _ready() -> void:
	if item == null:
		item = SlimeRegistry.base_types()[0]  # editörden türsüz konduysa
	super()
	add_to_group(&"slimes")
	_apply_visuals(slime_type)
	_enter_idle()


func is_hungry() -> bool:
	return _now() >= _hungry_at


func get_carry_data() -> Dictionary:
	return {"hungry_at": _hungry_at}


func apply_carry_data(data: Dictionary) -> void:
	_hungry_at = data.get("hungry_at", 0.0)


## Bu slime şu an bu eşyayı yiyebilir mi?
func can_eat(food_item: ItemType) -> bool:
	match food_item.category:
		ItemType.Category.FOOD:
			return is_hungry() and (slime_type.diet & food_item.food_bit()) != 0
		ItemType.Category.GEM:
			# Normal slime, kendi rengi dışındaki gemleri her zaman yer
			return not slime_type.is_large() \
					and food_item != slime_type.gem \
					and SlimeRegistry.type_for_gem(food_item) != null
	return false


## Fırlatılan bir şey çarptı: beklerken kısa bir ezilme ("bonk").
func bonk(_from_dir: Vector2) -> void:
	if motion == Motion.GROUNDED and (state == State.IDLE or state == State.LAND):
		_change_state(State.LAND, BONK_TIME)


func _grounded_process(delta: float) -> void:
	_timer -= delta
	match state:
		State.IDLE:
			var target: Pickup = _nearest_edible(_eat_range())
			if target != null:
				_start_eating(target)
				return
			if is_hungry():
				_set_frame(FRAME_IDLE if fmod(_time, 1.0) < 0.5 else FRAME_IDLE_2)
				_want_timer -= delta
				if _want_timer <= 0.0:
					_want_timer = WANT_INTERVAL + randf_range(-1.5, 1.5)
					_show_want()
			else:
				_set_frame(FRAME_CONTENT if fmod(_time, 1.4) < 0.7 else FRAME_CONTENT_2)
			if _timer <= 0.0:
				_change_state(State.SQUASH, SQUASH_TIME)
		State.SQUASH:
			_set_frame(FRAME_SQUASH)
			if _timer <= 0.0:
				_start_hop()
		State.HOP:
			_set_frame(FRAME_STRETCH)
			if _fly_step(delta) >= 1.0:
				_on_landed()
		State.LAND:
			_set_frame(FRAME_SQUASH)
			if _timer <= 0.0:
				_enter_idle()
		State.EAT:
			# Çiğneme: ağız aç-kapa, her ısırıkta gövde hafifçe ezilir
			var chomp_closed: bool = fmod(_timer, CHOMP_PERIOD) < CHOMP_PERIOD * 0.5
			_set_frame(FRAME_CHOMP_CLOSED if chomp_closed else FRAME_CHOMP_OPEN)
			sprite.scale = Vector2(1.1, 0.9) if chomp_closed else Vector2.ONE
			if _timer <= 0.0:
				_finish_eating()
		State.HAPPY:
			# İki küçük sevinç zıplaması
			var t: float = 1.0 - _timer / HAPPY_TIME
			sprite.position.y = sprite_base_y - absf(sin(t * TAU)) * 4.0
			_set_frame(FRAME_HAPPY)
			if _timer <= 0.0:
				sprite.position.y = sprite_base_y
				_enter_idle()
		State.TRANSFORM:
			_transform_process()


func _on_landed() -> void:
	if _visual_type != slime_type:
		_apply_visuals(slime_type)  # dönüşüm vakumla yarıda kesildiyse tamamla
	velocity = Vector2.ZERO
	sprite.position.y = sprite_base_y
	sprite.modulate = Color.WHITE
	_change_state(State.LAND, LAND_TIME)


func _pull_visual() -> void:
	sprite.modulate = Color.WHITE
	_set_frame(FRAME_SCARED if fmod(_time, 0.16) < 0.08 else FRAME_SCARED_2)


func _launched_visual() -> void:
	_set_frame(FRAME_STRETCH)


func _start_hop() -> void:
	var dir: Vector2 = Vector2.from_angle(randf() * TAU)
	var speed: float = slime_type.hop_speed
	var target: Pickup = _nearest_edible(FOOD_SENSE_RANGE)
	if target != null:
		# Hedefe doğru zıpla; yakınsa üstüne inecek kadar kısa zıpla
		var to_target: Vector2 = target.global_position - global_position
		dir = to_target.normalized()
		speed = minf(speed, to_target.length() / HOP_TIME)
	_start_flight(dir, speed, 0.0, HOP_TIME, slime_type.hop_height)
	Sfx.play_at("slime_hop", global_position)
	_change_state(State.HOP, HOP_TIME)


func _enter_idle() -> void:
	var wait: float = randf_range(slime_type.idle_time_min, slime_type.idle_time_max)
	if _nearest_edible(FOOD_SENSE_RANGE) != null:
		if not _noticed_food:
			_noticed_food = true
			Fx.pop_icon(self, Vector2(0, sprite_base_y * 2.0 - 4.0), ALERT_TEX)
		wait = 0.25
	else:
		_noticed_food = false
	_change_state(State.IDLE, wait)


func _start_eating(target: Pickup) -> void:
	_eaten = target.item
	target.consume_into(self)
	Sfx.play_at("slime_eat", global_position)
	_noticed_food = false
	Fx.pop_icon(self, Vector2(0, _head_y()), HEART_TEX)
	_change_state(State.EAT, EAT_TIME)


func _finish_eating() -> void:
	sprite.scale = Vector2.ONE
	var eaten: ItemType = _eaten
	_eaten = null
	if eaten != null and eaten.category == ItemType.Category.GEM:
		var other: SlimeType = SlimeRegistry.type_for_gem(eaten)
		if other != null and not slime_type.is_large():
			_start_transform(other)
			return
	_start_happy(eaten)


## Yiyecek yedikten sonra: sevinç, kalpler, gem(ler), tokluk.
## Favori yiyecekse her gemden 2 tane.
func _start_happy(eaten: ItemType = null) -> void:
	_hungry_at = _now() + slime_type.full_duration
	var head: float = _head_y()
	Fx.pop_icon(self, Vector2(-6, head), HEART_TEX, 0.0)
	Fx.pop_icon(self, Vector2(6, head - 2), HEART_TEX, 0.2)
	Fx.pop_icon(self, Vector2(0, head - 4), HEART_TEX, 0.4)

	Sfx.play_at("slime_happy", global_position)
	Sfx.play_at("gem", global_position)
	var gems: Array[ItemType] = []
	if slime_type.gem != null:
		gems.append(slime_type.gem)
	if slime_type.is_large() and slime_type.secondary.gem != null:
		gems.append(slime_type.secondary.gem)
	if eaten != null and slime_type.favorites().has(eaten):
		gems.append_array(gems.duplicate())
		Fx.pop_text(self, Vector2(0, head - 12), "Favori! x2", Color(1.0, 0.6, 0.8))
	var base_angle: float = randf() * TAU
	for i: int in gems.size():
		var angle: float = base_angle + TAU * i / gems.size()
		var gem: Vacuumable = gems[i].spawn(get_parent(), global_position)
		gem.launch(Vector2.from_angle(angle) * GEM_POP_SPEED)
	_change_state(State.HAPPY, HAPPY_TIME)


## Başka renkte gem yedikten sonra büyük slime'a dönüşüm.
## Tür hemen değişir (vakumlanırsa doğru türde girsin), görünüm yarıda değişir.
func _start_transform(other: SlimeType) -> void:
	item = SlimeRegistry.hybrid(slime_type, other)
	Sfx.play_at("slime_transform", global_position)
	_change_state(State.TRANSFORM, TRANSFORM_TIME)


func _transform_process() -> void:
	var t: float = 1.0 - _timer / TRANSFORM_TIME
	if t >= 0.5 and _visual_type != slime_type:
		_apply_visuals(slime_type)
		for i: int in 3:
			Fx.pop_icon(self, Vector2(randf_range(-10, 10), _head_y() + randf_range(-2, 6)), SPARKLE_TEX, i * 0.08)

	# Hızlanarak yanıp sönen parlama + giderek sönen esneme
	var blink_period: float = lerpf(0.2, 0.06, t)
	var bright: bool = t < 0.85 and fmod(_timer, blink_period) < blink_period * 0.5
	sprite.modulate = Color(1.8, 1.8, 1.8) if bright else Color.WHITE
	var pulse: float = 1.0 + sin(t * PI * 8.0) * 0.15 * (1.0 - t)
	sprite.scale = Vector2(pulse, 1.0 / pulse)
	_set_frame(FRAME_HAPPY if t >= 0.5 else FRAME_SCARED)

	if _timer <= 0.0:
		sprite.modulate = Color.WHITE
		sprite.scale = Vector2.ONE
		Fx.pop_icon(self, Vector2(-7, _head_y()), HEART_TEX, 0.0)
		Fx.pop_icon(self, Vector2(7, _head_y() - 2), HEART_TEX, 0.15)
		_enter_idle()


## Sprite sheet, boyut, gölge ve çarpışmayı türe göre ayarlar.
func _apply_visuals(t: SlimeType) -> void:
	_visual_type = t
	if t.is_large():
		sprite.texture = LARGE_SHEET
		sprite.vframes = SlimeRegistry.hybrid_count()
		sprite_base_y = LARGE_BASE_Y
		shadow.scale = Vector2(1.5, 1.5)
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = LARGE_SHAPE_SIZE
		collision.shape = shape
		collision.position = Vector2(0, -LARGE_SHAPE_SIZE.y * 0.5)
		body_radius = LARGE_BODY_RADIUS
	else:
		body_radius = SMALL_BODY_RADIUS
		sprite.texture = SMALL_SHEET
		sprite.vframes = SlimeLooks.type_count()
		sprite_base_y = SMALL_BASE_Y
		shadow.scale = Vector2.ONE
		collision.shape = _small_shape
		collision.position = _small_shape_pos
	sprite.hframes = FRAME_COUNT
	sprite.position.y = sprite_base_y


## Kafasının üstünde diyetindeki yiyeceklerden birinin ikonu belirir.
func _show_want() -> void:
	if _noticed_food:
		return
	var options: Array[String] = []
	for i: int in DIET_ICON_ITEMS.size():
		if slime_type.diet & (1 << i):
			options.append(DIET_ICON_ITEMS[i])
	if options.is_empty():
		return
	var food: ItemType = ItemDatabase.get_item(options.pick_random())
	# Yarı yarıya favorisini göster
	var favs: Array[ItemType] = slime_type.favorites()
	if not favs.is_empty() and randf() < 0.5:
		food = favs.pick_random()
	if food != null:
		Fx.pop_icon(self, Vector2(0, _head_y() - 4), food.icon)


func _nearest_edible(max_range: float) -> Pickup:
	var best: Pickup = null
	var best_dist: float = max_range
	for node: Node in get_tree().get_nodes_in_group(&"pickups"):
		var p: Pickup = node as Pickup
		if p == null or not p.is_available() or not can_eat(p.item):
			continue
		var dist: float = global_position.distance_to(p.global_position)
		if dist <= best_dist:
			best = p
			best_dist = dist
	return best


func _eat_range() -> float:
	return LARGE_EAT_RANGE if slime_type.is_large() else EAT_RANGE


## Kafanın biraz üstü (efektler için).
func _head_y() -> float:
	return sprite_base_y * 2.0 - 2.0


func _change_state(new_state: State, duration: float) -> void:
	state = new_state
	_timer = duration


func _set_frame(column: int) -> void:
	sprite.frame_coords = Vector2i(column, _visual_type.sheet_row)


## Oyun saati (kayıtla birlikte saklanır; açlık buna göre işler).
func _now() -> float:
	return Game.play_time

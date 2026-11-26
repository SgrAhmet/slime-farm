class_name ChickenNest
extends Node2D
## Tavuk yuvası: meyve ağacı mantığıyla çevresinde en fazla MAX_BIRDS kuş tutar.
## Biri vakumlanıp götürülür ya da yenirse SPAWN_TIME saniye sonra yenisi çıkar
## (çoğunlukla civciv, bazen tavuk ya da horoz).

const MAX_BIRDS: int = 3
## Bu yarıçaptaki kuşlar yuvanınki sayılır (piksel).
const RADIUS: float = 72.0
const SPAWN_TIME: float = 45.0
const COUNT_INTERVAL: float = 0.5
## [kimlik, olasılık eşiği (birikimli)]
const SPAWN_TABLE: Array = [["chick", 0.5], ["hen", 0.85], ["rooster", 1.0]]
const POP_TIME: float = 0.3

var _timer: float = SPAWN_TIME
var _count_timer: float = 0.0
var _nearby: int = 0


func _physics_process(delta: float) -> void:
	_count_timer -= delta
	if _count_timer <= 0.0:
		_count_timer = COUNT_INTERVAL
		_nearby = _count_nearby()
	if _nearby >= MAX_BIRDS:
		_timer = SPAWN_TIME
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = SPAWN_TIME
		spawn_bird(true)
		_nearby += 1


## Yeni oyunda yuvayı doldurur.
func fill(count: int = 2) -> void:
	for i: int in count:
		spawn_bird(false)


func spawn_bird(animate: bool) -> Node:
	var roll: float = randf()
	var id: String = "hen"
	for row: Array in SPAWN_TABLE:
		if roll <= float(row[1]):
			id = row[0]
			break
	var item: ItemType = ItemDatabase.get_item(id)
	var offset: Vector2 = Vector2.from_angle(randf() * TAU) * randf_range(10.0, 20.0)
	var bird: Vacuumable = item.spawn(get_parent(), global_position + offset)
	bird.set(&"home", global_position)
	if animate:
		bird.sprite.scale = Vector2.ZERO
		bird.create_tween().tween_property(bird.sprite, "scale", Vector2.ONE, POP_TIME) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return bird


## Kayıt için: sıradaki kuşa kalan süre.
func get_state() -> float:
	return _timer


func set_state(value: float) -> void:
	_timer = clampf(value, 0.0, SPAWN_TIME)


func _count_nearby() -> int:
	var n: int = 0
	for node: Node in get_tree().get_nodes_in_group(&"chickens"):
		var v: Vacuumable = node as Vacuumable
		if v != null and v.motion == Vacuumable.Motion.GROUNDED \
				and v.global_position.distance_to(global_position) <= RADIUS:
			n += 1
	return n

class_name Vacuumable
extends CharacterBody2D
## Vakumla çekilebilen ve fırlatılabilen dünya nesnelerinin ortak tabanı
## (slimelar, elmalar, gemler). Alt sınıflar yerdeki davranışı
## _grounded_process() ile tanımlar.

enum Motion { GROUNDED, SUCKED, LAUNCHED }

const LAUNCH_TIME: float = 0.5
const LAUNCH_HEIGHT: float = 8.0
const LAUNCH_DRAG: float = 0.6
## Kümes duvarlarının fizik katmanı (5. katman). Dışarıdan fırlatılan slime
## uçarken bu katmanı yok sayar (kümese girebilir); kümesin İÇİNDEN fırlatılan
## slime ise duvara çarpıp içeride kalır.
const CORRAL_LAYER: int = 16
# Uçarken bir slime'a çarpınca: hafif geri seker ve hemen yere düşer
const HIT_BOUNCE_SPEED: float = 22.0
const HIT_BOUNCE_DRAG: float = 0.5
const HIT_SETTLE_TIME: float = 0.15

# Vakumda çekilme: yavaş başlar, giderek hızlanır, ağza yaklaştıkça küçülür
const PULL_START_SPEED: float = 10.0
const PULL_ACCEL: float = 90.0
const PULL_MAX_SPEED: float = 110.0
const SHRINK_DISTANCE: float = 18.0
const CAPTURE_DISTANCE: float = 1.5

@export var item: ItemType
## Sprite'ın yerdeyken durduğu y konumu (alt kenarı gövde orijininde olsun diye).
@export var sprite_base_y: float = -8.0
## Yerdeki gövde yarıçapı (çarpışma kontrolü için, piksel).
@export var body_radius: float = 3.0

var motion: Motion = Motion.GROUNDED
var _time: float = 0.0
var _move_dir: Vector2 = Vector2.ZERO
var _move_speed: float = 0.0
var _move_drag: float = 0.0
var _fly_timer: float = 0.0
var _fly_duration: float = 1.0
var _fly_height: float = 0.0
var _pull_speed: float = 0.0
var _last_pull_frame: int = -100
## Bu uçuşta çarpılmayacak slimelar (fırlatma anında zaten temas edenler + çarpılanlar).
var _launch_ignore: Array[Node] = []
var _base_mask: int = 1
## Bu uçuşta kümes duvarlarının üstünden geçebilir mi (dışarıdan atıldıysa evet).
var _fly_over_corral: bool = true
## true iken kümes duvarları yok sayılır (kümes aşırı kalabalıkken kaçış).
var corral_escape: bool = false:
	set(value):
		corral_escape = value
		_refresh_mask()

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow


func _ready() -> void:
	add_to_group(&"vacuumable")
	_time = randf() * 10.0  # animasyonlar senkron olmasın
	_base_mask = collision_mask


func _refresh_mask() -> void:
	var mask: int = _base_mask
	if (motion == Motion.LAUNCHED and _fly_over_corral) or corral_escape:
		mask &= ~CORRAL_LAYER
	collision_mask = mask


func _physics_process(delta: float) -> void:
	_time += delta
	match motion:
		Motion.GROUNDED:
			_grounded_process(delta)
		Motion.SUCKED:
			# Vakum bu karede çekmeyi bıraktıysa serbest kal
			if Engine.get_physics_frames() - _last_pull_frame > 1:
				release()
		Motion.LAUNCHED:
			var t: float = _fly_step(delta)
			var s: float = minf(1.0, 0.35 + t * 2.0)
			sprite.scale = Vector2(s, s)
			_launched_visual()
			if t >= 1.0:
				_settle()
			else:
				_check_launch_hits()


## Vakumun nişan aldığı nokta: sprite'ın merkezi (ayak değil).
func get_aim_point() -> Vector2:
	return global_position + Vector2(0.0, sprite_base_y)


func can_be_sucked() -> bool:
	return motion != Motion.LAUNCHED


func is_being_sucked() -> bool:
	return motion == Motion.SUCKED


## Vakum her fizik karesinde çağırır. Nesne ağza girdiyse true döner.
func vacuum_pull(target: Vector2, delta: float) -> bool:
	if motion != Motion.SUCKED:
		motion = Motion.SUCKED
		_pull_speed = PULL_START_SPEED
		velocity = Vector2.ZERO
		shadow.visible = false
		z_index = 1
	_last_pull_frame = Engine.get_physics_frames()

	_pull_speed = minf(_pull_speed + PULL_ACCEL * delta, PULL_MAX_SPEED)
	global_position = global_position.move_toward(target, _pull_speed * delta)
	var dist: float = global_position.distance_to(target)

	# Ağza yaklaştıkça küçül, çekilirken titre ve esne
	var size: float = lerpf(0.1, 1.0, clampf(dist / SHRINK_DISTANCE, 0.0, 1.0))
	var wobble: float = sin(_time * 35.0) * 0.08
	sprite.scale = Vector2(size * (1.0 + wobble), size * (1.0 - wobble))
	sprite.position = Vector2(roundf(sin(_time * 50.0)) * size, sprite_base_y * size)
	_pull_visual()
	return dist <= CAPTURE_DISTANCE


## Vakum bıraktığında nesne yere düşer.
func release() -> void:
	if motion == Motion.SUCKED:
		_settle()


## Vakumdan fırlatma: verilen hızla uçar, yavaşlar ve yere iner.
func launch(launch_velocity: Vector2) -> void:
	_start_flight(launch_velocity.normalized(), launch_velocity.length(), LAUNCH_DRAG, LAUNCH_TIME, LAUNCH_HEIGHT)
	motion = Motion.LAUNCHED
	_fly_over_corral = not _is_inside_corral()
	_refresh_mask()
	shadow.visible = true
	z_index = 0
	_launch_ignore = []
	for node: Node in get_tree().get_nodes_in_group(&"slimes"):
		if node != self and _touches(node as Vacuumable):
			_launch_ignore.append(node)


## Çarpan bir nesneye tepki (alt sınıflar doldurur).
func bonk(_from_dir: Vector2) -> void:
	pass


## Envanterde saklanacak, bu nesneye özel durum (ör. slime'ın tokluğu).
func get_carry_data() -> Dictionary:
	return {}


func apply_carry_data(_data: Dictionary) -> void:
	pass


# --- Alt sınıfların doldurduğu kancalar ---

func _grounded_process(_delta: float) -> void:
	pass


func _on_landed() -> void:
	pass


func _pull_visual() -> void:
	pass


func _launched_visual() -> void:
	pass


# --- Uçuş yardımcıları (zıplama ve fırlatma ortak) ---

func _start_flight(dir: Vector2, speed: float, drag: float, duration: float, height: float) -> void:
	_move_dir = dir
	_move_speed = speed
	_move_drag = drag
	_fly_duration = duration
	_fly_height = height
	_fly_timer = 0.0


## Uçuşu bir kare ilerletir; 0..1 arası ilerleme döner.
func _fly_step(delta: float) -> float:
	_fly_timer += delta
	var t: float = clampf(_fly_timer / _fly_duration, 0.0, 1.0)
	velocity = _move_dir * _move_speed * (1.0 - t * _move_drag)
	move_and_slide()
	if get_slide_collision_count() > 0:
		_move_dir = _move_dir.bounce(get_slide_collision(0).get_normal())
	sprite.position.y = sprite_base_y - sin(t * PI) * _fly_height
	return t


## Şu an bir kümesin içinde mi? (Kümesler "corrals" grubunda, global_rect() verir.)
func _is_inside_corral() -> bool:
	for corral: Node in get_tree().get_nodes_in_group(&"corrals"):
		var rect: Rect2 = corral.call(&"global_rect")
		if rect.has_point(global_position):
			return true
	return false


func _touches(other: Vacuumable) -> bool:
	return other != null and other.motion == Motion.GROUNDED \
			and global_position.distance_to(other.global_position) <= body_radius + other.body_radius


## Uçarken yere basan bir slime'a değdiysek geri sek ve hemen düş.
func _check_launch_hits() -> void:
	for node: Node in get_tree().get_nodes_in_group(&"slimes"):
		var other: Vacuumable = node as Vacuumable
		if other == self or _launch_ignore.has(other) or not _touches(other):
			continue
		var away: Vector2 = global_position - other.global_position
		away = away.normalized() if away.length_squared() > 0.01 else -_move_dir
		_move_dir = away
		_move_speed = HIT_BOUNCE_SPEED
		_move_drag = HIT_BOUNCE_DRAG
		_fly_timer = maxf(_fly_timer, _fly_duration - HIT_SETTLE_TIME)
		_launch_ignore.append(other)
		other.bonk(-away)
		return


func _settle() -> void:
	velocity = Vector2.ZERO
	sprite.position = Vector2(0.0, sprite_base_y)
	sprite.scale = Vector2.ONE
	sprite.modulate = Color.WHITE
	shadow.visible = true
	z_index = 0
	motion = Motion.GROUNDED
	_refresh_mask()
	_on_landed()

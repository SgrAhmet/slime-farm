class_name Chicken
extends Pickup
## Tavuk, horoz ya da civciv. Yuvasının (home) çevresinde yürüyüp gagalar.
## Tavuk ve horoz et yiyen slimelar için yiyecektir (ItemType.food_kind = MEAT);
## civciv yenmez, GROW_TIME oyun saniyesi sonra tavuğa ya da horoza dönüşür.

enum State { IDLE, WALK, PECK }

const FRAME_IDLE: int = 0
const FRAME_WALK_A: int = 1
const FRAME_WALK_B: int = 2
const FRAME_PECK: int = 3
const FRAME_FLAP_A: int = 4
const FRAME_FLAP_B: int = 5

const CHICK_ID: StringName = &"chick"
## Civcivin büyüme süresi (oyun saniyesi).
const GROW_TIME: float = 120.0
const ROOSTER_CHANCE: float = 0.35
const WALK_SPEED: float = 16.0
const CHICK_WALK_SPEED: float = 12.0
## Yuvadan bu kadar uzaklaşınca geri döner (piksel).
const LEASH: float = 56.0
const SPARKLE_TEX: Texture2D = preload("res://assets/fx_sparkle.png")

var state: State = State.IDLE
## Gezindiği merkez (yuva ya da bırakıldığı yer).
var home: Vector2 = Vector2.INF
var _timer: float = 0.0
var _walk_dir: Vector2 = Vector2.ZERO
## Civciv bu oyun saatinde büyür (Game.play_time).
var _grow_at: float = -1.0
var _cluck_timer: float = randf_range(3.0, 14.0)


func _ready() -> void:
	super()
	add_to_group(&"chickens")
	if home == Vector2.INF:
		home = global_position
	if is_chick() and _grow_at < 0.0:
		_grow_at = Game.play_time + GROW_TIME
	_enter_idle()


func is_chick() -> bool:
	return item.id == CHICK_ID


func get_carry_data() -> Dictionary:
	return {"grow_at": _grow_at} if is_chick() else {}


func apply_carry_data(data: Dictionary) -> void:
	if data.has("grow_at"):
		_grow_at = float(data["grow_at"])


## Civcivi hemen büyüt (debug ve testler için de kullanılır).
func grow_up() -> void:
	if not is_chick():
		return
	# (hen.tres bu sahneyi kullandığı için preload döngüsü olmasın: çalışma anında yükle)
	item = ItemDatabase.get_item("rooster" if randf() < ROOSTER_CHANCE else "hen")
	_grow_at = -1.0
	Sfx.play_at("chicken", global_position)
	for i: int in 3:
		Fx.pop_icon(self, Vector2(randf_range(-6, 6), -14 + randf_range(-2, 2)), SPARKLE_TEX, i * 0.1)
	_set_frame(FRAME_IDLE)


func _grounded_process(delta: float) -> void:
	if _consumed:
		return
	if is_chick() and _grow_at >= 0.0 and Game.play_time >= _grow_at:
		grow_up()
	_timer -= delta
	_cluck_timer -= delta
	if _cluck_timer <= 0.0:
		_cluck_timer = randf_range(6.0, 16.0)
		Sfx.play_at("chick" if is_chick() else "chicken", global_position)
	match state:
		State.IDLE:
			_set_frame(FRAME_IDLE)
			if _timer <= 0.0:
				if randf() < 0.45:
					_change_state(State.PECK, randf_range(0.6, 1.4))
				else:
					_start_walk()
		State.WALK:
			var speed: float = CHICK_WALK_SPEED if is_chick() else WALK_SPEED
			velocity = _walk_dir * speed
			move_and_slide()
			if get_slide_collision_count() > 0:
				_walk_dir = _walk_dir.bounce(get_slide_collision(0).get_normal())
			sprite.flip_h = _walk_dir.x < 0.0
			_set_frame(FRAME_WALK_A if fmod(_time, 0.3) < 0.15 else FRAME_WALK_B)
			if _timer <= 0.0:
				velocity = Vector2.ZERO
				_enter_idle()
		State.PECK:
			_set_frame(FRAME_PECK if fmod(_time, 0.4) < 0.2 else FRAME_IDLE)
			if _timer <= 0.0:
				_enter_idle()


func _start_walk() -> void:
	var to_home: Vector2 = home - global_position
	if to_home.length() > LEASH:
		_walk_dir = to_home.normalized().rotated(randf_range(-0.4, 0.4))
	else:
		_walk_dir = Vector2.from_angle(randf() * TAU)
	_change_state(State.WALK, randf_range(0.6, 1.6))


func _enter_idle() -> void:
	_change_state(State.IDLE, randf_range(0.5, 2.0))


func _change_state(s: State, duration: float) -> void:
	state = s
	_timer = duration


func _on_landed() -> void:
	# Vakumdan fırlatılıp düştüğü yer yeni gezinme merkezi olur
	home = global_position
	_enter_idle()


func _pull_visual() -> void:
	_set_frame(FRAME_FLAP_A if fmod(_time, 0.12) < 0.06 else FRAME_FLAP_B)


func _launched_visual() -> void:
	_set_frame(FRAME_FLAP_A if fmod(_time, 0.16) < 0.08 else FRAME_FLAP_B)


func _set_frame(column: int) -> void:
	sprite.frame_coords = Vector2i(column, item.sheet_row)

class_name Player
extends CharacterBody2D
## Top-down oyuncu: 8 yönde hareket eder, sprite 4 yönden birine bakar.
## Vakum kullanılırken mouse'a doğru döner.

enum Facing { DOWN, UP, LEFT, RIGHT }

## Sprite sheet sütunları: 0 duruş, 1 adım A, 2 adım B.
const WALK_CYCLE: Array[int] = [1, 0, 2, 0]

## Yürüme hızı (piksel/saniye). Çaprazda da aynı kalır.
@export var speed: float = 80.0
## Yürüme animasyonunun saniyedeki kare sayısı.
@export var walk_fps: float = 8.0

var facing: Facing = Facing.DOWN
## Kapalıyken (ekran geçişlerinde) oyuncu hareket etmez ve vakum çalışmaz.
## Not: process_mode ile dondurmuyoruz; o, gövdeyi fizikten çıkarıp
## ışınlanma sonrası eski konumda alan tetiklenmesine yol açıyor.
var input_enabled: bool = true:
	set(value):
		input_enabled = value
		if vacuum_gun != null:
			vacuum_gun.enabled = value
var _anim_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var inventory: Inventory = $Inventory
@onready var vacuum_gun: VacuumGun = $VacuumGun


func _physics_process(delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO
	if input_enabled:
		dir = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = dir * speed
	move_and_slide()
	if vacuum_gun.is_active():
		_face_toward(vacuum_gun.aim_dir)
	else:
		_update_facing(dir)
	_update_gun_layer()
	_update_animation(delta, dir != Vector2.ZERO)


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	for i: int in Inventory.SLOT_COUNT:
		if event.is_action_pressed(StringName("slot_%d" % (i + 1))):
			inventory.select(i)
			return
	if event.is_action_pressed(&"slot_next"):
		inventory.select_offset(1)
	elif event.is_action_pressed(&"slot_prev"):
		inventory.select_offset(-1)


## Kamerayı harita sınırları (piksel) içinde tutar.
func set_camera_limits(bounds: Rect2i) -> void:
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.end.x
	camera.limit_bottom = bounds.end.y


## Oyuncuyu ışınlar (interpolasyon aradaki yolu çizmesin diye sıfırlanır).
func teleport(pos: Vector2) -> void:
	position = pos
	reset_physics_interpolation()


func _update_facing(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	var horizontal: Facing = Facing.RIGHT if dir.x > 0.0 else Facing.LEFT
	var vertical: Facing = Facing.DOWN if dir.y > 0.0 else Facing.UP
	if dir.x != 0.0 and dir.y != 0.0:
		# Çaprazda, zaten bastığımız yönlerden birine bakıyorsak onu koru
		if facing != horizontal and facing != vertical:
			facing = horizontal
	elif dir.x != 0.0:
		facing = horizontal
	else:
		facing = vertical


func _face_toward(v: Vector2) -> void:
	if absf(v.x) >= absf(v.y):
		facing = Facing.RIGHT if v.x > 0.0 else Facing.LEFT
	else:
		facing = Facing.DOWN if v.y > 0.0 else Facing.UP


## Yukarı bakarken silah karakterin arkasında çizilir.
func _update_gun_layer() -> void:
	var behind: bool = facing == Facing.UP
	var gun_index: int = vacuum_gun.get_index()
	var sprite_index: int = sprite.get_index()
	if behind != (gun_index < sprite_index):
		move_child(vacuum_gun, sprite_index)


func _update_animation(delta: float, moving: bool) -> void:
	var column: int = 0
	if moving:
		_anim_time += delta
		var index: int = int(_anim_time * walk_fps) % WALK_CYCLE.size()
		column = WALK_CYCLE[index]
	else:
		_anim_time = 0.0
	sprite.frame_coords = Vector2i(column, facing)

class_name Pickup
extends Vacuumable
## Yerde duran eşya (elma, havuç, gem). Vakumla alınabilir; yiyecekse slimelar yer.
## Kaynağına bağlı da durabilir (hang): ağaçta asılı elma ya da toprağa gömülü
## havuç. O zaman yenmez; vakumla çekilince kaynağından kopar.

const DEFAULT_BASE_Y: float = -7.0
## Sprite sheet sütunları
const FRAME_NORMAL: int = 0
const FRAME_SPARKLE: int = 1
const FRAME_PLANTED: int = 2

var _consumed: bool = false
var _hanging: bool = false
## Bağlıyken "toprağa gömülü" karesini kullan (havuç).
var _planted_look: bool = false


func _ready() -> void:
	super()
	add_to_group(&"pickups")
	if item.category == ItemType.Category.FOOD:
		add_to_group(&"food")
	sprite.frame_coords = Vector2i(0, item.sheet_row)


## Kaynağına bağlan: görsel, gövde orijininin `height` piksel üstünde çizilir.
## (Orijin kaynağın dibinde kalır ki y-sıralamada kaynağın önünde görünsün.)
## planted_look: toprağa gömülü karesi (sadece tepesi görünür).
func hang(height: float, planted_look: bool = false) -> void:
	_hanging = true
	_planted_look = planted_look
	sprite_base_y = height
	sprite.position.y = height
	shadow.visible = false
	if planted_look:
		sprite.frame_coords = Vector2i(FRAME_PLANTED, item.sheet_row)


func is_hanging() -> bool:
	return _hanging


## Yerde duruyor ve henüz yenmemiş mi?
func is_available() -> bool:
	return motion == Motion.GROUNDED and not _consumed and not _hanging


func can_be_sucked() -> bool:
	return super() and not _consumed


func vacuum_pull(target: Vector2, delta: float) -> bool:
	if _hanging:
		_detach()
	return super(target, delta)


## Bir slime tarafından yenir: ağzına doğru kayıp küçülerek kaybolur.
func consume_into(eater: Node2D) -> void:
	_consumed = true
	motion = Motion.GROUNDED  # uçuyorsa uçuşu durdur
	velocity = Vector2.ZERO
	remove_from_group(&"vacuumable")
	remove_from_group(&"pickups")
	remove_from_group(&"food")
	shadow.visible = false
	z_index = 1
	var tween: Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_parallel()
	tween.tween_property(self, "global_position", eater.global_position, 0.15)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	tween.chain().tween_callback(queue_free)


func _grounded_process(_delta: float) -> void:
	if _consumed:
		return
	if _hanging and _planted_look:
		return  # gömülü karede sabit
	var sparkle: bool
	if item.category == ItemType.Category.GEM:
		# Gemler hafifçe süzülür ve sık parlar
		sparkle = fmod(_time, 0.8) < 0.3
		sprite.position.y = sprite_base_y - (1.0 if fmod(_time, 1.2) < 0.6 else 0.0)
	else:
		sparkle = fmod(_time, 2.0) < 0.25
	sprite.frame_coords = Vector2i(FRAME_SPARKLE if sparkle else FRAME_NORMAL, item.sheet_row)


func _launched_visual() -> void:
	sprite.frame_coords = Vector2i(FRAME_NORMAL, item.sheet_row)


func _pull_visual() -> void:
	sprite.frame_coords = Vector2i(FRAME_NORMAL, item.sheet_row)


## Kaynağı kaldırıldı: kopup aşağı doğru yere düşer.
func drop_from_source() -> void:
	if not _hanging:
		return
	_detach()
	launch(Vector2(randf_range(-20.0, 20.0), randf_range(30.0, 50.0)))


## Kaynağından kop: orijini görselin olduğu yere taşı, normal eşya gibi davran.
func _detach() -> void:
	_hanging = false
	_planted_look = false
	global_position.y += sprite_base_y - DEFAULT_BASE_Y
	sprite_base_y = DEFAULT_BASE_Y
	reset_physics_interpolation()

extends Node2D
## Ana menü: "Oyuna Başla" -> 3 kayıt slotu (boşsa yeni oyun, doluysa yükle,
## eski sürümse yüklenemez) + her slotta onaylı "Sil" / "Çıkış".
## Arka planda çimenli çiftlik ve yerinde zıplayan slimelar.

const SLIME_SHEET: Texture2D = preload("res://assets/slimes.png")

const MENU_SIZE: Vector2i = Vector2i(20, 12)
const FENCE_ROW: int = 10
const SOURCE_ID: int = 0
const TILE_GRASS: Vector2i = Vector2i(0, 0)
const TILE_GRASS_ALT: Vector2i = Vector2i(1, 0)
const TILE_FENCE: Vector2i = Vector2i(4, 0)

const SLIME_FRAME_IDLE: int = 0
const SLIME_FRAME_SQUASH: int = 2
const SLIME_FRAME_STRETCH: int = 3
const SLIME_GROUND_Y: float = 158.0
const SLIME_SPACING: float = 30.0
const SLIME_MARGIN: float = 16.0
const HOP_HEIGHT: float = 10.0
const FADE_TIME: float = 0.35

var _slimes: Array[Sprite2D] = []
var _time: float = 0.0
var _leaving: bool = false
## Silme onayı bekleyen slot (-1 = yok). İlk tık "Emin?" yapar, ikinci tık siler.
var _pending_delete: int = -1

@onready var ground: TileMapLayer = $Ground
@onready var fences: TileMapLayer = $Fences
@onready var decor: Node2D = $Decor
@onready var main_buttons: VBoxContainer = %MainButtons
@onready var slot_buttons: VBoxContainer = %SlotButtons
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var back_button: Button = %BackButton
@onready var fade: ColorRect = %Fade


func _ready() -> void:
	Game.in_game = false
	Game.time_paused = false
	Game.current_slot = -1
	_build_background()
	_spawn_decor_slimes()

	start_button.pressed.connect(_show_slots)
	quit_button.pressed.connect(get_tree().quit)
	back_button.pressed.connect(_show_main)
	var buttons: Array[Button] = [start_button, quit_button, back_button]
	for i: int in Game.SLOT_COUNT:
		_slot_button(i).pressed.connect(_on_slot_pressed.bind(i))
		_delete_button(i).pressed.connect(_on_delete_pressed.bind(i))
		buttons.append(_slot_button(i))
		buttons.append(_delete_button(i))

	# Fare hangi butonun üstündeyse odak da orada olsun (tek vurgu)
	for button: Button in buttons:
		button.mouse_entered.connect(button.grab_focus)

	_show_main()
	fade.color.a = 1.0
	create_tween().tween_property(fade, "color:a", 0.0, FADE_TIME)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and slot_buttons.visible:
		_show_main()


func _process(delta: float) -> void:
	_time += delta
	for i: int in _slimes.size():
		# Her slime farklı fazda: döngünün %60'ı havada, kalanı yerde
		var phase: float = fmod(_time * 1.3 + i * 0.33, 1.0)
		var column: int = SLIME_FRAME_IDLE
		var lift: float = 0.0
		if phase < 0.6:
			lift = sin(phase / 0.6 * PI) * HOP_HEIGHT
			column = SLIME_FRAME_STRETCH
		elif phase < 0.68 or phase > 0.94:
			column = SLIME_FRAME_SQUASH
		_slimes[i].offset.y = -roundf(lift)
		_slimes[i].frame_coords = Vector2i(column, i)


func _show_main() -> void:
	slot_buttons.visible = false
	main_buttons.visible = true
	start_button.grab_focus()


func _show_slots() -> void:
	_pending_delete = -1
	_refresh_slots()
	main_buttons.visible = false
	slot_buttons.visible = true
	# Odağı ilk oynanabilir slota ver (eski sürüm slotlar devre dışı)
	for i: int in Game.SLOT_COUNT:
		if not _slot_button(i).disabled:
			_slot_button(i).grab_focus()
			return
	back_button.grab_focus()


func _refresh_slots() -> void:
	for i: int in Game.SLOT_COUNT:
		var status: Game.SlotStatus = Game.slot_status(i)
		var slot_button: Button = _slot_button(i)
		var delete_button: Button = _delete_button(i)
		match status:
			Game.SlotStatus.EMPTY:
				slot_button.text = "Slot %d · Boş (Yeni Oyun)" % (i + 1)
			Game.SlotStatus.OLD:
				slot_button.text = "Slot %d · Eski sürüm" % (i + 1)
			Game.SlotStatus.OK:
				slot_button.text = "Slot %d · %s" % [i + 1, Game.slot_summary(i)]
		# Eski sürüm kayıtlar oynanamaz; sadece silinebilir
		slot_button.disabled = status == Game.SlotStatus.OLD
		delete_button.visible = status != Game.SlotStatus.EMPTY
		delete_button.text = "Emin?" if _pending_delete == i else "Sil"


func _on_slot_pressed(slot: int) -> void:
	if _leaving or Game.slot_status(slot) == Game.SlotStatus.OLD:
		return
	_leaving = true
	var tween: Tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, FADE_TIME)
	if Game.has_save(slot):
		tween.tween_callback(Game.load_slot.bind(slot))
	else:
		tween.tween_callback(Game.start_new.bind(slot))


func _on_delete_pressed(slot: int) -> void:
	if _pending_delete == slot:
		Game.delete_save(slot)
		_pending_delete = -1
		_refresh_slots()
		_slot_button(slot).grab_focus()
	else:
		_pending_delete = slot
		_refresh_slots()


func _slot_button(i: int) -> Button:
	return slot_buttons.get_child(i).get_child(0) as Button


func _delete_button(i: int) -> Button:
	return slot_buttons.get_child(i).get_child(1) as Button


func _build_background() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	for y: int in MENU_SIZE.y:
		for x: int in MENU_SIZE.x:
			var tile: Vector2i = TILE_GRASS_ALT if rng.randf() < 0.12 else TILE_GRASS
			ground.set_cell(Vector2i(x, y), SOURCE_ID, tile)
	for x: int in MENU_SIZE.x:
		fences.set_cell(Vector2i(x, FENCE_ROW), SOURCE_ID, TILE_FENCE)


func _spawn_decor_slimes() -> void:
	var count: int = SlimeRegistry.BASE_TYPE_PATHS.size()
	for i: int in count:
		var slime: Sprite2D = Sprite2D.new()
		slime.texture = SLIME_SHEET
		slime.hframes = 11
		slime.vframes = count
		slime.frame_coords = Vector2i(SLIME_FRAME_IDLE, i)
		decor.add_child(slime)
		_slimes.append(slime)
	_place_decor_slimes()


func _place_decor_slimes() -> void:
	var view: Vector2 = get_viewport_rect().size
	var count: int = _slimes.size()
	var spacing: float = minf(SLIME_SPACING, (view.x - SLIME_MARGIN * 2.0) / maxf(count - 1, 1))
	for i: int in count:
		_slimes[i].position = Vector2(roundf(view.x * 0.5 + (i - (count - 1) * 0.5) * spacing),
				SLIME_GROUND_Y - SlimeLooks.SMALL_TILE / 2.0)

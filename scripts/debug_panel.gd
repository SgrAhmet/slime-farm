class_name DebugPanel
extends PanelContainer
## Test kolaylığı için debug paneli (F1 ile aç/kapat): oyuncu hızı, zamanı
## durdurma/ileri alma, para, bölgelere ışınlanma, slime açlığı, civciv
## büyütme, envantere eşya ekleme, anında kayıt.
## Panel açıkken ve fare üstündeyken vakum ateşlemez (VacuumGun kontrol eder).

const UI_THEME: Theme = preload("res://assets/ui_theme.tres")
const FONT_SIZE: int = 8
const WIDTH: float = 128.0
const BUTTON_COLOR: Color = Color("6e4a2c")
const BUTTON_HOVER: Color = Color("8f6038")
const BUTTON_PRESSED: Color = Color("4a301c")
const SPEED_STEPS: Array = [[1.0, "Normal"], [2.5, "Hızlı"], [5.0, "Çok hızlı"]]
const SKIP_TIME: float = Game.DAY_LENGTH / 8.0  # 3 oyun saati
const TELEPORTS: Array = [["Çiftlik", -1], ["Orman", WorldGen.Region.FOREST],
		["Yayla", WorldGen.Region.HIGHLANDS], ["Dağlar", WorldGen.Region.MOUNTAINS]]

static var _instance: DebugPanel = null

var farm: Node
var _speed_index: int = 0
var _base_speed: float = 0.0
var _speed_button: Button
var _time_button: Button


## Fare açık debug panelinin üstünde mi? (Vakum tıklamayı yok saysın diye.)
static func blocks_mouse() -> bool:
	if _instance == null or not is_instance_valid(_instance) or not _instance.visible:
		return false
	return _instance.get_global_rect().has_point(_instance.get_viewport().get_mouse_position())


func _ready() -> void:
	_instance = self
	theme = UI_THEME
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchor_left = 1.0
	anchor_right = 1.0
	offset_left = -WIDTH - 4.0
	offset_right = -4.0
	offset_top = 20.0
	add_theme_stylebox_override(&"panel", _box_style(Color(0.08, 0.06, 0.1, 0.85), Color("5a4a6a"), 3))
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 2)
	add_child(box)
	var title: Label = Label.new()
	title.text = "DEBUG  (F1 kapat)"
	title.add_theme_font_size_override(&"font_size", FONT_SIZE)
	title.add_theme_color_override(&"font_color", Color(0.95, 0.9, 0.43))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 2)
	grid.add_theme_constant_override(&"v_separation", 2)
	box.add_child(grid)

	_speed_button = _add(grid, "", _cycle_speed)
	_time_button = _add(grid, "", _toggle_time)
	_add(grid, "+3 saat", _skip_time)
	_add(grid, "+10.000 para", _add_money.bind(10000))
	for tp: Array in TELEPORTS:
		_add(grid, "> " + tp[0], _teleport.bind(tp[1]))
	_add(grid, "Slime acıktır", _set_hunger.bind(true))
	_add(grid, "Slime doyur", _set_hunger.bind(false))
	_add(grid, "Civciv büyüt", _grow_chicks)
	_add(grid, "Şimdi kaydet", _save_now)
	_add(grid, "+Meyveler", _give_all.bind(["apple", "star_fruit", "moon_grape"], 5))
	_add(grid, "+Sebzeler", _give_all.bind(["carrot", "beet", "ice_radish"], 5))
	_add(grid, "+Etler", _give_all.bind(["hen", "rock_hen"], 3))
	_add(grid, "Tümünü keşfet", func() -> void: farm.call(&"debug_discover_all"))
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_F1:
		visible = not visible
		get_viewport().set_input_as_handled()


func _add(parent: Control, text: String, action: Callable) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2((WIDTH - 8.0) / 2.0, 11)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_text = true
	b.add_theme_font_size_override(&"font_size", FONT_SIZE)
	b.add_theme_stylebox_override(&"normal", _box_style(BUTTON_COLOR, BUTTON_COLOR.darkened(0.4), 1))
	b.add_theme_stylebox_override(&"hover", _box_style(BUTTON_HOVER, BUTTON_COLOR.darkened(0.4), 1))
	b.add_theme_stylebox_override(&"pressed", _box_style(BUTTON_PRESSED, BUTTON_COLOR.darkened(0.4), 1))
	b.pressed.connect(action)
	parent.add_child(b)
	return b


func _box_style(bg: Color, border: Color, margin: int) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_content_margin_all(margin)
	return sb


func _refresh() -> void:
	_speed_button.text = "Hız: %s" % SPEED_STEPS[_speed_index][1]
	_time_button.text = "Zaman: %s" % ("DURDU" if Game.time_paused else "akıyor")


func _player() -> Player:
	return farm.get(&"player") as Player


func _cycle_speed() -> void:
	var player: Player = _player()
	if _base_speed <= 0.0:
		_base_speed = player.speed
	_speed_index = (_speed_index + 1) % SPEED_STEPS.size()
	player.speed = _base_speed * float(SPEED_STEPS[_speed_index][0])
	_refresh()


func _toggle_time() -> void:
	Game.time_paused = not Game.time_paused
	_refresh()


func _skip_time() -> void:
	Game.play_time += SKIP_TIME


func _add_money(amount: int) -> void:
	_player().inventory.add_money(amount)


func _teleport(region: int) -> void:
	farm.call(&"debug_teleport", region)


func _set_hunger(hungry: bool) -> void:
	for node: Node in get_tree().get_nodes_in_group(&"slimes"):
		node.call(&"apply_carry_data", {"hungry_at": 0.0 if hungry else Game.play_time + 300.0})


func _grow_chicks() -> void:
	for node: Node in get_tree().get_nodes_in_group(&"chickens"):
		if node.has_method(&"grow_up"):
			node.call(&"grow_up")


func _save_now() -> void:
	farm.call(&"debug_save")


func _give_all(ids: Array, count: int) -> void:
	for id: String in ids:
		_give(id, count)


func _give(id: String, count: int) -> void:
	var item: ItemType = ItemDatabase.get_item(id)
	for i: int in count:
		if not _player().inventory.add(item):
			break

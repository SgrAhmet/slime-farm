class_name SlimeBook
extends PanelContainer
## Slime Kitabı (B): 12 temel türün adı, resmi, yaşadığı yer, beslenmesi ve
## favori yiyeceği. Bir tür envantere ilk kez alınınca keşfedilir; o zamana kadar
## bilgileri gizlidir ("???", kararmış resim).

signal closed

const UI_THEME: Theme = preload("res://assets/ui_theme.tres")
const SLIME_SHEET: Texture2D = preload("res://assets/slimes.png")
const TITLE_COLOR: Color = Color(0.95, 0.91, 0.43)
const LABEL_COLOR: Color = Color(1, 0.95, 0.84)
const DIM_COLOR: Color = Color(0.75, 0.7, 0.62)
const LOCKED_TINT: Color = Color(0, 0, 0, 0.75)
const GRID_COLUMNS: int = 3
const CELL: int = 24
const SHEET_TILE: int = 20
## Sprite sheet sütunu: tok duruş (gülümseyen)
const PORTRAIT_FRAME: int = 9

## Türlerin kısa tanımları (kimlik -> metin).
const DESCRIPTIONS: Dictionary = {
	"red": "Neşeli ve meraklı. Elma kokusunu uzaktan alır.",
	"blue": "Sakin bir çiftlik dostu, sebze bahçelerinden ayrılmaz.",
	"gray": "Taş gibi sert görünür ama tavuk görünce coşar.",
	"pink": "Her şeyi yer, her yerde yaşar. Tatlı ama obur.",
	"cat": "Kulakları her sese döner; tavuk kovalamaya bayılır.",
	"bunny": "En yükseğe o zıplar. Havuca dayanamaz.",
	"mushroom": "Ormanın serin gölgesinde ağır ağır gezinir.",
	"dragon": "Küçük boynuzlu, yaylanın inatçı ruhu.",
	"leaf": "Başındaki filizle güneşlenmeyi sever.",
	"goat": "Sarp kayalıklarda bile sağlam basar.",
	"snow": "Karlı tepelerden inmiş; serinliği sever.",
	"feather": "Minik kanatlarıyla en hızlı zıplayan slime.",
}

## Keşfedilen tür kimlikleri (farm.gd doldurur ve kaydeder).
var discovered: Dictionary = {}
## Tür kimliği -> bulunduğu bölgeler metni (farm.gd verir).
var regions: Dictionary = {}

var _types: Array[SlimeType] = []
var _buttons: Array[Button] = []
var _selected: int = 0
var _title: Label
var _portrait: TextureRect
var _name: Label
var _lines: Array[Label] = []
var _fav_icon: TextureRect
var _fav_label: Label
var _desc: Label


func _ready() -> void:
	theme = UI_THEME
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 8
	offset_top = 8
	offset_right = -8
	offset_bottom = -8
	# Opak arka plan: alttaki dünya ve yazılar görünmesin
	var bg: StyleBoxFlat = StyleBoxFlat.new()
	bg.bg_color = Color(0.11, 0.09, 0.13)
	bg.border_color = Color(0.35, 0.29, 0.42)
	bg.set_border_width_all(1)
	bg.set_content_margin_all(6)
	add_theme_stylebox_override(&"panel", bg)
	_types = SlimeRegistry.base_types()
	_build()


func open() -> void:
	_refresh()
	visible = true
	(func() -> void: _buttons[_selected].grab_focus()).call_deferred()


func close() -> void:
	if visible:
		visible = false
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _build() -> void:
	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override(&"separation", 4)
	add_child(root)

	_title = _label(10, TITLE_COLOR)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_title)

	var body: HBoxContainer = HBoxContainer.new()
	body.add_theme_constant_override(&"separation", 8)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)

	var grid: GridContainer = GridContainer.new()
	grid.columns = GRID_COLUMNS
	grid.add_theme_constant_override(&"h_separation", 2)
	grid.add_theme_constant_override(&"v_separation", 2)
	body.add_child(grid)
	for i: int in _types.size():
		var b: Button = Button.new()
		b.custom_minimum_size = Vector2(CELL, CELL)
		b.icon = _types[i].icon
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.expand_icon = false
		b.toggle_mode = true
		for state: StringName in [&"normal", &"hover", &"pressed", &"focus"]:
			var box: StyleBoxFlat = StyleBoxFlat.new()
			box.bg_color = Color(0.2, 0.15, 0.12) if state != &"pressed" else Color(0.45, 0.32, 0.2)
			box.border_color = Color(0.95, 0.91, 0.43) if state == &"focus" or state == &"pressed" else Color(0.35, 0.29, 0.42)
			box.set_border_width_all(1)
			box.set_content_margin_all(2)
			b.add_theme_stylebox_override(state, box)
		b.pressed.connect(_select.bind(i))
		b.focus_entered.connect(_select.bind(i))
		grid.add_child(b)
		_buttons.append(b)

	var detail: VBoxContainer = VBoxContainer.new()
	detail.add_theme_constant_override(&"separation", 2)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail)

	var top: HBoxContainer = HBoxContainer.new()
	top.add_theme_constant_override(&"separation", 6)
	detail.add_child(top)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(40, 40)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top.add_child(_portrait)
	var info: VBoxContainer = VBoxContainer.new()
	info.add_theme_constant_override(&"separation", 1)
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_child(info)
	_name = _label(10, TITLE_COLOR)
	info.add_child(_name)
	for i: int in 2:
		var line: Label = _label(8, LABEL_COLOR)
		info.add_child(line)
		_lines.append(line)

	var fav_row: HBoxContainer = HBoxContainer.new()
	fav_row.add_theme_constant_override(&"separation", 2)
	detail.add_child(fav_row)
	var fav_title: Label = _label(8, LABEL_COLOR)
	fav_title.text = "Favorisi:"
	fav_row.add_child(fav_title)
	_fav_icon = TextureRect.new()
	_fav_icon.custom_minimum_size = Vector2(16, 16)
	_fav_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	fav_row.add_child(_fav_icon)
	_fav_label = _label(8, LABEL_COLOR)
	fav_row.add_child(_fav_label)
	var fav_note: Label = _label(8, DIM_COLOR)
	fav_note.text = "(2x gem)"
	fav_row.add_child(fav_note)

	_desc = _label(8, DIM_COLOR)
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.custom_minimum_size = Vector2(150, 0)
	detail.add_child(_desc)

	var footer: Label = _label(8, DIM_COLOR)
	footer.text = "Vakumla yakaladığın türler açılır  ·  [B] / Esc kapat"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(footer)


func _label(font_size: int, color: Color) -> Label:
	var l: Label = Label.new()
	l.add_theme_font_size_override(&"font_size", font_size)
	l.add_theme_color_override(&"font_color", color)
	return l


func _refresh() -> void:
	var count: int = 0
	for i: int in _types.size():
		var known: bool = _is_known(i)
		if known:
			count += 1
		_buttons[i].modulate = Color.WHITE
		_buttons[i].add_theme_color_override(&"icon_normal_color", Color.WHITE if known else LOCKED_TINT)
		_buttons[i].add_theme_color_override(&"icon_hover_color", Color.WHITE if known else LOCKED_TINT)
		_buttons[i].add_theme_color_override(&"icon_pressed_color", Color.WHITE if known else LOCKED_TINT)
		_buttons[i].add_theme_color_override(&"icon_focus_color", Color.WHITE if known else LOCKED_TINT)
	_title.text = "Slime Kitabı  ·  %d / %d keşfedildi" % [count, _types.size()]
	_select(_selected)


func _is_known(i: int) -> bool:
	return discovered.has(String(_types[i].id))


func _select(i: int) -> void:
	_selected = i
	# Klavye odağı da seçilene geçsin (tek vurgulu kutu)
	if visible and not _buttons[i].has_focus():
		_buttons[i].grab_focus()
	for j: int in _buttons.size():
		_buttons[j].set_pressed_no_signal(j == i)
	var t: SlimeType = _types[i]
	var known: bool = _is_known(i)
	var portrait: AtlasTexture = AtlasTexture.new()
	portrait.atlas = SLIME_SHEET
	portrait.region = Rect2(PORTRAIT_FRAME * SHEET_TILE, t.sheet_row * SHEET_TILE, SHEET_TILE, SHEET_TILE)
	_portrait.texture = portrait
	_portrait.modulate = Color.WHITE if known else LOCKED_TINT
	if known:
		_name.text = t.display_name
		_lines[0].text = "Yaşadığı yer: %s" % regions.get(String(t.id), "?")
		_lines[1].text = "Beslenme: %s" % t.diet_text()
		_fav_icon.texture = t.favorite.icon if t.favorite != null else null
		_fav_label.text = t.favorite.display_name if t.favorite != null else "-"
		_desc.text = DESCRIPTIONS.get(String(t.id), "")
	else:
		_name.text = "???"
		_lines[0].text = "Yaşadığı yer: ???"
		_lines[1].text = "Beslenme: ???"
		_fav_icon.texture = null
		_fav_label.text = "???"
		_desc.text = "Bu slime'ı vakumla yakalayınca bilgileri açılır."

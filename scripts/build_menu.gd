class_name BuildMenu
extends PanelContainer
## Satın alma penceresi: başlık, para, fiyatlı seçenekler ve "Kapat".
## Seçenek: {"id": StringName, "text": String, "price": int, "enabled": bool}

signal option_chosen(id: StringName)
signal closed

const UI_THEME: Theme = preload("res://assets/ui_theme.tres")
const TITLE_COLOR: Color = Color(0.94902, 0.909804, 0.427451)
const MONEY_COLOR: Color = Color(0.95, 0.79, 0.3)


var _box: VBoxContainer


func _ready() -> void:
	theme = UI_THEME
	visible = false
	_box = VBoxContainer.new()
	_box.add_theme_constant_override(&"separation", 5)
	add_child(_box)


func open(title: String, options: Array, money: int) -> void:
	for child: Node in _box.get_children():
		child.queue_free()

	var title_label: Label = Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override(&"font_color", TITLE_COLOR)
	_box.add_child(title_label)

	var money_label: Label = Label.new()
	money_label.text = "Paran: %d" % money
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_color_override(&"font_color", MONEY_COLOR)
	_box.add_child(money_label)

	var first: Button = null
	for option: Dictionary in options:
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(170, 0)
		if option.get("enabled", true):
			button.text = "%s · %d" % [option["text"], option["price"]] if int(option["price"]) > 0 else str(option["text"])
			button.pressed.connect(option_chosen.emit.bind(option["id"]))
			if first == null:
				first = button
		else:
			button.text = "%s · kurulu" % option["text"]
			button.disabled = true
		button.mouse_entered.connect(button.grab_focus)
		_box.add_child(button)

	var close_button: Button = Button.new()
	close_button.text = "Kapat"
	close_button.custom_minimum_size = Vector2(72, 0)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(close)
	close_button.mouse_entered.connect(close_button.grab_focus)
	_box.add_child(close_button)

	visible = true
	_center.call_deferred()
	(first if first != null else close_button).grab_focus.call_deferred()


func _center() -> void:
	reset_size()
	position = ((get_viewport_rect().size - size) * 0.5).floor()


func close() -> void:
	if visible:
		visible = false
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

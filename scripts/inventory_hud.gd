class_name InventoryHud
extends Control
## Ekranın altında envanter slotlarını, sol üstte parayı piksel piksel çizer.

const SLOT_SIZE: int = 20
const SLOT_GAP: int = 2
const MARGIN_BOTTOM: int = 4
const DIGITS: Texture2D = preload("res://assets/digits.png")
const COIN: Texture2D = preload("res://assets/coin.png")
const MONEY_POS: Vector2i = Vector2i(4, 4)
const MONEY_SCALE: int = 2
const COLOR_MONEY: Color = Color("f2c94c")
const COLOR_BG: Color = Color(0.08, 0.06, 0.1, 0.7)
const COLOR_BORDER: Color = Color("5a4a6a")
const COLOR_SELECTED: Color = Color("f2e86d")
const COLOR_SHADOW: Color = Color(0, 0, 0, 0.8)

var inventory: Inventory:
	set(value):
		inventory = value
		if inventory != null and not inventory.contents_changed.is_connected(queue_redraw):
			inventory.contents_changed.connect(queue_redraw)
		queue_redraw()


func _draw() -> void:
	if inventory == null:
		return
	var count: int = Inventory.SLOT_COUNT
	var total_width: int = count * SLOT_SIZE + (count - 1) * SLOT_GAP
	var origin: Vector2i = Vector2i(floori((size.x - total_width) / 2.0), floori(size.y) - SLOT_SIZE - MARGIN_BOTTOM)

	for i: int in count:
		var is_selected: bool = i == inventory.selected
		var pos: Vector2i = origin + Vector2i(i * (SLOT_SIZE + SLOT_GAP), -2 if is_selected else 0)
		var rect: Rect2 = Rect2(pos, Vector2(SLOT_SIZE, SLOT_SIZE))
		draw_rect(rect, COLOR_BG)
		_draw_frame(rect, COLOR_SELECTED if is_selected else COLOR_BORDER)

		var item: ItemType = inventory.get_item(i)
		if item != null and item.icon != null:
			draw_texture_rect(item.icon, Rect2(pos + Vector2i(2, 1), Vector2(16, 16)), false)
			_draw_number(inventory.get_count(i), pos + Vector2i(SLOT_SIZE - 2, SLOT_SIZE - 7), Color.WHITE, true)
		_draw_number(i + 1, pos + Vector2i(2, 2), Color(1, 1, 1, 0.5), false)

	_draw_money()


## Sol üst: koyu kutu içinde jeton + para miktarı (2x büyüklükte).
func _draw_money() -> void:
	var s: int = MONEY_SCALE
	var text_width: int = (str(inventory.money).length() * 4 - 1) * s
	var coin_size: Vector2i = Vector2i(COIN.get_size()) * s
	var box: Rect2 = Rect2(MONEY_POS, Vector2(coin_size.x + text_width + 10, coin_size.y + 6))
	draw_rect(box, COLOR_BG)
	_draw_frame(box, COLOR_BORDER)
	var inner: Vector2i = MONEY_POS + Vector2i(3, 3)
	draw_texture_rect(COIN, Rect2(inner, coin_size), false)
	_draw_number(inventory.money, inner + Vector2i(coin_size.x + 4, 1), COLOR_MONEY, false, s)


func _draw_frame(rect: Rect2, color: Color) -> void:
	var p: Vector2 = rect.position
	var s: Vector2 = rect.size
	draw_rect(Rect2(p, Vector2(s.x, 1)), color)
	draw_rect(Rect2(p + Vector2(0, s.y - 1), Vector2(s.x, 1)), color)
	draw_rect(Rect2(p, Vector2(1, s.y)), color)
	draw_rect(Rect2(p + Vector2(s.x - 1, 0), Vector2(1, s.y)), color)


## 3x5 piksel rakamlarla sayı yazar. right_align ise pos sağ üst köşedir.
## scale ile tam sayı katında büyütülür (keskin kalır).
func _draw_number(value: int, pos: Vector2i, color: Color, right_align: bool, scale: int = 1) -> void:
	var text: String = str(value)
	var width: int = (text.length() * 4 - 1) * scale
	var x: int = pos.x - width if right_align else pos.x
	var glyph: Vector2 = Vector2(3, 5) * scale
	for ch: String in text:
		var src: Rect2 = Rect2(ch.to_int() * 3, 0, 3, 5)
		draw_texture_rect_region(DIGITS, Rect2(Vector2(x + scale, pos.y + scale), glyph), src, COLOR_SHADOW)
		draw_texture_rect_region(DIGITS, Rect2(Vector2(x, pos.y), glyph), src, color)
		x += 4 * scale

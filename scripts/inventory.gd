class_name Inventory
extends Node
## Eşya envanteri: her slot tek bir türden en fazla ItemType.max_stack adet
## tutar. Her adedin kendi durum verisi saklanır (ör. slime'ın tokluğu).

signal contents_changed

const SLOT_COUNT: int = 8


## Envanterden çıkan bir adet eşya ve ona ait durum verisi.
class Entry:
	var item: ItemType
	var data: Dictionary

	func _init(p_item: ItemType, p_data: Dictionary) -> void:
		item = p_item
		data = p_data


var selected: int = 0
## Oyuncunun parası.
var money: int = 0
var _items: Array[ItemType] = []
## Slot başına, her adet için bir Dictionary.
var _payloads: Array[Array] = []


func _init() -> void:
	_items.resize(SLOT_COUNT)
	_payloads.resize(SLOT_COUNT)
	for i: int in SLOT_COUNT:
		_payloads[i] = []


func get_item(slot: int) -> ItemType:
	return _items[slot]


func get_count(slot: int) -> int:
	return _payloads[slot].size()


func can_add(item: ItemType) -> bool:
	return _find_slot_for(item) != -1


func add(item: ItemType, data: Dictionary = {}) -> bool:
	var slot: int = _find_slot_for(item)
	if slot == -1:
		return false
	_items[slot] = item
	_payloads[slot].append(data)
	contents_changed.emit()
	return true


## Seçili slottan bir adet çıkarır; slot boşsa null döner.
func take_selected() -> Entry:
	var item: ItemType = _items[selected]
	if item == null:
		return null
	var data: Dictionary = _payloads[selected].pop_back()
	if _payloads[selected].is_empty():
		_items[selected] = null
	contents_changed.emit()
	return Entry.new(item, data)


func add_money(amount: int) -> void:
	money = maxi(money + amount, 0)
	contents_changed.emit()


## Kayıt için: {"selected": i, "money": n, "slots": [null | {"item": id, "data": [...]}]}
func to_dict() -> Dictionary:
	var slots: Array = []
	for i: int in SLOT_COUNT:
		if _items[i] == null:
			slots.append(null)
		else:
			slots.append({"item": String(_items[i].id), "data": _payloads[i].duplicate(true)})
	return {"selected": selected, "money": money, "slots": slots}


func from_dict(d: Dictionary) -> void:
	var slots: Array = d.get("slots", [])
	for i: int in SLOT_COUNT:
		_items[i] = null
		_payloads[i] = []
		if i >= slots.size() or not slots[i] is Dictionary:
			continue
		var item: ItemType = ItemDatabase.get_item(str(slots[i].get("item", "")))
		if item == null:
			continue
		_items[i] = item
		for entry: Variant in slots[i].get("data", []):
			_payloads[i].append(entry if entry is Dictionary else {})
		if _payloads[i].is_empty():
			_items[i] = null
	selected = clampi(int(d.get("selected", 0)), 0, SLOT_COUNT - 1)
	money = maxi(int(d.get("money", 0)), 0)
	contents_changed.emit()


func select(slot: int) -> void:
	selected = clampi(slot, 0, SLOT_COUNT - 1)
	contents_changed.emit()


func select_offset(offset: int) -> void:
	select(posmod(selected + offset, SLOT_COUNT))


## Önce aynı türün dolmamış slotu, sonra boşsa seçili slot, sonra ilk boş slot.
func _find_slot_for(item: ItemType) -> int:
	for i: int in SLOT_COUNT:
		if _items[i] == item and get_count(i) < item.max_stack:
			return i
	if _items[selected] == null:
		return selected
	for i: int in SLOT_COUNT:
		if _items[i] == null:
			return i
	return -1

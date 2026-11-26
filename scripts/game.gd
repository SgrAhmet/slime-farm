extends Node
## Autoload "Game": aktif kayıt slotu, oyun süresi ve kayıt dosyaları.
## Kayıtlar user://save_slot_<n>.json içinde JSON olarak tutulur.

const SLOT_COUNT: int = 3
## Bir oyun gününün gerçek süresi (saniye). Test için 3 dakika.
const DAY_LENGTH: float = 180.0
## Yeni oyun bu saatte başlar (günün oranı; 0.3 = 07:12).
const DAY_START: float = 0.3
## Kayıt biçimi sürümü. Bundan eski kayıtlar menüde "Eski sürüm" görünür,
## yüklenemez; sadece silinebilir. Kayıt biçimi/dünya değişince artır.
const SAVE_VERSION: int = 2

enum SlotStatus { EMPTY, OK, OLD }
const GAME_SCENE: String = "res://scenes/main.tscn"
const MENU_SCENE: String = "res://scenes/main_menu.tscn"

## Aktif slot (0..SLOT_COUNT-1), oyunda değilken -1.
var current_slot: int = -1
## Oyunda geçen toplam süre (saniye). Slime açlığı bu saate göre işler,
## böylece kayıttan yüklenince doğru devam eder.
var play_time: float = 0.0
## Oyun sahnesi açılırken uygulanacak kayıt verisi (yeni oyunda boş).
var pending_load: Dictionary = {}
var in_game: bool = false
## Debug: true iken oyun saati ilerlemez (açlık, gece-gündüz, büyüme durur).
var time_paused: bool = false


func _process(delta: float) -> void:
	if in_game and not time_paused:
		play_time += delta


## Günün saati: 0..1 (0 = gece yarısı, 0.5 = öğlen).
func time_of_day() -> float:
	return fmod(play_time / DAY_LENGTH + DAY_START, 1.0)


func day_number() -> int:
	return int(play_time / DAY_LENGTH + DAY_START) + 1


## "Gün 2 · 14:30"
func clock_text() -> String:
	var minutes: int = int(time_of_day() * 1440.0)
	@warning_ignore("integer_division")
	return "Gün %d · %02d:%02d" % [day_number(), minutes / 60, minutes % 60]


func slot_path(slot: int) -> String:
	return "user://save_slot_%d.json" % (slot + 1)


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


func slot_status(slot: int) -> SlotStatus:
	if not has_save(slot):
		return SlotStatus.EMPTY
	var data: Dictionary = read_save(slot)
	if int(data.get("version", 0)) < SAVE_VERSION:
		return SlotStatus.OLD
	return SlotStatus.OK


func delete_save(slot: int) -> bool:
	if not has_save(slot):
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(slot))) == OK


func read_save(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var text: String = FileAccess.get_file_as_string(slot_path(slot))
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


func start_new(slot: int) -> void:
	current_slot = slot
	play_time = 0.0
	pending_load = {}
	get_tree().change_scene_to_file(GAME_SCENE)


func load_slot(slot: int) -> void:
	var data: Dictionary = read_save(slot)
	if data.is_empty():
		start_new(slot)
		return
	if int(data.get("version", 0)) < SAVE_VERSION:
		push_warning("Eski sürüm kayıt yüklenmedi (slot %d)." % (slot + 1))
		return
	current_slot = slot
	play_time = float(data.get("play_time", 0.0))
	pending_load = data
	get_tree().change_scene_to_file(GAME_SCENE)


func take_pending_load() -> Dictionary:
	var data: Dictionary = pending_load
	pending_load = {}
	return data


## Oyun durumunu aktif slota yazar.
func write_save(data: Dictionary) -> bool:
	if current_slot < 0:
		push_warning("Aktif kayıt slotu yok, kaydedilmedi.")
		return false
	data["version"] = SAVE_VERSION
	data["play_time"] = play_time
	data["saved_at"] = Time.get_datetime_string_from_system(false, true)
	var file: FileAccess = FileAccess.open(slot_path(current_slot), FileAccess.WRITE)
	if file == null:
		push_error("Kayıt dosyası açılamadı: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


## Menüde gösterilecek kısa özet: "25.11 14:02 · 1sa 05dk"
func slot_summary(slot: int) -> String:
	var data: Dictionary = read_save(slot)
	if data.is_empty():
		return ""
	var saved: String = str(data.get("saved_at", ""))  # "2026-11-25 14:02:33"
	var date_part: String = ""
	if saved.length() >= 16:
		date_part = "%s.%s %s" % [saved.substr(8, 2), saved.substr(5, 2), saved.substr(11, 5)]
	return "%s · %s" % [date_part, format_play_time(float(data.get("play_time", 0.0)))]


static func format_play_time(seconds: float) -> String:
	var minutes: int = int(seconds / 60.0)
	@warning_ignore("integer_division")
	var hours: int = minutes / 60
	if hours > 0:
		return "%dsa %02ddk" % [hours, minutes % 60]
	return "%ddk" % minutes

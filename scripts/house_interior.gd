class_name HouseInterior
extends Node2D
## Evin içi: tek oda, yatak, masa, saksı, halı. Haritanın dışında bir yerde
## durur; oyuncu kapıdan girince buraya ışınlanır.

signal exit_entered
signal bed_proximity_changed(near: bool)

const ROOM_SIZE: Vector2i = Vector2i(10, 8)
const DOOR_COLUMNS: Array[int] = [4, 5]
const WINDOW_COLUMNS: Array[int] = [2, 6]
const SOURCE_ID: int = 0
const TILE_FLOOR: Vector2i = Vector2i(9, 0)
const TILE_WALL: Vector2i = Vector2i(10, 0)
const TILE_WALL_TOP: Vector2i = Vector2i(11, 0)
const TILE_WALL_WINDOW: Vector2i = Vector2i(12, 0)

var player_near_bed: bool = false

@onready var floor_layer: TileMapLayer = $Floor
@onready var walls: TileMapLayer = $Walls
@onready var exit_zone: Area2D = $ExitZone
@onready var bed_zone: Area2D = $Bed/BedZone
@onready var entry_spawn_marker: Marker2D = $EntrySpawn


func _ready() -> void:
	_build_room()
	exit_zone.body_entered.connect(_on_exit_body_entered)
	bed_zone.body_entered.connect(_on_bed_zone.bind(true))
	bed_zone.body_exited.connect(_on_bed_zone.bind(false))


func entry_spawn() -> Vector2:
	return entry_spawn_marker.global_position


func room_rect() -> Rect2:
	return Rect2(global_position, Vector2(ROOM_SIZE * 16))


func _build_room() -> void:
	for y: int in ROOM_SIZE.y:
		for x: int in ROOM_SIZE.x:
			var cell: Vector2i = Vector2i(x, y)
			var side: bool = x == 0 or x == ROOM_SIZE.x - 1
			var bottom: bool = y == ROOM_SIZE.y - 1
			if y == 0 or side or (bottom and not DOOR_COLUMNS.has(x)):
				walls.set_cell(cell, SOURCE_ID, TILE_WALL_TOP)
			elif y == 1:
				walls.set_cell(cell, SOURCE_ID, TILE_WALL_WINDOW if WINDOW_COLUMNS.has(x) else TILE_WALL)
			else:
				floor_layer.set_cell(cell, SOURCE_ID, TILE_FLOOR)


func _on_exit_body_entered(body: Node2D) -> void:
	if body is Player:
		exit_entered.emit()


func _on_bed_zone(body: Node2D, near: bool) -> void:
	if body is Player:
		player_near_bed = near
		bed_proximity_changed.emit(near)

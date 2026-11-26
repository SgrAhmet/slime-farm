class_name House
extends StaticBody2D
## Çiftlik evi (dış görünüş). Kapının önündeki alana basınca door_entered yayar.

signal door_entered

## Evden çıkınca oyuncunun duracağı yer (kapı alanının biraz aşağısı).
const EXIT_OFFSET: Vector2 = Vector2(0, 22)

@onready var door_zone: Area2D = $DoorZone


func _ready() -> void:
	door_zone.body_entered.connect(_on_door_body_entered)


func exit_spawn() -> Vector2:
	return global_position + EXIT_OFFSET


func _on_door_body_entered(body: Node2D) -> void:
	if body is Player:
		door_entered.emit()

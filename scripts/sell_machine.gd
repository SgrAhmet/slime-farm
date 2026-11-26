class_name SellMachine
extends StaticBody2D
## Gem satış makinesi: içine fırlatılan gemleri ItemType.sell_price'tan satar.
## Gem olmayan eşyalar ve slimelar gövdeye çarpıp geri seker.

signal sold(item: ItemType, price: int)

const MONEY_COLOR: Color = Color(0.95, 0.79, 0.3)

@onready var sprite: Sprite2D = $Sprite2D
@onready var intake: Area2D = $Intake

var _bump_tween: Tween


func _ready() -> void:
	intake.body_entered.connect(_on_intake_body_entered)


func _on_intake_body_entered(body: Node2D) -> void:
	var pickup: Pickup = body as Pickup
	if pickup == null or pickup.motion != Vacuumable.Motion.LAUNCHED:
		return
	if pickup.item.category != ItemType.Category.GEM or pickup.item.sell_price <= 0:
		return
	var price: int = pickup.item.sell_price
	pickup.consume_into(self)
	Sfx.play_at("coin", global_position)
	sold.emit(pickup.item, price)
	Fx.pop_text(self, Vector2(0, -36), "+%d" % price, MONEY_COLOR)
	_bump()


## Satışta makine hafifçe zıplar.
func _bump() -> void:
	if _bump_tween:
		_bump_tween.kill()
	sprite.scale = Vector2(1.12, 0.88)
	_bump_tween = create_tween()
	_bump_tween.tween_property(sprite, "scale", Vector2.ONE, 0.25) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

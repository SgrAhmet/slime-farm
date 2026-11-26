class_name ItemType
extends Resource
## Envantere girebilen her şeyin ortak verisi (slime, yiyecek, gem).

enum Category { SLIME, FOOD, GEM }
## Yiyeceğin türü: slimeların beslenmesi buna göre (SlimeType.diet).
enum FoodKind { NONE, FRUIT, VEGGIE, MEAT }

@export var id: StringName
@export var display_name: String
@export var category: Category = Category.FOOD
## HUD'da gösterilen ikon.
@export var icon: Texture2D
## Haritaya çıkınca oluşturulan sahne (kökü Vacuumable olmalı).
@export var world_scene: PackedScene
## Dünya sahnesinin sprite sheet'indeki satır.
@export var sheet_row: int = 0
## Bir envanter slotunda en fazla kaç tane taşınır.
@export var max_stack: int = 20
## Satış makinesinde verilen para (0 = satılamaz).
@export var sell_price: int = 0
## Yiyecekse türü (NONE = yenmez, ör. civciv).
@export var food_kind: FoodKind = FoodKind.NONE


## Diyet bit maskesinde bu yiyeceğin biti (SlimeType.diet ile karşılaştırılır).
func food_bit() -> int:
	return 0 if food_kind == FoodKind.NONE else 1 << (int(food_kind) - 1)


## Bu eşyayı haritada oluşturur.
func spawn(parent: Node, at: Vector2) -> Vacuumable:
	var node: Vacuumable = world_scene.instantiate()
	node.item = self
	node.position = at
	parent.add_child(node)
	node.reset_physics_interpolation()
	return node

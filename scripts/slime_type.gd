class_name SlimeType
extends ItemType
## Bir slime türünün verisi: davranış ayarları + yediğinde verdiği gem.

## Zıplarken yatay hız (piksel/saniye).
@export var hop_speed: float = 40.0
## Zıplama yüksekliği (piksel).
@export var hop_height: float = 6.0
## İki zıplama arasında bekleme süresi aralığı (saniye).
@export var idle_time_min: float = 0.8
@export var idle_time_max: float = 2.2
## Yediği yiyecekler (bit maskesi: 1 meyve, 2 sebze, 4 et). Büyük slimeda iki türünkü birleşir.
@export_flags("Meyve", "Sebze", "Et") var diet: int = 7
## Yemek yedikten sonra tok kalma süresi (saniye).
@export var full_duration: float = 300.0
## Yemek yiyince düşürdüğü gem (büyük slimede ana rengin gemi).
@export var gem: ItemType
## Büyük (melez) slimelerde ikinci renk; normal slimede boş.
@export var secondary: SlimeType


## Diyetin okunur hali: "Meyve + Et"
func diet_text() -> String:
	var parts: PackedStringArray = []
	for i: int in 3:
		if diet & (1 << i):
			parts.append(["Meyve", "Sebze", "Et"][i])
	return " + ".join(parts)


func is_large() -> bool:
	return secondary != null

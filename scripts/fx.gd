class_name Fx
extends RefCounted
## Küçük görsel efektler.


## Bir ikonu (kalp, ünlem...) parent'ın üstünde belirtip yukarı süzerek söndürür.
static func pop_icon(parent: Node2D, offset: Vector2, texture: Texture2D, delay: float = 0.0) -> void:
	var icon: Sprite2D = Sprite2D.new()
	icon.texture = texture
	icon.position = offset
	icon.z_index = 5
	icon.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	icon.modulate.a = 0.0
	parent.add_child(icon)

	var tween: Tween = icon.create_tween()
	tween.tween_interval(delay)
	tween.tween_property(icon, "modulate:a", 1.0, 0.05)
	tween.tween_property(icon, "position:y", offset.y - 10.0, 0.8) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icon, "modulate:a", 0.0, 0.4).set_delay(0.4)
	tween.tween_callback(icon.queue_free)


## Yükselip sönen kısa yazı (ör. "+15").
static func pop_text(parent: Node2D, offset: Vector2, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.size = Vector2(48, 14)
	label.position = offset - label.size * 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", 10)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", Color(0.1, 0.07, 0.04))
	label.add_theme_constant_override(&"outline_size", 4)
	label.z_index = 5
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)

	var tween: Tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 14.0, 0.9) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.5)
	tween.tween_callback(label.queue_free)

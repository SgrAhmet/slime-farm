class_name VacuumGun
extends Node2D
## Vakum silahı: mouse'a doğru döner.
## Sağ tık (vacuum_suck) koni içindeki slime ve eşyaları çeker, sol tık
## (vacuum_shoot) seçili slottaki eşyayı fırlatır.

signal item_launched(entry: Inventory.Entry, at: Vector2, launch_velocity: Vector2)

const SPRITE_X: float = -1.0
const WORLD_MASK: int = 1

@export var inventory: Inventory
@export var suck_range: float = 70.0
@export_range(5.0, 90.0) var cone_half_angle: float = 30.0
@export var launch_speed: float = 140.0
## Sol tık basılı tutulursa iki atış arası süre.
@export var shoot_interval: float = 0.3

## Kapalıyken emme ve atış yapılmaz (ekran geçişleri).
var enabled: bool = true
var aim_dir: Vector2 = Vector2.RIGHT
var is_sucking: bool = false
var _hum: AudioStreamPlayer = null
const HUM_VOLUME: float = -10.0
var _cooldown: float = 0.0
var _fx_time: float = 0.0
var _recoil: float = 0.0
var _shoot_was_held: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var nozzle: Marker2D = $Nozzle


func _physics_process(delta: float) -> void:
	var to_mouse: Vector2 = get_global_mouse_position() - global_position
	if to_mouse.length_squared() > 1.0:
		aim_dir = to_mouse.normalized()
	rotation = aim_dir.angle()
	sprite.flip_v = aim_dir.x < 0.0

	_cooldown -= delta
	# Fare debug panelinin üstündeyken tıklamalar panele gider
	var ui_blocked: bool = DebugPanel.blocks_mouse()
	is_sucking = enabled and not ui_blocked and Input.is_action_pressed(&"vacuum_suck")
	# Her yeni tık tam bir atış; basılı tutunca shoot_interval aralıkla tekrar
	var shoot_held: bool = enabled and not ui_blocked and Input.is_action_pressed(&"vacuum_shoot")
	var shoot_clicked: bool = shoot_held and not _shoot_was_held
	_shoot_was_held = shoot_held
	_update_hum()
	if is_sucking:
		_fx_time += delta
		_suck(delta)
	elif shoot_clicked or (shoot_held and _cooldown <= 0.0):
		_shoot()

	# Geri tepme ve emerken titreme
	_recoil = move_toward(_recoil, 0.0, 20.0 * delta)
	var shake: float = 1.0 if is_sucking and fmod(_fx_time, 0.1) < 0.05 else 0.0
	sprite.position.x = SPRITE_X - roundf(_recoil) - shake
	queue_redraw()


## Vakum uğultusu: emerken döngüde çalar.
func _update_hum() -> void:
	if _hum == null:
		_hum = AudioStreamPlayer.new()
		_hum.stream = Sfx.loop_stream("vacuum_loop")
		_hum.volume_db = HUM_VOLUME
		add_child(_hum)
	if is_sucking and not _hum.playing:
		_hum.play()
	elif not is_sucking and _hum.playing:
		_hum.stop()


func is_active() -> bool:
	return enabled and (Input.is_action_pressed(&"vacuum_suck") or Input.is_action_pressed(&"vacuum_shoot"))


func _suck(delta: float) -> void:
	var origin: Vector2 = nozzle.global_position
	var half_angle: float = deg_to_rad(cone_half_angle)
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

	for node: Node in get_tree().get_nodes_in_group(&"vacuumable"):
		var target: Vacuumable = node as Vacuumable
		if target == null or not target.can_be_sucked():
			continue
		var pulling: bool = target.is_being_sucked()
		var aim_point: Vector2 = target.global_position if pulling else target.get_aim_point()
		var to_target: Vector2 = aim_point - origin
		var dist: float = to_target.length()
		# Çekilmeye başlamış nesne biraz daha geniş alanda tutulur
		var leeway: float = 1.25 if pulling else 1.0
		if dist > suck_range * leeway:
			continue
		if dist > 12.0 and absf(aim_dir.angle_to(to_target)) > half_angle * leeway:
			continue
		if not pulling:
			if not inventory.can_add(target.item):
				continue
			if _is_blocked(space, origin, aim_point):
				continue

		if target.vacuum_pull(origin, delta):
			if inventory.add(target.item, target.get_carry_data()):
				Sfx.play("vacuum_pop")
				target.queue_free()
			else:
				target.release()


func _shoot() -> void:
	var entry: Inventory.Entry = inventory.take_selected()
	if entry == null:
		return
	_cooldown = shoot_interval
	_recoil = 3.0
	# Slime oyuncunun ayak hizasından, nişan yönüne doğru çıkar
	var feet: Vector2 = (get_parent() as Node2D).global_position
	var spawn: Vector2 = feet + aim_dir * 8.0
	if _is_blocked(get_world_2d().direct_space_state, feet, spawn):
		spawn = feet
	Sfx.play("vacuum_shoot")
	item_launched.emit(entry, spawn, aim_dir * launch_speed)


func _is_blocked(space: PhysicsDirectSpaceState2D, from: Vector2, to: Vector2) -> bool:
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to, WORLD_MASK)
	return not space.intersect_ray(query).is_empty()


func _draw() -> void:
	if not is_sucking:
		return
	# Ağza doğru akan emme partikülleri (yerel uzayda: +x = nişan yönü)
	var half_angle: float = deg_to_rad(cone_half_angle)
	var count: int = 14
	for i: int in count:
		var angle: float = sin(float(i) * 12.9898) * half_angle
		var phase: float = fmod(_fx_time * 1.6 + float(i) / count, 1.0)
		var dist: float = (1.0 - phase) * suck_range * 0.8
		var p: Vector2 = nozzle.position + Vector2.from_angle(angle) * dist
		draw_rect(Rect2(p.round(), Vector2.ONE), Color(0.85, 0.95, 1.0, 0.2 + phase * 0.6))

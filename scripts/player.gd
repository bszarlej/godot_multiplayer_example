extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $PlayerSprite

const SPEED := 150

var last_direction = Vector2.DOWN

var last_sent_position = Vector2.INF
var last_sent_animation = ""
var last_sent_flip_h = null


func _ready() -> void:
	var camera = Camera2D.new()
	camera.set_zoom(Vector2(2, 2))
	add_child(camera)
	if is_multiplayer_authority():
		camera.make_current()
	multiplayer.peer_connected.connect(_on_peer_connected)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	var direction = Input.get_vector(
		"move_left",
	 	"move_right",
		"move_up",
		"move_down"
		)

	if direction != Vector2.ZERO:
		last_direction = direction
		velocity = direction * SPEED
		sprite.flip_h = direction.x < 0
		if last_sent_flip_h != sprite.flip_h:
			remote_update_sprite_flip_h.rpc(sprite.flip_h)
			last_sent_flip_h = sprite.flip_h
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	update_animation()
	
	if multiplayer.multiplayer_peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:	
		if last_sent_position != global_position:
			remote_update_position.rpc(global_position)
			last_sent_position = global_position
			
		if last_sent_animation != sprite.animation:
			remote_update_animation.rpc(sprite.animation)
			last_sent_animation = sprite.animation

# Send the new player our current state
func _on_peer_connected(id: int) -> void:
	if is_multiplayer_authority():
		remote_update_position.rpc_id(id, global_position)
		remote_update_animation.rpc_id(id, sprite.animation)
		remote_update_sprite_flip_h.rpc_id(id, sprite.flip_h)

func update_animation() -> void:
	var anim_prefix := ""
	var anim_suffix := ""
	
	if velocity != Vector2.ZERO:
		anim_prefix = "walk"
	else:
		anim_prefix = "idle"
	
	if velocity.y > 0:
		anim_suffix = "down"
	elif velocity.y < 0:
		anim_suffix = "up"
	elif last_direction.y > 0:
		anim_suffix = "down"
	elif last_direction.y < 0:
		anim_suffix = "up"
	else:
		anim_suffix = "side"
		
	var anim_name = "%s_%s" % [anim_prefix, anim_suffix]
	sprite.play(anim_name)

@rpc("any_peer")
func remote_update_position(position: Vector2) -> void:
	global_position = position


@rpc("any_peer")
func remote_update_animation(animation_name: String) -> void:
	sprite.play(animation_name)
	
	
@rpc("any_peer")
func remote_update_sprite_flip_h(value: bool) -> void:
	sprite.flip_h = value

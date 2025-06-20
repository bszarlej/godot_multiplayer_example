class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $PlayerSprite

const SPEED := 150

var last_direction = Vector2.DOWN

var username: String:
	get: return $UsernameLabel.text
	set(value): 
		if not value.is_empty():
			$UsernameLabel.text = value
		else:
			$UsernameLabel.text = "Player%s" % get_multiplayer_authority()

var username_color: Color:
	get: return $UsernameLabel.get_theme_color("font_color")
	set(color): $UsernameLabel.add_theme_color_override("font_color", color)


func _ready() -> void:
	var camera = Camera2D.new()
	camera.set_zoom(Vector2(2, 2))
	add_child(camera)
	if is_multiplayer_authority():
		camera.make_current()
		username = Global.username
		username_color = Global.username_colors[randi() % Global.username_colors.size()]
		var game = get_tree().get_root().get_node("Game")
		game.receive_player_username.rpc_id(1, get_multiplayer_authority(), username)
	sprite.play()

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
	else:
		velocity = Vector2.ZERO
	update_animation()
	move_and_slide()

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
		
	var animation = "%s_%s" % [anim_prefix, anim_suffix]
	sprite.animation = animation

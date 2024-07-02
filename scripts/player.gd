extends CharacterBody3D

# change the player layer to 2 bc when we have two players spawned
# they are colliding infintely and move upwards 

# to synchronize things between secenes: $MultiplayerSynchronizer
# then add the properties to sync like:
# player position and rotation, camera rotation

signal health_changed(health_value)

const SPEED = 10.0
const JUMP_VELOCITY = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var camera = $Camera3D
@onready var animation_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Pistol/MuzzleFlash
@onready var ray_cast = $Camera3D/RayCast3D 
var health = 3
var gravity = 20.0


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
func _ready():
	if not is_multiplayer_authority() : return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#make sure the camera set for the correct player
	camera.current = true

func _unhandled_input(event):
	if not is_multiplayer_authority() : return
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x,-PI/4,PI/4)
	if Input.is_action_just_pressed("shoot") and \
		animation_player.current_animation != "shoot":
			play_shoot_effects.rpc()
			if ray_cast.is_colliding():
				var hit_player=ray_cast.get_collider()
				# we may think : hit_player.health -=1
				# but thi lowreing the helth of the local player
				hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
	
func _physics_process(delta):
	if not is_multiplayer_authority() : return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if animation_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		animation_player.play("move")
	else:
		animation_player.play("idle")
		
	move_and_slide()
	
# remote procedure calls
@rpc("call_local")
# play_shoot_effects only called locally unliss using:
# @rpc("call_local") to call it in remote instance and local 
func play_shoot_effects():
	animation_player.stop()
	animation_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

# we calling receive_damage from the player that is dealing damage 
@rpc("any_peer")
func receive_damage():
	health -=1
	if health <= 0:
		health=3
		position = Vector3.ZERO
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		animation_player.play("idle")
	

class_name PlayerStateCrouch extends PlayerState

@export var deceleration_rate : float = 10

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play( "Crouch" )
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false

func exit() -> void:
	player.collision_stand.disabled = false
	player.collision_crouch.disabled = true

func handle_input(_event: InputEvent) -> PlayerState:	
	if _event.is_action_pressed("jump"):
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle
	return next_state
#
#func _player_can_fall_through_one_way_platform() -> bool:
	#if player.is_on_floor() == false: 
		#return false
	#if player.animation_player.is_playing():
		#return false
	#player.one_way_platform_shape_cast.force_shapecast_update()
	#return player.one_way_platform_shape_cast.is_colliding()

#func physics_process(_delta: float) -> PlayerState:
	#player.velocity.x -= player.velocity.x * deceleration_rate * _delta
	#if _player_can_fall_through_one_way_platform():
		#player.position.y += 4
	#if player.is_on_floor() == false:
		#return fall
	#return next_state

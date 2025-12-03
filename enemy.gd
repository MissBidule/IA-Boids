extends CharacterBody3D


@export var speed = 5.0
@export var direction = Vector3.ZERO
var wall_escape = false
var wall_escape_timer = 0.0
var wall_escape_dir = Vector3.ZERO

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	$zombie/AnimationPlayer.play("Walk")
	#$zombie/AnimationPlayer.play("idleLook")
		
	move_and_slide()

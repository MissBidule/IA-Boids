extends Area3D

@export var maxPos : Vector3
@export var minPos : Vector3
@export var distanceToFollow : float = 5
@export var cohesionDistance : float = 7
@export var numberOfBoids : int = 10
@export var zombie : PackedScene
@export var separationDistance : float = 0.8
@export var speedLimit : float = 0.3
@export var cohesionCoeff : float = 0.8
@export var separationCoeff : float = 1.0
@export var alignmentCoeff : float = 5.0
@export var boundaryCoeff : float = 6.0
@export var BoundaryWallValue : float = 10
@export var isPaused : bool = false

@export var obstacles: Array[StaticBody3D] = []
@export var player: CharacterBody3D

var myBoids: Array[CharacterBody3D] = []

func _ready() -> void:
	for i in numberOfBoids :
		var RandCoord = Vector3(randf_range(minPos.x, maxPos.x),
								minPos.y,
								randf_range(minPos.z, maxPos.z))
		var randDirection = Vector3(randf_range(-speedLimit, speedLimit), 0, randf_range(-speedLimit, speedLimit))
		var boid = zombie.instantiate()
		add_child(boid)
		myBoids.append(boid)
		boid.position = RandCoord
		boid.direction = randDirection

func limitVelocity (boid : CharacterBody3D) -> void:
	if (boid.direction.length() > speedLimit) :
		boid.direction = boid.direction/(boid.direction).length()*speedLimit;

func separation(boid : CharacterBody3D) -> Vector3:
	var avoidVector = Vector3.ZERO

	for currentBoid in myBoids :
		if currentBoid != boid && currentBoid.position.distance_to(boid.position) < separationDistance :
			avoidVector -= (currentBoid.position - boid.position);
	
	for obstacle in obstacles :
		if obstacle.position.distance_to(boid.position) < 2 * separationDistance :
			avoidVector -= (obstacle.position - boid.position);

	return avoidVector;


func cohesion(boid : CharacterBody3D) -> Vector3:
	var centerOfMass = Vector3.ZERO;
	var cohesionNeighbor = 0
	for currentBoid in myBoids :
		if(currentBoid != boid && currentBoid.position.distance_to(boid.position) < cohesionDistance) :
			centerOfMass += currentBoid.position
			cohesionNeighbor += 1
	if (cohesionNeighbor == 0) : return centerOfMass
	return (centerOfMass/(cohesionNeighbor))/100.0

func alignment(boid : CharacterBody3D) -> Vector3:
	var directionAverage = Vector3.ZERO
	var alignmentNeighbor = 0
	for currentBoid in myBoids :
		if (currentBoid != boid && currentBoid.position.distance_to(boid.position) < distanceToFollow) :
			directionAverage+=currentBoid.direction;
			alignmentNeighbor += 1
	if (player.position.distance_to(boid.position) < distanceToFollow) :
			directionAverage+=(player.position - boid.position).normalized();
			alignmentNeighbor += 1
	if (alignmentNeighbor == 0) : return directionAverage
	return (directionAverage/(alignmentNeighbor))/8.0

func boundaries(boid : CharacterBody3D) -> Vector3:
	var v = Vector3.ZERO
	var hit_wall = false
	
	if (boid.position.x < minPos.x) :
		v.x = lerp(v.x, BoundaryWallValue, (minPos.x - boid.position.x))
		hit_wall = true
		boid.wall_escape_dir.x = randf_range(0, 1)
		if (boid.wall_escape_dir.z == 0) : boid.wall_escape_dir.z = randf_range(-1, 1)
	elif (boid.position.x > maxPos.x) :
		v.x = lerp(v.x, -BoundaryWallValue, (boid.position.x - maxPos.x))
		hit_wall = true
		boid.wall_escape_dir.x = randf_range(-1, 0)
		if (boid.wall_escape_dir.z == 0) : boid.wall_escape_dir.z = randf_range(-1, 1)
	
	if (boid.position.z < minPos.z) :
		v.z = lerp(v.z, BoundaryWallValue, (minPos.z - boid.position.z))
		hit_wall = true
		if (boid.wall_escape_dir.x == 0) : boid.wall_escape_dir.x = randf_range(-1, 1)
		boid.wall_escape_dir.z = randf_range(0, 1)
	elif (boid.position.z > maxPos.z) :
		v.z = lerp(v.z, -BoundaryWallValue, (boid.position.z - maxPos.z))
		hit_wall = true
		if (boid.wall_escape_dir.x == 0) : boid.wall_escape_dir.x = randf_range(-1, 1)
		boid.wall_escape_dir.z = randf_range(-1, 0)
		
	if hit_wall:
		boid.wall_escape = true
		boid.wall_escape_timer = randf_range(0.6, 1.2)   # random duration
		boid.wall_escape_dir = boid.wall_escape_dir.normalized()
	
	return v.normalized()

func _physics_process(delta: float) -> void:
	if (!isPaused) :
		for currentBoid in myBoids :
			var cohesionValue = cohesionCoeff * cohesion(currentBoid)
			var separationValue = separationCoeff * separation(currentBoid)
			var alignmentValue = alignmentCoeff * alignment(currentBoid)
			var boundariesValue = boundaryCoeff * boundaries(currentBoid)

			if currentBoid.wall_escape:
				currentBoid.wall_escape_timer -= delta

				# While escaping, ignore boundaries and flock rules
				currentBoid.direction = currentBoid.wall_escape_dir * speedLimit

				if currentBoid.wall_escape_timer <= 0:
					currentBoid.wall_escape = false    # return to normal flock mode
			else:
				currentBoid.direction += (boundariesValue + separationValue + alignmentValue + cohesionValue)
			limitVelocity(currentBoid);
			if currentBoid.velocity.length() > 0.01:
				currentBoid.look_at(currentBoid.position - Vector3(currentBoid.velocity.x, 0, currentBoid.velocity.z))

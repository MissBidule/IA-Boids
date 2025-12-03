extends Area3D

var maxPos
var minPos
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

var myBoids

func _ready() -> void:
	
	for i in range (i, numberOfBoids) :
		var RandCoord = Vector3(randf_range(minPos.x, maxPos.x),
								randf_range(minPos.y, maxPos.y),
								randf_range(minPos.z, maxPos.z));
		var boid = zombie.instantiate()
		add_child(boid)
		myBoids.append(boid)
		boid.localPosition = RandCoord

func limitVelocity (boid : CharacterBody3D) -> void:
	if (boid.velocity.norm() > speedLimit) :
		boid.velocity = boid.velocity/(boid.velocity).norm()*speedLimit;

func separation(boid : CharacterBody3D) -> Vector3:
	var avoidVector = Vecto3.ZERO

	for currentBoid in myBoids :
		if currentBoid != boid && Vector3.distance(currentBoid.pos, boid.position) < separationDistance :
			avoidVector -= (currentBoid.getPos() - boid.getPos());

	return avoidVector;


glm::vec3 Flock :: cohesion(Boid& boid){

	glm::vec3 centerOfMass = glm::vec3(0,0,0);
	
		for(Boid& currentBoid : myBoids){

			if(&currentBoid != &boid && glm::distance(currentBoid.getPos(),boid.getPos())<cohesionDistance){

				centerOfMass+=currentBoid.getPos();
			}

	}

	return (centerOfMass/static_cast<float>(myBoids.size()))/100.0f;
}

glm::vec3 Flock :: alignment(Boid& boid){

	glm::vec3 velocityAverage = glm::vec3(0,0,0);
	
		for(Boid& currentBoid : myBoids){

			if(&currentBoid != &boid && glm::distance(currentBoid.getPos(),boid.getPos())<distanceToFollow){

				velocityAverage+=currentBoid.getVelocity();
			}

	}

	return (velocityAverage/static_cast<float>(myBoids.size()))/8.0f;
}

glm::vec3 Flock :: boundaries(Boid& boid) {

	glm::vec3 v;
	if(boid.getPos().x < minPos.x){
		v.x = BoundaryWallValue;
	}else if(boid.getPos().x > maxPos.x){
		v.x = -BoundaryWallValue;
	}
	if(boid.getPos().y < minPos.y){
		v.y = BoundaryWallValue;
	}else if(boid.getPos().y > maxPos.y){
		v.y = -BoundaryWallValue;
	}
	if(boid.getPos().z < minPos.z){
		v.z = BoundaryWallValue;
	}else if(boid.getPos().z > maxPos.z){
		v.z = -BoundaryWallValue;
	}
	return v;
}

void Flock :: simulate(){

	if(!isPaused){

		for(Boid& currentBoid : myBoids){

			glm::vec3 cohesionValue = cohesionCoeff*cohesion(currentBoid);
			glm::vec3 separationValue = separationCoeff*separation(currentBoid);
			glm::vec3 alignmentValue = alignmentCoeff*alignment(currentBoid);
			glm::vec3 boundariesValue = boundaryCoeff*boundaries(currentBoid);

			currentBoid.setVelocity(currentBoid.getVelocity()+boundariesValue+separationValue+alignmentValue+cohesionValue);
			limitVelocity(currentBoid);
			currentBoid.setPos(currentBoid.getPos()+currentBoid.getVelocity()) ;
		}

	}
}

void Flock::displayParam() {
	ImGui::Begin(("Flock settings "+name).c_str());
	ImGui::Text("maxSpeed");
	ImGui::SliderFloat("Max speed", &speedLimit, .001f, 10.f);
	ImGui::SliderFloat("Distance see for alignment", &distanceToFollow, .01f, 10);
	ImGui::SliderFloat("Distance see for cohesion", &cohesionDistance, .01f, 10);
	ImGui::SliderFloat("Distance see for separation", &separationDistance, .01f, 10);

	ImGui::SliderFloat("coefficient for alignment force", &alignmentCoeff, .1f, 10);
	ImGui::SliderFloat("coefficient for cohesion force", &cohesionCoeff, .1f, 10);
	ImGui::SliderFloat("coefficient for separation force", &separationCoeff, .1f, 10);
	ImGui::SliderFloat("coefficient for boundary force", &boundaryCoeff, .1f, 10);
	ImGui::Checkbox("Pause", &isPaused);

	ImGui::End();
}

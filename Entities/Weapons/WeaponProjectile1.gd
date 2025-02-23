extends Node3D

const SPEED = 25.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

func _ready():
	pass

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		ray.enabled = false
		var collider = ray.get_collider()
		print("Bullet hit:", collider)
		if collider.is_in_group("enemy"):
			collider.take_damage(10)  # Apply damage to the enemy
		await get_tree().create_timer(0.20).timeout  # Seconds to show impact particle
		queue_free()

func _on_timer_timeout():
	queue_free()

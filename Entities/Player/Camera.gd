extends Camera3D

@export_category("Follow this node")
@export var camera_point: Node3D
var point_position: Vector3
var lerp_speed := 0.1

func _ready():
	set_as_top_level(true)
	if camera_point:
		point_position = camera_point.global_position
	else:
		print("Error: Camera Point is not assigned")

func _process(delta):
	if camera_point:
		follow_player(delta)

func follow_player(_delta):
	point_position = camera_point.global_position
	var desired_position = Vector3(point_position.x, self.global_transform.origin.y, point_position.z)
	self.global_transform.origin = self.global_transform.origin.lerp(desired_position, lerp_speed)

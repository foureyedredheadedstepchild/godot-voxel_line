@tool
@icon("voxel_line.png")
class_name VoxelLine
extends Node3D

#var mesh_instance : PackedScene = preload("voxel.tscn")
var material : Resource = preload("voxel.material") as Material

var voxels : Array = []
var pool : Array = []
var pool_index : int = 0

@export var points : PackedVector3Array = [
	Vector3(0, 0, 0),
	Vector3(0, 8, 16) 
]

@export_color_no_alpha var color : Color = Color.CYAN:
	set(p_value):
		color = p_value
		_set_color(color)
	get:
		return color

@export_range(0.1, 16.0, 0.1) var width : float = 1.0:
	set(p_value):
		width = p_value
	get:
		return width

func _draw3d() -> void:
	if points.size() < 2:
		return
	if Engine.is_editor_hint():
		var global_origin : Vector3 = get_global_transform().origin
		for i in range(0, points.size() - 1):
			var A : Vector3 = points[i] + global_origin
			var B : Vector3 = points[i + 1] + global_origin
			voxel_line(A, B, width, color)

		_set_width(width)

func _physics_process(p_delta : float) -> void:
	_draw3d()

func add_voxel(p_size : float, p_color : Color) -> MeshInstance3D:
	var mesh_instance : MeshInstance3D = MeshInstance3D.new()
	mesh_instance.set_name("Voxel_" + str(pool_index))
	var box_mesh : BoxMesh = BoxMesh.new()
#	box_mesh.set_size(Vector3(p_size, p_size, p_size))
	box_mesh.size = Vector3.ONE * p_size
	mesh_instance.set_mesh(box_mesh)
	material.set_albedo(p_color)
	box_mesh.set_material(material)
	return mesh_instance

func get_pool(p_size : float, p_color : Color) -> MeshInstance3D:
	var voxel : MeshInstance3D 
	if (pool.size() > 0):
		voxel = pool.pop_front()
		voxel.set_visible(true)
	else:
#		voxel = mesh_instance.instantiate()
#		voxel.get_mesh().set_size(Vector3(p_size, p_size, p_size))
		voxel = add_voxel(p_size, p_color)
		add_child(voxel)
		pool_index += 1
	return voxel

func set_pool(p_voxel : MeshInstance3D) -> void:
	p_voxel.set_visible(false)
	pool.append(p_voxel)

func voxel_line(p_start : Vector3, p_end : Vector3, p_size : float, p_color : Color) -> void:
	var direction : Vector3 = p_end - p_start
	var length : float = direction.length()
	var inv_size : float = 1.0 / p_size
	var step : int = ceili(length * inv_size) + 1
	if (step <= 0):
		return
	var inv_step : float = 1.0 / step
	var distance : float = length * inv_step # / step
	var offset : Vector3 = direction.normalized() * distance
	var size : int = voxels.size()
	if (step < size):
		for i in range(step, size):
			set_pool(voxels[i]) 
		voxels.resize(step)
	else:
		for i in range(size, step):
			voxels.push_back(get_pool(p_size, p_color))
	for i in range(step):
		var voxel_origin : Vector3 = p_start + i * offset
#		var voxel_origin : Vector3 = p_start + direction * (i * inv_step)
#		var t : float = i / (step - 1.0)
#		var voxel_origin : Vector3 = p_start + t * direction
		voxels[i].global_transform.origin = round(voxel_origin * inv_size) * p_size
 
func _set_color(p_color : Color) -> void:
	material.set_albedo(color)

func _set_width(p_width : float) -> void:
	for i in voxels.size():
		var voxel : MeshInstance3D = voxels[i]
		var mesh : BoxMesh = voxel.get_mesh()
		mesh.size = Vector3.ONE * p_width

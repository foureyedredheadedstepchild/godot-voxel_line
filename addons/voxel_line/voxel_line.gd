@tool
@icon("voxel_line.png")
extends Node3D
class_name VoxelLine

#var mesh_instance : PackedScene = preload("voxel.tscn")
var material : Resource = preload("voxel.material")

#@export var points : PackedVector3Array = [
#	Vector3(0, 0, 0),
#	Vector3(0, 8, 16) 
#]
#@export var width : float = 1.0
#@export_color_no_alpha var color : Color = Color.CYAN

var voxels : Array = []
var pool : Array = []
var pool_index : int = 0

#func _process(p_delta : float) -> void:
#	if points.size() < 2:
#		return
#	if Engine.is_editor_hint():
#		for i in range(0, points.size() - 1):
#			var origin : Vector3 = get_global_transform().origin
#			var A  : Vector3 = points[i] + origin
#			var B  : Vector3 = points[i + 1] + origin
#			voxel_line(A, B, width, color)

func add_voxel(p_size : float, p_color : Color) -> MeshInstance3D:
	var mesh_instance : MeshInstance3D = MeshInstance3D.new()
	mesh_instance.set_name("Voxel_" + str(pool_index))
	var box_mesh : BoxMesh = BoxMesh.new()
	box_mesh.set_size(Vector3(p_size, p_size, p_size))
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
#	var inv_step : float = (1.0 / step)
	var distance : float = length / step
	var offset : Vector3 = direction.normalized() * distance
	if (step <= 0):
		return
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

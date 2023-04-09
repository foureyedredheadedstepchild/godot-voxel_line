@tool
# @icon("voxel_line.png")
extends Node3D
class_name VoxelLine
#var material : Resource = preload("voxel.material")
#@export var points = [
#	Vector3(0, 0, 0),
#	Vector3(0, 8, 16)
#]
#@export var width = 1.0
var voxels : Array = []
var pool : Array = []
var pool_index : int = 0

#func _process(p_delta : float) -> void:
#	if points.size() < 2:
#		return
#	if Engine.is_editor_hint():
#		for i in range(0, points.size() - 1):
#			var origin : Vector3 = get_global_transform().origin
#			var A : Vector3 = points[i] + origin
#			var B : Vector3 = points[i + 1] + origin
#			voxel_line(A, B, width)

func add_voxel(p_size : float) -> MeshInstance3D:
	var mesh_instance : MeshInstance3D = MeshInstance3D.new()
	mesh_instance.set_name("Voxel_" + str(pool_index))
	var mesh : BoxMesh = BoxMesh.new()
	mesh.set_size(Vector3(p_size, p_size, p_size))
	mesh_instance.set_mesh(mesh)
#	mesh.material = material
#	mesh.material.flags_unshaded = true
	return mesh_instance

func get_pool(p_size : float = 1.0) -> MeshInstance3D:
	var voxel : MeshInstance3D 
	if (pool.size() > 0):
		voxel = pool.pop_front()
		voxel.set_visible(true)
	else:
		voxel = add_voxel(p_size)
		add_child(voxel)
		pool_index += 1
	return voxel

func set_pool(p_voxel : MeshInstance3D) -> void:
	p_voxel.set_visible(false)
	pool.append(p_voxel)

func voxel_line(p_start : Vector3, p_end : Vector3, p_size : float) -> void:
	var direction : Vector3 = p_end - p_start
	var length : float = direction.length();
	var inv_size : float = 1.0 / p_size
	var step : int = ceili(length * inv_size) + 1
#	var inv_steps : float = (1.0 / num_steps)
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
			voxels.push_back(get_pool(p_size))
	for i in range(step):
		var voxel_origin : Vector3 = p_start + i * offset
		voxels[i].global_transform.origin = round(voxel_origin * inv_size) * p_size

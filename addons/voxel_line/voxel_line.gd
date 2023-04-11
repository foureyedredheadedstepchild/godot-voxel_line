@tool
@icon("voxel_line.png")
class_name VoxelLine
extends Node3D

var multimesh_instance : MultiMeshInstance3D

#var mesh_instance : PackedScene = preload("voxel.tscn")
var material : Resource = preload("voxel.material") as Material

var voxels : Array = []
var pool : Array = []
var pool_index : int = 0

@export var enable_multimesh : bool = true

@export var points : PackedVector3Array = [
	Vector3(0, 0, 0),
	Vector3(0, 8, 16) 
]

@export_range(0.1, 16.0, 0.1) var size : float = 1.0:
	set(p_value):
		size = p_value
	get:
		return size

@export_color_no_alpha var color : Color = Color.CYAN:
	set(p_value):
		color = p_value
		_set_color(color)
	get:
		return color

func _ready():
	if (enable_multimesh):
		var global_origin : Vector3 = get_global_transform().origin
		set_multimesh_instance(global_origin, 0, size, color)

func _draw3d() -> void:
	if points.size() < 2:
		return
	if Engine.is_editor_hint():
		var global_origin : Vector3 = get_global_transform().origin
		for i in range(0, points.size() - 1):
			var start : Vector3 = points[i] + global_origin
			var end : Vector3 = points[i + 1] + global_origin
			voxel_line(start, end, size, color)

		_set_width(size)

func _physics_process(p_delta : float) -> void:
	_draw3d()

func set_multimesh_instance(p_origin : Vector3, p_instance_count : int, p_size : float, p_color : Color) -> void:
	if (multimesh_instance):
		return
	multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.set_name("MultiMeshInstance_" + str(p_instance_count))
	material.set_albedo(p_color)
	multimesh_instance.set_material_override(material)
	add_child(multimesh_instance)
	var multi_mesh : MultiMesh = MultiMesh.new()
	multi_mesh.set_transform_format(MultiMesh.TRANSFORM_3D)
	multi_mesh.set_instance_count(p_instance_count)
	multi_mesh.set_visible_instance_count(-1)
#	multi_mesh.set_use_colors(true)
#	multi_mesh.set_instance_color(p_instance_count, p_color)
	var mesh : BoxMesh = BoxMesh.new()
	mesh.set_size(Vector3.ONE * p_size)
	multi_mesh.set_mesh(mesh)
	multimesh_instance.set_multimesh(multi_mesh)

func get_multimesh_instance() -> MultiMeshInstance3D:
	return multimesh_instance

func add_voxel(p_size : float, p_color : Color) -> MeshInstance3D:
	var mesh_instance : MeshInstance3D = MeshInstance3D.new()
	mesh_instance.set_name("Voxel_" + str(pool_index))
	var mesh : BoxMesh = BoxMesh.new()
	mesh.set_size(Vector3.ONE * p_size)
	mesh_instance.set_mesh(mesh)
	material.set_albedo(p_color)
	mesh.set_material(material)
	return mesh_instance

func get_pool(p_size : float, p_color : Color) -> MeshInstance3D:
	var voxel : MeshInstance3D 
	if (pool.size() > 0):
		voxel = pool.pop_front()
		voxel.set_visible(true)
	else:
#		voxel = mesh_instance.instantiate()
#		voxel.get_mesh().set_size(Vector3.ONE * p_size)
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
	if (enable_multimesh):
		_kill()

		var global_origin : Vector3 = get_global_transform().origin
		set_multimesh_instance(global_origin, 0, size, p_color)
		if (multimesh_instance):
			var multimesh : MultiMesh = multimesh_instance.get_multimesh()
			multimesh.set_instance_count(step)
			multimesh.get_mesh().set_size(Vector3.ONE * p_size)
			var instance_count : int = multimesh.get_instance_count()
			for i in range(instance_count):
				var voxel_transform : Transform3D = Transform3D()
				var voxel_origin : Vector3 = p_start + i * offset
				voxel_transform.origin = to_local(round(voxel_origin * inv_size) * p_size)
				multimesh.set_instance_transform(i, voxel_transform)
	else:
		if (multimesh_instance):
			multimesh_instance.call_deferred('free')
			multimesh_instance = null

		var voxels_size : int = voxels.size()
		if (step < voxels_size):
			for i in range(step, voxels_size):
				set_pool(voxels[i]) 
			voxels.resize(step)
		else:
			for i in range(voxels_size, step):
				voxels.push_back(get_pool(p_size, p_color))
		for i in range(step):
			var voxel_origin : Vector3 = p_start + i * offset
#			var voxel_origin : Vector3 = p_start + direction * (i * inv_step)
#			var t : float = i / (step - 1.0)
#			var voxel_origin : Vector3 = p_start + t * direction
			voxels[i].global_transform.origin = round(voxel_origin * inv_size) * p_size
 
func _set_color(p_color : Color) -> void:
	material.set_albedo(color)

func _set_width(p_size : float) -> void:
	if (voxels.is_empty()):
		return
	for i in voxels.size():
		var voxel : MeshInstance3D = voxels[i]
		var mesh : BoxMesh = voxel.get_mesh()
		mesh.set_size(Vector3.ONE * p_size)

func _kill() -> void:
	if (voxels.is_empty()):
		return
	var voxels_size : int = voxels.size()
	for i in range(voxels_size - 1, -1, -1):
		var voxel : MeshInstance3D = voxels[i]
		voxel.call_deferred('free')
		voxels.remove_at(i)

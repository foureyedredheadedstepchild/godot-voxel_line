@tool
@icon("voxel_line.png")
class_name VoxelLine
extends MultiMeshInstance3D

var multi_mesh : MultiMesh
#var mesh_instance : PackedScene = preload("voxel.tscn")
var material : Resource = preload("voxel.material") as Material

@export var points : PackedVector3Array = [
	Vector3(0, 0, 0),
	Vector3(0, 8, 16)
]:
	set(p_value):
		points = p_value
		_update()
	get:
		return points

@export_range(0.1, 16.0, 0.1) var size : float = 1.0:
	set(p_value):
		size = p_value
		_update()
	get:
		return size

@export_color_no_alpha var color : Color = Color.CYAN:
	set(p_value):
		color = p_value
#		_set_color(color)
		_update()
	get:
		return color

func _ready():
	set_multi_mesh(0, size, color)
	_update()

func _update() -> void:
	if (is_inside_tree()):
		if (points.size() < 2):
			return
		var origin : Vector3 = get_global_transform().origin
		for i in range(0, points.size() - 1):
			var start : Vector3 = points[i] + origin
			var end : Vector3 = points[i + 1] + origin
			voxel_line(start, end, size, color)

func set_multi_mesh(p_instance_count : int, p_size : float, p_color : Color) -> void:
	if (multi_mesh != null):
		return
	multi_mesh = MultiMesh.new()
	multi_mesh.set_transform_format(MultiMesh.TRANSFORM_3D)
	multi_mesh.set_instance_count(p_instance_count)
#	multi_mesh.set_use_colors(true)
#	multi_mesh.set_instance_color(p_instance_count, p_color)
	var mesh : BoxMesh = BoxMesh.new()
	mesh.set_size(Vector3.ONE * p_size)
	mesh.set_material(material)
	multi_mesh.set_mesh(mesh)
	set_multimesh(multi_mesh)

func voxel_line(p_start : Vector3, p_end : Vector3, p_size : float, p_color : Color) -> void:
	var direction : Vector3 = p_end - p_start
	var length : float = direction.length()
	var inv_size : float = 1.0 / p_size
	var step : int = ceili(length * inv_size)
	if (step <= 0): 
		return
	var inv_step : float = 1.0 / float(step)
	var distance : float = length * inv_step
	var offset : Vector3 = direction.normalized() * distance
	if (multi_mesh != null):
		multi_mesh.set_instance_count(step)
		multi_mesh.get_mesh().set_size(Vector3.ONE * p_size)
		var instance_count : int = multi_mesh.get_instance_count()
		for i in range(instance_count):
			var voxel_transform : Transform3D = Transform3D()
			var origin : Vector3 = (p_start - get_global_transform().origin) + i * offset
			voxel_transform.origin = round(origin * inv_size) * p_size
			multi_mesh.set_instance_transform(i, voxel_transform)

func _set_color(p_color : Color) -> void:
	if (multi_mesh != null):
		var mesh : BoxMesh = multi_mesh.get_mesh()
		mesh.get_material().set_albedo(p_color)

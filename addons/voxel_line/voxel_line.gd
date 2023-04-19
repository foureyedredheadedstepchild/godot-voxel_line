@tool
@icon("voxel_line.png")
class_name VoxelLine
extends MultiMeshInstance3D

var multi_mesh : MultiMesh
#var mesh_instance : PackedScene = preload("voxel.tscn")
var material : Resource = preload("voxel.material") as Material

enum Type {
	LINE = 0,
	CIRCLE
}

@export_enum("Line", "Circle") var type: int = 0:
	set(p_value):
		type = p_value
		_update()
	get:
		return type

@export var points : PackedVector3Array = [
	Vector3(0, 0, 0),
	Vector3(0, 8, 16)
]:
	set(p_value):
		points = p_value
		_update()
	get:
		return points

@export_range(0.1, 64.0, 0.1) var size : float = 1.0:
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
		
const MAX_RADIUS : float = 256
@export_range(0.1, MAX_RADIUS, 0.1) var radius : float = 1.0:
	set(p_value):
		radius = p_value
		_update()
	get:
		return radius

func _ready():
	set_multi_mesh(0, size, color)
	_update()

func _update() -> void:
	if (is_inside_tree()):
		var origin : Vector3 = get_global_transform().origin
		if type == 0:
			if (points.size() < 2):
				return
			for i in range(0, points.size() - 1):
				var start : Vector3 = points[i] + origin
				var end : Vector3 = points[i + 1] + origin
				voxel_line(start, end, size, color)
		else:
			voxel_circle(origin, radius, size, color)

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
	if (p_size <= 0):
		return
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
			var origin : Vector3 = (p_start - get_global_transform().origin) + float(i) * offset
			voxel_transform.origin = round(origin * inv_size) * p_size
			multi_mesh.set_instance_transform(i, voxel_transform)

func voxel_circle(p_center: Vector3, p_radius: float, p_size: float, p_color: Color) -> void:
	if (p_radius <= 0) || (p_size <= 0):
		return
	var inv_size : float = TAU / (p_size * 2)
	var step : int = ceil((TAU * p_radius) * inv_size) * 2
	if (step <= 0): 
		return
	if (multi_mesh != null):
		var instance_count : int = multi_mesh.get_instance_count()
		if (instance_count != step):
			multi_mesh.set_instance_count(step)
			instance_count = step
		_set_size(p_size)
		var inv_angle : float = TAU * (1.0 / float(step))
#		var cos_angle : float = cos(inv_angle)
#		var sin_angle : float = sin(inv_angle)
		var origin : Vector3 = p_center + Vector3(p_radius * 2.0, 0, 0)
		var basis : Basis = Basis(Vector3.UP, inv_angle)
		var transform : Transform3D = get_global_transform()
		for i in range(instance_count):
#			origin *= basis
			origin = xform(basis, origin)
#			origin = origin.rotated(Vector3.UP, inv_angle)
			transform.origin = round(origin * inv_size) * p_size
			multi_mesh.set_instance_transform(i, transform)
#			var x : float = origin.x * cos_angle - origin.z * sin_angle
#			var z : float = origin.x * sin_angle + origin.z * cos_angle
#			origin.x = x
#			origin.z = z

func xform(p_basis : Basis, p_vec : Vector3) -> Vector3:
	return Vector3( p_basis.x.dot(p_vec), 
					p_basis.y.dot(p_vec), 
					p_basis.z.dot(p_vec))

func _set_size(p_size : float) -> void:
	var size : Vector3 = Vector3.ONE * p_size
	var mesh : BoxMesh = multi_mesh.get_mesh()
	if mesh.get_size() != size:
		mesh.set_size(size)

func _set_type(p_type : int = Type.LINE) -> void:
	type = p_type

func _set_color(p_color : Color) -> void:
	if (multi_mesh != null):
		var mesh : BoxMesh = multi_mesh.get_mesh()
		mesh.get_material().set_albedo(p_color)

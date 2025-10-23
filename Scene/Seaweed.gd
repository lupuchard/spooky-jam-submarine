@tool
extends MeshInstance2D
class_name Seaweed

@export var height: float = 64.0:
	set(value):
		height = value
		update_height()

func _ready() -> void:
	mesh = QuadMesh.new()
	texture = preload("res://Assets/seaweed.png")
	
	rotation = PI
	z_index = -2
	material = ShaderMaterial.new()
	material.shader = preload("res://Scene/Seaweed.gdshader")
	
	update_height()

func update_height() -> void:
	mesh.size = Vector2(16.0, height)
	mesh.subdivide_depth = height / 8.0
	material.set_shader_parameter("height", height / 32.0)

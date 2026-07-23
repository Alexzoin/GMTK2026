@tool
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var shader_material = color_rect.material as ShaderMaterial

@export var stripes: float = 5:
	set(value):
		stripes = value
		if shader_material:
			shader_material.set_shader_parameter("stripes", value)
@export_range(0, 1) var stripe_thickness: float = 0.33:
	set(value):
		stripe_thickness = value
		if shader_material:
			shader_material.set_shader_parameter("stripe_thickness", value)
@export var bendyness: float = 0.3:
	set(value):
		bendyness = value
		if shader_material:
			shader_material.set_shader_parameter("bendyness", value)
@export var wave_rotation: float = 0:
	set(value):
		wave_rotation = value
		if shader_material:
			shader_material.set_shader_parameter("rotation", value)
@export var spin: float = 0.05:
	set(value):
		spin = value
		if shader_material:
			shader_material.set_shader_parameter("spin", value)
@export var wave_frequency: float = 2.0:
	set(value):
		wave_frequency = value
		if shader_material:
			shader_material.set_shader_parameter("wave_frequency", value)
@export var shrink: float = 15.0:
	set(value):
		shrink = value
		if shader_material:
			shader_material.set_shader_parameter("shrink", value)
@export var stripe_color: Color = Color.WHITE:
	set(value):
		stripe_color = value
		if shader_material:
			shader_material.set_shader_parameter("stripe_color", value)
@export var background_color: Color = Color.TRANSPARENT:
	set(value):
		background_color = value
		if shader_material:
			shader_material.set_shader_parameter("background_color", value)
@export var smooth_edge: bool = false:
	set(value):
		smooth_edge = value
		if shader_material:
			shader_material.set_shader_parameter("smooth_edge", value)

func _ready() -> void:
	_update_shader_parameters()

func _update_shader_parameters() -> void:
	if not shader_material:
		return
		
	shader_material.set_shader_parameter("stripes", stripes)
	shader_material.set_shader_parameter("stripe_thickness", stripe_thickness)
	shader_material.set_shader_parameter("bendyness", bendyness)
	shader_material.set_shader_parameter("rotation", wave_rotation)
	shader_material.set_shader_parameter("spin", spin)
	shader_material.set_shader_parameter("wave_frequency", wave_frequency)
	shader_material.set_shader_parameter("shrink", shrink)
	shader_material.set_shader_parameter("stripe_color", stripe_color)
	shader_material.set_shader_parameter("background_color", background_color)
	shader_material.set_shader_parameter("smooth_edge", smooth_edge)

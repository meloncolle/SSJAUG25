extends Path3D

var rail_a: PackedVector2Array = [
	Vector2(0.5, 0),
	Vector2(0.354, 0.354),
	Vector2(0, 0.5),
	Vector2(-0.354, 0.354),
	Vector2(-0.5, 0),
	Vector2(-0.354, -0.354),
	Vector2(0, -0.5),
	Vector2(0.354, -0.354),
]

var rail_b: PackedVector2Array = [
	Vector2(5.5, 0),
	Vector2(5.354, 0.354),
	Vector2(5, 0.5),
	Vector2(4.646, 0.354),
	Vector2(4.5, 0),
	Vector2(4.646, -0.354),
	Vector2(5, -0.5),
	Vector2(5.354, -0.354),
]

func _ready() -> void:
	$RailA.polygon = rail_a
	$RailB.polygon = rail_b

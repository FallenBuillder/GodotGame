extends Path2D

@export var path_width := 100.0
@export var segment_length := 50.0
@export var path_color := Color(0.6, 0.2, 0.8, 0.5)
@export var path_border_color := Color(0.8, 0.4, 1.0, 0.8)
@export var border_width := 3.0
@export var show_path := true

func _ready():
	generate_path_blocker()
	queue_redraw()

func _draw():
	if not show_path or not curve or curve.get_point_count() < 2:
		return
	
	var points = curve.get_baked_points()
	
	var left_side = []
	var right_side = []
	
	for i in range(points.size()):
		var point = points[i]

		var tangent = Vector2.ZERO
		if i < points.size() - 1:
			tangent = (points[i + 1] - point).normalized()
		else:
			tangent = (point - points[i - 1]).normalized()
		
		var perpendicular = Vector2(-tangent.y, tangent.x)
		
		left_side.append(point + perpendicular * path_width / 2)
		right_side.append(point - perpendicular * path_width / 2)
	
	var polygon = PackedVector2Array()
	polygon.append_array(left_side)
	right_side.reverse()
	polygon.append_array(right_side)
	
	draw_colored_polygon(polygon, path_color)
	
	for i in range(left_side.size() - 1):
		draw_line(left_side[i], left_side[i + 1], path_border_color, border_width)
		draw_line(right_side[i], right_side[i + 1], path_border_color, border_width)

func generate_path_blocker():
	var old_blocker = get_node_or_null("PathBlocker")
	if old_blocker:
		old_blocker.queue_free()
	
	var area = Area2D.new()
	area.name = "PathBlocker"
	area.collision_layer = 2
	area.collision_mask = 2
	add_child(area)
	
	var path_length = curve.get_baked_length()
	var num_segments = max(int(path_length / segment_length), 1)
	
	for i in range(num_segments + 1):
		var offset = (float(i) / num_segments) * path_length
		var sample_pos = curve.sample_baked(offset)
		
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = path_width / 2
		
		collision_shape.shape = circle_shape
		collision_shape.position = sample_pos
		
		area.add_child(collision_shape)

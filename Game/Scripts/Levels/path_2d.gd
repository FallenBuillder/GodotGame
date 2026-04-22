extends Path2D

@export var path_width: = 100.0
@export var segment_length: = 100.0

func _ready():
    generate_path_blocker()

func generate_path_blocker() -> void :
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

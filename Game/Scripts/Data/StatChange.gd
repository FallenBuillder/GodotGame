class_name StatChange
extends Resource

enum Mode{ADD, SET, MULTIPLY}

@export var stat: String = ""
@export var mode: Mode = Mode.ADD
@export var value: float = 0.0
@export var scene_value: PackedScene

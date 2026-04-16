extends Node

enum PlacementMode { CLICK_AND_DROP, DRAG_AND_DROP }
var placement_mode = PlacementMode.DRAG_AND_DROP


func get_placement_mode_name() -> String:
	match placement_mode:
		PlacementMode.CLICK_AND_DROP:
			return "Click & Drop"
		PlacementMode.DRAG_AND_DROP:
			return "Drag & Drop"
	return "Unknown"

func set_placement_mode(mode) -> void:
	placement_mode = mode

func get_auto_start() -> bool:
	return WaveManager.is_auto_start

func set_auto_start(value: bool) -> void:
	WaveManager.is_auto_start = value

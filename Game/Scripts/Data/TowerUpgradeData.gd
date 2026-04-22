class_name TowerUpgradeData
extends Resource

@export var upgrade_name: String = "Upgrade"
@export var icon: Texture2D
@export var cost: int = 200
@export var description: String = ""
@export var new_bullet_scene: PackedScene
@export var new_tower_sprite_idle: Texture2D
@export var new_tower_sprite_shoot: Texture2D
@export var proximity_speed_bonus: bool = false
@export var proximity_max_bonus_pct: float = 0.0
@export var unlock_sentry_scene: PackedScene
@export var unlock_foam_scene: PackedScene
@export var unlock_trap_scene: PackedScene
@export var sentry_sprite_idle: Texture2D
@export var sentry_sprite_shoot: Texture2D
@export var sentry_bullet_scene: PackedScene
@export var sentry_expert_mode: bool = false

@export var stat_changes: Array[StatChange] = []

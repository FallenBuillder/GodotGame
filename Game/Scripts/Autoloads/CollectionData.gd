extends Node

var _built: = false

var tower_database: Dictionary = {
    1: {
        "tower_id": 1, 
        "name": "Crossbow Mouse", 
        "cost": 200, 
        "damage": 1, 
        "range": 225.0, 
        "fire_rate": 0.94, 
        "pierce": 3, 
        "damage_type_name": "Basic", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Basic.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Basic/MyszNormalnaLVL1Spo.png")
    }, 
    2: {
        "tower_id": 2, 
        "name": "Magic Mouse", 
        "cost": 300, 
        "damage": 0, 
        "range": 108.0, 
        "fire_rate": 2.1, 
        "pierce": 150, 
        "damage_type_name": "Freeze", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Freeze.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Freeze/MyszSpowalniajacaLVL1Spo.png")
    }, 
    3: {
        "tower_id": 3, 
        "name": "Sniper Mouse", 
        "cost": 350, 
        "damage": 2, 
        "range": -1.0, 
        "fire_rate": 1.36, 
        "pierce": 1, 
        "damage_type_name": "Basic", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Sniper.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Sniper/MyszSnajperskaLVL1Spo.png")
    }, 
    4: {
        "tower_id": 4, 
        "name": "Engineer Mouse", 
        "cost": 450, 
        "damage": 1, 
        "range": 160.0, 
        "fire_rate": 0.645, 
        "pierce": 3, 
        "damage_type_name": "Basic", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Engineer.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Engineer/MyszInzynierLVL1.png")
    }, 
    5: {
        "tower_id": 5, 
        "name": "Bomb Mouse", 
        "cost": 650, 
        "damage": 1, 
        "range": 108.0, 
        "fire_rate": 1.51, 
        "pierce": 40, 
        "damage_type_name": "Explosion", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Bomb.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Bomb/MyszBombowaLVL1Spo.png")
    }, 
    6: {
        "tower_id": 6, 
        "name": "Boxing Mouse", 
        "cost": 750, 
        "damage": 1, 
        "range": 95.0, 
        "fire_rate": 0.4, 
        "pierce": 4, 
        "damage_type_name": "Basic", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Mele.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Mele/MyszMeleLVL1Spo.png")
    }, 
    7: {
        "tower_id": 7, 
        "name": "Cheese Farm", 
        "cost": 1080, 
        "damage": 1, 
        "range": 0.0, 
        "fire_rate": 0.0, 
        "pierce": 0, 
        "damage_type_name": "Basic", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Farm.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Farm/FarmaSeraLVL1.png")
    }, 
    8: {
        "tower_id": 8, 
        "name": "Super Mouse", 
        "cost": 2000, 
        "damage": 1, 
        "range": 250.0, 
        "fire_rate": 0.12, 
        "pierce": 3, 
        "damage_type_name": "Basic", 
        "unlocked": true, 
        "scene_path": "res://Game/Scenes/Towers/Super.tscn", 
        "sprite": load("res://Game/Graphics/Towers/Super/SuperMyszLVL1Spo.png")
    }
}

var enemy_database: Dictionary = {
    1: {
        "id": 1, 
        "name": "Red Swiss", 
        "health": 1, 
        "speed": 70.0, 
        "damage": 1, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": true, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/1_basic_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/1 Basic/SerBasicRed.png")
    }, 
    2: {
        "id": 2, 
        "name": "Blue Swiss", 
        "health": 1, 
        "speed": 98.0, 
        "damage": 2, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/2_basic_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/2 Basic/SerBasicBlue.png")
    }, 
    3: {
        "id": 3, 
        "name": "Green Swiss", 
        "health": 1, 
        "speed": 126.0, 
        "damage": 3, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/3_basic_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/3 Basic/SerBasicGreen.png")
    }, 
    4: {
        "id": 4, 
        "name": "Yellow Swiss", 
        "health": 1, 
        "speed": 224.0, 
        "damage": 4, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/4_basic_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/4 Basic/SerBasicYellow.png")
    }, 
    5: {
        "id": 5, 
        "name": "Pink Swiss", 
        "health": 1, 
        "speed": 245.0, 
        "damage": 5, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/5_basic_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/5 Basic/SerBasicPink.png")
    }, 
    6: {
        "id": 6, 
        "name": "Black Mozzarella", 
        "health": 1, 
        "speed": 126.0, 
        "damage": 11, 
        "reward": 1, 
        "immunities": [1], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/6_explosion_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/6 Explosion/SerExplosionBlack.png")
    }, 
    7: {
        "id": 7, 
        "name": "White Mozzarella", 
        "health": 1, 
        "speed": 140.0, 
        "damage": 11, 
        "reward": 1, 
        "immunities": [2], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/7_freeze_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/7 Freeze/SerFreezeWhite.png")
    }, 
    8: {
        "id": 8, 
        "name": "Zebra Mozzarella", 
        "health": 1, 
        "speed": 126.0, 
        "damage": 23, 
        "reward": 1, 
        "immunities": [1, 2], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/8_freeze_&_explosion_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/8 Explosion & Freeze/SerExplosionFreezeZebra.png")
    }, 
    9: {
        "id": 9, 
        "name": "Feta", 
        "health": 1, 
        "speed": 70.0, 
        "damage": 23, 
        "reward": 1, 
        "immunities": [0], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/9_sharp_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/9 Sharp/SerSharpLead.png")
    }, 
    10: {
        "id": 10, 
        "name": "Rainbow Swiss", 
        "health": 1, 
        "speed": 154.0, 
        "damage": 47, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/10_basic_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/10 Basic/SerBasicRainbow.png")
    }, 
    11: {
        "id": 11, 
        "name": "Parmesan", 
        "health": 10, 
        "speed": 175.0, 
        "damage": 104, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/11_resilient_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/11 Resilient/SerResiliantBasicCeramic.png")
    }, 
    12: {
        "id": 12, 
        "name": "Gouha", 
        "health": 200, 
        "speed": 70.0, 
        "damage": 616, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/12_boss_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/12 Boss/SerBossMoab.png")
    }, 
    13: {
        "id": 13, 
        "name": "Camembert", 
        "health": 700, 
        "speed": 17.5, 
        "damage": 3164, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/13_boss_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/13 Boss/SerBossBFG.png")
    }, 
    14: {
        "id": 14, 
        "name": "Cheddar", 
        "health": 4000, 
        "speed": 12.6, 
        "damage": 16656, 
        "reward": 1, 
        "immunities": [], 
        "unlocked": false, 
        "killed": 0, 
        "scene_path": "res://Game/Scenes/Enemies/14_boss_enemy.tscn", 
        "sprite": load("res://Game/Graphics/Enemies/14 Boss/SerBossZomg.png")
    }
}

func _ready() -> void :
    call_deferred("_build_all")

func _build_all() -> void :
    if _built:
        return
    _built = true



func ensure_built() -> void :
    if not _built:
        _build_all()

func _get_texture(node: Node) -> Texture2D:
    var s = node.get_node_or_null("Sprite2D")
    if s:
        return s.texture
    var a = node.get_node_or_null("AnimatedSprite2D")
    if a and a.sprite_frames:
        var frames = a.sprite_frames
        if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
            return frames.get_frame_texture("idle", 0)
    return null

"\nfunc _build_tower_data() -> void:\n\tvar dir = \"res://Game/Scenes/Towers/\"\n\tvar da = DirAccess.open(dir)\n\tif not da:\n\t\treturn\n\tfor fname in da.get_files():\n\t\tif not fname.ends_with(\".tscn\"):\n\t\t\tcontinue\n\t\tvar scene = load(dir + fname)\n\t\tif not scene:\n\t\t\tcontinue\n\t\tvar node = scene.instantiate()\n\t\tvar tid = node.get(\"tower_id\")\n\t\tif tid == null:\n\t\t\tnode.queue_free()\n\t\t\tcontinue\n\t\tif node.get(\"show_in_collection\") == false:\n\t\t\tnode.queue_free()\n\t\t\tcontinue\n\t\ttowers[tid] = {\n\t\t\t\"tower_id\": tid,\n\t\t\t\"scene_path\": dir + fname,\n\t\t\t\"name\": node.get(\"tower_name\") if \"tower_name\" in node else \"Tower\",\n\t\t\t\"unlocked\": false,\n\t\t\t\"sprite\": _get_texture(node),\n\t\t\t\"cost\": node.get(\"cost\") if \"cost\" in node else 0,\n\t\t\t\"damage\": node.get(\"damage\") if \"damage\" in node else 0,\n\t\t\t\"range\": node.get(\"detection_range\") if \"detection_range\" in node else 0,\n\t\t\t\"fire_rate\": node.get(\"fire_rate\") if \"fire_rate\" in node else 0.0,\n\t\t\t\"damage_type_name\": [\"Basic\", \"Explosion\", \"Freeze\"][node.get(\"damage_type\") if \"damage_type\" in node else 0],\n\t\t\t\"pierce\": node.get(\"pierce\") if \"pierce\" in node else 1,\n\t\t}\n\t\tnode.queue_free()\n\nfunc _build_enemy_data() -> void:\n\tvar dir = \"res://Game/Scenes/Enemies/\"\n\tvar da = DirAccess.open(dir)\n\tif not da:\n\t\treturn\n\tfor fname in da.get_files():\n\t\tif not fname.ends_with(\".tscn\"):\n\t\t\tcontinue\n\t\tif \"_camo\" in fname or \"_regen\" in fname:\n\t\t\tcontinue\n\t\tvar scene = load(dir + fname)\n\t\tif not scene:\n\t\t\tcontinue\n\t\tvar node = scene.instantiate()\n\t\tvar eid = node.get(\"enemy_id\") if \"enemy_id\" in node else 0\n\t\tenemies[eid] = {\n\t\t\t\"id\": eid,\n\t\t\t\"scene_path\": dir + fname,\n\t\t\t\"name\": node.get(\"enemy_name\") if \"enemy_name\" in node else \"Enemy\",\n\t\t\t\"sprite\": _get_texture(node),\n\t\t\t\"health\": node.get(\"health\") if \"health\" in node else 0,\n\t\t\t\"speed\": node.get(\"speed\") if \"speed\" in node else 0,\n\t\t\t\"damage\": node.get(\"damage\") if \"damage\" in node else 0,\n\t\t\t\"reward\": node.get(\"reward\") if \"reward\" in node else 1,\n\t\t\t\"immunities\": node.get(\"damage_immunities\") if \"damage_immunities\" in node else [],\n\t\t}\n\t\tnode.queue_free()\n"

-- enemy_1
-- 普通 小怪

return {
    id = "enemy_1",
    name = "汀",
    
    health = 30.0,

    attack = 5.0,
    attack_type = 0,
    -- 近战 弹道速度为 0
    projectile_speed = 0, 
    bullet_scene = "",
    sprite_frames = "res://game/assets/monster/enemy_1/enemy_1.tres",

    speed = 120.0,

    stop_distance = 40.0,
    attack_range = 50.0,
    discover_distance = 500.0;
}
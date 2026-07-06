-- 小白龙
-- 定位 射手

return {

    id = "enemy_2",
    name = "闫",

    health = 23.0,

    attack = 4.0,
    attack_type = 1,
    -- 远程 有 弹道
    projectile_speed = 175,
    bullet_scene = "res://game/features/enemy/LosEnemyBullet/LosEnemy2Bullet/LosEnemy2Bullet.tscn",
    sprite_frames = "res://game/assets/monster/enemy_2/enemy_2.tres",

    speed = 140.0,
    
    stop_distance = 400.0,     -- 远程保持距离
    attack_range = 450.0,
    discover_distance = 500.0,
}

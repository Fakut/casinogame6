// Pokud hráč není nezranitelný
if (other.invincible_timer <= 0) {
    other.hp -= damage;
    
    // Knockback
    var knockback_dir = direction;
    other.vel_x = lengthdir_x(other.knockback_force * 0.7, knockback_dir);
    other.vel_y = lengthdir_y(other.knockback_force * 0.7, knockback_dir) - 2;
    
    other.is_knockback = true;
    other.knockback_timer = 8;
    other.invincible_timer = other.invincible_duration;
    
    if (other.hp <= 0) {
        other.hp = 0;
        global.current_wave = 0;
        game_restart();
    }
}

// Zničení projektilu
instance_destroy();
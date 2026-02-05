// Stejná kolize jako normální enemy (kdyby se dotkl)
if (other.invincible_timer > 0) {
    exit;
}

other.hp -= 10;  // Menší damage při dotyku

// Knockback
var knockback_dir = point_direction(x, y, other.x, other.y);
other.vel_x = lengthdir_x(other.knockback_force, knockback_dir);
other.vel_y = lengthdir_y(other.knockback_force, knockback_dir) - 3;

other.is_knockback = true;
other.knockback_timer = 10;
other.invincible_timer = other.invincible_duration;

if (other.hp <= 0) {
    other.hp = 0;
    global.current_wave = 0;
    game_restart();
}
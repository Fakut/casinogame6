// Pokud jsi nezranitelný, ignoruj
if (invincible_timer > 0) exit;

// Vezmi damage
hp -= 10;
total_damage_taken += 10;

// Knockback
var knockback_dir = point_direction(other.x, other.y, x, y);
vel_x = lengthdir_x(knockback_force, knockback_dir);
vel_y = lengthdir_y(knockback_force, knockback_dir) - 3;

is_knockback = true;
knockback_timer = 10;
invincible_timer = invincible_duration;

// Smrt
if (hp <= 0) {
    hp = 0;
    global.current_wave = 0;
    global.player_money = 0;
    game_restart();
}
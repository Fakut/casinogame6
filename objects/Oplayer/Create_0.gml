// ========== PERSISTENCE + SINGLETON ==========
persistent = true;

// Nastavení okna (jen první spuštění)
window_set_size(1920, 1080);

// Flag že jsem byl inicializovaný
initialized = true;

depth = -100;

// Zbraně
current_weapon = 0;
weapon_unlocked = [true, false, false, false, false];

// Pohyb
move_speed = 4;
jump_force = 9;
gravity_force = 0.5;
vel_x = 0;
vel_y = 0;
max_fall_speed = 10;

x_previous = x;  
y_previous = y;  

// Double Jump
max_jumps = 2;
jumps_remaining = max_jumps;

// Sprint/Dash
sprint_multiplier = 1.8;
is_sprinting = false;
dash_speed = 15;
dash_duration = 10;
dash_cooldown = 30;
dash_timer = 0;
dash_cooldown_timer = 0;
is_dashing = false;

// Wall Jump
on_wall = 0;
wall_jump_force_x = 6;
wall_jump_force_y = 9;
wall_slide_speed = 2;

// Combat
hp = 100;
max_hp = 100;
attack_damage = 25;
attack_cooldown = 0;
attack_speed = 30;
facing = 1;
spike_immunity = 0;

// Knockback
knockback_force = 6;
knockback_timer = 0;
is_knockback = false;
invincible_timer = 0;
invincible_duration = 30;

// Peníze
money = 0;

// Image stabilizace
image_speed = 1;
image_angle = 0;
image_xscale = 1;
image_yscale = 1;

// Aim direction
aim_direction = 0;

// ========== STATISTIKY  ==========
total_damage_dealt = 0;
total_damage_taken = 0;
total_money_earned = 0;
total_enemies_killed = 0;

casino_slots_spins = 0;
casino_blackjack_hands = 0;
casino_roulette_spins = 0;
casino_total_won = 0;
casino_total_spent = 0;

total_shots_fired = 0;
total_shots_hit = 0;
total_jumps = 0;
total_dashes = 0;
// ========== BOSS STATS ==========
hp = 1000;
max_hp = 1000;
is_dead = false;

// Movement
move_speed = 2;
vel_x = 0;
vel_y = 0;
gravity_force = 0.5;
max_fall_speed = 10;
direction_facing = 1;

// Jump
jump_force = 12;
jump_cooldown = 0;
jump_cooldown_max = 60;

// ========== AI STATES ==========
state = "idle";
state_timer = 0;

// Detection
target = Oplayer;
detection_range = 600;
attack_range = 400;
melee_range = 100;

// ========== ATTACK TIMERS ==========
attack_cooldown = 0;
attack_cooldown_max = 120;

// Shotgun attack
shotgun_projectile_count = 8;
shotgun_spread_angle = 60;

// Slam attack
slam_charge_time = 0;
slam_charge_max = 45;
is_charging_slam = false;

// Wave attack
wave_speed = 4;
wave_damage = 30;

// ========== PHASE SYSTEM ==========
current_phase = 1;
phase_2_threshold = 0.66;
phase_3_threshold = 0.33;

// ========== INVINCIBILITY ==========
invincible_timer = 0;
invincible_duration = 10;

// ========== VISUAL ==========
flash_timer = 0;
shake_timer = 0;

show_debug_message("BOSS SPAWNED - HP: " + string(hp));
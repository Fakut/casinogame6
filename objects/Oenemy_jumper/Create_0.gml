// ========== ZÁKLADNÍ STATS ==========
hp = 50;
max_hp = 50;
damage = 10;
move_speed = 2;
is_dead = false;

// ========== POHYB ==========
vel_x = 0;
vel_y = 0;
gravity_force = 0.5;
max_fall_speed = 10;

// ========== SMĚR ==========
direction_facing = choose(-1, 1);

// ========== JUMP ==========
jump_force = 12;  // Používá se jako -jump_force v Step
jump_cooldown = 0;
jump_cooldown_max = 60;
on_ground = false;

// ========== AI ==========
state = "idle";
target = Oplayer;
detection_range = 400;

// ========== IDLE & WALK TIMERS ==========
idle_timer = 0;
idle_duration = 30;
walk_timer = random_range(120, 240);

// ========== PLATFORM DETECTION ==========
can_jump_to_platform = false;
target_platform_x = 0;
target_platform_y = 0;

// ========== INVINCIBILITY ==========
invincible_timer = 0;
invincible_duration = 10;

// ========== CONTACT DAMAGE COOLDOWN ==========
contact_damage_cooldown = 0;
contact_damage_cooldown_max = 60;

// Anti-stuck
turn_cooldown = 0;
stuck_timer = 0;
last_x = x;
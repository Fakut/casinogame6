// Střílející nepřítel
depth = -100;

// Stats
hp = 50;
max_hp = 50;
damage = 12;
move_speed = 1.5;
is_dead = false;

// Physics
vel_x = 0;
vel_y = 0;
gravity_force = 0.5;
max_fall_speed = 10;

// Shooting
shoot_cooldown = 0;
shoot_cooldown_max = 90;
projectile_speed = 6;

// AI
chase_range = 300;           // Vidí z daleka
attack_range = 250;          // Začne střílet
retreat_distance = 120;      // Začne couvat
can_see_player = false;

// Patrol (když nevidí hráče)
patrol_direction = choose(-1, 1);  // Random start směr
idle_timer = 0;
patrol_speed = 1;  // Pomalejší než chase

// Směr
direction_facing = patrol_direction;

// Visual
shoot_flash_timer = 0;


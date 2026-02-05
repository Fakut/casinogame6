// Létající nepřítel
depth = -100;

// Stats
hp = 60;
max_hp = 60;
damage = 15;
is_dead = false;

// Movement
move_speed = 3.5;
vel_x = 0;
vel_y = 0;
max_speed = 3.5;

// Smooth turning
target_vel_x = 0;
target_vel_y = 0;
acceleration = 0.15;

// AI
seen_player_once = false;
chase_range = 400;
direction_x = 1;

// Pathfinding
check_distance = 40;
stuck_timer = 0;
last_x = x;
last_y = y;

// Detour
detour_timer = 0;
detour_distance = 0;

// Hover
hover_offset = random(360);
hover_speed = 0.04;
hover_amount = 6;
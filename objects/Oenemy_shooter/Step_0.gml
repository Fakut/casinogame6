// Smrt
if (hp <= 0 && !is_dead) {
    is_dead = true;
    
    // ========== TRACK KILL ==========
    if (instance_exists(Oplayer)) {
        Oplayer.total_enemies_killed++;
    }
    
    // ========== NOTIFY WAVE MANAGER ==========
    if (instance_exists(Owave_manager)) {
        Owave_manager.enemies_alive -= 1;
    }
    
    var money_amount = 10;
    if (instance_exists(Owave_manager)) {
        var wave_index = min(Owave_manager.current_wave - 1, array_length(Owave_manager.wave_config) - 1);
        if (wave_index >= 0) {
            money_amount = Owave_manager.wave_config[wave_index].money_drop;
        }
    }
    
    var money = instance_create_layer(x, y - 10, "Instances", Omoney);
    if (instance_exists(money)) {
        money.value = money_amount;
    }
    
    instance_destroy();
    exit;
}

// ========== KONTROLA ZEMĚ ==========
var on_ground = place_meeting(x, y + 1, Oground);

// ========== GRAVITACE ==========
if (!on_ground) {
    vel_y += gravity_force;
    if (vel_y > max_fall_speed) {
        vel_y = max_fall_speed;
    }
} else {
    vel_y = 0;
}

// ========== COOLDOWNS ==========
if (shoot_cooldown > 0) {
    shoot_cooldown--;
}

if (shoot_flash_timer > 0) {
    shoot_flash_timer--;
}

if (idle_timer > 0) {
    idle_timer--;
}

// ========== LINE OF SIGHT - RAYCASTING ==========
can_see_player = false;

if (instance_exists(Oplayer)) {
    var dist = point_distance(x, y, Oplayer.x, Oplayer.y);
    
    if (dist < chase_range) {
        // Raycasting od středu shootera ke středu hráče
        var start_x = x;
        var start_y = y - 8;  // Střed shootera
        var end_x = Oplayer.x;
        var end_y = Oplayer.y - 16;  // Střed hráče (ne nohy!)
        
        var ray_dist = point_distance(start_x, start_y, end_x, end_y);
        var ray_dir = point_direction(start_x, start_y, end_x, end_y);
        var check_step = 16;  // Kontroluj každých 16 pixelů
        var can_see = true;
        
        // Kontroluj každý bod na cestě
        for (var i = check_step; i < ray_dist - check_step; i += check_step) {
            var check_x = start_x + lengthdir_x(i, ray_dir);
            var check_y = start_y + lengthdir_y(i, ray_dir);
            
            // Pokud je tam zeď → nevidí
            if (place_meeting(check_x, check_y, Oground)) {
                can_see = false;
                break;
            }
        }
        
        can_see_player = can_see;
    }
}

// ========== AI ==========
vel_x = 0;

if (can_see_player && instance_exists(Oplayer)) {
    var dist = point_distance(x, y, Oplayer.x, Oplayer.y);
    
    // Otoč se k hráči
    if (Oplayer.x < x) {
        direction_facing = -1;
    } else {
        direction_facing = 1;
    }
    
    // ========== STŘÍLENÍ ==========
    if (dist < attack_range && shoot_cooldown <= 0) {
        var bullet = instance_create_layer(x, y - 8, "Instances", Oenemy_projectile);
        
        if (instance_exists(bullet)) {
            var shoot_dir = point_direction(x, y, Oplayer.x, Oplayer.y);
            bullet.direction = shoot_dir;
            bullet.speed = projectile_speed;
            bullet.damage = damage;
            bullet.image_angle = shoot_dir;
            
            shoot_cooldown = shoot_cooldown_max;
            shoot_flash_timer = 5;
        }
    }
    
    // ========== POHYB PODLE DISTANCE ==========
    if (dist < retreat_distance) {
        // ========== 1. MOC BLÍZKO - COUVEJ! ==========
        var retreat_dir = -direction_facing;
        vel_x = move_speed * retreat_dir;
        
        // ========== KONTROLA KRAJE PŘI COUVÁNÍ - DVOJITÁ! ==========
        if (on_ground) {
            // První kontrola (dál od okraje)
            var edge_check_distance = 24;  // Kontroluj dál
            var edge_check_down = 20;       // Hlouběji
            
            var check_x = x + (retreat_dir * edge_check_distance);
            var check_y = y + edge_check_down;
            
            if (!place_meeting(check_x, check_y, Oground)) {
                vel_x = 0;  // ZASTAV SE
            }
            
            // Druhá kontrola (blíž)
            var safe_check_x = x + (retreat_dir * 10);
            var safe_check_y = y + 10;
            
            if (!place_meeting(safe_check_x, safe_check_y, Oground)) {
                vel_x = 0;  // BEZPEČNOSTNÍ ZASTAV
            }
        }
        
    } else if (dist < attack_range) {
        // ========== 2. IDEÁLNÍ ODSTUP - STŮJ ==========
        vel_x = 0;
        
    } else {
        // ========== 3. MOC DALEKO - CHASE! ==========
        vel_x = move_speed * direction_facing;
        
        // ========== KONTROLA JINÝCH SHOOTERŮ ==========
        var shooter_ahead = false;
        
        with (Oenemy_shooter) {
            if (id != other.id) {
                var dist_to_shooter = point_distance(x, y, other.x, other.y);
                var vertical_diff = abs(y - other.y);
                var horizontal_diff = x - other.x;
                
                // Je přede mnou (ve směru pohybu)?
                var is_in_front = (other.direction_facing == 1 && horizontal_diff > 0 && horizontal_diff < 60) ||
                                  (other.direction_facing == -1 && horizontal_diff < 0 && horizontal_diff > -60);
                
                // Je na stejné platformě?
                if (is_in_front && vertical_diff < 20) {
                    other.shooter_ahead = true;
                }
            }
        }
        
        // Pokud je shooter před tebou → ZASTAV SE
        if (shooter_ahead) {
            vel_x = 0;
        }
        
        // ========== KONTROLA KRAJE PŘI CHASE - DVOJITÁ! ==========
        if (on_ground && !shooter_ahead) {
            // První kontrola
            var edge_check_distance = 24;
            var edge_check_down = 20;
            
            var check_x = x + (direction_facing * edge_check_distance);
            var check_y = y + edge_check_down;
            
            if (!place_meeting(check_x, check_y, Oground)) {
                vel_x = 0;  // ZASTAV SE
            }
            
            // Druhá kontrola
            var safe_check_x = x + (direction_facing * 10);
            var safe_check_y = y + 10;
            
            if (!place_meeting(safe_check_x, safe_check_y, Oground)) {
                vel_x = 0;  // BEZPEČNOSTNÍ ZASTAV
            }
        }
    }
    
} else {
    // ========== PATROL - NEVIDÍ HRÁČE ==========
    if (idle_timer <= 0) {
        vel_x = patrol_speed * patrol_direction;
        direction_facing = patrol_direction;
        
        // ========== KONTROLA KRAJE PŘI PATROL - DVOJITÁ! ==========
        if (on_ground) {
            // První kontrola (dál)
            var edge_check_distance = 24;  // Kontroluj dál od okraje
            var edge_check_down = 20;       // Hlouběji
            
            var check_x = x + (patrol_direction * edge_check_distance);
            var check_y = y + edge_check_down;
            
            if (!place_meeting(check_x, check_y, Oground)) {
                // NENÍ ZEM → OTOČ SE
                patrol_direction = -patrol_direction;
                direction_facing = patrol_direction;
                vel_x = 0;
                idle_timer = 30;
            }
            
            // Druhá kontrola (blíž) - bezpečnostní
            var safe_check_x = x + (patrol_direction * 10);
            var safe_check_y = y + 10;
            
            if (!place_meeting(safe_check_x, safe_check_y, Oground)) {
                // BEZPEČNOSTNÍ OTOČ
                patrol_direction = -patrol_direction;
                direction_facing = patrol_direction;
                vel_x = 0;
                idle_timer = 30;
            }
        }
    } else {
        vel_x = 0;
    }
}

// ========== KOLIZE SE ZDÍ ==========
if (place_meeting(x + vel_x, y, Oground)) {
    while (!place_meeting(x + sign(vel_x), y, Oground)) {
        x += sign(vel_x);
    }
    vel_x = 0;
    
    // Otoč patrol směr
    if (!can_see_player) {
        patrol_direction = -patrol_direction;
        direction_facing = patrol_direction;
        idle_timer = 30;
    }
}

x += vel_x;

// ========== KOLIZE Y ==========
if (place_meeting(x, y + vel_y, Oground)) {
    while (!place_meeting(x, y + sign(vel_y), Oground)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}

y += vel_y;

// ========== OTOČENÍ SPRITE ==========
if (direction_facing == -1) {
    image_xscale = -1;
} else {
    image_xscale = 1;
}

// ========== DAMAGE ==========
if (place_meeting(x, y, Ospike)) {
    hp -= 25;
}

if (y > room_height + 100) {
    hp = 0;
}
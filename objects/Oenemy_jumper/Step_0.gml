// Smrt
if (hp <= 0 && !is_dead) {
    is_dead = true;
    
    // ========== TRACK KILL ==========
    if (instance_exists(Oplayer)) {
        Oplayer.total_enemies_killed++;
    }
    
    // NOTIFY WAVE MANAGER
    if (instance_exists(Owave_manager)) {
        Owave_manager.enemies_alive -= 1;
    }
    
    var money_amount = 18;
    if (instance_exists(Owave_manager)) {
        var wave_index = min(Owave_manager.current_wave - 1, array_length(Owave_manager.wave_config) - 1);
        if (wave_index >= 0) {
            money_amount = Owave_manager.wave_config[wave_index].money_drop;
        }
    }
    
    var money = instance_create_layer(x, y, "Instances", Omoney);
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

// ========== COOLDOWNS & TIMERS ==========
if (jump_cooldown > 0) {
    jump_cooldown--;
}

if (idle_timer > 0) {
    idle_timer--;
}

if (walk_timer > 0) {
    walk_timer--;
}

if (turn_cooldown > 0) {
    turn_cooldown--;
}

// ========== STUCK DETECTION ==========
if (on_ground) {
    if (abs(x - last_x) < 0.5) {
        stuck_timer++;
        
        if (stuck_timer > 90 && turn_cooldown <= 0) {
            direction_facing = -direction_facing;
            turn_cooldown = 60;
            stuck_timer = 0;
            idle_timer = 0;
            show_debug_message("Jumper unstuck - forced turn");
        }
    } else {
        stuck_timer = 0;
    }
    
    last_x = x;
}

// ========== DETEKCE PLATFORMY NAD/POD ==========
can_jump_to_platform = false;

if (on_ground) {
    // Výpočet fyziky skoku
    var jump_air_time = (jump_force * 2) / gravity_force;
    var max_horizontal_distance = move_speed * 1.8 * (jump_air_time * 0.5);
    var max_jump_height = (jump_force * jump_force) / (2 * gravity_force);
    
    // ========== PARAMETRY - 3 BLOKY NAD/POD (96px) ==========
    var search_distance = min(max_horizontal_distance, 96);
    var search_height_up = 96;
    var search_height_down = 96;
    
    var best_platform_found = false;
    var best_platform_x = 0;
    var best_platform_y = 0;
    var best_distance = 9999;
    
    // Hledej platformy NAHORU
    for (var search_x = 32; search_x <= search_distance; search_x += 16) {
        var check_x = x + (direction_facing * search_x);
        
        for (var search_y = 16; search_y <= search_height_up; search_y += 16) {
            var check_y = y - search_y;
            
            if (place_meeting(check_x, check_y + 1, Oground) && 
                !place_meeting(check_x, check_y - 16, Oground) &&
                !place_meeting(check_x, check_y, Oground)) {
                
                var has_clear_path = true;
                for (var gap_check = 16; gap_check < search_x; gap_check += 16) {
                    var gap_x = x + (direction_facing * gap_check);
                    if (place_meeting(gap_x, y, Oground)) {
                        has_clear_path = false;
                        break;
                    }
                }
                
                if (has_clear_path) {
                    var dist = point_distance(x, y, check_x, check_y);
                    if (dist < best_distance) {
                        best_distance = dist;
                        best_platform_x = check_x;
                        best_platform_y = check_y;
                        best_platform_found = true;
                    }
                }
            }
        }
    }
    
    // Hledej platformy DOLŮ
    if (!best_platform_found) {
        for (var search_x = 32; search_x <= search_distance; search_x += 16) {
            var check_x = x + (direction_facing * search_x);
            
            var has_gap_below = true;
            
            for (var gap_check_y = 16; gap_check_y <= 32; gap_check_y += 16) {
                var gap_y = y + gap_check_y;
                if (place_meeting(check_x, gap_y, Oground)) {
                    has_gap_below = false;
                    break;
                }
            }
            
            if (!has_gap_below) {
                continue;
            }
            
            for (var search_y = 32; search_y <= search_height_down; search_y += 16) {
                var check_y = y + search_y;
                
                if (place_meeting(check_x, check_y + 1, Oground) && 
                    !place_meeting(check_x, check_y - 16, Oground)) {
                    
                    var dist = point_distance(x, y, check_x, check_y);
                    if (dist < best_distance) {
                        best_distance = dist;
                        best_platform_x = check_x;
                        best_platform_y = check_y;
                        best_platform_found = true;
                    }
                }
            }
        }
    }
    
    if (best_platform_found) {
        can_jump_to_platform = true;
        target_platform_x = best_platform_x;
        target_platform_y = best_platform_y;
    }
}

// ========== AI - CHŮZE A SKOK ==========
if (on_ground) {
    if (idle_timer <= 0) {
        vel_x = move_speed * direction_facing;
        
        var jump_air_time = (jump_force * 2) / gravity_force;
        var horizontal_jump_distance = move_speed * 1.8 * (jump_air_time * 0.5);
        var safe_distance = ceil(horizontal_jump_distance) + 16;
        
        // ========== EDGE CHECK ==========
        var edge_safe = true;
        
        var platform_below_and_close = false;
        if (can_jump_to_platform && target_platform_y > y) {
            var platform_distance = point_distance(x, y, target_platform_x, target_platform_y);
            
            // Pokud je platforma POD a dosažitelná → ignoruj edge check
            if (platform_distance <= horizontal_jump_distance * 1.3) {
                platform_below_and_close = true;
                edge_safe = true;
                
                show_debug_message("Platform below in range - SKIP edge check");
            }
        }
        
        if (!platform_below_and_close) {
            var check_x_1 = x + (direction_facing * 16);
            var check_y_1 = y + 12;
            if (!place_meeting(check_x_1, check_y_1, Oground)) edge_safe = false;
            
            var check_x_2 = x + (direction_facing * (safe_distance / 2));
            var check_y_2 = y + 20;
            if (!place_meeting(check_x_2, check_y_2, Oground)) edge_safe = false;
            
            var check_x_3 = x + (direction_facing * safe_distance);
            var check_y_3 = y + 28;
            if (!place_meeting(check_x_3, check_y_3, Oground)) edge_safe = false;
        }
        
        // ========== POKUD NENÍ BEZPEČNÉ ==========
        if (!edge_safe) {
            // Pokud vidí platformu → SKOČ
            if (can_jump_to_platform && jump_cooldown <= 0) {
                var platform_distance = point_distance(x, y, target_platform_x, target_platform_y);
                
                show_debug_message("Edge unsafe - trying platform jump (dist: " + string(round(platform_distance)) + ")");
                
                if (platform_distance <= horizontal_jump_distance * 1.3) {
                    vel_y = -jump_force;
                    
                    // Extra speed pro jump dolů
                    if (target_platform_y > y) {
                        vel_x = move_speed * direction_facing * 2.2;
                        show_debug_message(">>> JUMPING DOWN <<<");
                    } else {
                        vel_x = move_speed * direction_facing * 1.8;
                    }
                    
                    jump_cooldown = jump_cooldown_max;
                    turn_cooldown = 60;
                } else {
                    show_debug_message("Platform too far - turning around");
                    if (turn_cooldown <= 0) {
                        vel_x = 0;
                        direction_facing = -direction_facing;
                        idle_timer = 20;
                        turn_cooldown = 60;
                    } else {
                        vel_x = 0;
                    }
                }
            } else {
                if (turn_cooldown <= 0) {
                    vel_x = 0;
                    direction_facing = -direction_facing;
                    idle_timer = 20;
                    walk_timer = random_range(120, 240);
                    turn_cooldown = 60;
                } else {
                    vel_x = 0;
                }
            }
        }
        // ========== POKUD JE BEZPEČNÉ ==========
        else {
            if (jump_cooldown <= 0) {
                var should_jump = false;
                var jump_strength = jump_force;
                var jump_reason = "";
                
                // 1. ZEĎ
                if (place_meeting(x + (direction_facing * 20), y, Oground) && 
                    !place_meeting(x + (direction_facing * 20), y - 32, Oground)) {
                    should_jump = true;
                    jump_strength = jump_force;
                    jump_reason = "WALL";
                }
                
                // 2. PLATFORMA
                else if (can_jump_to_platform) {
                    var platform_distance = point_distance(x, y, target_platform_x, target_platform_y);
                    
                    if (platform_distance <= horizontal_jump_distance * 1.3) {
                        should_jump = true;
                        jump_strength = jump_force;
                        
                        if (target_platform_y > y) {
                            vel_x = move_speed * direction_facing * 2.2;
                            jump_reason = "PLATFORM DOWN";
                        } else {
                            vel_x = move_speed * direction_facing * 1.5;
                            jump_reason = "PLATFORM UP";
                        }
                    }
                }
                
                // 3. RANDOM
                else if (random(100) < 5) {
                    should_jump = true;
                    jump_strength = jump_force * random_range(0.7, 1.0);
                    jump_reason = "RANDOM";
                }
                
                // 4. ROUTINE
                else if (random(100) < 3) {
                    should_jump = true;
                    jump_strength = jump_force * random_range(0.8, 1.0);
                    jump_reason = "ROUTINE";
                }
                
                // PROVEĎ SKOK
                if (should_jump) {
                    vel_y = -jump_strength;
                    jump_cooldown = jump_cooldown_max;
                    
                    show_debug_message(">>> JUMP: " + jump_reason + " <<<");
                    
                    // Random otočení - S COOLDOWNEM
                    if (random(100) < 20 && jump_reason != "PLATFORM DOWN" && jump_reason != "PLATFORM UP" && turn_cooldown <= 0) {
                        var new_direction = -direction_facing;
                        var turn_safe = true;
                        
                        var turn_check_1 = x + (new_direction * 16);
                        if (!place_meeting(turn_check_1, y + 12, Oground)) turn_safe = false;
                        
                        var turn_check_2 = x + (new_direction * (safe_distance / 2));
                        if (!place_meeting(turn_check_2, y + 20, Oground)) turn_safe = false;
                        
                        var turn_check_3 = x + (new_direction * safe_distance);
                        if (!place_meeting(turn_check_3, y + 28, Oground)) turn_safe = false;
                        
                        if (turn_safe) {
                            direction_facing = new_direction;
                            turn_cooldown = 60;
                        }
                    }
                }
            }
        }
        
        // Walk timer
        if (walk_timer <= 0) {
            if (random(100) < 20) {
                vel_x = 0;
                idle_timer = random_range(15, 30);
            }
            walk_timer = random_range(120, 240);
        }
        
    } else {
        vel_x = 0;
    }
    
} else {
    vel_x = move_speed * direction_facing * 0.8;
}

// ========== KOLIZE SE ZDÍ ==========
if (place_meeting(x + vel_x, y, Oground)) {
    while (!place_meeting(x + sign(vel_x), y, Oground)) {
        x += sign(vel_x);
    }
    
    if (!on_ground && abs(vel_x) > 1) {
        vel_x = -vel_x * 0.7;
        if (turn_cooldown <= 0) {
            direction_facing = -direction_facing;
            turn_cooldown = 60;
        }
    } else {
        vel_x = 0;
        if (turn_cooldown <= 0) {
            direction_facing = -direction_facing;
            idle_timer = 20;
            turn_cooldown = 60;
        }
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
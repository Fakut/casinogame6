// Smrt
if (hp <= 0 && !is_dead) {
    is_dead = true;
    
    // ========== TRACK KILL ==========
    if (instance_exists(Oplayer)) {
        Oplayer.total_enemies_killed++;
    }
    
    if (instance_exists(Owave_manager)) {
        Owave_manager.enemies_alive -= 1;
    }
    
    var money_amount = 15;
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

// ========== HOVER EFEKT ==========
hover_offset += hover_speed;
var hover_y = sin(hover_offset) * hover_amount;

// ========== DETECTION ==========
if (instance_exists(Oplayer)) {
    var dist = point_distance(x, y, Oplayer.x, Oplayer.y);
    
    if (!seen_player_once && dist < chase_range) {
        var dir = point_direction(x, y, Oplayer.x, Oplayer.y);
        var can_see = true;
        
        for (var i = 16; i < dist; i += 16) {
            var check_x = x + lengthdir_x(i, dir);
            var check_y = y + lengthdir_y(i, dir);
            
            if (place_meeting(check_x, check_y, Oground)) {
                can_see = false;
                break;
            }
        }
        
        if (can_see) {
            seen_player_once = true;
            show_debug_message("Player spotted! Chase forever!");
        }
    }
}

// ========== AI ==========
if (seen_player_once && instance_exists(Oplayer)) {
    var target_x = Oplayer.x;
    var target_y = Oplayer.y;
    
    var dx = target_x - x;
    var dy = target_y - y;
    var dist = point_distance(x, y, target_x, target_y);
    
    // ========== DYNAMICKÝ CHECK DISTANCE ==========
    var check_dist = check_distance;
    
    var blocked_big_right = place_meeting(x + check_dist, y, Oground);
    var blocked_big_left = place_meeting(x - check_dist, y, Oground);
    var blocked_big_up = place_meeting(x, y - check_dist, Oground);
    var blocked_big_down = place_meeting(x, y + check_dist, Oground);
    
    if (blocked_big_right && blocked_big_left && blocked_big_up && blocked_big_down) {
        check_dist = 20;
    }
    
    // ========== OBSTACLE DETECTION ==========
    var blocked_right = place_meeting(x + check_dist, y, Oground);
    var blocked_left = place_meeting(x - check_dist, y, Oground);
    var blocked_up = place_meeting(x, y - check_dist, Oground);
    var blocked_down = place_meeting(x, y + check_dist, Oground);
    
    // ========== STUCK DETECTION ==========
    var completely_stuck = blocked_right && blocked_left && blocked_up && blocked_down;
    
    if (completely_stuck) {
        var small_check = 12;
        blocked_right = place_meeting(x + small_check, y, Oground);
        blocked_left = place_meeting(x - small_check, y, Oground);
        blocked_up = place_meeting(x, y - small_check, Oground);
        blocked_down = place_meeting(x, y + small_check, Oground);
        
        if (blocked_right && blocked_left && blocked_up && blocked_down) {
            if (!place_meeting(x + 4, y, Oground)) blocked_right = false;
            if (!place_meeting(x - 4, y, Oground)) blocked_left = false;
            if (!place_meeting(x, y - 4, Oground)) blocked_up = false;
            if (!place_meeting(x, y + 4, Oground)) blocked_down = false;
        }
    }
    
    // ========== DETOUR TRACKING ==========
    var want_right = dx > 0;
    var want_left = dx < 0;
    var want_up = dy < 0;
    var want_down = dy > 0;
    
    var mainly_horizontal = abs(dx) > abs(dy);
    var mainly_vertical = abs(dy) > abs(dx);
    
    var blocked_towards_player = false;
    if (want_right && blocked_right) blocked_towards_player = true;
    if (want_left && blocked_left) blocked_towards_player = true;
    if (want_up && blocked_up) blocked_towards_player = true;
    if (want_down && blocked_down) blocked_towards_player = true;
    
    if (blocked_towards_player) {
        detour_timer++;
    } else {
        if (detour_timer > 0) {
            show_debug_message("Detour complete! Was " + string(detour_timer) + " frames");
        }
        detour_timer = 0;
    }
    
    // ========== DETOUR LEVELS ==========
    var extra_detour = (detour_timer > 60);
    var super_long_detour = (detour_timer > 120);
    
    // ========== VÝPOČET SMĚRU ==========
    var move_x = 0;
    var move_y = 0;
    
    // ========== HRÁČ HORIZONTÁLNĚ ==========
    if (mainly_horizontal) {
        if (want_right && !blocked_right) {
            move_x = 1;
        } else if (want_left && !blocked_left) {
            move_x = -1;
        } 
        else if (want_right && blocked_right) {
            if (super_long_detour) {
                if (!blocked_up) {
                    move_y = -1;
                    move_x = 0.3;
                } else if (!blocked_down) {
                    move_y = 1;
                    move_x = 0.3;
                } else {
                    move_x = -0.5;
                }
            } else {
                var detour_strength = extra_detour ? 1.5 : 1.0;
                
                if (!blocked_up && (want_up || !blocked_down)) {
                    move_y = -1 * detour_strength;
                } else if (!blocked_down) {
                    move_y = 1 * detour_strength;
                }
            }
        } else if (want_left && blocked_left) {
            if (super_long_detour) {
                if (!blocked_up) {
                    move_y = -1;
                    move_x = -0.3;
                } else if (!blocked_down) {
                    move_y = 1;
                    move_x = -0.3;
                } else {
                    move_x = 0.5;
                }
            } else {
                var detour_strength = extra_detour ? 1.5 : 1.0;
                
                if (!blocked_up && (want_up || !blocked_down)) {
                    move_y = -1 * detour_strength;
                } else if (!blocked_down) {
                    move_y = 1 * detour_strength;
                }
            }
        }
        
        if (move_x != 0 && !super_long_detour) {
            if (want_up && !blocked_up) {
                move_y = -0.5;
            } else if (want_down && !blocked_down) {
                move_y = 0.5;
            }
        }
    }
    // ========== HRÁČ VERTIKÁLNĚ ==========
    else if (mainly_vertical) {
        if (want_up && !blocked_up) {
            move_y = -1;
        } else if (want_down && !blocked_down) {
            move_y = 1;
        }
        else if (want_up && blocked_up) {
            if (super_long_detour) {
                if (!blocked_down) {
                    move_y = 1;
                } else if (!blocked_right) {
                    move_x = 1;
                } else if (!blocked_left) {
                    move_x = -1;
                }
            } else {
                var detour_strength = extra_detour ? 1.5 : 1.0;
                
                if (!blocked_right && (want_right || !blocked_left)) {
                    move_x = 1 * detour_strength;
                } else if (!blocked_left) {
                    move_x = -1 * detour_strength;
                }
            }
        } else if (want_down && blocked_down) {
            if (super_long_detour) {
                if (!blocked_up) {
                    move_y = -1;
                } else if (!blocked_right) {
                    move_x = 1;
                } else if (!blocked_left) {
                    move_x = -1;
                }
            } else {
                var detour_strength = extra_detour ? 1.5 : 1.0;
                
                if (!blocked_right && (want_right || !blocked_left)) {
                    move_x = 1 * detour_strength;
                } else if (!blocked_left) {
                    move_x = -1 * detour_strength;
                }
            }
        }
        
        if (move_y != 0 && !super_long_detour) {
            if (want_right && !blocked_right) {
                move_x = 0.5;
            } else if (want_left && !blocked_left) {
                move_x = -0.5;
            }
        }
    }
    // ========== DIAGONÁLNĚ ==========
    else {
        if (want_right && !blocked_right) {
            move_x = 1;
        } else if (want_left && !blocked_left) {
            move_x = -1;
        }
        
        if (want_up && !blocked_up) {
            move_y = -1;
        } else if (want_down && !blocked_down) {
            move_y = 1;
        }
    }
    
    // ========== STUCK → ESCAPE ==========
    if (move_x == 0 && move_y == 0) {
        if (!want_up && !blocked_up) {
            move_y = -1;
        } else if (!want_down && !blocked_down) {
            move_y = 1;
        } else if (!want_right && !blocked_right) {
            move_x = 1;
        } else if (!want_left && !blocked_left) {
            move_x = -1;
        } else if (!blocked_up) {
            move_y = -1;
        } else if (!blocked_down) {
            move_y = 1;
        } else if (!blocked_right) {
            move_x = 1;
        } else if (!blocked_left) {
            move_x = -1;
        } else {
            move_x = -sign(dx) * 0.3;
            move_y = -sign(dy) * 0.3;
        }
    }
    
    // ========== APLIKUJ POHYB SE SMOOTH ACCELERATION ==========
    target_vel_x = move_x * move_speed;
    target_vel_y = move_y * move_speed;
    
    vel_x = lerp(vel_x, target_vel_x, acceleration);
    vel_y = lerp(vel_y, target_vel_y, acceleration);
    
    if (dx < 0) {
        direction_x = -1;
    } else if (dx > 0) {
        direction_x = 1;
    }
    
} else {
    target_vel_x = 0;
    target_vel_y = 0;
    
    vel_x = lerp(vel_x, target_vel_x, 0.1);
    vel_y = lerp(vel_y, target_vel_y, 0.1);
    
    detour_timer = 0;
}

// ========== HOVER ==========
if (seen_player_once) {
    vel_y += hover_y * 0.05;
} else {
    vel_y += hover_y * 0.15;
}

// ========== LIMIT ==========
var current_speed = point_distance(0, 0, vel_x, vel_y);
if (current_speed > max_speed) {
    vel_x = (vel_x / current_speed) * max_speed;
    vel_y = (vel_y / current_speed) * max_speed;
}

// ========== KOLIZE ==========
if (place_meeting(x + vel_x, y, Oground)) {
    while (!place_meeting(x + sign(vel_x), y, Oground)) {
        x += sign(vel_x);
    }
    vel_x = 0;
}

x += vel_x;

if (place_meeting(x, y + vel_y, Oground)) {
    while (!place_meeting(x, y + sign(vel_y), Oground)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}

y += vel_y;

// ========== SPRITE ==========
if (direction_x == -1) {
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
// Nakresli sprite
draw_self();

// Health bar
draw_set_color(c_red);
draw_rectangle(x - 7, y - 15, x + 7, y - 12, false);
draw_set_color(c_green);
draw_rectangle(x - 7, y - 15, x - 7 + (14 * (hp / max_hp)), y - 12, false);
draw_set_color(c_white);

// ========== DEBUG (F3) ==========
if (keyboard_check(vk_f3)) {
    draw_set_halign(fa_center);
    
    // Jump cooldown
    draw_set_color(c_white);
    draw_text(x, y - 50, "Jump CD: " + string(jump_cooldown));
    
    // Platform detection
    if (can_jump_to_platform) {
        draw_set_color(c_lime);
        draw_text(x, y - 65, "CAN JUMP!");
        
        // Cílová platforma - velký kruh
        draw_set_color(c_lime);
        draw_circle(target_platform_x, target_platform_y, 12, true);
        draw_line_width(x, y, target_platform_x, target_platform_y, 3);
        
        // Vzdálenost v pixelech A blocích
        var platform_dist = point_distance(x, y, target_platform_x, target_platform_y);
        draw_set_color(c_white);
        draw_text(target_platform_x, target_platform_y - 25, string(round(platform_dist)) + "px");
        
        // Výška v blocích
        var height_diff = abs(target_platform_y - y);
        var blocks = height_diff / 32;
        draw_text(target_platform_x, target_platform_y - 40, string(blocks) + " blocks");
        
        // Směr - VÝRAZNÉ
        if (target_platform_y < y) {
            draw_set_color(c_yellow);
            draw_text_transformed(target_platform_x, target_platform_y - 55, "UP!", 1.5, 1.5, 0);
        } else {
            draw_set_color(c_orange);
            draw_text_transformed(target_platform_x, target_platform_y - 55, "DOWN!", 1.5, 1.5, 0);
            
            // Extra označení pro DOWN
            draw_set_alpha(0.5);
            draw_circle(target_platform_x, target_platform_y, 20, false);
            draw_set_alpha(1);
        }
    } else {
        draw_set_color(c_red);
        draw_text(x, y - 65, "NO PLATFORM");
    }
    
    // Edge check kruhy
    var on_ground = place_meeting(x, y + 1, Oground);
    if (on_ground) {
        var jump_air_time = (jump_force * 2) / gravity_force;
        var horizontal_jump_distance = move_speed * 1.8 * (jump_air_time * 0.5);
        var safe_distance = ceil(horizontal_jump_distance) + 16;
        
        // Check 1 (blízko - 16px)
        var check_x1 = x + (direction_facing * 16);
        var check_y1 = y + 12;
        
        if (place_meeting(check_x1, check_y1, Oground)) {
            draw_set_color(c_lime);
        } else {
            draw_set_color(c_red);
        }
        draw_circle(check_x1, check_y1, 5, false);
        draw_set_color(c_white);
        draw_text(check_x1, check_y1 - 15, "1");
        
        // Check 2 (střed)
        var check_x2 = x + (direction_facing * (safe_distance / 2));
        var check_y2 = y + 20;
        
        if (place_meeting(check_x2, check_y2, Oground)) {
            draw_set_color(c_yellow);
        } else {
            draw_set_color(c_orange);
        }
        draw_circle(check_x2, check_y2, 6, false);
        draw_set_color(c_white);
        draw_text(check_x2, check_y2 - 15, "2");
        
        // Check 3 (daleko - kam dopadne)
        var check_x3 = x + (direction_facing * safe_distance);
        var check_y3 = y + 28;
        
        if (place_meeting(check_x3, check_y3, Oground)) {
            draw_set_color(c_aqua);
        } else {
            draw_set_color(c_purple);
        }
        draw_circle(check_x3, check_y3, 7, false);
        draw_set_color(c_white);
        draw_text(check_x3, check_y3 - 15, "3");
        
        // Search area visualization
        var max_horizontal_distance = move_speed * 1.8 * (jump_air_time * 0.5);
        var max_jump_height = (jump_force * jump_force) / (2 * gravity_force);
        var search_distance = min(max_horizontal_distance, 96);
        var search_height_up = 96;      // ← 3 bloky NAD
        var search_height_down = 96;    // ← 3 bloky POD
        
        // Box nahoru (žlutý) - 3 bloky
        draw_set_alpha(0.15);
        draw_set_color(c_yellow);
        var box_x1 = x;
        var box_y1 = y - search_height_up;
        var box_x2 = x + (direction_facing * search_distance);
        var box_y2 = y;
        draw_rectangle(box_x1, box_y1, box_x2, box_y2, false);
        
        // Box dolů (oranžový) - 3 bloky
        draw_set_color(c_orange);
        var box_y3 = y;
        var box_y4 = y + search_height_down;
        draw_rectangle(box_x1, box_y3, box_x2, box_y4, false);
        
        // Gap check zona (červená) - 1 blok
        draw_set_color(c_red);
        var gap_y1 = y + 16;
        var gap_y2 = y + 32;
        draw_rectangle(box_x1, gap_y1, box_x2, gap_y2, false);
        
        draw_set_alpha(1);
        
        // Labels - v blocích!
        draw_set_color(c_yellow);
        draw_text(x + (direction_facing * 20), y - 48, "UP 3 BLOCKS");
        
        draw_set_color(c_red);
        draw_text(x + (direction_facing * 20), y + 24, "GAP 1 BLOCK");
        
        draw_set_color(c_orange);
        draw_text(x + (direction_facing * 20), y + 64, "DOWN 3 BLOCKS");
        
        // Čísla v pixelech
        draw_set_color(c_aqua);
        draw_text(x + (direction_facing * 20), y - 64, "(-96px)");
        draw_text(x + (direction_facing * 20), y + 16, "(+16-32px)");
        draw_text(x + (direction_facing * 20), y + 88, "(+32-96px)");
    }
    
    // State
    if (idle_timer > 0) {
        draw_set_color(c_aqua);
        draw_text(x, y - 80, "IDLE");
    } else {
        draw_set_color(c_white);
        draw_text(x, y - 80, "WALK");
    }
    
    // Jump physics info
    var jump_air_time = (jump_force * 2) / gravity_force;
    var max_jump_height = (jump_force * jump_force) / (2 * gravity_force);
    draw_set_color(c_aqua);
    draw_text(x, y - 95, "Max: " + string(round(max_jump_height)) + "px (" + string(max_jump_height/32) + " blocks)");
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}
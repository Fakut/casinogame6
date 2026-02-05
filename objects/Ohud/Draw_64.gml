// ========== SKRYJ HUD PŘI PAUSE ==========
if (global.game_paused) exit;

gpu_set_texfilter(false);
draw_set_font(fnt_pixel);

// ========== HUD - VŠE NA JEDNOM MÍSTĚ ==========

gpu_set_texfilter(false);
draw_set_font(fnt_pixel);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

if (!instance_exists(Oplayer)) {
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    exit;
}

// ========== CHECK CASINO ==========
var casino_open = (instance_exists(Ocasino_manager) && Ocasino_manager.casino_active);

// ========== HEALTH BAR - SKRYJ V CASINU ==========
if (!casino_open) {
    var bar_x = 20;
    var bar_y = 20;
    var bar_width = 180;
    var bar_height = 20;

    draw_set_color(c_black);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

    var hp_percent = Oplayer.hp / Oplayer.max_hp;
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_width * hp_percent), bar_y + bar_height, false);

    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    
    // HP V ČÍSLECH NAD BAREM!
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_text(bar_x + bar_width / 2, bar_y - 1, string(Oplayer.hp) + " / " + string(Oplayer.max_hp));

    // ========== JUMP INDICATOR ==========
    var jump_x = 20;
    var jump_y = bar_y + bar_height + 8;
    var dot_size = 12;
    var dot_spacing = 20;

    for (var i = 0; i < Oplayer.max_jumps; i++) {
        var dot_x = jump_x + (i * dot_spacing);
        
        if (i < Oplayer.jumps_remaining) {
            draw_set_color(c_white);
            draw_circle(dot_x + dot_size/2, jump_y + dot_size/2, dot_size/2, false);
        } else {
            draw_set_color(c_black);
            draw_circle(dot_x + dot_size/2, jump_y + dot_size/2, dot_size/2, false);
        }
    }
}

// ========== PENÍZE ==========
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_color(c_yellow);
draw_text(gui_w - 20, 20, "$" + string(Oplayer.money));

// ========== WEAPON CURRENT - SKRYJ V CASINU ==========
if (!casino_open) {
    if (variable_global_exists("weapons")) {
        draw_set_halign(fa_center);
        var weapon = global.weapons[Oplayer.current_weapon];
        
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_rectangle(gui_w / 2 - 100, gui_h - 60, gui_w / 2 + 100, gui_h - 20, false);
        draw_set_alpha(1);
        
        draw_set_color(weapon.color);
        draw_text(gui_w / 2, gui_h - 50, weapon.icon + " " + weapon.name);
        
        var cooldown_percent = Oplayer.attack_cooldown / weapon.fire_rate;
        draw_set_color(c_dkgray);
        draw_rectangle(gui_w / 2 - 80, gui_h - 30, gui_w / 2 + 80, gui_h - 25, false);
        
        if (cooldown_percent > 0) {
            draw_set_color(c_red);
            draw_rectangle(gui_w / 2 - 80, gui_h - 30, gui_w / 2 - 80 + (160 * (1 - cooldown_percent)), gui_h - 25, false);
        } else {
            draw_set_color(c_lime);
            draw_rectangle(gui_w / 2 - 80, gui_h - 30, gui_w / 2 + 80, gui_h - 25, false);
        }
    }
}

// ========== WEAPON LIST (VPRAVO) - VŽDY VIDITELNÉ! ==========
if (variable_global_exists("weapons")) {
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    
    var list_x = gui_w - 20;
    var list_y = 60;
    
    draw_set_color(c_white);
    draw_text(list_x, list_y, "WEAPONS:");
    list_y += 25;
    
    for (var i = 0; i < array_length(global.weapons); i++) {
        var weapon = global.weapons[i];
        
        if (Oplayer.weapon_unlocked[i]) {
            // Odemčená zbraň - barevná
            draw_set_color(weapon.color);
            if (i == Oplayer.current_weapon) {
                draw_text(list_x, list_y, "> " + weapon.icon + " " + weapon.name);
            } else {
                draw_text(list_x, list_y, weapon.icon + " " + weapon.name);
            }
        } else {
            // Locked zbraň - šedá
            draw_set_color(c_dkgray);
            draw_text(list_x, list_y, "LOCKED");
        }
        
        list_y += 20;
    }
}

// ========== TAB PROMPT V SHOPU ==========
if (room == Room_shop && !casino_open) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_yellow);
    draw_text(gui_w / 2, gui_h - 120, "[TAB] Open Casino");
}

// ========== VLNA INFO ==========
if (room == Room_level1 && instance_exists(Owave_manager)) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text(20, 70, "Wave: " + string(Owave_manager.current_wave));
    
    if (Owave_manager.wave_active) {
        draw_text(20, 90, "Enemies: " + string(Owave_manager.enemies_alive) + " / " + string(Owave_manager.enemies_to_spawn));
    }
    
    if (Owave_manager.wave_complete) {
        draw_set_color(c_lime);
        draw_text(20, 115, "WAVE COMPLETED!");
        draw_text(20, 135, "Go to shop");
    }
    
    if (Owave_manager.auto_start_timer > 0 && !Owave_manager.wave_active) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_yellow);
        var seconds = ceil(Owave_manager.auto_start_timer / 30);
        draw_text_transformed(gui_w / 2, 150, "Next wave in " + string(seconds), 2, 2, 0);
    }
}

// ========== WEAPON UNLOCK NOTIFICATION ==========
if (weapon_unlock_timer > 0 && weapon_unlock_message != "") {
    var notify_y = 150;
    
    var alpha = 1;
    if (weapon_unlock_timer < 30) {
        alpha = weapon_unlock_timer / 30;
    }
    
    draw_set_alpha(alpha);
    
    // Stín
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_transformed(gui_w / 2 + 2, notify_y + 2, weapon_unlock_message, 2, 2, 0);
    
    // Text
    draw_set_color(c_yellow);
    draw_text_transformed(gui_w / 2, notify_y, weapon_unlock_message, 2, 2, 0);
    
    draw_set_alpha(1);
}

// Reset
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ========== RESET ==========
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
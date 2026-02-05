if (!global.game_paused) exit;

gpu_set_texfilter(false);
draw_set_font(fnt_pixel);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// Tmavé pozadí
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// ========== LEVÝ BOX - COMBAT + PLAYER STATS ==========
if (instance_exists(Oplayer)) {
    var left_box_w = 280;
    var left_box_h = 420;
    var left_box_x = 40;
    var left_box_y = gui_h / 2 - left_box_h / 2;

    // Pozadí
    draw_set_color(c_dkgray);
    draw_rectangle(left_box_x, left_box_y, left_box_x + left_box_w, left_box_y + left_box_h, false);
    draw_set_color(c_white);
    draw_rectangle(left_box_x, left_box_y, left_box_x + left_box_w, left_box_y + left_box_h, true);

    // Text
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var lx = left_box_x + 15;
    var ly = left_box_y + 15;
    var spacing = 24;

    // COMBAT STATS
    draw_set_color(c_yellow);
    draw_text(lx, ly, "COMBAT STATS:");
    ly += spacing + 5;

    draw_set_color(c_white);
    draw_text(lx, ly, "Damage Dealt:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(floor(Oplayer.total_damage_dealt)));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Damage Taken:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(floor(Oplayer.total_damage_taken)));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Enemies Killed:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(Oplayer.total_enemies_killed));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Shots Fired:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(Oplayer.total_shots_fired));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Shots Hit:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(Oplayer.total_shots_hit));
    ly += spacing;

    var accuracy = 0;
    if (Oplayer.total_shots_fired > 0) {
        accuracy = (Oplayer.total_shots_hit / Oplayer.total_shots_fired) * 100;
    }
    draw_set_color(c_white);
    draw_text(lx, ly, "Accuracy:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(floor(accuracy)) + "%");
    ly += spacing + 8;

    // PLAYER STATS
    draw_set_color(c_yellow);
    draw_text(lx, ly, "PLAYER STATS:");
    ly += spacing + 5;

    draw_set_color(c_white);
    draw_text(lx, ly, "Max HP:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(Oplayer.max_hp));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Speed:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string_format(Oplayer.move_speed, 1, 1));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Jump Force:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string_format(Oplayer.jump_force, 1, 1));
    ly += spacing;

    draw_set_color(c_white);
    draw_text(lx, ly, "Max Jumps:");
    draw_set_color(c_yellow);
    draw_text(lx + 180, ly, string(Oplayer.max_jumps));
    ly += spacing;

    if (variable_global_exists("weapons")) {
        draw_set_color(c_white);
        draw_text(lx, ly, "Weapon DMG:");
        draw_set_color(c_yellow);
        draw_text(lx + 180, ly, string(global.weapons[Oplayer.current_weapon].damage));
    }
}

// ========== PRAVÝ BOX - CASINO + MONEY + MOVEMENT ==========
if (instance_exists(Oplayer)) {
    var right_box_w = 280;
    var right_box_h = 420;
    var right_box_x = gui_w - right_box_w - 40;
    var right_box_y = gui_h / 2 - right_box_h / 2;

    // Pozadí
    draw_set_color(c_dkgray);
    draw_rectangle(right_box_x, right_box_y, right_box_x + right_box_w, right_box_y + right_box_h, false);
    draw_set_color(c_white);
    draw_rectangle(right_box_x, right_box_y, right_box_x + right_box_w, right_box_y + right_box_h, true);

    var rx = right_box_x + 15;
    var ry = right_box_y + 15;
    var spacing = 24;

    // CASINO STATS
    draw_set_color(c_yellow);
    draw_text(rx, ry, "CASINO STATS:");
    ry += spacing + 5;

    // Slots
    draw_set_color(c_white);
    draw_text(rx, ry, "Slot Spins:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, string(Oplayer.casino_slots_spins));
    ry += spacing;

    // Blackjack
    draw_set_color(c_white);
    draw_text(rx, ry, "Blackjack Hands:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, string(Oplayer.casino_blackjack_hands));
    ry += spacing;

    // Roulette
    draw_set_color(c_white);
    draw_text(rx, ry, "Roulette Spins:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, string(Oplayer.casino_roulette_spins));
    ry += spacing + 8;

    // MONEY
    draw_set_color(c_yellow);
    draw_text(rx, ry, "MONEY:");
    ry += spacing + 5;

    draw_set_color(c_white);
    draw_text(rx, ry, "Total Earned:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, "$" + string(Oplayer.total_money_earned));
    ry += spacing;

    draw_set_color(c_white);
    draw_text(rx, ry, "Total Spent:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, "$" + string(Oplayer.casino_total_spent));
    ry += spacing + 8;

    // MOVEMENT
    draw_set_color(c_yellow);
    draw_text(rx, ry, "MOVEMENT:");
    ry += spacing + 5;

    draw_set_color(c_white);
    draw_text(rx, ry, "Jumps:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, string(Oplayer.total_jumps));
    ry += spacing;

    draw_set_color(c_white);
    draw_text(rx, ry, "Dashes:");
    draw_set_color(c_yellow);
    draw_text(rx + 180, ry, string(Oplayer.total_dashes));
}

// ========== STŘEDNÍ BOX - PAUSE MENU ==========
var box_w = 300;
var box_h = 280;
var box_x = gui_w / 2 - box_w / 2;
var box_y = gui_h / 2 - box_h / 2;

draw_set_color(c_dkgray);
draw_rectangle(box_x, box_y, box_x + box_w, box_y + box_h, false);
draw_set_color(c_white);
draw_rectangle(box_x, box_y, box_x + box_w, box_y + box_h, true);

// Nadpis
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_yellow);
draw_text_transformed(gui_w / 2, box_y + 60, "PAUSED", 2, 2, 0);

// Menu options
var start_y = gui_h / 2;
var spacing = 70;
var options = ["RESUME", "QUIT GAME"];

for (var i = 0; i < array_length(options); i++) {
    var yy = start_y + (i * spacing);
    
    if (i == selected) {
        draw_set_color(c_yellow);
        draw_text_transformed(gui_w / 2, yy, "> " + options[i] + " <", 1.5, 1.5, 0);
    } else {
        draw_set_color(c_white);
        draw_text(gui_w / 2, yy, options[i]);
    }
}

// ========== NÁPOVĚDA POD STŘEDNÍM BOXEM ==========
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(gui_w / 2, box_y + box_h + 15, "[W/S] Select  |  [ENTER] Confirm  |  [ESC] Resume");

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
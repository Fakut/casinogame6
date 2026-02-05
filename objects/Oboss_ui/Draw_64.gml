if (instance_exists(boss)) {
    var bar_width = 800;
    var bar_height = 40;
    var bar_x = (display_get_gui_width() / 2) - (bar_width / 2);
    var bar_y = 50;
    
    // Background
    draw_set_color(c_black);
    draw_rectangle(bar_x - 4, bar_y - 4, bar_x + bar_width + 4, bar_y + bar_height + 4, false);
    
    // HP bar
    var hp_percent = boss.hp / boss.max_hp;
    draw_set_color(c_red);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_width * hp_percent), bar_y + bar_height, false);
    
    // Border
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    
    // Text
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(bar_x + (bar_width / 2), bar_y + (bar_height / 2), "BOSS: " + string(boss.hp) + " / " + string(boss.max_hp));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Phase
    draw_set_color(c_yellow);
    draw_text(bar_x + (bar_width / 2) - 100, bar_y - 30, "PHASE " + string(boss.current_phase));
    draw_set_color(c_white);
}
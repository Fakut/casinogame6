// Nakresli dveře
draw_self();

// Prompt s TVÝM FONTEM
if (prompt && instance_exists(Oplayer)) {
    gpu_set_texfilter(false);
    draw_set_font(fnt_pixel);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    
    // ========== TŘI STAVY ==========
    
    // 1. LOCKED
    if (locked_during_boss && !boss_defeated_flag) {
        // Stín
        draw_set_color(c_black);
        draw_text(x + hitbox_width/2 + 1, y - 22, "LOCKED");
        draw_text(x + hitbox_width/2 + 1, y - 2, "Defeat the Boss!");
        
        // Text
        draw_set_color(c_red);
        draw_text(x + hitbox_width/2, y - 21, "LOCKED");
        draw_set_color(c_gray);
        draw_text(x + hitbox_width/2, y - 1, "Defeat the Boss!");
    }
    // 2. VICTORY
    else if (boss_defeated_flag) {
        // Stín
        draw_set_color(c_black);
        draw_text_transformed(x + hitbox_width/2 + 1, y - 42, "★ VICTORY ★", 1.2, 1.2, 0);
        draw_text(x + hitbox_width/2 + 1, y - 2, "[E] Return to Game");
        
        // Text
        draw_set_color(c_yellow);
        draw_text_transformed(x + hitbox_width/2, y - 41, "★ VICTORY ★", 1.2, 1.2, 0);
        draw_set_color(c_white);
        draw_text(x + hitbox_width/2, y - 1, "[E] Return to Game");
    }
    // 3. NORMÁLNÍ
    else {
        // Stín
        draw_set_color(c_black);
        draw_text(x + hitbox_width/2 + 1, y - 2, "[E] Enter Shop");
        
        // Text
        draw_set_color(c_yellow);
        draw_text(x + hitbox_width/2, y - 1, "[E] Enter Shop");
    }
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
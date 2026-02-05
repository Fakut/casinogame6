// Nakresli dveře
draw_self();

// Prompt s TVÝM FONTEM
if (prompt && instance_exists(Oplayer)) {
    gpu_set_texfilter(false);
    draw_set_font(fnt_pixel);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    
    // Stín
    draw_set_color(c_black);
    draw_text(x + hitbox_width/2 + 1, y - 11, "[E] Back to Level");
    
    // Text
    draw_set_color(c_lime);
    draw_text(x + hitbox_width/2, y - 12, "[E] Back to Level");
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
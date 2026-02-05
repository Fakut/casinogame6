// Shoot flash efekt
if (shoot_flash_timer > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_yellow, 1);
} else {
    draw_self();
}

// Health bar
draw_set_color(c_red);
draw_rectangle(x - 7, y - 15, x + 7, y - 12, false);
draw_set_color(c_green);
draw_rectangle(x - 7, y - 15, x - 7 + (14 * (hp / max_hp)), y - 12, false);
draw_set_color(c_white);


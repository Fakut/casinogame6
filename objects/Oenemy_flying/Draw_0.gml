// Sprite
draw_self();

// Health bar
draw_set_color(c_red);
draw_rectangle(x - 7, y - 15, x + 7, y - 12, false);
draw_set_color(c_green);
draw_rectangle(x - 7, y - 15, x - 7 + (14 * (hp / max_hp)), y - 12, false);
draw_set_color(c_white);


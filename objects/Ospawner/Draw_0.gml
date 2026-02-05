// Spawn effect
if (spawn_effect_timer > 0) {
    var alpha = spawn_effect_timer / spawn_effect_duration;
    draw_set_alpha(alpha);
    draw_set_color(c_yellow);
    draw_circle(x, y, 32 * (1 - alpha), true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
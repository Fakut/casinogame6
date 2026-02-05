// Nakresli projektil
draw_self();

// === ROULETTE - rotace ===
if (weapon_type == "roulette") {
    image_angle += 10;  // Točí se!
}

// === POKER CHIP - explosion radius indicator ===
if (weapon_type == "chip" && explosion_radius > 0) {
    draw_set_alpha(0.2);
    draw_set_color(c_red);
    draw_circle(x, y, explosion_radius, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
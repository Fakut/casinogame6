// Zaokrouhli pozice pro kreslení (proti sub-pixel třepání)
var draw_x = round(x);
var draw_y = round(y);

// Blikání při nezranitelnosti
if (invincible_timer > 0) {
    if (invincible_timer % 4 < 2) {
        draw_sprite_ext(sprite_index, image_index, draw_x, draw_y, facing, 1, 0, c_red, 0.5);
    } else {
        draw_sprite_ext(sprite_index, image_index, draw_x, draw_y, facing, 1, 0, c_white, 1);
    }
} else {
    // Normální kreslení
    draw_sprite_ext(sprite_index, image_index, draw_x, draw_y, facing, 1, 0, c_white, 1);
}
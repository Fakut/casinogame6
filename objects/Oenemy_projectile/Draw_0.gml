// Nakresli projektil s červeným zabarvením
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, 1);

// Trail efekt (volitelné)
draw_set_alpha(0.3);
draw_sprite_ext(sprite_index, image_index, x - lengthdir_x(5, direction), y - lengthdir_y(5, direction), image_xscale * 0.7, image_yscale * 0.7, image_angle, c_orange, 1);
draw_set_alpha(1);
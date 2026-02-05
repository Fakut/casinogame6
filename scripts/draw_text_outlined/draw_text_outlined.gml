// @description draw_text_outlined(x, y, text, outline_color)
// @param x
// @param y
// @param text
// @param outline_color

function draw_text_outlined(xx, yy, text, outline_color) {
    var original_color = draw_get_color();
    
    // Outline (8 směrů)
    draw_set_color(outline_color);
    draw_text(xx - 1, yy - 1, text);
    draw_text(xx, yy - 1, text);
    draw_text(xx + 1, yy - 1, text);
    draw_text(xx - 1, yy, text);
    draw_text(xx + 1, yy, text);
    draw_text(xx - 1, yy + 1, text);
    draw_text(xx, yy + 1, text);
    draw_text(xx + 1, yy + 1, text);
    
    // Hlavní text
    draw_set_color(original_color);
    draw_text(xx, yy, text);
}
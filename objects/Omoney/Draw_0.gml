// Nakresli peníze
draw_self();

// Blikání před pickupem (volitelné)
if (!can_pickup) {
    draw_set_alpha(0.5);
    draw_self();
    draw_set_alpha(1);
}
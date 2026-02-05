// Pohyb
x += speed_wave * direction_facing;

lifetime++;

// Check collision s hráčem
if (!hit_player && instance_exists(Oplayer)) {
    if (place_meeting(x, y, Oplayer)) {
        Oplayer.hp -= damage;
        hit_player = true;
        show_debug_message("Wave hit player!");
    }
}

// Edge check
var edge_check_x = x + (direction_facing * 16);
var edge_check_y = y + 20;

if (!place_meeting(edge_check_x, edge_check_y, Oground)) {
    instance_destroy();
    exit;
}

// Timeout
if (lifetime >= max_lifetime) {
    instance_destroy();
}
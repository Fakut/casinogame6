// Aktualizuj image_angle podle direction
image_angle = direction;

// Lifetime
lifetime--;
if (lifetime <= 0) {
    instance_destroy();
}

// Zničení mimo room
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
}

// Zničení při nárazu do zdi
if (place_meeting(x, y, Oground)) {
    instance_destroy();
}
// ========== MAGNETISMUS K HRÁČI ==========
if (can_pickup && instance_exists(Oplayer)) {
    var dist = point_distance(x, y, Oplayer.x, Oplayer.y);
    
    if (dist < magnet_range) {
        var dir_to_player = point_direction(x, y, Oplayer.x, Oplayer.y);
        vel_x = lengthdir_x(magnet_speed, dir_to_player);
        vel_y = lengthdir_y(magnet_speed, dir_to_player);
    }
}

// ========== GRAVITACE ==========
if (!can_pickup || point_distance(x, y, Oplayer.x, Oplayer.y) >= magnet_range) {
    vel_y += gravity_force;
}

// ========== KOLIZE SE ZEMÍ ==========
if (place_meeting(x, y + vel_y, Oground)) {
    while (!place_meeting(x, y + sign(vel_y), Oground)) {
        y += sign(vel_y);
    }
    vel_y = -vel_y * bounce;
    
    if (abs(vel_y) < 1) {
        vel_y = 0;
    }
}

// ========== POHYB ==========
x += vel_x;
y += vel_y;

vel_x *= 0.95;

if (pickup_timer > 0) {
    pickup_timer--;
    if (pickup_timer <= 0) {
        can_pickup = true;
    }
}

// ========== PICKUP HRÁČEM ==========
if (can_pickup && instance_exists(Oplayer)) {
    if (place_meeting(x, y, Oplayer)) {
        Oplayer.money += value;
        Oplayer.total_money_earned += value;
        
        // ========== CHIP UNLOCK ==========
        if (Oplayer.weapon_unlocked[1] == false) {
            Oplayer.weapon_unlocked[1] = true;
        }
        
        instance_destroy();
    }
}
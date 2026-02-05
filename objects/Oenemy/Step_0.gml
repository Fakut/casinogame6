// Smrt
if (hp <= 0 && !is_dead) {
    is_dead = true;
    
    // ========== TRACK KILL ==========
    if (instance_exists(Oplayer)) {
        Oplayer.total_enemies_killed++;
    }
    
    // NOTIFY WAVE MANAGER
    if (instance_exists(Owave_manager)) {
        Owave_manager.enemies_alive -= 1;
    }
    
    var money_amount = 10;
    if (instance_exists(Owave_manager)) {
        var wave_index = min(Owave_manager.current_wave - 1, array_length(Owave_manager.wave_config) - 1);
        if (wave_index >= 0) {
            money_amount = Owave_manager.wave_config[wave_index].money_drop;
        }
    }
    
    var money = instance_create_layer(x, y - 10, "Instances", Omoney);
    if (instance_exists(money)) {
        money.value = money_amount;
    }
    
    instance_destroy();
    exit;
}

// ========== KONTROLA ZEMĚ ==========
var on_ground = place_meeting(x, y + 1, Oground);

// ========== GRAVITACE ==========
if (!on_ground) {
    vel_y += gravity_force;
    if (vel_y > max_fall_speed) {
        vel_y = max_fall_speed;
    }
} else {
    vel_y = 0;
}

// ========== POHYB ==========
vel_x = move_speed * direction_facing;

// ========== KONTROLA KRAJE PLATFORMY (ne zeď!) ==========
if (on_ground) {
    var edge_check_distance = 32;  // Kontroluj vpředu
    var edge_check_down = 8;        // Kontroluj dolů
    
    // Kontrola jestli je zem PŘED ním a PŮL (ne zeď!)
    var check_x = x + (direction_facing * edge_check_distance);
    var check_y = y + edge_check_down;
    
    // Pokud NENÍ zem pod tím bodem → je to kraj platformy
    if (!place_meeting(check_x, check_y, Oground)) {
        // NENÍ ZEM před ním → Otoč se!
        direction_facing = -direction_facing;
        vel_x = -vel_x;
    }
}

// ========== KOLIZE SE ZDÍ (normálně, může jít až k ní) ==========
if (place_meeting(x + vel_x, y, Oground)) {
    // Jemná kolize - posuň se až ke zdi
    while (!place_meeting(x + sign(vel_x), y, Oground)) {
        x += sign(vel_x);
    }
    vel_x = 0;
    direction_facing = -direction_facing;
}

// Aplikuj pohyb X
x += vel_x;

// ========== KOLIZE Y ==========
if (place_meeting(x, y + vel_y, Oground)) {
    while (!place_meeting(x, y + sign(vel_y), Oground)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}

y += vel_y;

// ========== KOLIZE Y (gravitace) ==========
if (place_meeting(x, y + vel_y, Oground)) {
    while (!place_meeting(x, y + sign(vel_y), Oground)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}

// Aplikuj vertikální pohyb
y += vel_y;

// ========== OTOČENÍ SPRITE ==========
if (direction_facing == -1) {
    image_xscale = -1;
} else {
    image_xscale = 1;
}

// ========== SPIKE DAMAGE ==========
if (place_meeting(x, y, Ospike)) {
    hp -= 25;
}

// ========== SPADL DO PROPADLIŠTĚ ==========
if (y > room_height + 100) {
    hp = 0;  // Zabij ho
}
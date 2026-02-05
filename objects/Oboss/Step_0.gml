// ========== SMRT ==========
if (hp <= 0 && !is_dead) {
    is_dead = true;
    
    // Boss death effect
    repeat(30) {
        var explosion_x = x + random_range(-80, 80);
        var explosion_y = y + random_range(-80, 80);
    }
    
    // Victory
    global.boss_defeated = true;
    
    // Spawn MEGA reward
    repeat(15) {
        var money = instance_create_layer(
            x + random_range(-100, 100), 
            y - random_range(0, 80), 
            "Instances", 
            Omoney
        );
        money.value = 150;
    }
    
    // ========== ODEMKNI SHOP DOOR ==========
    with (Oshop_door) {
        locked_during_boss = false;
        boss_defeated_flag = true;
    }
    
    // ========== DEAKTIVUJ BOSS FIGHT ==========
    if (instance_exists(Owave_manager)) {
        Owave_manager.boss_fight_active = false;
    }
    
    show_debug_message("=== BOSS DEFEATED - Shop Door unlocked! ===");
    
    instance_destroy();
    exit;
}

// ========== PHASE CHECK ==========
var hp_percent = hp / max_hp;

if (hp_percent <= phase_3_threshold && current_phase < 3) {
    current_phase = 3;
    attack_cooldown_max = 80;
    show_debug_message("BOSS PHASE 3 - ENRAGED!");
}
else if (hp_percent <= phase_2_threshold && current_phase < 2) {
    current_phase = 2;
    attack_cooldown_max = 100;
    show_debug_message("BOSS PHASE 2 - AGGRESSIVE!");
}

// ========== GROUND CHECK ==========
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

// ========== COOLDOWNS ==========
if (attack_cooldown > 0) attack_cooldown--;
if (jump_cooldown > 0) jump_cooldown--;
if (invincible_timer > 0) invincible_timer--;
if (flash_timer > 0) flash_timer--;
if (shake_timer > 0) shake_timer--;

// ========== AI ==========
if (instance_exists(target)) {
    var dist = point_distance(x, y, target.x, target.y);
    
    // Směr k hráči
    if (target.x < x) {
        direction_facing = -1;
    } else {
        direction_facing = 1;
    }
    
    // ========== STATE MACHINE ==========
    state_timer++;
    
    switch(state) {
        case "idle":
            vel_x = 0;
            
            if (dist < detection_range) {
                state = "chase";
                state_timer = 0;
            }
            break;
        
        case "chase":
            vel_x = move_speed * direction_facing * (current_phase * 0.5);
            
            // Edge check
            if (on_ground) {
                var edge_check_x = x + (direction_facing * 40);
                var edge_check_y = y + 20;
                
                if (!place_meeting(edge_check_x, edge_check_y, Oground)) {
                    vel_x = 0;
                }
            }
            
            // ========== ATTACK DECISION ==========
            if (attack_cooldown <= 0) {
                if (dist <= melee_range) {
                    state = "attack_slam";
                    state_timer = 0;
                    is_charging_slam = true;
                    slam_charge_time = 0;
                    vel_x = 0;
                }
                else if (dist <= attack_range) {
                    state = "attack_shotgun";
                    state_timer = 0;
                    vel_x = 0;
                }
                else if (random(100) < 10 && jump_cooldown <= 0) {
                    state = "jump_attack";
                    state_timer = 0;
                    vel_y = -jump_force * 1.2;
                    jump_cooldown = jump_cooldown_max;
                }
            }
            break;
        
        case "attack_shotgun":
            vel_x = 0;
            
            if (state_timer == 30) {
                var base_angle = point_direction(x, y - 16, target.x, target.y);
                var spread = shotgun_spread_angle;
                
                for (var i = 0; i < shotgun_projectile_count; i++) {
                    var angle = base_angle - (spread / 2) + (spread / (shotgun_projectile_count - 1)) * i;
                    
                    var bullet = instance_create_layer(x + (direction_facing * 20), y - 16, "Instances", Oenemy_projectile);
                    bullet.direction = angle;
                    bullet.speed = 8;
                    bullet.damage = 20;
                    bullet.image_angle = angle;
                }
                
                shake_timer = 20;
                show_debug_message("BOSS SHOTGUN BLAST!");
            }
            
            if (state_timer >= 60) {
                state = "chase";
                state_timer = 0;
                attack_cooldown = attack_cooldown_max;
            }
            break;
        
        case "attack_slam":
            vel_x = 0;
            
            if (is_charging_slam) {
                slam_charge_time++;
                
                if (slam_charge_time >= slam_charge_max) {
                    is_charging_slam = false;
                    
                    shake_timer = 30;
                    
                    // Spawn ground wave LEFT
                    var wave_left = instance_create_layer(x - 32, y, "Instances", Oboss_wave);
                    wave_left.direction_facing = -1;
                    wave_left.damage = wave_damage;
                    
                    // Spawn ground wave RIGHT
                    var wave_right = instance_create_layer(x + 32, y, "Instances", Oboss_wave);
                    wave_right.direction_facing = 1;
                    wave_right.damage = wave_damage;
                    
                    show_debug_message("BOSS GROUND SLAM!");
                }
            }
            
            if (state_timer >= 90) {
                state = "chase";
                state_timer = 0;
                attack_cooldown = attack_cooldown_max;
            }
            break;
        
        case "jump_attack":
            vel_x = move_speed * direction_facing * 2;
            
            if (on_ground && state_timer > 30) {
                if (point_distance(x, y, target.x, target.y) < 80) {
                    if (instance_exists(target)) {
                        target.hp -= 25;
                        show_debug_message("BOSS JUMP SLAM HIT!");
                    }
                }
                
                shake_timer = 15;
                state = "chase";
                state_timer = 0;
                attack_cooldown = attack_cooldown_max / 2;
            }
            break;
    }
    
} else {
    state = "idle";
    vel_x = 0;
}

// ========== KOLIZE X ==========
if (place_meeting(x + vel_x, y, Oground)) {
    while (!place_meeting(x + sign(vel_x), y, Oground)) {
        x += sign(vel_x);
    }
    vel_x = 0;
}

x += vel_x;

// ========== KOLIZE Y ==========
if (place_meeting(x, y + vel_y, Oground)) {
    while (!place_meeting(x, y + sign(vel_y), Oground)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}

y += vel_y;

// ========== SPRITE FLIP ==========
if (direction_facing == -1) {
    image_xscale = -2;
} else {
    image_xscale = 2;
}

// ========== DAMAGE ==========
if (place_meeting(x, y, Ospike)) {
    hp -= 25;
}
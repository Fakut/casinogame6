// Zraň nepřítele
if (instance_exists(other)) {
    other.hp -= damage;
}

// ========== TRACKING (MIMO IF!) ==========
if (instance_exists(owner) && object_get_name(owner.object_index) == "Oplayer") {
    owner.total_damage_dealt += damage;
    owner.total_shots_hit++;
}

// === POKER CHIP EXPLOSION ===
if (weapon_type == "chip" && explosion_radius > 0) {
    var enemies = ds_list_create();
    collision_circle_list(x, y, explosion_radius, Oenemy, false, true, enemies, false);
    
    for (var i = 0; i < ds_list_size(enemies); i++) {
        var enemy = enemies[| i];
        if (instance_exists(enemy) && enemy != other) {
            var splash_dmg = damage * 0.5;
            enemy.hp -= splash_dmg;
            
            if (instance_exists(owner) && object_get_name(owner.object_index) == "Oplayer") {
                owner.total_damage_dealt += splash_dmg;
            }
        }
    }
    
    ds_list_destroy(enemies);
}

instance_destroy();
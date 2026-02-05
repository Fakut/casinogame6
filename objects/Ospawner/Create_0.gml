// Spawner - spawn point pro nepřátele

// Spawn effect timer
spawn_effect_timer = 0;
spawn_effect_duration = 30;

// Spawn funkce
function spawn_enemy() {
    if (!instance_exists(Owave_manager)) {
        show_debug_message("ERROR: Owave_manager doesn't exist!");
        return noone;
    }
    
    // Získej typ nepřítele z wave manageru
    var enemy_type = Owave_manager.get_enemy_type_for_wave();
    
    // Spawn nepřítele na pozici spawneru
    var enemy = noone;
    
    switch(enemy_type) {
        case "basic":
            enemy = instance_create_layer(x, y, "Instances", Oenemy);
            break;
        case "jumper":
            enemy = instance_create_layer(x, y, "Instances", Oenemy_jumper);
            break;
        case "shooter":
            // ========== CHECK - JE UŽ SHOOTER NA TÉTO PLATFORMĚ? ==========
            var platform_occupied = false;
            
            with (Oenemy_shooter) {
                var dist = point_distance(x, y, other.x, other.y);
                
                // Pokud je shooter blízko spawnu (do 200px)
                if (dist < 200) {
                    platform_occupied = true;
                    break;
                }
            }
            
            // Pokud je platforma obsazená → spawni BASIC místo shootera
            if (platform_occupied) {
                enemy = instance_create_layer(x, y, "Instances", Oenemy);
                enemy_type = "basic";  // Změň typ pro debug message
                show_debug_message("Platform occupied - spawning basic enemy instead");
            } else {
                enemy = instance_create_layer(x, y, "Instances", Oenemy_shooter);
            }
            break;
        case "flying":
            enemy = instance_create_layer(x, y, "Instances", Oenemy_flying);
            break;
    }
    
    // ========== WAVE SCALING ==========
    if (instance_exists(enemy) && instance_exists(Owave_manager)) {
        var current_wave = Owave_manager.current_wave;
        var wave_multiplier = 1 + ((current_wave - 1) * 0.15);  // +15% per wave
        
        // HP scaling
        enemy.max_hp = floor(enemy.max_hp * wave_multiplier);
        enemy.hp = enemy.max_hp;
        
        // Damage scaling
        enemy.damage = floor(enemy.damage * wave_multiplier);
        
        // ========== SPEED - RANDOM VARIANCE + WAVE BONUS ==========
		var base_speed = enemy.move_speed;  // Originální speed
		var speed_variance = random_range(0.85, 1.15);  // ±15% variance
		var wave_bonus = 1 + ((current_wave - 1) * 0.05);  // +5% per wave
    
		enemy.move_speed = base_speed * speed_variance * wave_bonus;
        
        // Trackuj v wave manageru
        Owave_manager.enemies_alive++;
        Owave_manager.enemies_spawned++;
        
        // Spawn effect
        spawn_effect_timer = spawn_effect_duration;
    }
    
    return enemy;
}
// Žádný spawning během boss fightu
if (boss_fight_active) {
    return;
}

// ========== AUTO-START VLNY ==========
if (auto_start_timer > 0) {
    auto_start_timer--;
    if (auto_start_timer <= 0 && !wave_active) {
        start_wave();
    }
}

// ========== SPAWNING NEPŘÁTEL ==========
if (wave_active && enemies_spawned < enemies_to_spawn) {
    spawn_timer--;
    
    if (spawn_timer <= 0) {
        // Kolik enemáků ještě zbývá?
        var remaining = enemies_to_spawn - enemies_spawned;
        
        // Pokud zbývá jen 1, spawni jen 1
        if (remaining == 1) {
            spawn_enemy();
            show_debug_message("Spawned 1 enemy (last one) - " + string(enemies_spawned) + "/" + string(enemies_to_spawn));
        }
        // Pokud zbývá 2+, spawni 2
        else {
            spawn_enemy();
            spawn_enemy();
            show_debug_message("Spawned 2 enemies - " + string(enemies_spawned) + "/" + string(enemies_to_spawn));
        }
        
        spawn_timer = spawn_delay;
    }
}

// ========== KONTROLA DOKONČENÍ VLNY ==========
if (wave_active && enemies_spawned >= enemies_to_spawn && enemies_alive <= 0) {
    wave_active = false;
    wave_complete = true;
    
    show_debug_message("Wave " + string(current_wave) + " complete!");
}

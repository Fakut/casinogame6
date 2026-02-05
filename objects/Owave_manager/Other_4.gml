// Room Start

// Pokud se vracíme z obchodu, automaticky spusť další vlnu
if (variable_global_exists("came_from_shop") && global.came_from_shop) {
    show_debug_message("Returned from shop - starting next wave!");
    
    // Počkej chvíli než začne vlna (aby hráč měl čas)
    auto_start_timer = 90;  // 3 sekundy delay
    wave_complete = false;
    
    // Reset flagu
    global.came_from_shop = false;
} else {
    // Normální room start
    current_wave = global.current_wave;
    
    // AUTO-START vlny (pokud ještě nebyla spuštěna)
    if (current_wave == 0) {
        auto_start_timer = auto_start_delay;
        wave_active = false;
        wave_complete = false;
    }
}

// Reset spawn hodnot
enemies_to_spawn = 0;
enemies_spawned = 0;
enemies_alive = 0;
spawn_timer = spawn_delay;
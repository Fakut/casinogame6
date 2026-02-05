// ESC = Toggle pause (ale NE když je casino!)
if (keyboard_check_pressed(vk_escape)) {
    // ========== OCHRANA PŘED ESC V CASINU! ==========
    if (instance_exists(Ocasino_manager) && Ocasino_manager.casino_active) {
        exit;
    }
    
    // Casino není aktivní - toggle pause normálně
    global.game_paused = !global.game_paused;
    
    if (global.game_paused) {
        // Zastav hru
        instance_deactivate_all(true);
        instance_activate_object(Opause_menu);
        instance_activate_object(Ohud);
        instance_activate_object(Ogame_init);
        instance_activate_object(Oplayer);  // ← AKTIVUJ OPLAYER!
    } else {
        // Aktivuj vše zpátky
        instance_activate_all();
    }
}

// Pokud je pauza aktivní
if (global.game_paused) {
    // Navigace
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        selected--;
        if (selected < 0) selected = max_options;
    }
    
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        selected++;
        if (selected > max_options) selected = 0;
    }
    
    // Výběr
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        switch (selected) {
            case 0:  // Resume
                global.game_paused = false;
                instance_activate_all();
                break;
                
            case 1:  // Quit
                global.game_paused = false;
                instance_activate_all();
                game_end();
                break;
        }
    }
}
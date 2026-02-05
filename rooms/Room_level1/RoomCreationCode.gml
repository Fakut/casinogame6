// Room Creation Code - přesměrování hráče po návratu z obchodu
if (variable_global_exists("returning_from_shop") && global.returning_from_shop) {
    show_debug_message("=== RETURNING FROM SHOP ===");
    
    // Persistent hráč UŽ EXISTUJE, jen ho přesuň
    if (instance_exists(Oplayer)) {
        show_debug_message("Player exists, moving to spawn point");
        
        with (Oplayer) {
            if (variable_global_exists("spawn_x")) {
                x = clamp(global.spawn_x, 0, room_width);
                show_debug_message("New X: " + string(x));
            }
            if (variable_global_exists("spawn_y")) {
                y = clamp(global.spawn_y, 0, room_height);
                show_debug_message("New Y: " + string(y));
            }
            
            // DEBUG - ukaž stats po návratu
            show_debug_message("Player HP after return: " + string(hp) + "/" + string(max_hp));
            show_debug_message("Player Money after return: $" + string(money));
            show_debug_message("Player Weapons after return: " + string(weapon_unlocked));
        }
    } else {
        show_debug_message("ERROR: Player doesn't exist after return!");
    }
    
    // Reset flagu
    global.returning_from_shop = false;
    
    // AUTO-START další vlny
    if (instance_exists(Owave_manager)) {
        Owave_manager.wave_complete = false;
        Owave_manager.auto_start_timer = Owave_manager.auto_start_delay;
        show_debug_message("Auto-start další vlny nastaven!");
    }
}
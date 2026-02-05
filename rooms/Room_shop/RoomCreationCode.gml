// ========== SPAWN HRÁČE U DVEŘÍ ==========
if (instance_exists(Oplayer)) {
    show_debug_message("=== PLAYER ENTERING SHOP ===");
    
    with (Oplayer) {
        // Najdi Odoor_back (zpáteční dveře)
        if (instance_exists(Odoor_back)) {
            var door = instance_nearest(x, y, Odoor_back);
            
            // Spawn hráče před dveřmi
            x = door.x + 32;  // 32 pixelů vpravo od dveří
            y = door.y;       // Na stejné výšce
            
            show_debug_message("Player spawned at door: X=" + string(x) + ", Y=" + string(y));
            show_debug_message("Player HP: " + string(hp) + "/" + string(max_hp));
            show_debug_message("Player Money: $" + string(money));
            show_debug_message("Player Weapons: " + string(weapon_unlocked));
        } else {
            // Fallback pokud dveře neexistují
            x = 100;
            y = 400;
            show_debug_message("Door not found, using fallback position");
        }
    }
}
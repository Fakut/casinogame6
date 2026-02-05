// Kontrola hitboxu
var pl = instance_nearest(x, y, Oplayer);

if (pl != noone) {
    var in_hitbox = (pl.x >= x && 
                     pl.x <= x + hitbox_width &&
                     pl.y >= y && 
                     pl.y <= y + hitbox_height);
    
    if (in_hitbox) {
        prompt = true;
        
        if (keyboard_check_pressed(ord("E"))) {
            
            // ========== LOCKED BĚHEM BOSS FIGHTU ==========
            if (locked_during_boss && !boss_defeated_flag) {
                show_debug_message("Door locked - defeat the boss first!");
                return;
            }
            
            // ========== BOSS DEFEATED - NÁVRAT DO ROOM_GAME ==========
            if (boss_defeated_flag) {
                show_debug_message("=== Returning to main game - VICTORY! ===");
                
                locked_during_boss = false;
                boss_defeated_flag = false;
                
                if (instance_exists(Owave_manager)) {
                    Owave_manager.boss_room_unlocked = false;
                    Owave_manager.boss_fight_active = false;
                    Owave_manager.current_wave = 5;
                }
                
                global.boss_defeated = false;
                
                room_goto(Room_game);
                return;
            }
            
            // ========== NORMÁLNÍ VSTUP DO SHOPU ==========
            // Ukonči aktuální vlnu
            if (instance_exists(Owave_manager)) {
                Owave_manager.wave_active = false;
                Owave_manager.wave_complete = true;
                
                with (Oenemy) instance_destroy();
                with (Oenemy_flying) instance_destroy();
                with (Oenemy_jumper) instance_destroy();
                with (Oenemy_shooter) instance_destroy();
                
                Owave_manager.enemies_alive = 0;
            }
            
            // Ulož spawn pozici
            global.return_room = room;
            global.spawn_x = x + 32;
            global.spawn_y = y;
            global.returning_from_shop = false;
            global.came_from_shop = false;
            
            room_goto(Room_shop);
        }
    } else {
        prompt = false;
    }
} else {
    prompt = false;
}
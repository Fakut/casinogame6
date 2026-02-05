var pl = instance_nearest(x, y, Oplayer);

// ========== CASINO CHECK ==========
if (instance_exists(Ocasino_manager) && Ocasino_manager.casino_active) {
    show_prompt = false;
    exit;
}
	
if (pl != noone) {
    // Hitbox od TOP LEFT corner
    var in_hitbox = (pl.x >= x && 
                     pl.x <= x + hitbox_width &&
                     pl.y >= y && 
                     pl.y <= y + hitbox_height);
    
    if (in_hitbox) {
        prompt = true;
        
        if (keyboard_check_pressed(ord("E"))) {
            global.returning_from_shop = true;
            global.came_from_shop = true;
            
            // ========== BOSS SYSTEM CHECK ==========
            if (instance_exists(Owave_manager)) {
                // První vstup do boss room (po wave 4)
                if (Owave_manager.boss_room_unlocked && !Owave_manager.boss_fight_active) {
                    show_debug_message("=== ENTERING BOSS ROOM ===");
                    room_goto(Room_boss);
                    return;
                }
                // Návrat během boss fightu (hráč byl v shopu nakupovat)
                else if (Owave_manager.boss_fight_active) {
                    show_debug_message("Returning to boss fight...");
                    room_goto(Room_boss);
                    return;
                }
            }
            
            // ========== NORMÁLNÍ NÁVRAT ==========
            if (variable_global_exists("return_room")) {
                room_goto(global.return_room);
            } else {
                room_goto(Room_level1);
            }
        }
    } else {
        prompt = false;
    }
} else {
    prompt = false;
}
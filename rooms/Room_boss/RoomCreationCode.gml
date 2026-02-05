// ========== BOSS ROOM INITIALIZATION ==========

// 1. Spawn BOSS (UPRAV X/Y PODLE TVÉ MAPY!)
var boss_spawn_x = 540;  // ← Změň!
var boss_spawn_y = 580;   // ← Změň!

instance_create_layer(boss_spawn_x, boss_spawn_y, "Instances", Oboss);

// 2. Boss UI
instance_create_layer(0, 0, "UI", Oboss_ui);

// 3. Zamkni shop door
with (Oshop_door) {
    locked_during_boss = true;
    boss_defeated_flag = false;
}

// 4. Znemožni spawning
with (Ospawner) {
    instance_destroy();
}

// 5. Aktivuj boss fight
if (instance_exists(Owave_manager)) {
    Owave_manager.boss_fight_active = true;
}

show_debug_message("=== BOSS ROOM - Fight begins! ===");
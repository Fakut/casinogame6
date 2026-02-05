// Wave Manager - řízení vln nepřátel
depth = -1000;
persistent = true; 

// Nastavení vln
current_wave = 0;
wave_active = false;
wave_complete = false;
auto_start_timer = 0;
auto_start_delay = 1; 

enemies_to_spawn = 0;
enemies_spawned = 0;
enemies_alive = 0;

spawn_delay = 60;  // Delay mezi spawny (frames)
spawn_timer = 0;

// Konfigurace vln
wave_config = [
    { enemies: 10, money_drop: 10 },      // Vlna 1
    { enemies: 15, money_drop: 15 },    // Vlna 2
    { enemies: 20, money_drop: 20 },      // Vlna 3
    { enemies: 25, money_drop: 25 },    // Vlna 4
    { enemies: 30, money_drop: 30 }       // Vlna 5
];

// Globální proměnné
if (!variable_global_exists("current_wave")) {
    global.current_wave = 0;
}

// AUTO-START první vlny
auto_start_timer = auto_start_delay;

// Typy nepřátel
enemy_types = [Oenemy, Oenemy_flying, Oenemy_jumper, Oenemy_shooter];

// ========== FUNKCE ==========

// Šance spawnu podle vlny
function get_enemy_type_for_wave() {
    var wave = current_wave;
    
    // Vlna 1: pouze základní
    if (wave == 1) {
        return "jumper";
    }
    // Vlna 2: základní + shooter
    else if (wave == 2) {
        var rand = random(100);
        if (rand < 70) {
            return "basic";  // 70% základní
        } else {
            return "shooter";  // 30% shooter
        }
    }
    // Vlna 3: mix všech
    else if (wave == 3) {
        var rand = random(100);
        if (rand < 40) {
            return "basic";  // 40% základní
        } else if (rand < 60) {
            return "shooter";  // 20% shooter
        } else if (rand < 80) {
            return "flying";  // 20% flying
        } else {
            return "jumper";  // 20% jumper
        }
    }
    // Vlna 4+: více pokročilých
    else {
        var rand = random(100);
        if (rand < 25) {
            return "basic";  // 25% základní
        } else if (rand < 50) {
            return "shooter";  // 25% shooter
        } else if (rand < 75) {
            return "flying";  // 25% flying
        } else {
            return "jumper";  // 25% jumper
        }
    }
}

// Start vlny
function start_wave() {
    current_wave++;
    global.current_wave = current_wave;
    
    var wave_index = min(current_wave - 1, array_length(wave_config) - 1);
    var config = wave_config[wave_index];
    
    enemies_to_spawn = config.enemies;
    enemies_spawned = 0;
    enemies_alive = 0;
    wave_active = true;
    wave_complete = false;
    spawn_timer = spawn_delay;
    
    show_debug_message("=== WAVE " + string(current_wave) + " STARTED ===");
    show_debug_message("Enemies to spawn: " + string(enemies_to_spawn));
}

// Spawn nepřítele přes náhodný Ospawner
function spawn_enemy() {
    // Najdi náhodný spawner
    var spawner_count = instance_number(Ospawner);
    if (spawner_count <= 0) {
        show_debug_message("ERROR: No Ospawner objects found!");
        return noone;
    }
    
    var random_spawner = instance_find(Ospawner, irandom(spawner_count - 1));
    
    if (!instance_exists(random_spawner)) {
        show_debug_message("ERROR: Spawner doesn't exist!");
        return noone;
    }
    
    // ========== ZAVOLEJ spawn_enemy() NA SPAWNERU ==========
    var enemy = random_spawner.spawn_enemy();
    
    return enemy;
}

// Boss system
boss_room_unlocked = false;
boss_fight_active = false;
// Game initialization - spustí se jednou
depth = -10000;
persistent = true;

// === FULLSCREEN ===
window_set_fullscreen(true);

// === RESET GAME FUNCTION ===
global.reset_game = function() {
    // Smaž všechny persistent objekty
    if (instance_exists(Owave_manager)) {
        instance_destroy(Owave_manager);
    }
    
    // Reset všech globálních proměnných
    global.player_money = 0;          // ← Reset peněz
    global.current_wave = 0;          // Reset wave
    global.unlocked_weapons = [true, false, false, false, false];  // Reset zbraní (volitelné)
    global.game_paused = false;
    
    // Restart celé hry
    game_restart();
}

// Inicializuj zbraně
global.weapons = [];

// Zbraň 0: PLAYING CARDS
global.weapons[0] = {
    name: "Playing Cards",
    description: "Rychle haze hraci karty",
    damage: 20,
    speed: 12,
    fire_rate: 15,
    projectile_sprite: spr_card_projectile,  // ← ZMĚNĚNO
    projectile_size: 1,
    cost: 0,
    color: c_white,
    icon: ""
};

// Zbraň 1: POKER CHIPS
global.weapons[1] = {
    name: "Poker Chips",
    description: "Explosvni poker zetony",
    damage: 35,
    speed: 8,
    fire_rate: 30,
    explosion_radius: 50,
    projectile_sprite: spr_chip_projectile,  // ← ZMĚNĚNO
    projectile_size: 1.2,
    cost: 150,
    color: c_red,
    icon: ""
};

// Zbraň 2: LUCKY DICE
global.weapons[2] = {
    name: "Lucky Dice",
    description: "6 kostek najednou",
    damage: 15,
    speed: 10,
    fire_rate: 45,
    projectile_count: 6,
    spread: 35,
    projectile_sprite: spr_dice_projectile,  // ← ZMĚNĚNO
    projectile_size: 0.9,
    cost: 200,
    color: c_lime,
    icon: ""
};

// Zbraň 3: ROULETTE
global.weapons[3] = {
    name: "Roulette Spin",
    description: "Nahodny damage 10-100!",
    damage: 50,
    damage_min: 10,
    damage_max: 100,
    speed: 7,
    fire_rate: 60,
    projectile_sprite: spr_roulette_projectile,  // ← ZMĚNĚNO
    projectile_size: 1.5,
    cost: 300,
    color: c_yellow,
    icon: ""
};

// Zbraň 4: SLOT MACHINE
global.weapons[4] = {
    name: "Slot Machine",
    description: "3 projektily, jackpot sance",
    damage: 25,
    speed: 9,
    fire_rate: 20,
    projectile_count: 3,
    spread: 15,
    jackpot_chance: 0.1,
    jackpot_damage: 200,
    projectile_sprite: spr_slot_projectile,  // ← ZMĚNĚNO
    projectile_size: 1,
    cost: 500,
    color: c_fuchsia,
    icon: ""
};

// Aktuální zbraň hráče
global.current_weapon = 0;

// Pause systém
global.game_paused = false;

show_debug_message("Game initialized!");
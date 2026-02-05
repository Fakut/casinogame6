// Casino Manager - Gambling pro upgrady + UNLOCK ZBRANĚ
depth = -9999;
casino_active = false;

// Roulette result display timer
roulette_result_timer = 0;
roulette_result_display_duration = 60;
roulette_showing_result = false;

// ========== CENY ==========
slot_spin_cost = 30;
blackjack_hand_cost = 50;
roulette_spin_cost = 40;

// ========== WEAPON UNLOCK ŠANCE - 100% ==========
slot_weapon_unlock_chance = 1.0;           // 100%
blackjack_weapon_unlock_chance = 1.0;      // 100%
roulette_weapon_unlock_chance = 1.0;       // 100%
money_pickup_weapon_chance = 1.0;          // 100%

// ========== SLOT MACHINE ==========
slot_symbols = ["CHERRY", "LEMON", "ORANGE", "DIAMOND", "STAR", "SEVEN"];
slot_result = ["", "", ""];
slot_spinning = false;
slot_spin_timer = 0;
slot_spin_duration = 60;

slot_rewards = {
    cherry_3: {name: "+10 Max HP", type: "max_hp", value: 10},
    lemon_3: {name: "+0.5 Speed", type: "speed", value: 0.5},
    orange_3: {name: "+1 Jump Force", type: "jump", value: 1},
    diamond_3: {name: "+20 Max HP", type: "max_hp", value: 20},
    star_3: {name: "+1 Extra Jump", type: "max_jump", value: 1},
    seven_3: {name: "JACKPOT! All Stats!", type: "jackpot", value: 5},
    any_2: {name: "+5 Max HP", type: "max_hp", value: 5}
};

slot_last_reward = "";

// ========== BLACKJACK ==========
bj_deck = [];
bj_player_hand = [];
bj_dealer_hand = [];
bj_game_active = false;
bj_player_stand = false;
bj_dealer_reveal = false;
bj_result = "";

bj_dealer_draw_timer = 0;
bj_dealer_draw_delay = 30;
bj_dealer_drawing = false;

bj_rewards = {
    win: {name: "+5 Weapon Damage", type: "damage", value: 5},
    blackjack: {name: "BLACKJACK! +10 Damage", type: "damage", value: 10}
};

bj_last_reward = "";
bj_weapon_unlock_chance = 1.0;  // 100%

// ========== ROULETTE ==========
roulette_numbers = [];
roulette_result = -1;
roulette_spinning = false;
roulette_spin_timer = 0;
roulette_spin_duration = 90;
roulette_bet_type = "none";
roulette_bet_number = -1;

roulette_red_numbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];

roulette_rewards = {
    red_black: {name: "+15 Max HP", type: "max_hp", value: 15},
    number: {name: "+50 Max HP + +15 Damage", type: "mega", value: 50}
};

roulette_last_reward = "";
roulette_weapon_unlock_chance = 1.0;  // 100%

// ========== UI ==========
active_game = "none";
show_casino_menu = false;

// ========== FUNKCE ==========
function unlock_random_weapon() {
    if (!instance_exists(Oplayer)) return "No player";
    if (!variable_global_exists("weapons")) return "No weapons";
    
    var locked_list = [];
    for (var m = 0; m < array_length(Oplayer.weapon_unlocked); m++) {
        if (!Oplayer.weapon_unlocked[m]) {
            array_push(locked_list, m);
        }
    }
    
    if (array_length(locked_list) == 0) {
        return "All weapons unlocked!";
    }
    
    var unlock_id = locked_list[irandom(array_length(locked_list) - 1)];
    Oplayer.weapon_unlocked[unlock_id] = true;
    
    var unlock_name = global.weapons[unlock_id].name;
    
    return unlock_name + " UNLOCKED!";
}

// ========== UNLOCK SPECIFICKÉ ZBRANĚ ==========
function unlock_specific_weapon(weapon_name) {
    if (!instance_exists(Oplayer)) return "No player";
    if (!variable_global_exists("weapons")) return "No weapons";
    
    // Najdi index zbraně podle jména
    var weapon_index = -1;
    for (var i = 0; i < array_length(global.weapons); i++) {
        if (global.weapons[i].name == weapon_name) {
            weapon_index = i;
            break;
        }
    }
    
    if (weapon_index == -1) {
        return "Weapon not found!";
    }
    
    // Zkontroluj jestli už není odemčená
    if (Oplayer.weapon_unlocked[weapon_index]) {
        return weapon_name + " already unlocked!";
    }
    
    // Odemkni
    Oplayer.weapon_unlocked[weapon_index] = true;
    
    return weapon_name + " UNLOCKED!";
}

function create_deck() {
    var deck = [];
    var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];
    
    for (var s = 0; s < 4; s++) {
        for (var v = 0; v < array_length(values); v++) {
            array_push(deck, {
                value: values[v],
                numeric: (v == 0) ? 11 : min(v + 1, 10)
            });
        }
    }
    
    for (var i = array_length(deck) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = deck[i];
        deck[i] = deck[j];
        deck[j] = temp;
    }
    
    return deck;
}

function calculate_hand_value(hand) {
    var total = 0;
    var aces = 0;
    
    for (var i = 0; i < array_length(hand); i++) {
        total += hand[i].numeric;
        if (hand[i].value == "A") aces++;
    }
    
    while (total > 21 && aces > 0) {
        total -= 10;
        aces--;
    }
    
    return total;
}

function apply_reward(reward) {
    if (!instance_exists(Oplayer)) {
        return;
    }
    
    switch (reward.type) {
        case "hp":
            // ========== VŽDY DOPLŇ HP NA MAXIMUM ==========
            Oplayer.hp = Oplayer.max_hp;
            
            // A PAK PŘIDEJ BONUS
            Oplayer.max_hp += reward.value;
            Oplayer.hp = Oplayer.max_hp;  // Doplň znovu na nové maximum
            break;
        
        case "max_hp":
            // ========== VŽDY DOPLŇ HP NA MAXIMUM ==========
            Oplayer.hp = Oplayer.max_hp;
            
            // A PAK PŘIDEJ BONUS
            Oplayer.max_hp += reward.value;
            Oplayer.hp = Oplayer.max_hp;  // Doplň znovu na nové maximum
            break;
        
        case "speed":
            Oplayer.move_speed += reward.value;
            break;
        
        case "jump":
            Oplayer.jump_force += reward.value;
            break;
        
        case "max_jump":
            Oplayer.max_jumps += reward.value;
            break;
        
        case "damage":
            if (variable_global_exists("weapons")) {
                global.weapons[Oplayer.current_weapon].damage += reward.value;
            }
            break;
        
        case "jackpot":
            // ========== JACKPOT - HEAL + BONUS ==========
            Oplayer.hp = Oplayer.max_hp;  // Doplň na maximum
            Oplayer.max_hp += reward.value;
            Oplayer.hp = Oplayer.max_hp;  // Doplň znovu
            Oplayer.move_speed += 0.3;
            Oplayer.jump_force += 1;
            break;
        
        case "mega":
            // ========== MEGA - HEAL + BONUS ==========
            Oplayer.hp = Oplayer.max_hp;  // Doplň na maximum
            Oplayer.max_hp += reward.value;
            Oplayer.hp = Oplayer.max_hp;  // Doplň znovu
            if (variable_global_exists("weapons")) {
                global.weapons[Oplayer.current_weapon].damage += 15;
            }
            break;
    }
}

function initialize_roulette() {
    roulette_numbers = [];
    for (var i = 0; i <= 36; i++) {
        array_push(roulette_numbers, i);
    }
}

initialize_roulette();
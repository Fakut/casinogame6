// Casino Manager - Step

// ========== OTEVŘENÍ MENU (TAB) - JEN V SHOPU! ==========
if (keyboard_check_pressed(vk_tab) && room == Room_shop) {
    show_casino_menu = !show_casino_menu;
    casino_active = show_casino_menu;
    
    if (show_casino_menu) {
        active_game = "none";
    }
}

if (!show_casino_menu) exit;

// ========== SLOT MACHINE ==========
if (slot_spinning) {
    slot_spin_timer++;
    
    if (slot_spin_timer % 5 == 0) {
        for (var i = 0; i < 3; i++) {
            slot_result[i] = slot_symbols[irandom(array_length(slot_symbols) - 1)];
        }
    }
    
    if (slot_spin_timer >= slot_spin_duration) {
        slot_spinning = false;
        slot_spin_timer = 0;
        
        for (var i = 0; i < 3; i++) {
            slot_result[i] = slot_symbols[irandom(array_length(slot_symbols) - 1)];
        }
        
        check_slot_win();
    }
}

// ========== ROULETTE ==========
if (roulette_spinning) {
    roulette_spin_timer++;
    
    if (roulette_spin_timer % 3 == 0) {
        roulette_result = irandom(36);
    }
    
    if (roulette_spin_timer >= roulette_spin_duration) {
        roulette_spinning = false;
        roulette_spin_timer = 0;
        roulette_result = irandom(36);
        
        roulette_showing_result = true;
        roulette_result_timer = 0;
        
        check_roulette_win();
    }
}

if (roulette_showing_result) {
    roulette_result_timer++;
    
    if (roulette_result_timer >= roulette_result_display_duration) {
        roulette_showing_result = false;
        roulette_result_timer = 0;
    }
}

// ========== BLACKJACK AI - S DELAY A BUST FIX! ==========
if (bj_game_active && bj_player_stand && !bj_dealer_reveal) {
    var player_value = calculate_hand_value(bj_player_hand);
    
    // BUST FIX - pokud hráč bustne, dealer už netahá!
    if (player_value > 21) {
        bj_dealer_reveal = true;
        bj_result = "BUST - No Reward";
        bj_last_reward = "";
        return;
    }
    
    if (!bj_dealer_drawing) {
        bj_dealer_drawing = true;
        bj_dealer_draw_timer = 0;
    }
    
    if (bj_dealer_drawing) {
        bj_dealer_draw_timer++;
        
        var dealer_value = calculate_hand_value(bj_dealer_hand);
        
        if (dealer_value < 17 && bj_dealer_draw_timer >= bj_dealer_draw_delay) {
            array_push(bj_dealer_hand, bj_deck[0]);
            array_delete(bj_deck, 0, 1);
            bj_dealer_draw_timer = 0;
        } else if (dealer_value >= 17) {
            bj_dealer_drawing = false;
            bj_dealer_reveal = true;
            
            if (dealer_value > 21) {
                bj_result = "Dealer Bust - YOU WIN!";
                bj_last_reward = bj_rewards.win.name;
                apply_reward(bj_rewards.win);
                
                // ========== DICE UNLOCK! ==========
                if (random(1) < bj_weapon_unlock_chance) {
                    var weapon_unlock_msg = unlock_specific_weapon("Lucky Dice");
                    bj_last_reward += "\n" + weapon_unlock_msg;
                }
            } else if (player_value > dealer_value) {
                if (player_value == 21 && array_length(bj_player_hand) == 2) {
                    bj_result = "BLACKJACK! YOU WIN BIG!";
                    bj_last_reward = bj_rewards.blackjack.name;
                    apply_reward(bj_rewards.blackjack);
                    
                    // ========== DICE UNLOCK (BLACKJACK = 100%)! ==========
                    var weapon_unlock_msg_bj = unlock_specific_weapon("Lucky Dice");
                    bj_last_reward += "\n" + weapon_unlock_msg_bj;
                } else {
                    bj_result = "YOU WIN!";
                    bj_last_reward = bj_rewards.win.name;
                    apply_reward(bj_rewards.win);
                    
                    // ========== DICE UNLOCK! ==========
                    if (random(1) < bj_weapon_unlock_chance) {
                        var weapon_unlock_msg2 = unlock_specific_weapon("Lucky Dice");
                        bj_last_reward += "\n" + weapon_unlock_msg2;
                    }
                }
            } else if (player_value == dealer_value) {
                bj_result = "PUSH - No Reward";
                bj_last_reward = "";
            } else {
                bj_result = "Dealer Wins - No Reward";
                bj_last_reward = "";
            }
        }
    }
}

// ========== FUNKCE ==========
function check_slot_win() {
    slot_last_reward = "";
    
    if (slot_result[0] == slot_result[1] && slot_result[1] == slot_result[2]) {
        var symbol = slot_result[0];
        var reward = undefined;
        
        switch (symbol) {
            case "CHERRY": reward = slot_rewards.cherry_3; break;
            case "LEMON": reward = slot_rewards.lemon_3; break;
            case "ORANGE": reward = slot_rewards.orange_3; break;
            case "DIAMOND": reward = slot_rewards.diamond_3; break;
            case "STAR": reward = slot_rewards.star_3; break;
            case "SEVEN": reward = slot_rewards.seven_3; break;
        }
        
        if (reward != undefined) {
            slot_last_reward = reward.name;
            apply_reward(reward);
            
            // ========== SLOT MACHINE UNLOCK (NE PRO SEVEN!) ==========
            if (symbol != "SEVEN") {
                if (random(1) < slot_weapon_unlock_chance) {
                    var weapon_unlock_msg3 = unlock_specific_weapon("Slot Machine");
                    slot_last_reward += "\n" + weapon_unlock_msg3;
                }
            }
        }
    }
    else if (slot_result[0] == slot_result[1] || slot_result[1] == slot_result[2] || slot_result[0] == slot_result[2]) {
        slot_last_reward = slot_rewards.any_2.name;
        apply_reward(slot_rewards.any_2);
        
        // ========== SLOT MACHINE UNLOCK! ==========
        if (random(1) < slot_weapon_unlock_chance) {
            var weapon_unlock_msg4 = unlock_specific_weapon("Slot Machine");
            slot_last_reward += "\n" + weapon_unlock_msg4;
        }
    } else {
        slot_last_reward = "No match - No reward";
    }
}

function check_roulette_win() {
    roulette_last_reward = "";
    
    if (roulette_bet_type == "number") {
        if (roulette_bet_number == roulette_result) {
            roulette_last_reward = "WIN! " + roulette_rewards.number.name;
            apply_reward(roulette_rewards.number);
            
            // ========== ROULETTE SPIN UNLOCK (NUMBER = 100%)! ==========
            var weapon_unlock_msg = unlock_specific_weapon("Roulette Spin");
            roulette_last_reward += "\n" + weapon_unlock_msg;
        } else {
            roulette_last_reward = "LOSS - No reward";
        }
    } else if (roulette_bet_type == "red") {
        if (array_contains(roulette_red_numbers, roulette_result)) {
            roulette_last_reward = "WIN! " + roulette_rewards.red_black.name;
            apply_reward(roulette_rewards.red_black);
            
            // ========== ROULETTE SPIN UNLOCK! ==========
            if (random(1) < roulette_weapon_unlock_chance) {
                var weapon_unlock_msg5 = unlock_specific_weapon("Roulette Spin");
                roulette_last_reward += "\n" + weapon_unlock_msg5;
            }
        } else {
            roulette_last_reward = "LOSS - No reward";
        }
    } else if (roulette_bet_type == "black") {
        if (!array_contains(roulette_red_numbers, roulette_result) && roulette_result != 0) {
            roulette_last_reward = "WIN! " + roulette_rewards.red_black.name;
            apply_reward(roulette_rewards.red_black);
            
            // ========== ROULETTE SPIN UNLOCK! ==========
            if (random(1) < roulette_weapon_unlock_chance) {
                var weapon_unlock_msg6 = unlock_specific_weapon("Roulette Spin");
                roulette_last_reward += "\n" + weapon_unlock_msg6;
            }
        } else {
            roulette_last_reward = "LOSS - No reward";
        }
    }
}
if (!show_casino_menu) exit;

gpu_set_texfilter(false);
draw_set_font(fnt_pixel);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// Pozadí
draw_set_alpha(0.95);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// Header
draw_set_halign(fa_center);
draw_set_color(c_yellow);
draw_text_transformed(gui_w / 2, 20, "UPGRADE CASINO", 2, 2, 0);

draw_set_color(c_lime);
if (instance_exists(Oplayer)) {
    draw_text(gui_w / 2, 60, "Money: $" + string(Oplayer.money));
}
draw_set_color(c_white);
draw_text(gui_w / 2, 85, "Press TAB to close");

// ========== MENU ==========
if (active_game == "none") {
    draw_set_color(c_yellow);
    draw_text(gui_w / 2, 130, "SELECT GAME:");
    
    draw_set_color(c_white);
    draw_text(gui_w / 2, 180, "[1] Slot Machine");
    draw_text(gui_w / 2, 210, "    $" + string(slot_spin_cost) + " per spin - Win stat upgrades!");
    
    draw_text(gui_w / 2, 260, "[2] Blackjack");
    draw_text(gui_w / 2, 290, "    $" + string(blackjack_hand_cost) + " per hand - Win weapon damage!");
    
    draw_text(gui_w / 2, 340, "[3] Roulette");
    draw_text(gui_w / 2, 370, "    $" + string(roulette_spin_cost) + " per spin - Win massive upgrades!");
    
    // Input
    if (keyboard_check_pressed(ord("1"))) {
        active_game = "slots";
        slot_result = ["", "", ""];
        slot_last_reward = "";
    }
    if (keyboard_check_pressed(ord("2"))) {
        active_game = "blackjack";
        bj_game_active = false;
        bj_last_reward = "";
    }
    if (keyboard_check_pressed(ord("3"))) {
        active_game = "roulette";
        roulette_last_reward = "";
        roulette_bet_type = "none";
    }
}

// ========== SLOT MACHINE ==========
else if (active_game == "slots") {
    draw_set_color(c_yellow);
    draw_text(gui_w / 2, 120, "SLOT MACHINE");
    
    // Reels
    var reel_y = gui_h / 2 - 80;
    for (var i = 0; i < 3; i++) {
        var reel_x = gui_w / 2 - 120 + (i * 120);
        
        draw_set_color(c_dkgray);
        draw_rectangle(reel_x - 50, reel_y - 50, reel_x + 50, reel_y + 50, false);
        draw_set_color(c_yellow);
        draw_rectangle(reel_x - 50, reel_y - 50, reel_x + 50, reel_y + 50, true);
        
        if (slot_result[i] != "") {
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed(reel_x, reel_y, slot_result[i], 1.5, 1.5, 0);
        }
    }
    
    draw_set_valign(fa_top);
    
    // Reward
    if (slot_last_reward != "") {
        draw_set_color(c_lime);
        draw_set_halign(fa_center);
        
        var lines = string_split(slot_last_reward, "\n");
        for (var i = 0; i < array_length(lines); i++) {
            draw_text_transformed(gui_w / 2, gui_h / 2 + 80 + (i * 30), lines[i], 1.2, 1.2, 0);
        }
    }
    
    // Controls
    draw_set_halign(fa_center);
    if (!slot_spinning) {
        if (instance_exists(Oplayer) && Oplayer.money >= slot_spin_cost) {
            draw_set_color(c_lime);
            draw_text(gui_w / 2, gui_h - 150, "[SPACE] SPIN ($" + string(slot_spin_cost) + ")");
            
            if (keyboard_check_pressed(vk_space)) {
                Oplayer.money -= slot_spin_cost;
                Oplayer.casino_slots_spins++;
                Oplayer.casino_total_spent += slot_spin_cost;
                slot_spinning = true;
                slot_spin_timer = 0;
                slot_last_reward = "";
            }
        } else {
            draw_set_color(c_red);
            draw_text(gui_w / 2, gui_h - 150, "Not enough money!");
        }
    } else {
        draw_set_color(c_yellow);
        draw_text_transformed(gui_w / 2, gui_h - 150, "SPINNING...", 1.5, 1.5, 0);
    }
    
    draw_set_color(c_white);
    draw_text(gui_w / 2, gui_h - 80, "[ESC] Back");
    
    if (keyboard_check_pressed(vk_escape)) {
        active_game = "none";
    }
}

// ========== BLACKJACK ==========
else if (active_game == "blackjack") {
    draw_set_color(c_yellow);
    draw_text(gui_w / 2, 120, "BLACKJACK");
    
    if (!bj_game_active) {
        if (instance_exists(Oplayer) && Oplayer.money >= blackjack_hand_cost) {
            draw_set_color(c_white);
            draw_text(gui_w / 2, 250, "[SPACE] Deal Cards ($" + string(blackjack_hand_cost) + ")");
            
            if (keyboard_check_pressed(vk_space)) {
                Oplayer.money -= blackjack_hand_cost;
                Oplayer.casino_blackjack_hands++;
                Oplayer.casino_total_spent += blackjack_hand_cost;
                bj_deck = create_deck();
                bj_dealer_hand = [bj_deck[0]];
                bj_player_hand = [bj_deck[1], bj_deck[2]];
                array_delete(bj_deck, 0, 3);
                bj_game_active = true;
                bj_player_stand = false;
                bj_dealer_reveal = false;
                bj_dealer_drawing = false;
                bj_result = "";
                bj_last_reward = "";
            }
        } else {
            draw_set_color(c_red);
            draw_text(gui_w / 2, 250, "Not enough money!");
        }
        
        draw_set_color(c_white);
        draw_text(gui_w / 2, 280, "[ESC] Back");
    } else {
        // DEALER
        draw_set_halign(fa_left);
        draw_set_color(c_red);
        draw_text(100, 180, "DEALER:");
        
        draw_set_color(c_white);
        var dealer_str = "";
        for (var i = 0; i < array_length(bj_dealer_hand); i++) {
            dealer_str += bj_dealer_hand[i].value + " ";
        }
        draw_text(100, 210, dealer_str);
        
        if (bj_dealer_reveal) {
            draw_text(100, 240, "Value: " + string(calculate_hand_value(bj_dealer_hand)));
        } else if (!bj_player_stand) {
            draw_text(100, 240, "Value: ??");
        } else {
            draw_set_color(c_yellow);
            draw_text(100, 240, "Value: DRAWING...");
        }
        
        // PLAYER
        draw_set_color(c_lime);
        draw_text(100, 320, "YOU:");
        
        draw_set_color(c_white);
        var player_str = "";
        for (var i = 0; i < array_length(bj_player_hand); i++) {
            player_str += bj_player_hand[i].value + " ";
        }
        draw_text(100, 350, player_str);
        draw_text(100, 380, "Value: " + string(calculate_hand_value(bj_player_hand)));
        
        // ACTIONS
        if (!bj_player_stand && !bj_dealer_reveal) {
            draw_set_halign(fa_center);
            draw_set_color(c_lime);
            draw_text(gui_w / 2, gui_h - 150, "[H] Hit  [S] Stand");
            
            if (keyboard_check_pressed(ord("H"))) {
                array_push(bj_player_hand, bj_deck[0]);
                array_delete(bj_deck, 0, 1);
                
                if (calculate_hand_value(bj_player_hand) > 21) {
                    bj_player_stand = true;
                }
            }
            if (keyboard_check_pressed(ord("S"))) {
                bj_player_stand = true;
            }
        }
        else if (bj_player_stand && !bj_dealer_reveal) {
            draw_set_halign(fa_center);
            draw_set_color(c_yellow);
            draw_text(gui_w / 2, gui_h - 150, "Dealer drawing...");
        }
        
        // RESULT
        if (bj_result != "") {
            draw_set_halign(fa_center);
            draw_set_color(c_yellow);
            draw_text_transformed(gui_w / 2, 480, bj_result, 1.3, 1.3, 0);
            
            if (bj_last_reward != "") {
                draw_set_color(c_lime);
                var lines = string_split(bj_last_reward, "\n");
                for (var i = 0; i < array_length(lines); i++) {
                    draw_text_transformed(gui_w / 2, 520 + (i * 25), lines[i], 1.1, 1.1, 0);
                }
            }
            
            if (instance_exists(Oplayer) && Oplayer.money >= blackjack_hand_cost) {
                draw_set_color(c_lime);
                draw_text(gui_w / 2, gui_h - 120, "[SPACE] Play Again ($" + string(blackjack_hand_cost) + ")");
                
                if (keyboard_check_pressed(vk_space)) {
                    Oplayer.money -= blackjack_hand_cost;
                    Oplayer.casino_blackjack_hands++;
                    Oplayer.casino_total_spent += blackjack_hand_cost;
                    bj_deck = create_deck();
                    bj_dealer_hand = [bj_deck[0]];
                    bj_player_hand = [bj_deck[1], bj_deck[2]];
                    array_delete(bj_deck, 0, 3);
                    bj_game_active = true;
                    bj_player_stand = false;
                    bj_dealer_reveal = false;
                    bj_dealer_drawing = false;
                    bj_result = "";
                    bj_last_reward = "";
                }
            } else {
                draw_set_color(c_red);
                draw_text(gui_w / 2, gui_h - 120, "Not enough money!");
            }
            
            draw_set_color(c_white);
            draw_text(gui_w / 2, gui_h - 80, "[ESC] Back");
        }
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        active_game = "none";
        bj_game_active = false;
    }
}

// ========== ROULETTE ==========
else if (active_game == "roulette") {
    draw_set_color(c_yellow);
    draw_text(gui_w / 2, 120, "ROULETTE");
    
    if (!roulette_spinning && roulette_bet_type == "none" && !roulette_showing_result) {
        if (instance_exists(Oplayer) && Oplayer.money >= roulette_spin_cost) {
            draw_set_color(c_white);
            draw_text(gui_w / 2, 200, "Choose bet ($" + string(roulette_spin_cost) + "):");
            
            draw_set_color(c_red);
            draw_text(gui_w / 2, 250, "[R] RED (1:1)");
            draw_set_color(c_white);
            draw_text(gui_w / 2, 280, "[B] BLACK (1:1)");
            draw_text(gui_w / 2, 310, "[0-9] Number 0-9 (35:1)");
            draw_text(gui_w / 2, 340, "[Q/W/E] Numbers 10-36 (Q=10-19, W=20-29, E=30-36)");
            
            if (keyboard_check_pressed(ord("R"))) {
                Oplayer.money -= roulette_spin_cost;
                Oplayer.casino_roulette_spins++;
                Oplayer.casino_total_spent += roulette_spin_cost;
                roulette_bet_type = "red";
                roulette_spinning = true;
                roulette_spin_timer = 0;
                roulette_last_reward = "";
            }
            if (keyboard_check_pressed(ord("B"))) {
                Oplayer.money -= roulette_spin_cost;
                Oplayer.casino_roulette_spins++;
                Oplayer.casino_total_spent += roulette_spin_cost;
                roulette_bet_type = "black";
                roulette_spinning = true;
                roulette_spin_timer = 0;
                roulette_last_reward = "";
            }
            
            for (var i = 0; i <= 9; i++) {
                if (keyboard_check_pressed(ord(string(i)))) {
                    Oplayer.money -= roulette_spin_cost;
                    Oplayer.casino_roulette_spins++;
                    Oplayer.casino_total_spent += roulette_spin_cost;
                    roulette_bet_type = "number";
                    roulette_bet_number = i;
                    roulette_spinning = true;
                    roulette_spin_timer = 0;
                    roulette_last_reward = "";
                }
            }
            
            if (keyboard_check(ord("Q"))) {
                for (var i = 0; i <= 9; i++) {
                    if (keyboard_check_pressed(ord(string(i)))) {
                        Oplayer.money -= roulette_spin_cost;
                        Oplayer.casino_roulette_spins++;
                        Oplayer.casino_total_spent += roulette_spin_cost;
                        roulette_bet_type = "number";
                        roulette_bet_number = 10 + i;
                        roulette_spinning = true;
                        roulette_spin_timer = 0;
                        roulette_last_reward = "";
                    }
                }
            }
            if (keyboard_check(ord("W"))) {
                for (var i = 0; i <= 9; i++) {
                    if (keyboard_check_pressed(ord(string(i)))) {
                        Oplayer.money -= roulette_spin_cost;
                        Oplayer.casino_roulette_spins++;
                        Oplayer.casino_total_spent += roulette_spin_cost;
                        roulette_bet_type = "number";
                        roulette_bet_number = 20 + i;
                        roulette_spinning = true;
                        roulette_spin_timer = 0;
                        roulette_last_reward = "";
                    }
                }
            }
            if (keyboard_check(ord("E"))) {
                for (var i = 0; i <= 6; i++) {
                    if (keyboard_check_pressed(ord(string(i)))) {
                        Oplayer.money -= roulette_spin_cost;
                        Oplayer.casino_roulette_spins++;
                        Oplayer.casino_total_spent += roulette_spin_cost;
                        roulette_bet_type = "number";
                        roulette_bet_number = 30 + i;
                        roulette_spinning = true;
                        roulette_spin_timer = 0;
                        roulette_last_reward = "";
                    }
                }
            }
        } else {
            draw_set_color(c_red);
            draw_text(gui_w / 2, 250, "Not enough money!");
        }
        
        draw_set_color(c_white);
        draw_text(gui_w / 2, 400, "[ESC] Back");
    }
    else if (roulette_spinning) {
        draw_set_color(c_yellow);
        draw_text_transformed(gui_w / 2, gui_h / 2 - 120, "SPINNING...", 2, 2, 0);
        
        var is_red_anim = array_contains(roulette_red_numbers, roulette_result);
        draw_set_color(is_red_anim ? c_red : c_white);
        draw_text_transformed(gui_w / 2, gui_h / 2 - 20, string(roulette_result), 4, 4, 0);
    }
    else if (roulette_showing_result) {
        var is_red = array_contains(roulette_red_numbers, roulette_result);
        var color_name = "";
        
        if (roulette_result == 0) {
            draw_set_color(c_lime);
            color_name = "GREEN";
        } else if (is_red) {
            draw_set_color(c_red);
            color_name = "RED";
        } else {
            draw_set_color(c_white);
            color_name = "BLACK";
        }
        
        draw_text_transformed(gui_w / 2, gui_h / 2 - 140, color_name, 2.5, 2.5, 0);
        draw_text_transformed(gui_w / 2, gui_h / 2 - 50, string(roulette_result), 6, 6, 0);
        
        if (roulette_last_reward != "") {
            var is_win = (string_pos("WIN", roulette_last_reward) > 0);
            draw_set_color(is_win ? c_lime : c_red);
            
            var lines = string_split(roulette_last_reward, "\n");
            for (var i = 0; i < array_length(lines); i++) {
                draw_text_transformed(gui_w / 2, gui_h / 2 + 80 + (i * 35), lines[i], 1.3, 1.3, 0);
            }
        }
        
        var time_left = ceil((roulette_result_display_duration - roulette_result_timer) / 60);
        draw_set_color(c_yellow);
        draw_text(gui_w / 2, gui_h - 120, "Next spin in: " + string(time_left) + "s");
        
        draw_set_color(c_white);
        draw_text(gui_w / 2, gui_h - 80, "[ESC] Back");
    }
    else {
        draw_set_color(c_white);
        draw_text(gui_w / 2, gui_h / 2, "Ready for next spin!");
        draw_text(gui_w / 2, gui_h / 2 + 40, "Press R, B, or number...");
        
        roulette_bet_type = "none";
        roulette_last_reward = "";
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        active_game = "none";
        roulette_bet_type = "none";
        roulette_last_reward = "";
        roulette_showing_result = false;
        roulette_result_timer = 0;
    }
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
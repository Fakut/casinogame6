// Padající peníze
depth = -150;
value = 10; // Kolik peněz obsahuje

// Fyzika
vel_y = -4; // Začne vyskočit nahoru
vel_x = irandom_range(-2, 2); // Náhodný horizontální směr
gravity_force = 0.3;
bounce = 0.4; // Odraz

// Pickup
can_pickup = false;
pickup_timer = 15; // Delay než je možné posbírat (frames)

// Visual
image_speed = 0;
sprite_index = spr_money; // MUSÍŠ VYTVOŘIT sprite "Smoney" (např. žlutá mince)

// Magnetismus (volitelné)
magnet_range = 80;
magnet_speed = 3;
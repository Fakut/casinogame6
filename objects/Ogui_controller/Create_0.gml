// GUI Controller
depth = -10000;
persistent = true;

// GUI odpovídá viewportu
display_set_gui_size(960, 540);  // Změň podle tvého viewportu

// OSTROST
gpu_set_texfilter(false);
gpu_set_tex_filter(false);
gpu_set_tex_mip_enable(mip_off);
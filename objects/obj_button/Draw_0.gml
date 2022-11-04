draw_self();
sprite_index = on ? sp_button_active : sp_button;
draw_set_color(color_get_value(image_blend) > 120 ? $0f0f0f : c_white);
draw_set_alpha(0.8);
draw_set_halign(image_xscale < 0 ? fa_right : fa_left);
draw_set_valign(fa_middle);
draw_text((image_xscale < 0 ? bbox_right : bbox_left) + 16*sign(image_xscale), y, string_upper(text) + value_text);
draw_set_alpha(1);

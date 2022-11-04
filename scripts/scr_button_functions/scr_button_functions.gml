// Export
function scr_button_function_export(){
    Main.msdf.export();
}

// Import
function scr_button_function_import(){
	Main.msdf.import();
}
function scr_button_function_pxrange(){
	Main.msdf.pxrange = get_integer("Range: ", Main.msdf.pxrange);
	value_text = ": "+string(Main.msdf.pxrange);
}
function scr_button_function_import_size(){
	Main.msdf.size = max(1, get_integer("Range: ", Main.msdf.size));
	value_text = ": "+string(Main.msdf.size);
}

// Text
function scr_button_function_text(){
    var t = get_string("Text to display:", Main.text);
    if ( Main.text == "") return;
    Main.text = t;
    text = Main.text;
}
function scr_button_function_text_color(){
    Main.color = get_color(Main.color);
    image_blend = Main.color;
}

// Borders
function scr_button_function_enable_borders(){
	on = !on;
	Main.msdf.border = on;
}
function scr_button_function_border_color(){
    Main.border.color = get_color(Main.border.color);
    image_blend = Main.border.color;
}
function scr_button_function_border_thickness(){
    Main.border.thickness = get_integer("Border thickness:", Main.border.thickness);
    value_text = ": "+string(Main.border.thickness);
}

// Shadows
function scr_button_function_enable_shadow(){
	on = !on;
	Main.msdf.shadow = on;
}
function scr_button_function_shadow_color(){
    Main.shadow.color = get_color(Main.shadow.color);
    image_blend = Main.shadow.color;
}
function scr_button_function_shadow_alpha(){
    Main.shadow.alpha = get_integer("Shadow Alpha: ", Main.shadow.alpha);
    value_text = ": "+string(Main.shadow.alpha);
}
function scr_button_function_shadow_distance(){
    Main.shadow.distance = get_integer("Shadow distance: ", Main.shadow.distance);
    value_text = ": "+string(Main.shadow.distance);
}
function scr_button_function_shadow_direction(){
    Main.shadow.direction = get_integer("Shadow direction: ", Main.shadow.direction);
    value_text = ": "+string(Main.shadow.direction);
}
function scr_button_function_shadow_smoothness(){
    Main.shadow.smooth = get_integer("Shadow smoothness: ", Main.shadow.smooth);
    value_text = ": "+string(Main.shadow.smooth);
}

// Gradient
function scr_button_function_enable_gradient(){
	on = !on;
	Main.msdf.gradient = on;
}
function scr_button_function_gradient_color(){
    Main.gradient.color = get_color(Main.gradient.color);
    image_blend = Main.gradient.color;
}
function scr_button_function_gradient_falloff(){
    Main.gradient.falloff = get_integer("Gradient falloff: ", Main.gradient.falloff);
    value_text = ": "+string(Main.gradient.falloff);
}
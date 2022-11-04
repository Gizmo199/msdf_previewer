x = room_width * .5;
y = room_height* .5;

text = "Hello world";
color= c_black;
font = "";

border  = { color : c_black, thickness: .5 }
shadow  = { color : c_black, alpha: .21, distance: 15, direction: 128, smooth: 5}
gradient= { color : c_red, falloff: 1 }

msdf = new msdf_generator();
apply_effects=function(scr)/*=>*/{
    scr.msdf_shadow(shadow.color, 
                    shadow.alpha * msdf.shadow, 
                    size/lengthdir_x(shadow.distance, shadow.direction + 180), 
                    size/lengthdir_y(shadow.distance, shadow.direction + 180), 
                    shadow.smooth);
                    
    scr.msdf_border(border.color, 
                    msdf.border*border.thickness);
                    
    scr.gradient(gradient.color, gradient.falloff * msdf.gradient);
    return scr;
}

size    = 1;
sizeTo  = size;

draw_set_font(fnt_default);
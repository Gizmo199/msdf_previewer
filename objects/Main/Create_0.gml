#macro SCREEN   Main.screen
#macro TEXT     SCREEN.display
#macro MSDF     Main.msdf

mouse_xprevious = mouse_x;
mouse_yprevious = mouse_y;

text = "Hello world";
font = "";
msdf = new msdf_generator();
text_editor = true;
import = false;

screen = new ui_screen({ sequence: seq_screen, x: room_width*.5, y: room_height*.5 });
button_apply=function(button_path, button_description, button_function)/*=>*/{
    var button = button_path;
    if ( button == undefined ) return;
    button.desc = button_description;
    
    with ( button ){
        on_click = button_function;
        on_update= method(button, function(){ if ( entered ) {SCREEN.description.text = desc;} });
    }
}
button_apply(screen.button_import.import, "Import", function(){ import = !import });
button_apply(screen.button_gradient.gradient, "Gradient", function(){ MSDF.gradient = !MSDF.gradient; });
button_apply(screen.button_shadow.shadow, "Shadow", function(){ MSDF.shadow = !MSDF.shadow;});
button_apply(screen.button_border.border, "Border", function(){ MSDF.border = !MSDF.border;});
button_apply(screen.button_export.export, "Export", function(){ MSDF.export(); });

apply_movement=function()/*=>*/{
    bbox_update();
    
    title.color = title_box.entered ? c_dkgray : c_white;
    
    if ( mouse_check_button(mb_left) && title_box.entered && (TEXT.selected == undefined || TEXT.selected == self)){
        TEXT.selected = self;
        
        var dis = point_distance(mouse_x, mouse_y, Main.mouse_xprevious, Main.mouse_yprevious);
        var dir = point_direction(Main.mouse_xprevious, Main.mouse_yprevious, mouse_x, mouse_y);
        var ldx = lengthdir_x(dis, dir);
        var ldy = lengthdir_y(dis, dir);
        x += ldx;
        y += ldy;
        
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].x += ldx;
            elements[i].y += ldy;
            elements[i].bbox_update();
        }
    }
    if ( !mouse_check_button(mb_left) && TEXT.selected == self ) TEXT.selected = undefined;
}
with ( screen.display ){
    size    = 1;
    sizeTo  = size;
    selected= undefined;
    
    font    = "";
    border  = { color : c_white, thickness: .5, popup: undefined }
    shadow  = { color : c_black, alpha: .5, distance: 15, direction: 128, smooth: 5, popup: undefined}
    gradient= { color : c_red, falloff: .5, popup: undefined }
    text_editor = undefined;
    import_popup= undefined;
    
    apply_effects=function(scr)/*=>*/{
        
        scr.msdf_shadow(shadow.color, 
                        shadow.alpha * MSDF.shadow, 
                        size/lengthdir_x(shadow.distance, shadow.direction + 180), 
                        size/lengthdir_y(shadow.distance, shadow.direction + 180), 
                        shadow.smooth);
                        
        scr.msdf_border(border.color, 
                        MSDF.border*border.thickness);
                        
        scr.gradient(gradient.color, gradient.falloff * MSDF.gradient);
        return scr;
        
    }
    on_update = method(self, function(){
        
        // TEXT
        if ( Main.text_editor && text_editor == undefined){
            text_editor= new ui_screen({sequence: seq_popup_text, x: room_width - 280, y: 76});
            with ( text_editor.container ){
                
                // Mains
                on_update = method(self, Main.apply_movement);
                
                // Values
                color_value.on_click = method(color_value, function(){
                    TEXT.color = get_color(TEXT.color);
                    color = TEXT.color;
                    mouse_clear(mb_left);
                });
                text_value.on_click = method(text_value, function(){
                    TEXT.text = get_string("Text", TEXT.text);
                    
                    var cont = "";
                    var len = 40;
                    if ( string_length(TEXT.text) > len ) cont = "...";
                    text = string_copy(string(TEXT.text), 1, len) + cont;
                    mouse_clear(mb_left);
                });
                with ( font_value ){
                    
                    clicked = false;
                    options = [];
                    og_draw = draw;
                    open    = false;

                    update_options=method(self,function(){
                        options = [];
                        for ( var i=0; i<array_length(MSDF.msdf); i++){
                            options[i] = MSDF.msdf[i].button;
                        }
                    })
                    on_click = method(self, function(){ if ( array_length(options) > 0 ) {open = !open; mouse_clear(mb_left);}});
                    on_update = method(self, function(){
                        for ( var i=0; i<array_length(options); i++ ){
                            if ( Main.font == options[i].fontname ) text = options[i].text;
                        }
                    });
                    
                    draw=method(self, function(){
                        og_draw();
                        
                        draw_set_halign(fa_center);
                        draw_set_valign(fa_middle);
                        if ( !open ){
                            draw_set_color(entered ? #3CB878 : c_white);
                            draw_text(x, y, text);
                        } else {
                            var osize = array_length(options);
                            draw_set_color(c_dkgray);
                            draw_rectangle(bbox.left, bbox.top, bbox.right, bbox.bottom + osize*16, false);
                            
                            draw_set_color(#3CB878);
                            draw_text(x, y, "- fonts -");
                            for( var i=0; i<osize; i++ ){
                                draw_set_color(c_white);
                                var yy = y + (i * 16) + 16;
                                if ( point_in_rectangle(mouse_x, mouse_y, bbox.left, yy-8, bbox.right, yy+8)){
                                    draw_set_color(#3CB878);
                                    draw_rectangle(bbox.left, yy-8, bbox.right, yy+8, false);
                                    draw_set_color(c_dkgray);
                                    
                                    if ( mouse_check_button_pressed(mb_left) ) {
                                        Main.font = options[i].fontname;
                                        on_click();
                                    }
                                }
                                draw_text(x, yy, options[i].text);
                            }
                        }
                    })
                    
                }
            }
            array_push(SCREEN.elements, text_editor);
        }
        
        // IMPORT
        if ( Main.import && import_popup == undefined){
            import_popup = new ui_screen({sequence: seq_popup_import, x: room_width*.5, y: room_height*.5});
            with ( import_popup.container ){
                
                pxrange_value.text = MSDF.pxrange;
                size_value.text = MSDF.size;
                
                // Mains
                on_update = method(self, Main.apply_movement);
                close.on_click = method(close, function(){
                    for ( var i=0; i<array_length(SCREEN.elements); i++ ){
                        if ( SCREEN.elements[i] == TEXT.import_popup ){
                            array_delete(SCREEN.elements, i, 1);
                            TEXT.import_popup = undefined;
                            Main.import = false;
                            return;
                        }
                    }
                });
                
                // Values
                size_value.on_click = method(size_value, function(){
                    MSDF.size = max(1, get_integer("Import size", MSDF.size));
                    text = string(MSDF.size);
                    mouse_clear(mb_left);
                });
                pxrange_value.on_click = method(pxrange_value, function(){
                    MSDF.pxrange = get_integer("Pixel Range", MSDF.pxrange);
                    text = string(MSDF.pxrange);
                    mouse_clear(mb_left);
                });
                button_import.on_click = method(button_import, function(){
                    MSDF.import(); 
                    TEXT.text_editor.container.font_value.update_options();
                    TEXT.import_popup.container.close.on_click();
                })
            }
            array_push(SCREEN.elements, import_popup);
        }
        
        // BORDERS
        if ( MSDF.border && border.popup == undefined){
            border.popup = new ui_screen({sequence: seq_popup_border, x: 128, y: 128});
            with ( border.popup.container ){
                
                // Mains
                on_update = method(self, Main.apply_movement);
                close.on_click = method(close, function(){
                    for ( var i=0; i<array_length(SCREEN.elements); i++ ){
                        if ( SCREEN.elements[i] == TEXT.border.popup ){
                            array_delete(SCREEN.elements, i, 1);
                            TEXT.border.popup = undefined;
                            MSDF.border = false;
                            return;
                        }
                    }
                });
                
                // Values
                color_value.on_click = method(color_value, function(){
                    TEXT.border.color = get_color(TEXT.border.color);
                    color = TEXT.border.color;
                    mouse_clear(mb_left);
                });
                thickness_value.on_click = method(thickness_value, function(){
                    TEXT.border.thickness = get_integer("Thickness", TEXT.border.thickness);
                    text = string(TEXT.border.thickness);
                    mouse_clear(mb_left);
                })
            }
            array_push(SCREEN.elements, border.popup);
        }
        
        // GRADIENTS
        if ( MSDF.gradient && gradient.popup == undefined){
            gradient.popup = new ui_screen({sequence: seq_popup_gradient, x: 128, y: 224});
            with ( gradient.popup.container ){
                
                // Mains
                on_update = method(self, Main.apply_movement);
                close.on_click = method(close, function(){
                    for ( var i=0; i<array_length(SCREEN.elements); i++ ){
                        if ( SCREEN.elements[i] == TEXT.gradient.popup ){
                            array_delete(SCREEN.elements, i, 1);
                            TEXT.gradient.popup = undefined;
                            MSDF.gradient = false;
                            return;
                        }
                    }
                });
                
                // Values
                color_value.on_click = method(color_value, function(){
                    TEXT.gradient.color = get_color(TEXT.gradient.color);
                    color = TEXT.gradient.color;
                    mouse_clear(mb_left);
                });
                alpha_value.on_click = method(alpha_value, function(){
                    TEXT.gradient.falloff = get_integer("Falloff", TEXT.gradient.falloff);
                    text = string(TEXT.gradient.falloff);
                    mouse_clear(mb_left);
                })
            }
            array_push(SCREEN.elements, gradient.popup);
        }
        
        // SHADOWS
        if ( MSDF.shadow && shadow.popup == undefined){
            shadow.popup = new ui_screen({sequence: seq_popup_shadow, x: 128, y: 320});
            with ( shadow.popup.container ){
                
                // Mains
                on_update = method(self, Main.apply_movement);
                close.on_click = method(close, function(){
                    for ( var i=0; i<array_length(SCREEN.elements); i++ ){
                        if ( SCREEN.elements[i] == TEXT.shadow.popup ){
                            array_delete(SCREEN.elements, i, 1);
                            TEXT.shadow.popup = undefined;
                            MSDF.shadow = false;
                            return;
                        }
                    }
                });
                
                // Values
                color_value.on_click = method(color_value, function(){
                    TEXT.shadow.color = get_color(TEXT.shadow.color);
                    color = TEXT.shadow.color;
                    mouse_clear(mb_left);
                });
                alpha_value.on_click = method(alpha_value, function(){
                    TEXT.shadow.alpha = get_integer("Alpha", TEXT.shadow.alpha);
                    text = string(TEXT.shadow.alpha);
                    mouse_clear(mb_left);
                });
                smooth_value.on_click = method(smooth_value, function(){
                    TEXT.shadow.smooth = get_integer("Alpha", TEXT.shadow.smooth);
                    text = string(TEXT.shadow.smooth);
                    mouse_clear(mb_left);
                })
            }
            array_push(SCREEN.elements, shadow.popup);
        }
        
        font = Main.font;
        size_string = "";
        
        if ( mouse_check_button(mb_middle) ) {
            var dis = point_distance(mouse_x, mouse_y, Main.mouse_xprevious, Main.mouse_yprevious);
            var dir = point_direction(Main.mouse_xprevious, Main.mouse_yprevious, mouse_x, mouse_y);
            x += lengthdir_x(dis, dir);
            y += lengthdir_y(dis, dir);
        }
        
        var n = text;
        if ( string_length(string_replace_all(text, "[scale,", ""))     < string_length(text) ||
             string_length(string_replace_all(text, "[scaleStack,", ""))< string_length(text)) {
                 size_string = "";
                 return;
             }
        size += (mouse_wheel_up() - mouse_wheel_down()) * 8;
        sizeTo = lerp(sizeTo, size, 0.2);
        size_string = "[scale, "+string(sizeTo)+"]";
        
    });
    draw = method(self, function(){
        apply_effects(scribble(font+size_string+text))
            .blend(color, alpha)
            .align(align.x, align.y)
            .draw(x, y);
    })
}
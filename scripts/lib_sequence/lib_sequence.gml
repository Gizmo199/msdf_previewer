enum ui_element_type { sprite = 1, general = 3, blend = 4, group = 11, text = 17 };
function ui_screen(init_data={}) constructor {
    
    sequence    = undefined;
    elements    = [];
    x           = 0;
    y           = 0;
    
    var keys = variable_struct_get_names(init_data);
    for ( var i=0; i<array_length(keys); i++ ){
        self[$ keys[i]] = init_data[$ keys[i]];
    }
    static init=function()/*=>*/{
        if ( sequence == undefined ) return;
        
        var base= new ui_element();
        var seq = sequence_get(sequence);
        parse(base, seq.tracks, {x: x, y: y}, ui_element);
        
        for ( var i=0; i<array_length(base.elements); i++ ){
            elements[i] = base.elements[i];
            self[$ base.elements[i].name] = base.elements[i];
        }
    }
    static get_type=function(etype)/*=>*/{
        var type = ui_element;
        switch(etype){
            case ui_element_type.group:    type = ui_element; break;
            case ui_element_type.sprite:   type = ui_element_sprite; break;
            case ui_element_type.text:     type = ui_element_text; break;
        }
        return type;
    }
    static parse=function(parent_element, next_element, position, type)/*=>*/{
        if ( is_array(next_element) ){
            for ( var i=0; i<array_length(next_element); i++ ){
                parse(parent_element, next_element[i], position, get_type(next_element[i].type));
            }
            return;
        }
        var next = [];
        var done = new type();
        for ( var i=0; i<array_length(next_element.tracks); i++ ){
            var track = next_element.tracks[i];
            switch(track.type){
                case ui_element_type.group:    array_push(next, {next_element: track, type: ui_element});        break;
                case ui_element_type.sprite:   array_push(next, {next_element: track, type: ui_element_sprite}); break;
                case ui_element_type.text:     array_push(next, {next_element: track, type: ui_element_text});   break;
                case ui_element_type.blend: 
                    var col = track.keyframes[0].channels[0].color;
                    var rgb = make_color_rgb(col[1]*255, col[2]*255, col[3]*255);
                    done.color = rgb;
                    done.alpha = col[0];
                    break;
                case ui_element_type.general: 
                    var val = track.keyframes[0].channels;
                    switch(track.name){
                        case "frameSize"    : done.frame = {x: val[0].value, y: val[1].value } break;
                        case "image_index"  : done.index = val[0].value; break;
                        case "position"     : done.x = val[0].value; done.y = val[1].value; break;
                        case "rotation"     : done.angle = val[0].value; break;
                        case "scale"        : done.scale = {x: val[0].value, y: val[1].value }; break;
                        case "origin"       : done.origin= {x: val[0].value, y: val[1].value }; break;
                    }
                break;
            }
        }
        done.parent = parent_element;
        done.root   = self;
        done.x += position.x;
        done.y += position.y;
        
        done.finalize(next_element);
        parent_element[$ done.name] = done;
        array_push(parent_element.elements, done);
        
        var new_pos = {x: done.x, y: done.y};
        for ( var i=0; i<array_length(next); i++ ){
            parse(done, next[i].next_element, new_pos, next[i].type);   
        }
    }
    static update=function()/*=>*/{
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].update();
        }
    }
    static draw =function()/*=>*/{
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].draw();
        }
    }
    init();
}
function ui_element() constructor {
    
    name    = "sequence element";
    elements= [];
    
    sprite  = noone;
    x       = 0;
    y       = 0;
    scale   = {x: 1, y: 1};
    origin  = {x: 1, y: 1};
    angle   = 0;
    index   = 0;
    parent  = undefined;
    color   = c_white;
    alpha   = 1;
    
    text    = "";
    font    = fnt_default;
    align   = {x: fa_left, y: fa_top}
    frame   = {x: 0, y: 0}
    
    bbox = {left: 0, top: 0, right: 0, bottom: 0};
    static on_enter = function(){};
    static on_leave = function(){};
    static on_click = function(){};
    entered  = false;
    
    
    static on_update= function(){};
    
    static finalize=function(elem)/*=>*/{
        name = elem.name;
    }
    static draw_elements=function()/*=>*/{
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].draw();
        }
    }
    static update=function()/*=>*/{
        on_update();
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].update();
        }
    }
    static draw=function()/*=>*/{draw_elements();}
    static command_exists=function(command)/*=>*/{
        var comm = name;
        name = string_replace_all(name, command, "");
        if ( string_length(name) < string_length(comm) ) return true;
        return false;
    }
    static bbox_update=function()/*=>*/{
        
    }
};
function ui_element_text() : ui_element() constructor {
    
    static bbox_update=function()/*=>*/{
        var size = {x: string_width(text), y: string_height(text)};
        if ( align.x == fa_center ){
            bbox = {
                left:   x - ( size.x *.5 * scale.x),
                top:    y - ( size.y *.5 * scale.y),
                right:  x + ( size.x *.5 * scale.x),
                bottom: y + ( size.y *.5 * scale.y)
            }
        }
        if ( align.x == fa_left ){
            bbox = {
                left:   x,
                top:    y - ( size.y *.5 * scale.y),
                right:  x + ( size.x * scale.x),
                bottom: y + ( size.y *.5 * scale.y)
            }
        }
    }
    static finalize=function(elem)/*=>*/{
        name = elem.name;
        var channel = elem.keyframes[0].channels[0];
        text = channel.text;
        align= {x: channel.alignmentH, y: channel.alignmentV};
        font = channel.fontIndex;
        bbox_update();
        
        if ( command_exists("[button]") ){
            on_enter=function()/*=>*/{index=1;}
            on_leave=function()/*=>*/{index=0;}
        }
    }
    static update=function()/*=>*/{
        var ent = entered;
        entered = point_in_rectangle(mouse_x, mouse_y, bbox.left, bbox.top, bbox.right, bbox.bottom);
        
        if ( ent && !entered ){
            on_leave();
        }
        if ( !ent && entered ) {
            on_enter();
        }
        if ( entered && mouse_check_button_pressed(mb_left) ){ on_click(); }
        on_update();
        
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].update();
        }
    }
    static draw=function()/*=>*/{
        if ( text != "" ){
            draw_set_font(font);
            draw_set_halign(align.x);
            draw_set_valign(align.y);
            draw_set_color(color);
            draw_set_alpha(alpha);
            draw_text(x, y, text);
            draw_set_alpha(1);
        }
        draw_elements();
    }
};
function ui_element_sprite() : ui_element() constructor {
    
    static bbox_update=function()/*=>*/{
        bbox = {
            left:   x - ( sprite_get_width(sprite)  *.5 * scale.x),
            top:    y - ( sprite_get_height(sprite) *.5 * scale.y),
            right:  x + ( sprite_get_width(sprite)  *.5 * scale.x),
            bottom: y + ( sprite_get_height(sprite) *.5 * scale.y)
        }
    }
    static finalize=function(elem)/*=>*/{
        name = elem.name;
        sprite = elem.keyframes[0].channels[0].spriteIndex;
        bbox_update();
        
        if ( command_exists("[button]") ){
            on_enter=function()/*=>*/{index=1;}
            on_leave=function()/*=>*/{index=0;}
        }
    }
    static update=function()/*=>*/{
        var ent = entered;
        entered = point_in_rectangle(mouse_x, mouse_y, bbox.left, bbox.top, bbox.right, bbox.bottom);
        
        if ( ent && !entered ){
            on_leave();
        }
        if ( !ent && entered ) {
            on_enter();
        }
        if ( entered && mouse_check_button_pressed(mb_left) ){ on_click(); }
        on_update();
        
        for ( var i=0; i<array_length(elements); i++ ){
            elements[i].update();
        }
    }
    static draw=function()/*=>*/{
        if ( sprite != noone ){
            draw_sprite_ext(sprite, index, x, y, scale.x, scale.y, angle, color, alpha);
        }
        draw_elements();
    }
};
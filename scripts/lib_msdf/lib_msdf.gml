function msdf_generator(init_data={}) constructor{
    
    msdf    = [];
    shadow  = false;
    border  = false;
    gradient= false;
    pxrange = 4;
    size    = 32;
    
    var keys = variable_struct_get_names(init_data);
    for ( var i=0; i<array_length(keys); i++ ){
        self[$ keys[i]] = init_data[$ keys[i]];
    }
    
    static export=function()/*=>*/{
        if ( !directory_exists(working_directory + "/png") || 
             !directory_exists(working_directory + "/json") ) return;
        if ( array_length(msdf) <= 0 ) return;
        
        var file = get_save_filename("Folder", "scribble_msdf_fonts");
        if ( file == "" ) return;
        
        if ( directory_exists(file) ) directory_destroy(file);
        directory_create(file);
        
        for ( var i=0; i<array_length(msdf); i++ ){
            var png = msdf[i].sprite;
            var jsn = msdf[i].json;
            
            var path = file + "/" + msdf[i].name;
            sprite_save(png, 0, path + ".png");
            var f = file_text_open_write(path + ".json");
            file_text_write_string(f, jsn);
        }
    }
    static import=function()/*=>*/{
        
        var path_png = working_directory + "/png";
        var path_jsn = working_directory + "/json";
        if ( !directory_exists(path_png) ) directory_create(path_png);
        if ( !directory_exists(path_jsn) ) directory_create(path_jsn);
        
        var fname = get_open_filenames("TTF file|*.ttf", "");
        if ( fname == "" ) return;
        clipboard_set_text(fname);
        
        var arr = [];
        var txt = fname;
        var pos = 0;
        repeat(1000){
            pos = string_pos(".ttf", txt) + 3;
            array_push(arr, string_copy(txt, 1, pos));
            txt = string_copy(txt, pos+2, string_length(txt));
            if ( txt == "" ) break;
        }
        
        for ( var i=0; i<array_length(arr); i++ ){
            if ( arr[i] == "xxx" ) return;
            var font_name = string_replace_all(filename_name(arr[i]), ".ttf", "");
            Main.size = size;
            
            var position = undefined;
            for ( var j=0; j<array_length(msdf); j++ ){
                if (msdf[j].name == font_name ) {
                    sprite_delete(msdf[j].sprite);
                    position = j;
                    break;
                }
            }
            show_debug_message(arr[i]);
            generate(font_name, arr[i]);
            
            var path    = working_directory + "png/"+font_name+".png";
            var jpth    = working_directory + "json/"+font_name+".json";
            var spr     = sprite_add(path, 0, 0, 0, 0, 0);
            var buf     = buffer_load(jpth);
            var ind     = {
                sprite  : spr, 
                name    : font_name,
                button  : undefined,
                json    : buffer_read(buf, buffer_text),
                file    : {
                    png : path,
                    json: jpth
                }
            }
            buffer_delete(buf);
            
            __scribble_font_add_msdf_from_project(spr, font_name);
            scribble_font_scale(font_name, size *.001 );
            
            if ( position == undefined ){
                var font = ind;
                font.button = instance_create_layer(room_width - 119, 16+ ( (array_length(msdf)+1) * 32), "Buttons", obj_button);
                font.button.image_yscale = .5;
                font.button.image_xscale = -3;
                font.button.text = font.name;
                font.button.fontname = "["+font.name+"]";
                font.button.func = method(font.button, function(){
                    on = true;
                    Main.font = fontname;
                    
                    with ( obj_button ){
                        if (variable_instance_exists(id, "fontname") && Main.font != fontname ) on = false;
                    }
                    
                });
                font.button.func();
                array_push(msdf, ind);
            }
        }
    }
    static clear=function()/*=>*/{
        for ( var i=0; i<array_length(msdf); i++ ){
            instance_destroy(msdf[i].button);
            sprite_delete(msdf[i].sprite);
        }
        msdf = [];
    }
    static generate=function(font_name, filepath)/*=>*/{
        execute_shell(working_directory + "/msdf-atlas-gen.exe", 
            "-font "+filepath
            + " -size "+string(size)
            + " -charset charset.txt"
            + " -format png"
            + " -imageout png/" + font_name + ".png"
            + " -json json/" + font_name + ".json"
            + " -pxrange "+string(pxrange));
    }
}

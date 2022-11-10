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

        var arr = [];
        var txt = string_replace_all(fname, ".ttf", ".ttf|");
        txt = string_replace_all(txt, " ", "");
        var t = "";
        for ( var i=1; i<string_length(txt)+1; i++){
            var char = string_char_at(txt, i);
            if ( char == "|"){
                array_push(arr, t);
                t = "";
                i++;
                continue;
            }
            t+=char;
        }
        
        for ( var i=0; i<array_length(arr); i++ ){
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
                font.button = {
                    fontname : "["+font.name+"]",
                    text     : font.name,
                }
                Main.font = "["+font.name+"]";
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

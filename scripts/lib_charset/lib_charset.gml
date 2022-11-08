/// @ignore
function __buffer_read_utf8(_buffer) {
	gml_pragma("forceinline");
	var _value = buffer_read(_buffer, buffer_u8);
	if ((_value & 0xE0) == 0xC0) { //two-byte
	    _value  = (_value & 0x1F) <<  6;
	    _value += (buffer_read(_buffer, buffer_u8) & 0x3F);
	} else if ((_value & 0xF0) == 0xE0) { //three-byte
	    _value  = ( _value & 0x0F) << 12;
	    _value += (buffer_read(_buffer, buffer_u8) & 0x3F) <<  6;
	    _value +=  buffer_read(_buffer, buffer_u8) & 0x3F;
	} else if ((_value & 0xF8) == 0xF0)  { //four-byte
	    _value  = (_value & 0x07) << 18;
	    _value += (buffer_read(_buffer, buffer_u8) & 0x3F) << 12;
	    _value += (buffer_read(_buffer, buffer_u8) & 0x3F) <<  6;
	    _value +=  buffer_read(_buffer, buffer_u8) & 0x3F;
	}
	
	return _value;
}

function charset_get_range(_str) {
	gml_pragma("forceinline");
    static strBuffer = buffer_create(1, buffer_fixed, 1);
    buffer_resize(strBuffer, string_byte_length(_str));
    buffer_seek(strBuffer, buffer_seek_start, 0);
    buffer_poke(strBuffer, 0, buffer_text, _str);
    var _range = [infinity, -infinity];
	var _size = buffer_get_size(strBuffer);
    while(true) {
        var _byte = __buffer_read_utf8(strBuffer);
        if (_byte < _range[0]) && (_byte >= 32) {
            _range[0] = _byte;
        } else if (_byte > _range[1]) {
            _range[1] = _byte;
        }
		if (buffer_tell(strBuffer) == _size) break;
    }
    return json_stringify(_range);
}

show_debug_message(charset_get_range("The quick brown fox jumped\n over the lazy dog."));
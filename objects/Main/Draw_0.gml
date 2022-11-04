size += (mouse_wheel_up() - mouse_wheel_down()) * 8;
size = clamp(size, 1, 128);
sizeTo = lerp(sizeTo, size, 0.2);

if ( text == "" ) exit;
apply_effects(scribble(font+"[scale, "+string(sizeTo)+"]"+text))
    .blend(color, 1)
    .align(fa_center, fa_middle)
    .draw(x, y);

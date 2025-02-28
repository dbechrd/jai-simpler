Font :: struct {
    // YUCKKKKK Simp takes these as separate args for some reason!?
    path: string;
    file: string;
    pixel_height: int;
    font: *Dynamic_Font;
}

fonts: [..] Font;

register_font :: (path: string, file: string, pixel_height: int, kern := false) -> *Font {
    font := array_add(*fonts);
    font.path = path;
    font.file = file;
    font.pixel_height = pixel_height;
    font.font = get_font_at_size(path, file, pixel_height);
    if kern {
        // prepare_for_kerning(font.font);  // hmmm...
    }
    return font;
}

init_fonts :: () {
    // for * fonts {
    //     using it;
    //     release_font(font);
    //     font = get_font_at_size(path, file, pixel_height);
    // }
}

deinit_fonts :: () {
    for fonts {
        release_font(it.font);
    }
    array_reset(*fonts);
}

// // NOTE: swap_buffers adds extra frames of delay to the loading times.. meh
// // dump text to the screen as fast as possible to show while other assets are loading; before the first game frame
// show_loading_text :: (text: string) {
//     h := fonts[0].pixel_height;
//     w := prepare_text(fonts[0].font, text);
//     draw_prepared_text(fonts[0].font, window_size.x / 2 - w / 2, window_size.y - h);
//     swap_buffers(window, vsync);
// }

draw_text_shadowed :: (font: *Dynamic_Font, x: s64, y: s64, text: string, color := Vector4.{0.95, 0.95, 0.95, 1},
                       shadow_color := Vector4.{0, 0, 0, -1}, effects: Font_Effects = 0)
{
    prepare_text(font, text, effects);
    draw_prepared_text_shadowed(font, x, y, color, shadow_color, effects);
}

draw_prepared_text_shadowed :: (font: *Dynamic_Font, x: s64, y: s64, color := Vector4.{0.95, 0.95, 0.95, 1},
                                shadow_color := Vector4.{0, 0, 0, -1}, effects: Font_Effects = 0)
{
    shadow := shadow_color;
    if shadow.w < 0 {
        shadow = BLACK;
        if color.x + color.y + color.z < 0.5 {
            shadow = WHITE;
        }
    }
    if shadow.w {
        y_offset := ifx context.simp.coordinate_system == .LEFT_HANDED then 1 else -1;
        if font.character_height > 24 y_offset *= 2;
        shadow.w = color.w;
        draw_prepared_text(font, x + 1, y + y_offset, shadow, effects);
        // draw_prepared_text(font, x + 2, y + y_offset * 2, shadow, effects);  // NOTE: To get higher offset, draw both, looks prettier?
    }
    draw_prepared_text(font, x, y, color, effects);
}

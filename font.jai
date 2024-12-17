// YUCKKKKK Simp takes these as separate args for some reason!?
font_path: string;
font_file: string;

// Maybe this should be a hash table or something?
font_tiny: *Dynamic_Font;
font_smaller: *Dynamic_Font;
font_small: *Dynamic_Font;
font_medium: *Dynamic_Font;
font_large: *Dynamic_Font;

init_font :: () {
    assert(xx font_path);
    assert(xx font_file);

    release_font(font_tiny);
    release_font(font_smaller);
    release_font(font_small);
    release_font(font_medium);
    release_font(font_large);

    pixel_height_tiny := window_size.y / 64;
    pixel_height_smaller := window_size.y / 48;
    pixel_height_small := window_size.y / 36;
    pixel_height_medium := window_size.y / 24;
    pixel_height_large := window_size.y / 16;

    font_tiny = get_font_at_size(font_path, font_file, pixel_height_tiny);
    font_smaller = get_font_at_size(font_path, font_file, pixel_height_smaller);
    font_small = get_font_at_size(font_path, font_file, pixel_height_small);
    font_medium = get_font_at_size(font_path, font_file, pixel_height_medium);
    font_large = get_font_at_size(font_path, font_file, pixel_height_large);
    assert(font_tiny != null);
    assert(font_smaller != null);
    assert(font_small != null);
    assert(font_medium != null);
    assert(font_large != null);
}

draw_prepared_text_shadowed :: (font: *Dynamic_Font, x: s64, y: s64, color := Vector4.{0.95, 0.95, 0.95, 1}, effects: Font_Effects = 0) {
    draw_prepared_text(font, x + 2, y - 1, Vector4.{ 0, 0, 0, 1 }, effects);
    draw_prepared_text(font, x, y, color, effects);
}

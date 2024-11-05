// TODO: Make this a hash table or something
font_small: *Dynamic_Font;
font_medium: *Dynamic_Font;
font_large: *Dynamic_Font;

init_font :: () {
    release_font(font_small);
    release_font(font_medium);
    release_font(font_large);

    pixel_height_small := window_size.y / 36;
    pixel_height_medium := window_size.y / 24;
    pixel_height_large := window_size.y / 16;

    font_small = get_font_at_size(".", "KarminaBold.otf", pixel_height_small);
    font_medium = get_font_at_size(".", "KarminaBold.otf", pixel_height_medium);
    font_large = get_font_at_size(".", "KarminaBold.otf", pixel_height_large);
    assert(font_small != null);
    assert(font_medium != null);
    assert(font_large != null);
}
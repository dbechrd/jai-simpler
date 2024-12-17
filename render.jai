init_render :: (title: string, window_size: Size) -> Window_Type, Size {
    window := create_window(window_size.x, window_size.y, title);
    set_render_target(window);

    width, height := get_render_dimensions(window);

    log("\n--- Render Info ---\n");
    log("window_size: % x %\n", width, height);
    return window, .{ width, height };
}

window_center :: () -> Vector2 {
    return .{ xx (window_size.x / 2), xx (window_size.y / 2) };
}

load_texture :: (texture: *Texture, filename: string, srgb := false, build_mipmaps := false) {
    if !texture_load_from_file(texture, filename, srgb, build_mipmaps) {
        log_error("Failed to load texture %\n", filename);
    }
}

clear_render_target :: (color: Vector4) {
    clear_render_target(
        color.x,
        color.y,
        color.z,
        color.w
    );
}

// NOTE: origin is bottom left, following the Simp convention
draw_rect :: (x: float, y: float, w: float, h: float, texture: *Texture = null, color := Vector4.{1,1,1,1}) {
    x0, y0, x1, y1 := x, y, x + w, y + h;
    if texture {
        set_shader_for_images(texture);
    } else {
        set_shader_for_color(true);
    }
    immediate_quad(x0, y0, x1, y1, color);
}

draw_rect_clamped_to_window :: (x: float, y: float, w: float, h: float, texture: *Texture = null, color := Vector4.{1,1,1,1}) -> clamp_offset: Vector2 {
    x0, y0, x1, y1 := x, y, x + w, y + h;

    clamp_offset: Vector2;

    if x0 < 0 {
        clamp_offset.x = -x0;
    }
    if y0 < 0 {
        clamp_offset.y = -y0;
    }
    if x1 > xx window_size.x {
        clamp_offset.x = window_size.x - x1;
    }
    if y1 > xx window_size.y {
        clamp_offset.y = window_size.y - y1;
    }

    draw_rect(x + clamp_offset.x, y + clamp_offset.y, w, h, texture, color);
    return clamp_offset;
}

#scope_file

#import "Simp";

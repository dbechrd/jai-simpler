Size :: struct { x: s64; y: s64; };
Pixel :: struct { x: s64; y: s64; };

window: Window_Type;
window_size: Size;
window_center: Vector2;

window_info: Saved_Window_Info;
window_resizes: [] Window_Resize_Record;

fullscreen: bool;
window_focused: bool;

#if ASSET_WATCHER {
    texture_by_filepath: Table(string, *Texture);
}

init_render :: (title: string, requested_window_size: Size) {
    #if ASSET_WATCHER {
        assert(!texture_by_filepath.allocated);
        init(*texture_by_filepath, 64);
    }

    window = create_window(requested_window_size.x, requested_window_size.y, title);
    set_render_target(window, ifx LEFT_HANDED then .LEFT_HANDED else .RIGHT_HANDED);

    window_size.x, window_size.y = get_render_dimensions(window);
    window_center = .{ xx (window_size.x / 2), xx (window_size.y / 2) };

    log("\n--- Render Info ---\n");
    log("window_size: % x %\n", window_size.x, window_size.y);
}

load_texture :: (texture: *Texture, filepath: string, srgb := false, build_mipmaps := false) {
    if !texture_load_from_file(texture, filepath, srgb, build_mipmaps) {
        log_error("Failed to load texture %\n", filepath);
        return;
    }
    #if ASSET_WATCHER table_add(*texture_by_filepath, filepath, texture);
}

clear_render_target :: (color: Vector4) {
    clear_render_target(
        color.x,
        color.y,
        color.z,
        color.w
    );
}

draw_rect :: inline (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}) {
    draw_rect(x, y, w, h, null, color);
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

draw_rect_clamped_to_window :: inline (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}) -> clamp_offset: Vector2 {
    return draw_rect_clamped_to_window(x, y, w, h, null, color);
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
#import "Hash_Table";

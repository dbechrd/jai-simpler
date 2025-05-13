window: Window_Type;
window_size: Vector2i;
window_center: Vector2;

window_info: Saved_Window_Info;
window_resizes: [] Window_Resize_Record;

fullscreen: bool;
window_focused: bool;

// note: the Table could just store *Texture since Bucket_Array is stable.. hmm...
texture_storage: Bucket_Array(Texture, 64);
texture_by_filepath: Table(string, Bucket_Locator);  // texture filepath -> texture_storage index

bucket_array_find_pointer :: (using array: *Bucket_Array, locator: Bucket_Locator) -> *array.type {
    bucket := all_buckets[locator.bucket_index];
    assert(bucket.occupied[locator.slot_index] == true);
    result := *bucket.data[locator.slot_index];
    return result;
}

init_render :: (title: string, requested_window_size: Vector2i) {
    #if ASSET_WATCHER {
        assert(!texture_by_filepath.allocated);
        init(*texture_by_filepath, 64);
    }

    window = create_window(requested_window_size.x, requested_window_size.y, title);
    set_render_target(window, ifx LEFT_HANDED then .LEFT_HANDED else .RIGHT_HANDED);

    window_size.x, window_size.y = get_render_dimensions(window);
    window_center = .{ xx (window_size.x / 2), xx (window_size.y / 2) };

    log("--- Render Info ---\n");
    log("window_size: % x %\n", window_size.x, window_size.y);
}

find_or_load_texture :: (filepath: string, srgb := false, build_mipmaps := false, force_reload := false) -> texture: *Texture {
    texture: *Texture;

    // Find/allocate texture
    locator, found := table_find(*texture_by_filepath, filepath);
    if found {
        texture = bucket_array_find_pointer(*texture_storage, locator);
    } else {
        locator, texture = bucket_array_add(*texture_storage, .{});
        table_add(*texture_by_filepath, filepath, locator);
    }

    // Load, or reload, if necessary
    if !found || force_reload {
        if !texture_load_from_file(texture, filepath, srgb, build_mipmaps) {
            // log_error("Failed to load texture '%'\n", filepath);  // Simp already logs this
            return null;
        }
    }
    return texture;
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
draw_rect :: (x: float, y: float, w: float, h: float, texture: *Texture = null, color := Vector4.{1,1,1,1}, uv_tl := Vector2.{}, uv_br := Vector2.{1, 1}) {
    x0, y0, x1, y1 := x, y, x + w, y + h;
    p0 := Vector2.{ x  , y   };
    p1 := Vector2.{ x  , y+h };
    p2 := Vector2.{ x+w, y+h };
    p3 := Vector2.{ x+w, y   };
    uv0 := uv_tl;
    uv1 := Vector2.{ uv_tl.x, uv_br.y };
    uv2 := uv_br;
    uv3 := Vector2.{ uv_br.x, uv_tl.y };
    if texture {
        set_shader_for_images(texture);
    } else {
        set_shader_for_color(true);
    }
    immediate_quad(p0, p1, p2, p3, color, uv0, uv1, uv2, uv3);
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
#import "Bucket_Array";
#import "Hash_Table";

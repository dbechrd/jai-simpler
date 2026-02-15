window: Window_Type;
window_size: Vector2i;
window_center: Vector2;

window_info: Saved_Window_Info;
window_resizes: [] Window_Resize_Record;

vsync: bool;
fullscreen: bool;
window_focused: bool;

// Note: The Table could just store *Texture since Bucket_Array is stable, but
// storing the Locator allows us to unload textures if we want to support that
// later (because it tells you which Bucket_Array slot to remove without
// iterating the whole thing).
texture_storage: Bucket_Array(Texture, 64);
texture_by_filepath: Table(string, Bucket_Locator);

init_render :: (title: string, requested_window_size: Vector2i) {
    #if ASSET_WATCHER {
        assert(!texture_by_filepath.allocated);
        init(*texture_by_filepath, 64);
    }

    window = create_window(requested_window_size.x, requested_window_size.y, title);
    set_render_target(window, ifx LEFT_HANDED then .LEFT_HANDED else .RIGHT_HANDED);

    #if OS == .WINDOWS {
        #import "GL";
        vsync = xx wglGetSwapIntervalEXT();
    }

    window_size.x, window_size.y = get_render_dimensions(window);
    window_center = .{ xx (window_size.x / 2), xx (window_size.y / 2) };

    log("--- Render Info ---\n");
    log("window_size: % x % vsync=%\n", window_size.x, window_size.y, vsync);

    set_font_shaders();
}

clear_render_target :: (color: Vector4) {
    clear_render_target(
        color.x,
        color.y,
        color.z,
        color.w
    );
}

set_fullscreen :: (desire_fullscreen: bool) {
    #if OS == .WINDOWS {
        toggle_fullscreen(window, desire_fullscreen, *window_info);
        fullscreen = desire_fullscreen;
    }
}

set_vsync :: (desire_vsync: bool) {
    #if OS == .WINDOWS {
        #import "GL";
        wglSwapIntervalEXT(xx desire_vsync);
        vsync = desire_vsync;
    }
}

// bucket_array_find_pointer :: (using array: *Bucket_Array, locator: Bucket_Locator) -> *array.type {
//     bucket := all_buckets[locator.bucket_index];
//     assert(bucket.occupied[locator.slot_index] == true);
//     result := *bucket.data[locator.slot_index];
//     return result;
// }

find_or_load_texture :: (filepath: string, srgb := false, build_mipmaps := false, force_reload := false) -> texture: *Texture {
    log("Loading texture %", filepath);

    //caps, name := get_capabilities(context.allocator);
    //assert(caps & .FREE > 0, "This texture loader will waste a lot of memory if the allocator provided does not support free.");

    // Find/allocate texture
    texture: *Texture;
    found, locator := table_find(*texture_by_filepath, filepath);
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

//draw_rect :: inline (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}, outline_color := Black, outline_thickness := 0.0) {
//    draw_rect(x, y, w, h, null, color, outline_color=outline_color, outline_thickness=outline_thickness);
//}

draw_rect :: (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}, texture: *Texture = null, uv_tl := Vector2.{}, uv_br := Vector2.{1, 1}, outline_color := Black, outline_thickness := 0.0, $set_shader := true) {
    #if set_shader {
        if texture {
            set_shader_for_images(texture);
        } else {
            set_shader_for_color(true);
        }
    }

    p0 := Vector2.{ x  , y   };
    p1 := Vector2.{ x  , y+h };
    p2 := Vector2.{ x+w, y+h };
    p3 := Vector2.{ x+w, y   };
    uv0 := uv_tl;
    uv1 := Vector2.{ uv_tl.x, uv_br.y };
    uv2 := uv_br;
    uv3 := Vector2.{ uv_br.x, uv_tl.y };

    immediate_quad(p0, p1, p2, p3, color, uv0, uv1, uv2, uv3);
    if outline_thickness {
        draw_rect_outline(x, y, w, h, outline_color, outline_thickness);
    }
}

//draw_rect_clamped_to_window :: inline (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}, outline_color := Black, //outline_thickness := 0.0) -> clamp_offset: Vector2 {
//    return draw_rect_clamped_to_window(x, y, w, h, null, color, outline_color, outline_thickness);
//}

draw_rect_clamped_to_window :: (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}, texture: *Texture = null, outline_color := Black, outline_thickness := 0.0) -> clamp_offset: Vector2 {
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

    x_clamp := x + clamp_offset.x;
    y_clamp := y + clamp_offset.y;
    draw_rect(x_clamp, y_clamp, w, h, color, texture);
    if outline_thickness {
        draw_rect(x_clamp, y_clamp, w, h, color);
    }
    return clamp_offset;
}

draw_rect_outline :: (x: float, y: float, w: float, h: float, color := Vector4.{1,1,1,1}, thickness: float = 1.0, $set_shader := true) {
    #if set_shader {
        set_shader_for_color(true);
    }

    p0 := Vector2.{ x-thickness/2     , y-thickness/2     };  // tl
    p1 := Vector2.{ x+thickness/2 + w , y-thickness/2     };  // tr
    p2 := Vector2.{ x-thickness/2     , y+thickness/2 + h };  // bl
    p3 := Vector2.{ x+thickness/2 + w , y+thickness/2 + h };  // br
    immediate_line(p0-.{thickness/2, 0}, p1+.{thickness/2, 0}, thickness, color);  // top
    immediate_line(p2-.{thickness/2, 0}, p3+.{thickness/2, 0}, thickness, color);  // bottom
    immediate_line(p1, p3, thickness, color);  // right
    immediate_line(p2, p0, thickness, color);  // left
}

// todo: 1x3 and 3x1 mode, e.g. by having left_border/right_border 0 for vertical, use $constants to remove extra draw calls at compile time
// or.. detect degenerate quads and `continue` the loop (branching.. :/)
// or.. just let the degenerate quads "draw" and it's fine?
draw_rect_npatch :: (
    x: float, y: float, w: float, h: float,
    left_border: float, top_border: float, right_border: float, bottom_border: float,
    texture: *Texture, color := Vector4.{1,1,1,1}, uv_tl := Vector2.{}, uv_br := Vector2.{1, 1},
    $set_shader := true
) {
    #if set_shader {
        if texture {
            set_shader_for_images(texture);
        } else {
            set_shader_for_color(true);
        }
    }

    // Null-safe so that we still draw something when a texture fails to load
    if !texture {
        draw_rect(x, y, w, h, color);
        return;
    }

    cols := float.[x, x+left_border, x+w-right_border,  x+w];
    rows := float.[y, y+top_border,  y+h-bottom_border, y+h];

    uv_w := uv_br.x - uv_tl.x;
    uv_h := uv_br.y - uv_tl.y;
    uv_cols := float.[uv_tl.x, clamp(uv_tl.x + left_border/texture.width , uv_tl.x, uv_br.x), clamp(uv_br.x-right_border /texture.width , uv_tl.x, uv_br.x), uv_br.x];
    uv_rows := float.[uv_tl.y, clamp(uv_tl.y + top_border /texture.height, uv_tl.y, uv_br.y), clamp(uv_br.y-bottom_border/texture.height, uv_tl.y, uv_br.y), uv_br.y];

    // colors :: Vector4.[Red, Green, Yellow, Blue, Orange, Purple, Pink, Maroon, Lime];

    for i: 0..2 {
        for j: 0..2 {
            tl := Vector2.{ cols[j  ], rows[i  ] };
            bl := Vector2.{ cols[j  ], rows[i+1] };
            br := Vector2.{ cols[j+1], rows[i+1] };
            tr := Vector2.{ cols[j+1], rows[i  ] };
            tl_uv := Vector2.{ uv_cols[j  ], uv_rows[i  ] };
            bl_uv := Vector2.{ uv_cols[j  ], uv_rows[i+1] };
            br_uv := Vector2.{ uv_cols[j+1], uv_rows[i+1] };
            tr_uv := Vector2.{ uv_cols[j+1], uv_rows[i  ] };

            // color := colors[i*3 + j];
            immediate_quad(tl, bl, br, tr, color, tl_uv, bl_uv, br_uv, tr_uv);
        }
    }
}

draw_circle :: (center: Vector2, radius: float, color := White, segments := 16, pct_visible := 1.0, $set_shader := true) {
    #if set_shader {
        set_shader_for_color(true);
    }

    // draw manual triangle fan clockwise from 12 o'clock. triangle vertices counter-clockwise from the center.
    delta := 2*PI / segments;
    theta := -PI/2;  // 12 o'clock
    theta_max := -PI/2 + 2*PI * pct_visible;
    c := Vector3.{center.x, center.y, 0};
    r0: Vector3 = ---;
    r1 := Vector3.{cos(theta), sin(theta), 0};
    done := false;
    for 0..segments-1 if !done {
        theta += delta;
        if theta >= theta_max {
            theta = theta_max;
            done = true;
        }
        r0 = r1;
        r1 = .{cos(theta), sin(theta), 0};
        immediate_triangle(c, c+r1*radius, c+r0*radius, color, color, color);
    }
}

#scope_file

#import "Simp";
#import "Bucket_Array";
#import "Hash_Table";

OUT_OF_BOUNDS :: Vector2i.{-1, -1};
OUT_OF_BOUNDS_F :: #run make_vector2(OUT_OF_BOUNDS);

mouse_position: Vector2;
mouse_position_inverted: Vector2;
mouse_delta: Vector2;
mouse_delta_inverted: Vector2;
scroll_vel: Vector2;

keymap: Keymap;
debug_key_pressed := false;
debug_key_callback: ();

DebugKey :: () {
    if debug_key_callback {
        debug_key_callback();
    }
    debug_key_pressed = true;
}

is_key_down_start :: inline (button: Key_Code) -> bool {
    return cast(bool) (input_button_states[button] & .START);
}

is_key_down :: inline (button: Key_Code) -> bool {
    return cast(bool) (input_button_states[button] & .DOWN);
}

register_key_proc :: (keymap: *Keymap, ident: Code) #expand {
    add_proc(keymap, #run get_identifier_name(ident), #insert ident);
}

process_input :: () {
    window_focused = input_application_has_focus;
    x, y := get_mouse_pointer_position();
    mouse_in_bounds := window_focused && x >= 0 && x < window_size.x && y >= 0 && y < window_size.y;

    prev_mouse := mouse_position;
    prev_mouse_inv := mouse_position_inverted;

    if mouse_in_bounds {
        mouse_position = .{ xx x, xx y };
        mouse_position_inverted = .{ xx x, xx (window_size.y - y) };
        mouse_delta = mouse_position - prev_mouse;
        mouse_delta_inverted = mouse_delta_inverted - prev_mouse_inv;
    } else {
        mouse_position = OUT_OF_BOUNDS_F;
        mouse_position_inverted = OUT_OF_BOUNDS_F;
        mouse_delta = .{};
        mouse_delta_inverted = .{};
    }

    scroll_vel = .{};

    for events_this_frame {
        if keymap_handle_event(keymap, it) {
            continue;
        }

        if it.type == {
            case .QUIT;
                quit = true;
            case .MOUSE_WHEEL;
                if it.wheel_delta {
                    factor := it.wheel_delta / cast(float) it.typical_wheel_delta; // * 10;
                    if input_button_states[Key_Code.SHIFT] != .NONE {
                        scroll_vel += .{ factor, 0 };
                    } else {
                        scroll_vel += .{ 0, factor };
                    }
                }
        }
    }
}

#scope_file

#import "Input";
#import "Keymap";
#import "Trivial";

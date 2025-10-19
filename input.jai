OUT_OF_BOUNDS :: Vector2i.{-1, -1};
OUT_OF_BOUNDS_F :: #run make_vector2(OUT_OF_BOUNDS);

mouse_position: Vector2;
mouse_position_inverted: Vector2;
mouse_delta: Vector2;
mouse_delta_inverted: Vector2;
scroll_vel: Vector2;

keybinds: Keymap_Set;

input_captured_mouse := false;
input_captured_keyboard := false;

register_key_proc :: (keymap: *Keymap, ident: Code) #expand {
    add_proc(keymap, #run get_identifier_name(ident), #insert ident);
}

is_key_down_start :: inline (button: Key_Code) -> bool {
    return cast(bool) (input_button_states[button] & .START);
}

is_key_down :: inline (button: Key_Code) -> bool {
    return cast(bool) (input_button_states[button] & .DOWN);
}

is_mouse_keycode :: (key_code: Key_Code) -> bool {
    return key_code == .MOUSE_BUTTON_LEFT
        || key_code == .MOUSE_BUTTON_MIDDLE
        || key_code == .MOUSE_BUTTON_RIGHT
        || key_code == .MOUSE_WHEEL_UP
        || key_code == .MOUSE_WHEEL_DOWN;
}

is_mouse_event :: (event: Event) -> bool {
    return event.type == .MOUSE_WHEEL || (event.type == .KEYBOARD && is_mouse_keycode(event.key_code));
}

is_keyboard_event :: (event: Event) -> bool {
    return event.type == .KEYBOARD && !is_mouse_keycode(event.key_code);
}

process_input :: () {
    window_focused = input_application_has_focus;
    x, y := get_mouse_pointer_position(window, !LEFT_HANDED);
    //x = clamp(x, 0, window_size.x-1);
    //y = clamp(y, 0, window_size.y-1);
    // mouse_in_bounds := window_focused && x >= 0 && x < window_size.x && y >= 0 && y < window_size.y;

    prev_mouse := mouse_position;
    prev_mouse_inv := mouse_position_inverted;

    // if mouse_in_bounds {
        mouse_position = .{ xx x, xx y };
        mouse_position_inverted = .{ xx x, xx (window_size.y - y) };
        mouse_delta = mouse_position - prev_mouse;
        mouse_delta_inverted = mouse_delta_inverted - prev_mouse_inv;
    // } else {
    //     mouse_position = OUT_OF_BOUNDS_F;
    //     mouse_position_inverted = OUT_OF_BOUNDS_F;
    //     mouse_delta = .{};
    //     mouse_delta_inverted = .{};
    // }

    scroll_vel = .{};
    factor := mouse_delta_z / 120.0;
    if input_button_states[Key_Code.SHIFT] != .NONE {
        scroll_vel += .{ factor, 0 };
    } else {
        scroll_vel += .{ 0, factor };
    }

    for event: events_this_frame {
        #if GET_RECT {
            getrect_handle_event(event);
        }

        if input_captured_mouse && is_mouse_event(event) {
            continue;
        }
        if input_captured_keyboard && is_keyboard_event(event) && event.key_pressed {
            // note: don't continue on key release events, to prevent stuck keys
            continue;
        }

        // Try to handle the event via the keymap
        if handle_event(*keybinds, event) {
            continue;
        }

        #if OS == .WINDOWS {
            if event.key_code == .F4 && event.alt_pressed {
                quit = true;
            }
        }
        if event.type == .QUIT {
            quit = true;
        }
    }

    #if GET_RECT {
        // occluded  = `occluder_under_the_cursor != null` // a.k.a. "is the mouse over some GetRect window"
        // is_active = `active_widget != null`             // a.k.a. "are we statefully interacting e.g. with a text input in GetRect"
        occluded, is_active := ui_per_frame_update(window, xx window_size.x, xx window_size.y, now);
        input_captured_mouse, input_captured_keyboard = occluded, is_active;
    }
}

#scope_file

#import "Input";
#import "Keymap";
#import "Trivial";
#if GET_RECT {
    using GetRect :: #import "GetRect_LeftHanded";
}
OUT_OF_BOUNDS :: Vector2i.{-1, -1};
OUT_OF_BOUNDS_F :: #run make_vector2(OUT_OF_BOUNDS);

mouse_position: Vector2;
mouse_position_inverted: Vector2;
mouse_delta: Vector2;
mouse_delta_inverted: Vector2;
scroll_vel: Vector2;

keymap: Keymap;
debug_key_pressed := false;  // note: doesn't happen every frame, based on OS key repeat rate
debug_key_callback: ();

//input_captured_mouse := false;
//input_captured_keyboard := false;

DebugKey :: () {
    if debug_key_callback {
        debug_key_callback();
    }
    debug_key_pressed = true;
}

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
    factor := mouse_delta_z / 120.0;
    if input_button_states[Key_Code.SHIFT] != .NONE {
        scroll_vel += .{ factor, 0 };
    } else {
        scroll_vel += .{ 0, factor };
    }

    for event: events_this_frame {
        #if GET_RECT {
            getrect_handle_event(event);

            // Wait.. why would I need this? It should be handled by getrect_captured_keyboard below?

            //// If GetRect is going to handle the ESCAPE, don't forward it elsewhere.
            //if GetRect.active_widget && event.type == .KEYBOARD && event.key_code == .ESCAPE {
            //    // This causes the ESCAPE to not be handled properly by GetRect. Idk why I put this here originally,
            //    // but let's leave it commented out for now.
            //    //active_widget_deactivate_all();
            //    continue;
            //}

            // Check if event should be ignored due to GetRect captures
            getrect_captured_mouse := GetRect.occluder_under_the_cursor != null;
            getrect_captured_keyboard := GetRect.active_widget != null;
            if getrect_captured_mouse && is_mouse_event(event) {
               continue;
            }
            if getrect_captured_keyboard && is_keyboard_event(event) {
               continue;
            }
        }

        // Try to handle the event via the keymap
        if keymap_handle_event(keymap, event) {
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
}

#scope_file

#import "Input";
#import "Keymap";
#import "Trivial";
#if GET_RECT {
    using GetRect :: #import "GetRect_LeftHanded";
}
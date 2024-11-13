is_key_down_start :: inline (button: Key_Code) -> bool {
    return cast(bool) (input_button_states[button] & (.DOWN | .START));
}

is_key_down :: inline (button: Key_Code) -> bool {
    return cast(bool) (input_button_states[button] & .DOWN);
}

process_input :: () {
    window_focused = input_application_has_focus;
    x, y := get_mouse_pointer_position();
    mouse_position = .{ xx x, xx y };

    for events_this_frame {
        if keymap_handle_event(keymap, it) {
            continue;
        }

        if it.type == {
            case .QUIT;
                quit = true;
            case .MOUSE_WHEEL;
                if it.wheel_delta {
                    factor := it.wheel_delta / cast(float) it.typical_wheel_delta * 10;
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

using Input :: #import "Input";

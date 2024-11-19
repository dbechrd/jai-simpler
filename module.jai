#load "audio.jai";
#load "collision.jai";
#load "color.jai";
#load "font.jai";
#load "input.jai";
#load "logger.jai";
#load "render.jai";

Size :: struct { x: s64; y: s64; };

window: Window_Type;
window_info: Saved_Window_Info;
window_resizes: [] Window_Resize_Record;

window_size: Size;
fullscreen: bool;
window_focused: bool;

quit: bool;
now: float64;
frame_dt: float64;
frame_number: int;

mouse_position: Vector2;
mouse_position_inverted: Vector2;
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

init :: (title: string, requested_window_size: Size) {
    // HACK: For pong swapper thing
    if window return;

    #import "String";  // For path_strip_filename. @Cleanup.
    #import "System";  // For get_path_of_running_executable. @Cleanup.

    path := path_strip_filename(get_path_of_running_executable());
    set_working_directory(path);

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    init_logger();
    window, window_size = init_render(title, requested_window_size);
    init_font();
    init_audio();
}

// NOTE: Make sure you register your keymap procedures first!
init_keymap :: (filename: string) {
    add_proc(*keymap, "DebugKey", DebugKey);
    if !load_from_file(*keymap, "keymap", filename, false) {
        log_error("Failed to load keymap from file %\n", filename);
    }
}

deinit :: () {
    deinit_audio();
}

begin_frame :: () {
    future := seconds_since_init();
    frame_dt = future - now;
    now = future;  // the future is now
    frame_number += 1;

    update_window_events();

    // NOTE: This order is important because F11 could generate a window_resize event.
    debug_key_pressed = false;
    process_input();

    window_resizes = get_window_resizes();
    for window_resizes {
        update_window(it.window);
        if it.window == window && (it.width != window_size.x || it.height != window_size.y) {
            window_size = .{ it.width, it.height };
            init_font();
        }
    }
}

end_frame :: ($sleep_ms: s32) {
    update_audio();
    swap_buffers(window);

    memory_visualizer_per_frame_update();
    reset_temporary_storage();
    #if sleep_ms > 0 {
        sleep_milliseconds(sleep_ms);
    }
}

#scope_file

#import "Basic";
#import "Input";
#import "Keymap";
#import "Math";
#import "Window_Creation";
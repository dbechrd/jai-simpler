#load "audio.jai";
#load "collision.jai";
#load "color.jai";
#load "easing.jai";
#load "font.jai";
#load "input.jai";
#load "logger.jai";
#load "render.jai";

Size :: struct { x: s64; y: s64; };
Pixel :: struct { x: s64; y: s64; };

window: Window_Type;
window_info: Saved_Window_Info;
window_resizes: [] Window_Resize_Record;

window_size: Size;
window_center: Vector2;
fullscreen: bool;
window_focused: bool;

quit: bool;
now: float64;
vsync: bool = true;
frame_number: int;
frame_dt: float64;
ticks_per_second := 60;  // you can change this, but you must do it in init()!
tick_dt: float64;
tick_accum: float64;

Timing :: enum {
    Update;
    Tick;
    Draw;
    Audio;
    Count;
}
timings: [Timing.Count] float64;
timings_buf: [Timing.Count] float64;

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

GameMode :: struct {
    name: string;
    init: ();
    deinit: ();
    update: ();
    tick: ();
    draw: ();
};

game_modes: [..] GameMode;
game_mode: *GameMode;
requested_game_mode: *GameMode;

switch_game_mode :: (mode: *GameMode) {
    requested_game_mode = mode;
}

simpler_init :: (title: string, requested_window_size: Size, font_base_path: string, font_filename: string) {
    // HACK: For pong swapper thing
    if window return;

    #import "String";  // For path_strip_filename. @Cleanup.
    #import "System";  // For get_path_of_running_executable. @Cleanup.

    path := path_strip_filename(get_path_of_running_executable());
    set_working_directory(path);
    print("Working Directory: %\n", path);

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    font_path = font_base_path;
    font_file = font_filename;

    init_logger();
    window, window_size = init_render(title, requested_window_size);
    window_center = .{ xx (window_size.x / 2), xx (window_size.y / 2) };
    init_font();
    init_audio();
}

simpler_deinit :: () {
    if game_mode != null {
        game_mode.deinit();
    }
    deinit_audio();
}

// NOTE: Make sure you register your keymap procedures first!
init_keymap :: (filename: string) {
    add_proc(*keymap, "DebugKey", DebugKey);
    if !load_from_file(*keymap, "keymap", filename, false) {
        log_error("Failed to load keymap from file %\n", filename);
    }
}

begin_frame :: () {
    future := seconds_since_init();
    frame_dt = future - now;
    now = future;  // the future is now
    frame_number += 1;

    if requested_game_mode != game_mode {
        if game_mode != null {
            game_mode.deinit();
        }
        game_mode = requested_game_mode;
        log("Entering mode '%'.\n", game_mode.name);
        game_mode.init();
        tick_dt = 1.0 / ticks_per_second;
        tick_accum = tick_dt;  // ensure that we tick immediately on first frame
    }
}

simpler_update :: () {
    update_window_events();

    // NOTE: This order is important because F11 could generate a window_resize event.
    debug_key_pressed = false;
    process_input();

    window_resizes = get_window_resizes();
    for window_resizes {
        update_window(it.window);
        if it.window == window && (it.width != window_size.x || it.height != window_size.y) {
            window_size = .{ it.width, it.height };
            window_center = .{ xx (window_size.x / 2), xx (window_size.y / 2) };
            init_font();
        }
    }

    // ignore big spikes when debugging
    if frame_dt < tick_dt * 2 {
        tick_accum += frame_dt;
    }

    // per-frame updates
    t_update := seconds_since_init();
    game_mode.update();
    timings_buf[Timing.Update] = seconds_since_init() - t_update;

    // fixed physics tick
    t_tick_sum: float64;
    t_ticks := floor(tick_accum / tick_dt);
    if tick_accum > tick_dt {
        t_tick := seconds_since_init();
        game_mode.tick();
        t_tick_sum += seconds_since_init() - t_tick;
        tick_accum -= tick_dt;
    }
    timings_buf[Timing.Tick] = ifx t_ticks then t_tick_sum / t_ticks else 0;
}

simpler_draw :: () {
    t_draw := seconds_since_init();
    game_mode.draw();
    timings_buf[Timing.Draw] = seconds_since_init() - t_draw;
}

end_frame :: (sleep_ms: s32 = 0) {
    t_audio := seconds_since_init();
    update_audio();
    timings_buf[Timing.Audio] = seconds_since_init() - t_audio;

    swap_buffers(window, vsync);

    memory_visualizer_per_frame_update();
    reset_temporary_storage();
    if sleep_ms > 0 {
        sleep_milliseconds(sleep_ms);
    }

    timings = timings_buf;
}

simpler_game_loop :: () {
    while !quit {
        begin_frame();
        simpler_update();
        simpler_draw();
        end_frame();
    }
}

#scope_file

#import "Basic";
#import "Input";
#import "Keymap";
#import "Math";
#import "Window_Creation";
#import "File";
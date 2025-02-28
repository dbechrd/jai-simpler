#module_parameters ()(
    MEMORY_DEBUGGER := false,
    WIN_CONSOLE := false,       // hide console on windows
    LEFT_HANDED := true,        // Simp handedness
    BACKGROUND_AUDIO := false,  // play audio when window minimized (it platform supports it)
    ASSET_WATCHER := false      // hot reload texture
);

#load "audio.jai";
#load "collision.jai";
#load "color.jai";
#load "easing.jai";
#load "font.jai";
#load "input.jai";
#load "logger.jai";
#load "render.jai";
#if ASSET_WATCHER {
    #load "watcher.jai";
}

#run {
    #if OS == .WINDOWS && !WIN_CONSOLE {
        WR :: #import "Windows_Resources";
        WR.disable_runtime_console();
    }
}

quit: bool;  // you can set this manually

// Internal state, but not hidden because you might want to log/display them.
// Use set_tps() to set the tick rate.
now: float64;
vsync: bool = true;
frame_number: int;
frame_dt: float64;
ticks_per_second := 60;
tick_dt: float64;
tick_accum: float64;
tick_number: int;

set_tps :: (tps: int) {
    assert(tps >= 0);
    ticks_per_second = tps;
    tick_dt = ifx ticks_per_second then 1.0 / ticks_per_second else 0.0;
}

Timing :: enum {
    Tick;
    Update;
    Draw;
    Audio;
    #if ASSET_WATCHER {
        Asset_Watcher;
    }
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
    tick: ();
    update: ();
    draw: ();
};

game_mode: *GameMode;
requested_game_mode: *GameMode;

switch_game_mode :: (mode: *GameMode) {
    requested_game_mode = mode;
}

simpler_init :: (title: string, requested_window_size: Size) {
    // HACK: For pong swapper thing
    if window return;

    #import "String";  // For path_strip_filename. @Cleanup.
    #import "System";  // For get_path_of_running_executable. @Cleanup.

    path := path_strip_filename(get_path_of_running_executable());
    set_working_directory(path);
    log("Working Directory: %\n", path);

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    init_logger();
    init_render(title, requested_window_size);
    init_fonts();
    init_audio();
}

simpler_deinit :: () {
    if game_mode != null {
        game_mode.deinit();
    }
    deinit_audio();
    deinit_fonts();
    #if ASSET_WATCHER {
        asset_watcher_stop();
        deinit(*texture_by_filepath);
    }
    #if MEMORY_DEBUGGER {
        report_memory_leaks();
    }
    deinit_logger();
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

        #if ASSET_WATCHER asset_watcher_start();
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
        }
    }

    if ticks_per_second {
        tick_accum += frame_dt;
        // re-sync tick accumulator when there are big frame time spikes
        tick_accum = clamp(tick_accum, 0, tick_dt * 3);
    }

    // fixed physics tick
    t_tick := seconds_since_init();
    while ticks_per_second && tick_accum >= tick_dt {
        game_mode.tick();
        tick_accum -= tick_dt;
        tick_number += 1;
    }
    timings_buf[Timing.Tick] = seconds_since_init() - t_tick;

    // per-frame updates
    t_update := seconds_since_init();
    game_mode.update();
    timings_buf[Timing.Update] = seconds_since_init() - t_update;
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

    #if ASSET_WATCHER {
        t_asset_watcher := seconds_since_init();
        asset_watcher_update();
        timings_buf[Timing.Asset_Watcher] = seconds_since_init() - t_asset_watcher;
    }

    swap_buffers(window, vsync);

    reset_temporary_storage();
    memory_visualizer_per_frame_update();
    //if sleep_ms > 0 {
    //    sleep_milliseconds(sleep_ms);
    //}

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
#import "File_Watcher";
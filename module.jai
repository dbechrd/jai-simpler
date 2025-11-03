#module_parameters ()(
    MEMORY_DEBUGGER := false,
    WIN_CONSOLE := false,         // hide console on windows
    LEFT_HANDED := true,          // Simp handedness
    BACKGROUND_AUDIO := false,    // play audio when window minimized (it platform supports it)
    ASSET_WATCHER := false,       // hot reload texture
    GET_RECT := true,             // do GetRect input/update logic
    SDF_FONTS := true,            // replace the font shader with an SDF shader (see note below)
    LOG_SOURCES := true,          // print filenames or inferred sources in the log file for each line
    INFER_LOG_SOURCES := true,    // do some magic to figure out which module a log line came from (if LOG_SOURCES=true)
    ONE_TICK_PER_FRAME := false,  // for debugging, don't run many ticks at once when accumulator is high
    GAMEPAD_SUPPORT := false      // enable this to init/query gamepad input
);

/*
//---------------------------------------------------
// Using SDF_FONTS=true requires this patch to Simp:
//---------------------------------------------------
Simp/font.jai:814 (top of copy_glyph_to_bitmap)

    if data.utf32 != #char " " {
        err := FT_Render_Glyph(face.glyph, .SDF);
        if err {
            log_error("Failed to render glyph (utf32 = %) as SDF. err = %\n", data.utf32, err);
        }
    }
*/

#load "audio.jai";
#load "collision.jai";
#load "color.jai";
#load "easing.jai";
#load "font.jai";
#load "input.jai";
#load "logger.jai";
#load "parse.jai";
#load "render.jai";
#load "utils.jai";
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
frame_number: int;
frame_dt: float64;
ticks_per_second := 60;
tick_now: float64;
tick_number: int;
tick_dt: float64;
tick_accum: float64;

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
}
TIMING_COUNT :: #run enum_highest_value(Timing)+1;
timings: [TIMING_COUNT] float64;
timings_buf: [TIMING_COUNT] float64;

Perf_Stats :: struct {
    temp_storage_total_bytes_occupied: int;
    temp_storage_high_water_mark: int;
}
perf_stats: Perf_Stats;

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

simpler_init :: (title: string, requested_window_size: Vector2i) {
    auto_release_temp();

    seconds_since_init();  // force timer init

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    init_logger();

    {
        #import "String";  // For path_strip_filename. @Cleanup.
        #import "System";  // For get_path_of_running_executable. @Cleanup.

        path := path_strip_filename(get_path_of_running_executable());
        set_working_directory(path);
        log("Working Directory: %\n", path);
    }

    #if GAMEPAD_SUPPORT {
        init_gamepad();
        if gamepad.connected {
            gamepad.generate_events = true;
        } else {
            log("Failed to find a supported gampad.");
        }
    }
    init_render(title, requested_window_size);
    init_audio();
}

simpler_deinit :: () {
    if game_mode != null {
        game_mode.deinit();
    }
    deinit_audio();
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
    if !load_from_file(*keybinds, "keymap", filename, false) {
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
    #if GAMEPAD_SUPPORT {
        update_gamepad();
    }
    process_input();

    // NOTE: This is after process_input() because toggle_fullscreen() could generate a window_resize event.
    window_resizes = get_window_resizes();
    for window_resizes {
        update_window(it.window);
        if it.window == window && (it.width != window_size.x || it.height != window_size.y) {
            window_size = .{ it.width, it.height };
            window_center = .{ xx (window_size.x / 2), xx (window_size.y / 2) };
        }
    }

    if ticks_per_second && tick_number {
        tick_accum += frame_dt;
        // re-sync tick accumulator when there are big frame time spikes
        tick_accum = clamp(tick_accum, 0, tick_dt * 10);
    }

    // fixed physics tick
    t_tick := seconds_since_init();
    while ticks_per_second && tick_accum >= tick_dt {
        tick_number += 1;
        game_mode.tick();
        tick_now += tick_dt;
        tick_accum -= tick_dt;
        #if ONE_TICK_PER_FRAME {
            break;
        }
    }
    timings_buf[Timing.Tick] = seconds_since_init() - t_tick;

    // per-frame updates
    t_update := seconds_since_init();
    game_mode.update();
    timings_buf[Timing.Update] = seconds_since_init() - t_update;
}

simpler_draw :: () {
    // perf, if causes side effects, consider removing the minimized check
    if !window_minimized {
        t_draw := seconds_since_init();
        game_mode.draw();
        timings_buf[Timing.Draw] = seconds_since_init() - t_draw;
    }
}

end_frame :: () {
    t_audio := seconds_since_init();
    update_audio();
    timings_buf[Timing.Audio] = seconds_since_init() - t_audio;

    #if ASSET_WATCHER {
        t_asset_watcher := seconds_since_init();
        asset_watcher_update();
        timings_buf[Timing.Asset_Watcher] = seconds_since_init() - t_asset_watcher;
    }

    // HACK: For some reason minimizing the window causes SEVERE fps loss *unless* you don't call swap_buffers
    // while it's minimized. This makes no sense.. Ugh.
    if !window_minimized {
        swap_buffers(window, vsync);
    }

    timings = timings_buf;
    ts := context.temporary_storage;
    if ts {
        perf_stats.temp_storage_total_bytes_occupied = ts.total_bytes_occupied;
        perf_stats.temp_storage_high_water_mark = max(perf_stats.temp_storage_high_water_mark, ts.high_water_mark);
    }

    reset_temporary_storage();
    memory_visualizer_per_frame_update();
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
#if GET_RECT {
    using GetRect :: #import "GetRect_LeftHanded";
}
#if GAMEPAD_SUPPORT {
    #import "Gamepad";
}
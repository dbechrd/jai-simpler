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
fullscreen: bool;
window_focused: bool;

quit: bool;
now: float64;
frame_dt: float64;
frame_number: int;
ticks_per_second := 60;
tick_dt := cast(float64) 1.0 / 60.0;
tick_accum: float64;

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
    init_font();
    init_audio();

    tick_accum = tick_dt;  // ensure that we tick immediately on first frame
}

simpler_deinit :: () {
    if game_mode != null {
        game_mode.deinit();
    }
    // deinit_audio();  // causes freezing, so like.. let's just not do it then -_-
}

// NOTE: Make sure you register your keymap procedures first!
init_keymap :: (filename: string) {
    add_proc(*keymap, "DebugKey", DebugKey);
    if !load_from_file(*keymap, "keymap", filename, false) {
        log_error("Failed to load keymap from file %\n", filename);
    }
}

save_to_file :: (set: *Keymap_Set, filename: string) {
    builder: String_Builder;
    print_to_builder(*builder, set);
    data := builder_to_string(*builder);
    write_entire_file(filename, data);
}

print_to_builder :: (builder: *String_Builder, set: *Keymap_Set) {
    print_to_builder(builder, "[1]  # Version number; do not delete!\n");
    for set.keymaps {
        print_to_builder(builder, "\n[%]\n", it.section_name);
        print_keymap_mappings_to_builder(builder, it);
    }
}

save_to_file :: (keymap: *Keymap, filename: string) {
    builder: String_Builder;
    print_to_builder(*builder, keymap);
    data := builder_to_string(*builder);
    write_entire_file(filename, data);
}

print_to_builder :: (builder: *String_Builder, keymap: *Keymap) {
    print_to_builder(builder, "[1]  # Version number; do not delete!\n\n");
    print_keymap_mappings_to_builder(builder, keymap);
}

print_keymap_mappings_to_builder :: (builder: *String_Builder, keymap: *Keymap) {
    for keymap.mappings {
        key_chord_start := builder_string_length(builder);

        if it.modifier_flags.shift_pressed   print_to_builder(builder, "S-");
        if it.modifier_flags.ctrl_pressed    print_to_builder(builder, "C-");
        if it.modifier_flags.alt_pressed     print_to_builder(builder, "A-");
        // @ToDo: Keymap module doesn't currently handle cmd_meta_pressed, but probably should.
        if !it.respect_ignore_modifier_keys  print_to_builder(builder, "N-");

        key := map_key_to_string(xx it.utf32,, temp);
        print_to_builder(builder, "%", key);

        key_chord_length := builder_string_length(builder) - key_chord_start;

        // Vertical alignment
        LONGEST_MAPPING :: "S-C-A-N-Gamepad_LStickRight";
        for 0..(LONGEST_MAPPING.count - key_chord_length) {
            print_to_builder(builder, " ");
        }

        // @Note: To account for longer mappings than expected, we always print at least one space
        if it.command_string {
            print_to_builder(builder, " :%", it.command_string);
        } else {
            print_to_builder(builder, " %", keymap.procs[it.proc_index].name);
        }
        print_to_builder(builder, "\n");
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
            init_font();
        }
    }

    // ignore big spikes when debugging
    if frame_dt < tick_dt * 2 {
        tick_accum += frame_dt;
    }

    // per-frame updates
    game_mode.update();

    // fixed physics tick
    if tick_accum > tick_dt {
        game_mode.tick();
        tick_accum -= tick_dt;
    }
}

simpler_draw :: () {
    game_mode.draw();
}

end_frame :: (sleep_ms: s32 = 0) {
    update_audio();
    swap_buffers(window);

    memory_visualizer_per_frame_update();
    reset_temporary_storage();
    if sleep_ms > 0 {
        sleep_milliseconds(sleep_ms);
    }
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
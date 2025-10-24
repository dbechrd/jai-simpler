default_sound: Sound_Data;

init_audio :: () {
    log("--- Audio Info ---\n");

    devices := get_devices();
    log("devices: %\n", devices);

    success := sound_player_init(.{ audible_when_window_is_not_in_focus = BACKGROUND_AUDIO });
    assert(success);
    if !success {
        log_error("failed to initialize sound player\n");
        return;
    }

    log("sample_rate: %\n", get_audio_sampling_rate());
    log("volume: %\n", Sound.master_volume);
    // log("mix_levels: %\n", Sound.mix_levels);

    default_sound = load_audio_data("default_sound", MISSING_OGG_BYTES);
}

deinit_audio :: () {
    sound_player_shutdown();
}

set_category_volume :: (category: Sound_Category, volume: float) {
    Sound.mix_levels[category] = clamp(volume, 0.0, 1.0);
}

update_audio :: () {
    Sound.update();
}

// note: perturb flag ignored when looping, because there's no easy way to vary it per loop iteration right now
play_sound :: (sound_data: *Sound_Data, category := Sound_Category.GENERAL_SFX, volume := 1.0, perturb := 0.0, loop := false) {
    stream := make_stream(sound_data, category);
    if sound_data.type == .OGG_COMPRESSED {
        // HACK: If an .ogg isn't big enough to finish loading "initial pages", we need to disable the wait.
        stream.internal_flags &= ~.WAITING_FOR_INITIAL_DECODER_PAGES;
    }

    stream.user_volume_scale = volume;
    if loop {
        set_repeating(stream, loop);
    } else if perturb {
        // stream.user_volume_scale = random_get_within_range(0.5,  1);
        stream.rate_scale = random_get_within_range(1.0 - perturb, 1.0 + perturb);
    }
    start_playing(stream);
}

play_sound_random :: (sound_data: [] Sound_Data, category := Sound_Category.GENERAL_SFX, volume := 1.0, perturb := 0.0, loop := false) {
    pick_sound := *sound_data[random_get_within_bound(xx sound_data.count)];
    play_sound(pick_sound, category=category, volume=volume, perturb=perturb, loop=loop);
}

// Example usage:
//
//   sine_350: Sound_Data;
//   sine_440: Sound_Data;
//   sine_480: Sound_Data;
//   generate_sine_wave(*sine_350, "sine_350", 350.0);
//   generate_sine_wave(*sine_440, "sine_440", 440.0);
//   generate_sine_wave(*sine_480, "sine_480", 480.0);
//

// sound_data : destination struct
// sound_name : human-readable name
// frequency  : note to play in Hz
// gain       : volume strength in the range [0.0, 1.0] (warning: 1.0 is *very* loud)
generate_sine_wave :: (using sound_data: *Sound_Data, sound_name: string, frequency := 440.0, gain := 0.05, cycles := 1) {
    samples_per_cycle := cast(s64) (sampling_rate / frequency);

    name                     = sound_name;
    type                     = .LINEAR_SAMPLE_ARRAY;
    sampling_rate            = 44100;
    nchannels                = 2;
    nsamples_times_nchannels = (samples_per_cycle * cycles) * nchannels;  // exactly one period
    sample_buffer := NewArray(nsamples_times_nchannels + nchannels, s16);  // one trailing silence sample per channel
    buffer  = string.{ sample_buffer.count * 2, cast(*u8) sample_buffer.data };
    samples = sample_buffer.data;

    amplitude := 0xffff * gain;
    dx := frequency / sampling_rate;
    x := 0.0;
    for 0..samples_per_cycle-1 {
        sample := cast(s16) (amplitude * sin(x * TAU));
        sample_buffer[it*2] = sample;
        sample_buffer[it*2+1] = sample;
        x += dx;
    }
    for 1..cycles-1 {
        memcpy(*sample_buffer[it * samples_per_cycle * nchannels], *sample_buffer[0], samples_per_cycle * nchannels * size_of(s16));
    }
}

#load "note_frequencies.jai";

#scope_file

#load "missing_ogg.jai";

#import "PCG";
using Sound :: #import "Sound_Player";
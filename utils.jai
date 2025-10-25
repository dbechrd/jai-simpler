// TODO: Replace with new random_seed() overload in next beta
make_random_seed :: () -> u64 {
    #if CPU == .X64 {
        #import "Machine_X64";
        for 0..100 {  // upper bound, to avoid infinite loops if something funny is happening
            success, value := rdseed();
            if success {
                return value;
            }
        }
    }

    // Not x64, or rdseed failed, fall back on hashing the clock
    time := current_time_monotonic().low;
    time_hash := (get_hash(time >> 16).(u64) << 32) | get_hash(time);
    return time_hash;
}

image_to_ico :: (image_path: string, ico_path: string) {
    #if OS == .WINDOWS {
        #import "Ico_File";
        #import "File";
        ico_data := create_ico_file_from_bitmap_filename(image_path);
        write_entire_file(ico_path, ico_data);
    } else {
        log_error("Generating icons is only supported on Windows.\n");
    }
}

#scope_file

#import "Hash";
make_random_seed :: () -> u64 {
    time := current_time_monotonic().low;
    time_hash := (get_hash(time >> 16).(u64) << 32) | get_hash(time);
    return time_hash;
}

#scope_file

#import "Hash";
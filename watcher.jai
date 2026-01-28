asset_watcher_start :: () {
    if init(*asset_watcher, asset_changed, events_to_watch = .ALL_EVENTS) {
        img_dir :: "assets/img";
        if add_directories(*asset_watcher, img_dir) {
            log("[asset_watcher] Watching directory for changes: %\n", img_dir);
        } else {
            log("[asset_watcher] Failed to watch directory: %\n", img_dir);
        }
    } else {
        log("[asset_watcher] Warning: Failed to init asset watcher. Hot reloading disabled.\n");
    }
}

asset_watcher_update :: () {
    process_changes(*asset_watcher);
}

asset_watcher_stop :: () {
    deinit(asset_watcher);
}

#scope_file

asset_watcher: File_Watcher(string);

asset_changed :: (watcher: *File_Watcher(string), change: *File_Change, user_data: *string) {
    if change.events & .MODIFIED {
        if ends_with(change.full_path, ".png") {
            log("[asset_watcher] Reloading texture %...\n", change.full_path);
            find_or_load_texture(change.full_path, force_reload=true);
        }
        //log("[asset_watcher] Change for path %: % (user_data points to %)", change.full_path, change.events, <<user_data);
    }
}
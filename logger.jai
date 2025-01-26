log_file_path := "log.txt";

init_logger :: () {
    context.log_level = .VERY_VERBOSE;
    context.print_style.default_format_struct.use_long_form_if_more_than_this_many_members = -1;
    context.print_style.default_format_struct.use_newlines_if_long_form = true;
    context.print_style.default_format_array.stop_printing_after_this_many_elements = 1000;

    file, success := file_open(log_file_path, for_writing=true, keep_existing_content=false);
    if !success return;
    log_file = file;

    context.logger = (message: string, data: *void, info: Log_Info) {
        if !message then return;

        if info.common_flags & .VERY_VERBOSE_ONLY && context.log_level < .VERY_VERBOSE {
            return;
        }
        if info.common_flags & .VERBOSE_ONLY && context.log_level < .VERBOSE {
            return;
        }

        file_write(*log_file, message);

        // kernel32 :: #system_library "kernel32";
        // BOOL     :: enum s32 { FALSE :: 0; TRUE :: 1; }
        // HANDLE :: *void;
        // FlushFileBuffers :: (hFile: HANDLE) -> BOOL #foreign kernel32;
        // FlushFileBuffers(log_file.handle);
    };

    log_preamble();
}

deinit_logger :: () {
    file_close(*log_file);
}

#scope_file

log_file: File;

log_preamble :: () {
    log_cpu_info();
}

log_cpu_info :: () {
    log("\n--- CPU Info ---\n");
    cpu_info := get_cpu_info();
    log("vendor : %\n", cpu_info.vendor);
    log("SSE    : %\n", ifx check_feature(cpu_info.feature_leaves, x86_Feature_Flag.SSE) then "Supported" else "Not Supported");
    log("SSE2   : %\n", ifx check_feature(cpu_info.feature_leaves, x86_Feature_Flag.SSE2) then "Supported" else "Not Supported");
    log("AVX2   : %\n", ifx check_feature(cpu_info.feature_leaves, x86_Feature_Flag.AVX2) then "Supported" else "Not Supported");
}

#import "Machine_X64";
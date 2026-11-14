log_file_path := "log.txt";

#add_context log_source: string;

simpler_build_log_message :: (message: string, data: *void, info: Log_Info) -> string {
    builder: String_Builder;

    // timestamp
    timestamp := seconds_since_init();
    print_to_builder(*builder, "[%s]", timestamp);

    // log the source of message
    #if LOG_SOURCES {
        if info.location.line_number {
            before := builder_string_length(*builder);

            pad_right: int;
            append(*builder, "[ ");

            if context.log_source {
                print_to_builder(*builder, "%", context.log_source);
                pad_right = 16;
            } else {
                #if INFER_LOG_SOURCES {
                    // try to extract the module name, rather than just printing fully qualified file paths (YMMV)
                    log_source := info.location.fully_pathed_filename;
                    module_split := split(log_source, "modules/",, temp);
                    if module_split.count > 1 {
                        log_source = split(module_split[module_split.count-1], "/",, temp)[0];
                        print_to_builder(*builder, "%", log_source);
                    }
                    pad_right = 16;
                } else {
                    print_to_builder(*builder, "%:%", info.location.fully_pathed_filename, info.location.line_number);
                    pad_right = 80;
                }
            }

            if pad_right {
                bytes := builder_string_length(*builder) - before;
                if bytes < pad_right {
                    for 0..pad_right-bytes-1 {
                        append(*builder, " ");
                    }
                }
            }
            append(*builder, " ]");
        }
    }

    // log level
    {
        before := builder_string_length(*builder);
        if info.common_flags & .ERROR {
            append(*builder, "[ Error   ] ");
        } else if info.common_flags & .WARNING {
            append(*builder, "[ Warning ] ");
        } else {
            append(*builder, "[         ] ");
        }
    }

    // message
    append(*builder, message);
    if message[message.count-1] != #char "\n" {
        append(*builder, "\n");
    }

    output := builder_to_string(*builder,, temp);
    return output;
};

simpler_logger :: (message: string, data: *void, info: Log_Info) {
    if !log_file.handle then return;
    if !message then return;

    if info.common_flags & .VERY_VERBOSE_ONLY && context.log_level < .VERY_VERBOSE {
        return;
    }
    if info.common_flags & .VERBOSE_ONLY && context.log_level < .VERBOSE {
        return;
    }

    output := simpler_build_log_message(message, data, info);
    file_write(*log_file, output);

    // kernel32 :: #system_library "kernel32";
    // BOOL     :: enum s32 { FALSE :: 0; TRUE :: 1; }
    // HANDLE :: *void;
    // FlushFileBuffers :: (hFile: HANDLE) -> BOOL #foreign kernel32;
    // FlushFileBuffers(log_file.handle);
};

simpler_print_style :: () {
    context.log_level = .VERY_VERBOSE;
    context.print_style.default_format_struct.use_long_form_if_more_than_this_many_members = -1;
    context.print_style.default_format_struct.use_newlines_if_long_form = true;
    context.print_style.default_format_array.stop_printing_after_this_many_elements = 1000;
    context.print_style.default_format_float.trailing_width = 3;
    context.print_style.default_format_float.zero_removal = .NO;
}

init_logger :: (logger: Logger) {
    simpler_print_style();

    file, success := file_open(log_file_path, for_writing=true, keep_existing_content=false);
    if !success return;
    log_file = file;

    context.logger = logger;
    log_preamble();
}

deinit_logger :: () {
    file_close(*log_file);
    log_file.handle = null;
}

#scope_file

log_file: File;

log_preamble :: () {
    log_cpu_info();
}

log_cpu_info :: () {
    log("--- CPU Info ---\n");
    cpu_info := get_cpu_info();
    log("vendor : %\n", cpu_info.vendor);
    log("SSE    : %\n", ifx check_feature(cpu_info.feature_leaves, x86_Feature_Flag.SSE) then "Supported" else "Not Supported");
    log("SSE2   : %\n", ifx check_feature(cpu_info.feature_leaves, x86_Feature_Flag.SSE2) then "Supported" else "Not Supported");
    log("AVX2   : %\n", ifx check_feature(cpu_info.feature_leaves, x86_Feature_Flag.AVX2) then "Supported" else "Not Supported");
}

#import "String";
#import "Machine_X64";
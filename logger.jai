init_logger :: () {
    context.logger = (message: string, data: *void, info: Log_Info) {
        if !message then return;

        if info.common_flags & .VERY_VERBOSE_ONLY && context.log_level < .VERY_VERBOSE {
            return;
        }
        if info.common_flags & .VERBOSE_ONLY && context.log_level < .VERBOSE {
            return;
        }

        // Unify output to stdout so that everything shows up in VSCode's Output window.
        to_standard_error := false; //(info.common_flags & .ERROR) != 0;

        if message[message.count-1] != #char "\n" {
            write_strings(message, "\n", to_standard_error = to_standard_error);
        } else {
            write_string(message, to_standard_error = to_standard_error);
        }
    };
    context.log_level = .VERY_VERBOSE;
    context.print_style.default_format_struct.use_long_form_if_more_than_this_many_members = -1;
    context.print_style.default_format_struct.use_newlines_if_long_form = true;
    context.print_style.default_format_array.stop_printing_after_this_many_elements = 1000;

    log_preamble();
}

#scope_file

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
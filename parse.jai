expect_line :: (handler: *Text_File_Handler, $line_desc: string, $optional := false) -> line: string #expand {
    line, line_found := consume_next_line(handler);
    #if !optional {
        return_if(!line_found, #run tprint("Expected '%' line.", line_desc));
    }
    return line;
}

expect_eol :: () #expand {
    return_if(`line.count != 0, tprint("Expected end of line. Found '%'.", `line));
}

expect_eof :: (handler: *Text_File_Handler) #expand {
    line, line_found := consume_next_line(handler);
    return_if(line_found, tprint("Expected end of file. Found '%'.", line));
}

return_if :: (condition: bool, error: string) #expand {
    if condition {
        `return false, error;
    }
}

expect_int :: (s: *string, desc: string, base := 10, $T := int) -> value: T #expand {
    value:, success:, s.* = string_to_int(s.*, base, T);
    return_if(!success, tprint("Expected integer (%)", desc));

    s.* = eat_spaces(s.*);
    return value;
}

// note: both bounds inclusive
expect_int :: (s: *string, min: int, max: int, desc: string, base := 10, $T := int, zero_allowed := false) -> value: T #expand {
    value:, success:, s.* = string_to_int(s.*, base, T);
    return_if(!success, tprint("Expected integer (%) in range % to %.", desc, min, max));

    zero_okay := zero_allowed && value == 0;
    in_range := (value >= min && value <= max) || zero_okay;
    return_if(!in_range, tprint("Expected integer (%) in range % to %. Found '%'.", desc, min, max, value));

    s.* = eat_spaces(s.*);
    return value;
}

expect_string :: (s: *string, desc: string) -> value: string #expand {
    value:, s.* = break_by_spaces(s.*);
    return_if(!value, tprint("Expected string (%)", desc));

    return value;
}

expect_string_value :: (s: *string, desc: string, value: string) #expand {
    assert(xx value);

    _s := s.*;
    if _s.count >= value.count {
        for value {
            return_if(!_s || _s[0] != it, tprint("Expected '%' (%), found '%'.", value, desc, s));
            advance(*_s, 1);
        }
    }
    s.* = _s;
}

#scope_file

#import "Text_File_Handler";
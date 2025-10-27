expect_line :: (handler: *Text_File_Handler, line_desc: string, $optional := false) -> line: string #expand {
    line, line_found := consume_next_line(handler);
    #if !optional {
        return_if(!line_found, "Expected '%' line.", line_desc);
    }
    return line;
}

expect_eol :: () #expand {
    return_if(`line.count != 0, "Expected end of line. Found '%'.", `line);
}

expect_eof :: (handler: *Text_File_Handler) #expand {
    line, line_found := consume_next_line(handler);
    return_if(line_found, "Expected end of file. Found '%'.", line);
}

return_if :: (condition: bool, error: string, args: ..Any) #expand {
    if condition {
        // note: xx 0 allows this to return false, null, 0, etc.
        `return xx 0, tprint(error, ..args);
    }
}

expect_int :: (s: *string, desc: string, base := 10, $T := int) -> value: T #expand {
    value:, success:, s.* = string_to_int(s.*, base, T);
    return_if(!success, "Expected integer (%)", desc);

    s.* = eat_spaces(s.*);
    return value;
}

// note: both bounds inclusive
expect_int :: (s: *string, min: int, max: int, desc: string, base := 10, $T := int, zero_allowed := false) -> value: T #expand {
    value:, success:, s.* = string_to_int(s.*, base, T);
    return_if(!success, "Expected integer (%) in range % to %.", desc, min, max);

    zero_okay := zero_allowed && value == 0;
    in_range := (value >= min && value <= max) || zero_okay;
    return_if(!in_range, "Expected integer (%) in range % to %. Found '%'.", desc, min, max, value);

    s.* = eat_spaces(s.*);
    return value;
}

expect_string :: (s: *string, desc: string) -> value: string #expand {
    value:, s.* = break_by_spaces(s.*);
    return_if(!value, "Expected string (%)", desc);

    return value;
}

expect_string_literal :: (s: *string, literal: string, desc: string) #expand {
    assert(xx literal);

    _s := s.*;
    if _s.count >= literal.count {
        for literal {
            return_if(!_s || _s[0] != it, "Expected '%' (%), found '%'.", literal, desc, s);
            advance(*_s, 1);
        }
    }
    s.* = _s;
}

expect_2d_array :: (handler: *Text_File_Handler, $desc: string, array: [] $T, dims: Vector2i, min := S64_MIN, max := S64_MAX,
                    $validator: (value: int) -> (valid: bool, error: string) = null,
                    $assignment: (it: *T, value: int) -> (success: bool, error: string) = null) #expand {
    line := expect_line(handler, desc);
    for * array {
        value := expect_int(*line, min, max, #run tprint("% value", desc));
        #if validator {
            valid, error := validator(value);
            return_if(!valid, error);
        }
        #if assignment {
            success, error := assignment(it, value);
            return_if(!success, error);
        } else {
            it.* = xx value;
        }

        // last column
        if it_index % dims.x == dims.x-1 {
            expect_eol();
            // all rows but last
            if it_index < (dims.x * dims.y)-1 {
                line = expect_line(handler, desc);
            }
        }
    }
    expect_eol();
}

#scope_file

#import "Text_File_Handler";
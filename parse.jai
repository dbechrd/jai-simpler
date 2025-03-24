return_if :: (condition: bool, error: string) #expand {
    if condition {
        `return error;
    }
}

expect_int :: (s: *string, error: string) -> value: int #expand {
    value:, success:, s.* = string_to_int(s.*);
    if !success {
        `return error;
    }
    s.* = eat_spaces(s.*);
    return value;
}

// note: both bounds inclusive
expect_int :: (s: *string, min: int, max: int, error: string, zero_allowed := false) -> value: int #expand {
    value:, success:, s.* = string_to_int(s.*);
    if !success || ((value < min || value > max) && !(zero_allowed && value == 0)) {
        `return tprint("% Value out of range. Expected % to %, found %.",
            error, min, max, value);
    }
    s.* = eat_spaces(s.*);
    return value;
}

expect_string :: (s: *string, error: string) -> value: string #expand {
    value:, s.* = break_by_spaces(s.*);
    if !value {
        `return error;
    }
    return value;
}

expect_string_exact :: (s: *string, expected: string, error: string) #expand {
    assert(xx expected);

    _s := s.*;
    if _s.count >= expected.count {
        for expected {
            if !_s || _s[0] != it {
                `return tprint("% Expected '%', found '%'.",
                    error, expected, s);
            }
            advance(*_s, 1);
        }
    }
    s.* = _s;
}

#scope_file

#import "Text_File_Handler";
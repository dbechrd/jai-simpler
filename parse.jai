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
                log("unexpected string: '%' (expected '%')\n", s, expected);
                `return error;
            }
            advance(*_s, 1);
        }
    }
    s.* = _s;
}

#scope_file

#import "Text_File_Handler";
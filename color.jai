BLACK   :: Vector4.{ 0, 0, 0, 1 };
BLUE    :: Vector4.{ 0, 0, 1, 1 };
GREEN   :: Vector4.{ 0, 1, 0, 1 };
CYAN    :: Vector4.{ 0, 1, 1, 1 };
RED     :: Vector4.{ 1, 0, 0, 1 };
MAGENTA :: Vector4.{ 1, 0, 1, 1 };
YELLOW  :: Vector4.{ 1, 1, 0, 1 };
WHITE   :: Vector4.{ 1, 1, 1, 1 };
GRAY    :: Vector4.{ .5, .5, .5, 1 };

flash_factor :: () -> float {
    return 0.75 + cos(to_milliseconds(current_time_monotonic()) / 160.0) * 0.25;
}

brightness_factor :: inline () -> float {
    return flash_factor() + 0.3;
}

color_brightness :: inline (v: Vector4, s: float) -> Vector4 {
    return .{
        v.x * s,
        v.y * s,
        v.z * s,
        v.w
    };
}

color_flash :: inline (v: Vector4) -> Vector4 {
    return color_brightness(v, brightness_factor());
}

color_flash :: inline (v: Vector4, enabled: bool) -> Vector4 {
    return ifx enabled then color_brightness(v, brightness_factor()) else v;
}

// Convert integer RGB [0, 255] to float RGBA [0.0, 1.0]
rgb_normalize :: (r: int, g: int, b: int, a: int) -> Vector4 {
    c: Vector4;
    c.x = r / 255.0;
    c.y = g / 255.0;
    c.z = b / 255.0;
    c.w = a / 255.0;
    return c;
}

fade :: inline (v: Vector4, alpha: float) -> Vector4 {
    return .{
        v.x,
        v.y,
        v.z,
        v.w * alpha
    };
}
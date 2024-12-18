WHITE      :: Vector4.{ 1, 1, 1, 1 };
LIGHT_GRAY :: Vector4.{ .75, .75, .75, 1 };
GRAY       :: Vector4.{ .5, .5, .5, 1 };
DARK_GRAY  :: Vector4.{ .25, .25, .25, 1 };
BLACK      :: Vector4.{ 0, 0, 0, 1 };

BLUE       :: Vector4.{ 0, 0, 1, 1 };
GREEN      :: Vector4.{ 0, 1, 0, 1 };
CYAN       :: Vector4.{ 0, 1, 1, 1 };
RED        :: Vector4.{ 1, 0, 0, 1 };
MAGENTA    :: Vector4.{ 1, 0, 1, 1 };
YELLOW     :: Vector4.{ 1, 1, 0, 1 };

wave :: (t: float, amplitude := 1.0, frequency := 1.0) -> float {
    return amplitude * sin(2 * PI * t * frequency);
}

// Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
//
// Credit to Raylib:
// https://github.com/raysan5/raylib/blob/0d39e7137b28980f05843bd505ef3e74d8772d03/src/rtextures.c#L4980
//
color_brightness :: (color: Vector4, factor: float, $clamped := true) -> Vector4 {
    rgba := color;
    #if clamped {
        clamped_factor := clamp(factor, -1, 1);
        if clamped_factor < 0.0 {
            rgba *= 1.0 + clamped_factor;
            rgba.w = color.w;
        } else {
            rgba = rgba + ((.{1, 1, 1, 1} - rgba) * clamped_factor);
        }
    } else {
        rgba *= 1.0 + factor;
        rgba.w = color.w;
    }

    return rgba;
}

color_flash :: inline (color: Vector4, intensity: float, frequency := 1.0) -> Vector4 {
    intensity = clamp(intensity, 0, 1);
    factor := wave(xx now, intensity, frequency);
    return color_brightness(color, factor, clamped = false);
}

color_flash_if :: inline (color: Vector4, enabled: bool, intensity: float, frequency := 1.0) -> Vector4 {
    return ifx enabled then color_flash(color, intensity, frequency) else color;
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
TRANSPARENT     :: Vector4.{};
WHITE           :: Vector4.{ 1, 1, 1, 1 };
LIGHT_GRAY      :: Vector4.{ .75, .75, .75, 1 };
SEMI_LIGHT_GRAY :: Vector4.{ .66, .66, .66, 1 };
GRAY            :: Vector4.{ .5, .5, .5, 1 };
SEMI_DARK_GRAY  :: Vector4.{ .33, .33, .33, 1 };
DARK_GRAY       :: Vector4.{ .25, .25, .25, 1 };
BLACK           :: Vector4.{ 0, 0, 0, 1 };
BLUE            :: Vector4.{ 0, 0, 1, 1 };
GREEN           :: Vector4.{ 0, 1, 0, 1 };
CYAN            :: Vector4.{ 0, 1, 1, 1 };
RED             :: Vector4.{ 1, 0, 0, 1 };
MAGENTA         :: Vector4.{ 1, 0, 1, 1 };
YELLOW          :: Vector4.{ 1, 1, 0, 1 };

WHITE_HOVER :: #run WHITE * 1.25; // for highlighting textures on mouse hover

AliceBlue            :: #run rgb_normalize(240, 248, 255, 255);
AntiqueWhite         :: #run rgb_normalize(250, 235, 215, 255);
Aqua                 :: #run rgb_normalize(  0, 255, 255, 255);
Aquamarine           :: #run rgb_normalize(127, 255, 212, 255);
Azure                :: #run rgb_normalize(240, 255, 255, 255);
Beige                :: #run rgb_normalize(245, 245, 220, 255);
Bisque               :: #run rgb_normalize(255, 228, 196, 255);
Black                :: #run rgb_normalize(  0,   0,   0, 255);
BlanchedAlmond       :: #run rgb_normalize(255, 235, 205, 255);
Blue                 :: #run rgb_normalize(  0,   0, 255, 255);
BlueViolet           :: #run rgb_normalize(138,  43, 226, 255);
Brown                :: #run rgb_normalize(165,  42,  42, 255);
BurlyWood            :: #run rgb_normalize(222, 184, 135, 255);
CadetBlue            :: #run rgb_normalize( 95, 158, 160, 255);
Chartreuse           :: #run rgb_normalize(127, 255,   0, 255);
Chocolate            :: #run rgb_normalize(210, 105,  30, 255);
Coral                :: #run rgb_normalize(255, 127,  80, 255);
CornflowerBlue       :: #run rgb_normalize(100, 149, 237, 255);
Cornsilk             :: #run rgb_normalize(255, 248, 220, 255);
Crimson              :: #run rgb_normalize(220,  20,  60, 255);
Cyan                 :: #run rgb_normalize(  0, 255, 255, 255);
DarkBlue             :: #run rgb_normalize(  0,   0, 139, 255);
DarkCyan             :: #run rgb_normalize(  0, 139, 139, 255);
DarkGoldenRod        :: #run rgb_normalize(184, 134,  11, 255);
DarkGray             :: #run rgb_normalize(169, 169, 169, 255);
DarkGrey             :: #run rgb_normalize(169, 169, 169, 255);
DarkGreen            :: #run rgb_normalize(  0, 100,   0, 255);
DarkKhaki            :: #run rgb_normalize(189, 183, 107, 255);
DarkMagenta          :: #run rgb_normalize(139,   0, 139, 255);
DarkOliveGreen       :: #run rgb_normalize( 85, 107,  47, 255);
DarkOrange           :: #run rgb_normalize(255, 140,   0, 255);
DarkOrchid           :: #run rgb_normalize(153,  50, 204, 255);
DarkRed              :: #run rgb_normalize(139,   0,   0, 255);
DarkSalmon           :: #run rgb_normalize(233, 150, 122, 255);
DarkSeaGreen         :: #run rgb_normalize(143, 188, 143, 255);
DarkSlateBlue        :: #run rgb_normalize( 72,  61, 139, 255);
DarkSlateGray        :: #run rgb_normalize( 47,  79,  79, 255);
DarkSlateGrey        :: #run rgb_normalize( 47,  79,  79, 255);
DarkTurquoise        :: #run rgb_normalize(  0, 206, 209, 255);
DarkViolet           :: #run rgb_normalize(148,   0, 211, 255);
DeepPink             :: #run rgb_normalize(255,  20, 147, 255);
DeepSkyBlue          :: #run rgb_normalize(  0, 191, 255, 255);
DimGray              :: #run rgb_normalize(105, 105, 105, 255);
DimGrey              :: #run rgb_normalize(105, 105, 105, 255);
DodgerBlue           :: #run rgb_normalize( 30, 144, 255, 255);
FireBrick            :: #run rgb_normalize(178,  34,  34, 255);
FloralWhite          :: #run rgb_normalize(255, 250, 240, 255);
ForestGreen          :: #run rgb_normalize( 34, 139,  34, 255);
Fuchsia              :: #run rgb_normalize(255,   0, 255, 255);
Gainsboro            :: #run rgb_normalize(220, 220, 220, 255);
GhostWhite           :: #run rgb_normalize(248, 248, 255, 255);
Gold                 :: #run rgb_normalize(255, 215,   0, 255);
GoldenRod            :: #run rgb_normalize(218, 165,  32, 255);
Gray                 :: #run rgb_normalize(128, 128, 128, 255);
Grey                 :: #run rgb_normalize(128, 128, 128, 255);
Green                :: #run rgb_normalize(  0, 128,   0, 255);
GreenYellow          :: #run rgb_normalize(173, 255,  47, 255);
HoneyDew             :: #run rgb_normalize(240, 255, 240, 255);
HotPink              :: #run rgb_normalize(255, 105, 180, 255);
IndianRed            :: #run rgb_normalize(205,  92,  92, 255);
Indigo               :: #run rgb_normalize( 75,   0, 130, 255);
Ivory                :: #run rgb_normalize(255, 255, 240, 255);
Khaki                :: #run rgb_normalize(240, 230, 140, 255);
Lavender             :: #run rgb_normalize(230, 230, 250, 255);
LavenderBlush        :: #run rgb_normalize(255, 240, 245, 255);
LawnGreen            :: #run rgb_normalize(124, 252,   0, 255);
LemonChiffon         :: #run rgb_normalize(255, 250, 205, 255);
LightBlue            :: #run rgb_normalize(173, 216, 230, 255);
LightCoral           :: #run rgb_normalize(240, 128, 128, 255);
LightCyan            :: #run rgb_normalize(224, 255, 255, 255);
LightGoldenRodYellow :: #run rgb_normalize(250, 250, 210, 255);
LightGray            :: #run rgb_normalize(211, 211, 211, 255);
LightGrey            :: #run rgb_normalize(211, 211, 211, 255);
LightGreen           :: #run rgb_normalize(144, 238, 144, 255);
LightPink            :: #run rgb_normalize(255, 182, 193, 255);
LightSalmon          :: #run rgb_normalize(255, 160, 122, 255);
LightSeaGreen        :: #run rgb_normalize( 32, 178, 170, 255);
LightSkyBlue         :: #run rgb_normalize(135, 206, 250, 255);
LightSlateGray       :: #run rgb_normalize(119, 136, 153, 255);
LightSlateGrey       :: #run rgb_normalize(119, 136, 153, 255);
LightSteelBlue       :: #run rgb_normalize(176, 196, 222, 255);
LightYellow          :: #run rgb_normalize(255, 255, 224, 255);
Lime                 :: #run rgb_normalize(  0, 255,   0, 255);
LimeGreen            :: #run rgb_normalize( 50, 205,  50, 255);
Linen                :: #run rgb_normalize(250, 240, 230, 255);
Magenta              :: #run rgb_normalize(255,   0, 255, 255);
Maroon               :: #run rgb_normalize(128,   0,   0, 255);
MediumAquaMarine     :: #run rgb_normalize(102, 205, 170, 255);
MediumBlue           :: #run rgb_normalize(  0,   0, 205, 255);
MediumOrchid         :: #run rgb_normalize(186,  85, 211, 255);
MediumPurple         :: #run rgb_normalize(147, 112, 219, 255);
MediumSeaGreen       :: #run rgb_normalize( 60, 179, 113, 255);
MediumSlateBlue      :: #run rgb_normalize(123, 104, 238, 255);
MediumSpringGreen    :: #run rgb_normalize(  0, 250, 154, 255);
MediumTurquoise      :: #run rgb_normalize( 72, 209, 204, 255);
MediumVioletRed      :: #run rgb_normalize(199,  21, 133, 255);
MidnightBlue         :: #run rgb_normalize( 25,  25, 112, 255);
MintCream            :: #run rgb_normalize(245, 255, 250, 255);
MistyRose            :: #run rgb_normalize(255, 228, 225, 255);
Moccasin             :: #run rgb_normalize(255, 228, 181, 255);
NavajoWhite          :: #run rgb_normalize(255, 222, 173, 255);
Navy                 :: #run rgb_normalize(  0,   0, 128, 255);
OldLace              :: #run rgb_normalize(253, 245, 230, 255);
Olive                :: #run rgb_normalize(128, 128,   0, 255);
OliveDrab            :: #run rgb_normalize(107, 142,  35, 255);
Orange               :: #run rgb_normalize(255, 165,   0, 255);
OrangeRed            :: #run rgb_normalize(255,  69,   0, 255);
Orchid               :: #run rgb_normalize(218, 112, 214, 255);
PaleGoldenRod        :: #run rgb_normalize(238, 232, 170, 255);
PaleGreen            :: #run rgb_normalize(152, 251, 152, 255);
PaleTurquoise        :: #run rgb_normalize(175, 238, 238, 255);
PaleVioletRed        :: #run rgb_normalize(219, 112, 147, 255);
PapayaWhip           :: #run rgb_normalize(255, 239, 213, 255);
PeachPuff            :: #run rgb_normalize(255, 218, 185, 255);
Peru                 :: #run rgb_normalize(205, 133,  63, 255);
Pink                 :: #run rgb_normalize(255, 192, 203, 255);
Plum                 :: #run rgb_normalize(221, 160, 221, 255);
PowderBlue           :: #run rgb_normalize(176, 224, 230, 255);
Purple               :: #run rgb_normalize(128,   0, 128, 255);
RebeccaPurple        :: #run rgb_normalize(102,  51, 153, 255);
Red                  :: #run rgb_normalize(255,   0,   0, 255);
RosyBrown            :: #run rgb_normalize(188, 143, 143, 255);
RoyalBlue            :: #run rgb_normalize( 65, 105, 225, 255);
SaddleBrown          :: #run rgb_normalize(139,  69,  19, 255);
Salmon               :: #run rgb_normalize(250, 128, 114, 255);
SandyBrown           :: #run rgb_normalize(244, 164,  96, 255);
SeaGreen             :: #run rgb_normalize( 46, 139,  87, 255);
SeaShell             :: #run rgb_normalize(255, 245, 238, 255);
Sienna               :: #run rgb_normalize(160,  82,  45, 255);
Silver               :: #run rgb_normalize(192, 192, 192, 255);
SkyBlue              :: #run rgb_normalize(135, 206, 235, 255);
SlateBlue            :: #run rgb_normalize(106,  90, 205, 255);
SlateGray            :: #run rgb_normalize(112, 128, 144, 255);
SlateGrey            :: #run rgb_normalize(112, 128, 144, 255);
Snow                 :: #run rgb_normalize(255, 250, 250, 255);
SpringGreen          :: #run rgb_normalize(  0, 255, 127, 255);
SteelBlue            :: #run rgb_normalize( 70, 130, 180, 255);
Tan                  :: #run rgb_normalize(210, 180, 140, 255);
Teal                 :: #run rgb_normalize(  0, 128, 128, 255);
Thistle              :: #run rgb_normalize(216, 191, 216, 255);
Tomato               :: #run rgb_normalize(255,  99,  71, 255);
Turquoise            :: #run rgb_normalize( 64, 224, 208, 255);
Violet               :: #run rgb_normalize(238, 130, 238, 255);
Wheat                :: #run rgb_normalize(245, 222, 179, 255);
White                :: #run rgb_normalize(255, 255, 255, 255);
WhiteSmoke           :: #run rgb_normalize(245, 245, 245, 255);
Yellow               :: #run rgb_normalize(255, 255,   0, 255);
YellowGreen          :: #run rgb_normalize(154, 205,  50, 255);

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
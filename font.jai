prepare_font_for_sdf :: (font: *Dynamic_Font, kern := false) {
    if !font return;

    if kern {
        // prepare_for_kerning(font);  // hmmm...
    }
    #if SDF_FONTS {
        // HACK: Offset for SDF fonts. -9 works for all of them atm..
        font.font.y_offset_for_my_latin_characters = -9;
    }
}

set_font_shaders :: () {
    #if SDF_FONTS {
        shader_text.gl_handle   = get_shader_program(SHADER_TEXT_SDF);
        shader_text.alpha_blend = true;
    }
}

// // NOTE: swap_buffers adds extra frames of delay to the loading times.. meh
// // dump text to the screen as fast as possible to show while other assets are loading; before the first game frame
// show_loading_text :: (text: string) {
//     h := fonts[0].pixel_height;
//     w := prepare_text(fonts[0].font, text);
//     draw_prepared_text(fonts[0].font, window_size.x / 2 - w / 2, window_size.y - h);
//     swap_buffers(window, vsync);
// }

draw_text_shadowed :: (font: *Dynamic_Font, x: s64, y: s64, text: string, color := Vector4.{0.95, 0.95, 0.95, 1},
                       shadow_color := Vector4.{0, 0, 0, -1}, effects: Font_Effects = 0) -> width: s64
{
    w := prepare_text(font, text, effects);
    draw_prepared_text_shadowed(font, x, y, color, shadow_color, effects);
    return w;
}

draw_prepared_text_shadowed :: (font: *Dynamic_Font, x: s64, y: s64, color := Vector4.{0.95, 0.95, 0.95, 1},
                                shadow_color := Vector4.{0, 0, 0, -1}, effects: Font_Effects = 0)
{
    shadow := shadow_color;
    if shadow.w < 0 {
        shadow = BLACK;
        if color.x + color.y + color.z < 0.5 {
            shadow = WHITE;
        }
    }
    if shadow.w {
        y_offset := ifx context.simp.coordinate_system == .LEFT_HANDED then 1 else -1;
        if font.character_height > 24 y_offset *= 2;
        shadow.w = color.w;
        draw_prepared_text(font, x + 1, y + y_offset, shadow, effects);
        // draw_prepared_text(font, x + 2, y + y_offset * 2, shadow, effects);  // NOTE: To get higher offset, draw both, looks prettier?
    }
    draw_prepared_text(font, x, y, color, effects);
}


// x,y is top left of text, instead of baseline
draw_text_tl :: (font: *Dynamic_Font, x: s64, y: s64, text: string, color := Vector4.{1,1,1,1}, effects: Font_Effects = 0) -> width: s64 {
    return draw_text(font, x, y + font.character_height + font.typical_descender, text, color, effects);
}

// x,y is top left of text, instead of baseline
draw_prepared_text_tl :: (font: *Dynamic_Font, x: s64, y: s64, color := Vector4.{1,1,1,1}, effects: Font_Effects = 0) {
    draw_prepared_text(font, x, y + font.character_height + font.typical_descender, color, effects);
}

// x,y is top left of text, instead of baseline
draw_text_shadowed_tl :: (font: *Dynamic_Font, x: s64, y: s64, text: string, color := Vector4.{1,1,1,1}, shadow_color := Vector4.{0, 0, 0, -1}, effects: Font_Effects = 0) -> width: s64 {
    return draw_text_shadowed(font, x, y + font.character_height + font.typical_descender, text, color, shadow_color, effects);
}

// x,y is top left of text, instead of baseline
draw_prepared_text_shadowed_tl :: (font: *Dynamic_Font, x: s64, y: s64, color := Vector4.{1,1,1,1}, shadow_color := Vector4.{0, 0, 0, -1}, effects: Font_Effects = 0) {
    draw_prepared_text_shadowed(font, x, y + font.character_height + font.typical_descender, color, shadow_color, effects);
}

#scope_file

#import "Bucket_Array";

// TODO: https://cdn.cloudflare.steamstatic.com/apps/valve/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf
// TODO: https://www.youtube.com/watch?v=1b5hIMqz_wM&t=275s
SHADER_TEXT_SDF :: #string END
OUT_IN vec2 TextureCoords;
OUT_IN vec4 iterated_color;

#ifdef VERTEX_SHADER
in vec4 vert_position;
in vec4 vert_color;
in vec2 vert_uv0;

uniform mat4 projection;

void main() {
    gl_Position     = projection * vec4(vert_position.xy, 0.0, 1.0);
    iterated_color  = vert_color;
    TextureCoords   = vert_uv0;
}
#endif // VERTEX_SHADER

#ifdef FRAGMENT_SHADER
out vec4 color;

uniform sampler2D text_sampler;
uniform vec4 text_color;

void main () {
    float inner_smooth = 0.47;  // where the smoothing between glyph color and outline begins
    float inner_radius = 0.55;  // where the outline starts
    float outer_radius = 0.60;  // where the outline ends

    vec4 col = iterated_color;
    float texel = texture(text_sampler, TextureCoords).a;
    float signed_dist = 1.0 - texel;
    if (signed_dist >= outer_radius) {
        discard;
    }
    if (signed_dist >= inner_radius) {
        // TODO: outline color
        col.xyz = vec3(0);

        // Smooth the outline outer border [inner_radius, outer_radius] -> [1, 0]
        col.a = 1.0 - ((signed_dist - inner_radius) / (outer_radius - inner_radius));
    } else if (signed_dist >= inner_smooth) {
        // [inner_smooth, inner_radius] -> [0, 1]
        float alpha = (signed_dist - inner_smooth) / (inner_radius - inner_smooth);

        // Smooth the colored glyph's outer border against the outline
        col.xyz = mix(col.xyz, vec3(0), alpha);

        // Debug: Show smoothing as red/green gradient
        // col.xyz = mix(vec3(1,0,0), vec3(0,1,0), alpha);
    }
    color = col;
    // color = vec4(vec3(signed_dist), 1);
}
#endif // FRAGMENT_SHADER
END
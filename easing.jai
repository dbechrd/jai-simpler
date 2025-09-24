// https://easings.net/
// https://github.com/ai/easings.net/blob/master/src/easings/easingsFunctions.ts

ease_in_quad :: (t: float) -> float {
    return t * t;
}

ease_in_cubic :: (t: float) -> float {
    return t * t * t;
}

ease_in_quart :: (t: float) -> float {
    return t * t * t * t;
}

ease_in_quint :: (t: float) -> float {
    return t * t * t * t * t;
}

ease_out_quad :: (t: float) -> float {
    i := 1 - t;
    return 1 - i * i;
}

ease_out_cubic :: (t: float) -> float {
    i := 1 - t;
    return 1 - i * i * i;
}

ease_out_quart :: (t: float) -> float {
    i := 1 - t;
    return 1 - i * i * i * i;
}

ease_out_quint :: (t: float) -> float {
    i := 1 - t;
    return 1 - i * i * i * i * i;
}

ease_in_out_quad :: (t: float) -> float {
    if t < 0.5 {
        return 2 * t * t;
    } else {
        i := -2 * t + 2;
        return 1 - i * i / 2;
    }
}

ease_in_out_cubic :: (t: float) -> float {
    if t < 0.5 {
        return 4 * t * t * t;
    } else {
        i := -2 * t + 2;
        return 1 - i * i * i / 2;
    }
}

ease_in_out_quart :: (t: float) -> float {
    if t < 0.5 {
        return 8 * t * t * t * t;
    } else {
        i := -2 * t + 2;
        return 1 - i * i * i * i / 2;
    }
}

ease_in_out_quint :: (t: float) -> float {
    if t < 0.5 {
        return 16 * t * t * t * t * t;
    } else {
        i := -2 * t + 2;
        return 1 - i * i * i * i * i / 2;
    }
}

ease_out_bounce :: (t: float) -> float {
    n1 :: 7.5625;
    d1 :: 2.75;

    if t < 1 / d1 {
        return n1 * t * t;
    } else if t < 2 / d1 {
        tt := t - 1.5/d1;
        return n1 * tt * tt + 0.75;
    } else if t < 2.5 / d1 {
        tt := t - 2.25 / d1;
        return n1 * tt * tt + 0.9375;
    } else {
        tt := t - 2.625 / d1;
        return n1 * tt * tt + 0.984375;
    }
}

easing_update :: () {
    t += xx frame_dt;
    if t >= 1.2 {  // note: 1.2 to give a pause before resetting
        t = 0;
    }
}

easing_draw :: () {
    top_left := Vector2.{100, 300};
    cursor := top_left;
    for ease_func: easing_funcs {
        target_value := bar_size.y - nub_size.y;
        nub_offset := target_value * ease_func(clamp(t, 0, 1));

        // draw vertical progress bar
        // background
        draw_rect(cursor.x, cursor.y, bar_size.x, bar_size.y, color_brightness(DarkGreen, -0.4), outline_thickness=2);
        // nub
        draw_rect(cursor.x, cursor.y+bar_size.y-nub_size.y-nub_offset, nub_size.x, nub_size.y, color_brightness(YellowGreen, -0.2));

        cursor.y += bar_size.y + 10;

        // draw graph
        // background
        draw_rect(cursor.x, cursor.y, bar_size.x, bar_size.x, WhiteSmoke, outline_thickness=2);
        points := bar_size.x.(int) / 2;
        for 0..points {
            t := it / points.(float);

            // bottom left of graph
            x := cursor.x + bar_size.x * t;
            y := cursor.y + bar_size.x;

            // ease the y value
            y -= ease_func(xx t) * bar_size.x;

            // graph point
            draw_rect(x, y, 2, 2, Red, outline_thickness=1);
        }

        cursor.x += bar_size.x + 10;
        cursor.y = top_left.y;
    }
}

#scope_file

t: float;
bar_size :: Vector2.{50, 200};
nub_size :: Vector2.{50, 20};

easing_funcs :: type_of(ease_in_quad).[
    ease_in_quad,
    ease_in_cubic,
    ease_in_quart,
    ease_in_quint,
    ease_out_quad,
    ease_out_cubic,
    ease_out_quart,
    ease_out_quint,
    ease_in_out_quad,
    ease_in_out_cubic,
    ease_in_out_quart,
    ease_in_out_quint,
    ease_out_bounce,
];

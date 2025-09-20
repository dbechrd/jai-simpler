// https://easings.net/

ease_in_quad :: (x: float) -> float {
    return x * x;
}

ease_out_quad :: (x: float) -> float {
    return 1.0 - (1.0 - x) * (1.0 - x);
}

ease_in_quint :: (t: float) -> float {
    return t * t * t * t * t;
}

ease_out_quint :: (t: float) -> float {
    x := 1 - t;
    return 1 - x * x * x * x;
}

ease_out_bounce_1 :: (t: float) -> float {
    n1 :: 7.5625;
    d1 :: 2.75;

    if (t < 1 / d1) {
        return n1 * t * t;
    } else if (t < 2 / d1) {
        tt := t - 1.5/d1;
        return n1 * tt * tt + 0.75;
    } else if (t < 2.5 / d1) {
        tt := t - 2.25 / d1;
        return n1 * tt * tt + 0.9375;
    } else {
        tt := t - 2.625 / d1;
        return n1 * tt * tt + 0.984375;
    }
}

// NOTE: This one is pretty janky
ease_out_bounce_2 :: (t: float) -> float {
    d1 :: 0.8;
    d2 :: 0.9;

    if t < d1 {
        return ease_in_quint(t);
    } else if t < d2 {
        tt := (t-d1)/(d2-d1);
        return d1 + (1.0-d1) * ease_out_quint(tt);
    } else {
        tt := (t-d2)/(1.0-d2);
        return d2 + (1.0-d2) * ease_in_quint(tt);
    }
}
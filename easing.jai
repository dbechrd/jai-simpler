// https://easings.net/

ease_in_quad :: (x: float) -> float {
    return x * x;
}

ease_out_quad :: (x: float) -> float {
    return 1.0 - (1.0 - x) * (1.0 - x);
}
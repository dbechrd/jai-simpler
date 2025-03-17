point_overlaps_rect :: (p: Vector2, x: float, y: float, w: float, h: float) -> bool {
    return p.x >= x && p.x < x + w && p.y >= y && p.y < y + h;
}

mouse_overlaps_rect :: (x: float, y: float, w: float, h: float) -> bool {
    #if LEFT_HANDED {
        p := Vector2.{ mouse_position.x, mouse_position.y };
    } else {
        p := Vector2.{ mouse_position.x, window_size.y - mouse_position.y };
    }
    return point_overlaps_rect(p, x, y, w, h);
}

rect_overlaps_rect :: (ax: float, ay: float, aw: float, ah: float,
                       bx: float, by: float, bw: float, bh: float) -> bool {
    return ax + aw > bx && ay + ah > by && bx + bw > ax && by + bh > ay;
}
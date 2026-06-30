Rect :: struct {
    position: Vector2;
    size: Vector2;
}

operator+ :: (rect: Rect, offset: Vector2) -> Rect {
    result := rect;
    result.position += offset;
    return result;
}

operator- :: (rect: Rect, offset: Vector2) -> Rect {
    result := rect;
    result.position -= offset;
    return result;
}

point_overlaps_rect :: (p: Vector2, x: float, y: float, w: float, h: float) -> bool {
    return p.x >= x && p.x < x + w && p.y >= y && p.y < y + h;
}

point_overlaps_rect :: (p: Vector2, rect: Rect) -> bool {
    return point_overlaps_rect(p, rect.position.x, rect.position.y, rect.size.x, rect.size.y);
}

mouse_overlaps_rect :: (x: float, y: float, w: float, h: float) -> bool {
    if !window_focused return false;

    #if LEFT_HANDED {
        p := Vector2.{ mouse_position.x, mouse_position.y };
    } else {
        p := Vector2.{ mouse_position.x, window_size.y - mouse_position.y };
    }
    return point_overlaps_rect(p, x, y, w, h);
}

mouse_overlaps_rect :: (rect: Rect) -> bool {
    return point_overlaps_rect(mouse_position, rect.position.x, rect.position.y, rect.size.x, rect.size.y);
}

rect_overlaps_rect :: (ax: float, ay: float, aw: float, ah: float,
                       bx: float, by: float, bw: float, bh: float) -> bool {
    return ax + aw > bx && ay + ah > by && bx + bw > ax && by + bh > ay;
}

rect_overlaps_rect :: (a: Rect, b: Rect) -> bool {
    return a.position.x + a.size.w > b.position.x && ay + a.size.h > b.position.y &&
           b.position.x + b.size.w > a.position.x && by + b.size.h > a.position.y;
}

#if GET_RECT {
    mouse_overlaps_rect :: (r: GetRect.Rect) -> bool {
        if !window_focused return false;
        return mouse_overlaps_rect(r.x, r.y, r.w, r.h);
    }

    rect_union :: (r0: GetRect.Rect, r1: GetRect.Rect) -> GetRect.Rect {
        x := min(r0.x, r1.x);
        y := min(r0.y, r1.y);
        w := max(r0.x + r0.w, r1.x + r1.w) - x;
        h := max(r0.y + r0.h, r1.y + r1.h) - y;
        r := GetRect.Rect.{ x, y, w, h };
        return r;
    }
}

#scope_file

#if GET_RECT {
    using GetRect :: #import "GetRect_LeftHanded";
}
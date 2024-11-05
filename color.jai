BLACK   :: Vector4.{ 0, 0, 0, 1 };
BLUE    :: Vector4.{ 0, 0, 1, 1 };
GREEN   :: Vector4.{ 0, 1, 0, 1 };
CYAN    :: Vector4.{ 0, 1, 1, 1 };
RED     :: Vector4.{ 1, 0, 0, 1 };
MAGENTA :: Vector4.{ 1, 0, 1, 1 };
YELLOW  :: Vector4.{ 1, 1, 0, 1 };
WHITE   :: Vector4.{ 1, 1, 1, 1 };

color_brightness :: (v: Vector4, s: float) -> Vector4 {
    return Vector4.{
        v.x * s,
        v.y * s,
        v.z * s,
        v.w
    };
}
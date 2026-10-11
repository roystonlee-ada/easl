import CoreGraphics

/// The board's scroll origin on whole device pixels. On a 1x screen a view between pixels is
/// resampled, which blurs a terminal's text; snapping keeps it sharp. The exact origin is kept
/// beside the shown one, so pans in steps smaller than a pixel (a slow trackpad) still add up.
public struct PixelSnap: Sendable {
    /// Where the origin would be without snapping.
    public private(set) var exact: CGPoint?

    public init() {}

    /// `point` on the nearest whole pixel, at `pixels` device pixels per unit.
    public static func snapped(_ point: CGPoint, pixels: CGFloat) -> CGPoint {
        guard pixels > 0 else { return point }
        return CGPoint(x: (point.x * pixels).rounded() / pixels, y: (point.y * pixels).rounded() / pixels)
    }

    /// The origin to show for a move from `current` (what is shown now) to `proposed`. A step from
    /// where the snapped exact origin is shown carries on from the exact origin; anything else (a
    /// zoom, a jump) starts over from `proposed`.
    public mutating func origin(proposed: CGPoint, current: CGPoint, pixels: CGFloat) -> CGPoint {
        var target = proposed
        if let exact, Self.snapped(exact, pixels: pixels) == current {
            target = CGPoint(x: exact.x + proposed.x - current.x, y: exact.y + proposed.y - current.y)
        }
        exact = target
        return Self.snapped(target, pixels: pixels)
    }
}

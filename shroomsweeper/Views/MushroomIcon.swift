import SwiftUI

struct MushroomIcon: View {
    var showSpots: Bool = true

    @Environment(\.palette) private var palette

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let scale = size / 24.0
            ZStack {
                // Stem
                RoundedRectangle(cornerRadius: 2.6 * scale, style: .continuous)
                    .fill(palette.mushroomStem)
                    .frame(width: 5.6 * scale, height: 8 * scale)
                    .offset(x: (12 - 12) * scale, y: (16.5 - 12) * scale)
                // Cap
                MushroomCapShape()
                    .fill(palette.mushroomCap)
                    .frame(width: 19 * scale, height: 10 * scale)
                    .offset(x: 0, y: (8 - 12) * scale)
                if showSpots {
                    Ellipse()
                        .fill(palette.mushroomSpot)
                        .frame(width: 3.4 * scale, height: 2.6 * scale)
                        .offset(x: (9 - 12) * scale, y: (9.4 - 12) * scale)
                    Ellipse()
                        .fill(palette.mushroomSpot)
                        .frame(width: 2.4 * scale, height: 2 * scale)
                        .offset(x: (14.6 - 12) * scale, y: (8.2 - 12) * scale)
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

private struct MushroomCapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Original viewBox path: M2.5 13 C2.5 6.5 7 3 12 3 C17 3 21.5 6.5 21.5 13 Z
        // Scaled into rect (which represents the cap's bounding box 19w × 10h centered).
        let w = rect.width
        let h = rect.height
        let left = rect.minX
        let top = rect.minY
        let bottom = rect.maxY
        p.move(to: CGPoint(x: left, y: bottom))
        p.addCurve(
            to: CGPoint(x: left + w * 0.5, y: top),
            control1: CGPoint(x: left, y: top + h * 0.35),
            control2: CGPoint(x: left + w * 0.235, y: top)
        )
        p.addCurve(
            to: CGPoint(x: left + w, y: bottom),
            control1: CGPoint(x: left + w * 0.765, y: top),
            control2: CGPoint(x: left + w, y: top + h * 0.35)
        )
        p.closeSubpath()
        return p
    }
}

struct FlagIcon: View {
    @Environment(\.palette) private var palette

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let scale = size / 24.0
            ZStack {
                // Post
                RoundedRectangle(cornerRadius: 1.1 * scale, style: .continuous)
                    .fill(palette.markerPost)
                    .frame(width: 2.2 * scale, height: 9.6 * scale)
                    .offset(x: 0, y: (15.3 - 12) * scale)
                // Sign
                FlagSignShape()
                    .fill(palette.markerSign)
                    .frame(width: 16 * scale, height: 12.5 * scale)
                    .offset(x: 0, y: (9.25 - 12) * scale)
                // Caution stripe (small rect)
                RoundedRectangle(cornerRadius: 0.8 * scale, style: .continuous)
                    .fill(palette.markerInk)
                    .frame(width: 1.6 * scale, height: 3.4 * scale)
                    .offset(x: 0, y: (9.3 - 12) * scale)
                // Caution dot
                Circle()
                    .fill(palette.markerInk)
                    .frame(width: 1.9 * scale, height: 1.9 * scale)
                    .offset(x: 0, y: (13.2 - 12) * scale)
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

private struct FlagSignShape: Shape {
    // Pennant-style sign approximating M12 3 L20 14 Q20.9 15.5 19.1 15.5 L4.9 15.5 Q3.1 15.5 4 14 Z
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let rightOuter = CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.12)
        let rightCorner = CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.maxY)
        let leftCorner = CGPoint(x: rect.minX + rect.width * 0.06, y: rect.maxY)
        let leftOuter = CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.12)
        p.move(to: top)
        p.addLine(to: rightOuter)
        p.addQuadCurve(
            to: rightCorner,
            control: CGPoint(x: rect.maxX + rect.width * 0.06, y: rect.maxY)
        )
        p.addLine(to: leftCorner)
        p.addQuadCurve(
            to: leftOuter,
            control: CGPoint(x: rect.minX - rect.width * 0.06, y: rect.maxY)
        )
        p.closeSubpath()
        return p
    }
}

struct EmptyShroomIcon: View {
    @Environment(\.palette) private var palette

    var body: some View {
        MushroomCapAndStemSilhouette()
            .fill(palette.emptyMark)
            .opacity(0.5)
    }
}

private struct MushroomCapAndStemSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let capLeft = rect.minX + w * 0.10
        let capRight = rect.maxX - w * 0.10
        let capTop = rect.minY + h * 0.18
        let capBottom = rect.minY + h * 0.62
        let stemLeft = rect.minX + w * 0.36
        let stemRight = rect.maxX - w * 0.36
        let stemBottom = rect.maxY - h * 0.05
        p.move(to: CGPoint(x: capLeft, y: capBottom))
        p.addCurve(
            to: CGPoint(x: (capLeft + capRight) / 2, y: capTop),
            control1: CGPoint(x: capLeft, y: capTop + (capBottom - capTop) * 0.2),
            control2: CGPoint(x: capLeft + (capRight - capLeft) * 0.22, y: capTop)
        )
        p.addCurve(
            to: CGPoint(x: capRight, y: capBottom),
            control1: CGPoint(x: capRight - (capRight - capLeft) * 0.22, y: capTop),
            control2: CGPoint(x: capRight, y: capTop + (capBottom - capTop) * 0.2)
        )
        p.addLine(to: CGPoint(x: stemRight, y: capBottom))
        p.addLine(to: CGPoint(x: stemRight, y: stemBottom))
        p.addLine(to: CGPoint(x: stemLeft, y: stemBottom))
        p.addLine(to: CGPoint(x: stemLeft, y: capBottom))
        p.closeSubpath()
        return p
    }
}

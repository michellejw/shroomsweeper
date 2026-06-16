import ShroomKit
import SwiftUI

struct CellView: View {
    let cell: Cell
    let cols: Int
    var highlight: Bool = false
    let onTap: () -> Void
    let onLongPress: () -> Void

    @Environment(\.palette) private var palette
    @State private var pulse: Bool = false
    @State private var didLongPress: Bool = false

    private var cornerRadius: CGFloat {
        cols <= 9 ? 9 : (cols <= 12 ? 8 : 7)
    }

    private var numberFont: Font {
        let size: CGFloat = cols <= 9 ? 18 : (cols <= 12 ? 15 : 13)
        return .system(size: size, weight: .semibold, design: .rounded)
    }

    private var background: Color {
        if cell.isRevealed {
            if cell.isMine && cell.isExploded { return palette.explodeBg }
            return palette.tileRevealed
        }
        return cell.isFlagged ? palette.tileCoveredHi : palette.tileCovered
    }

    var body: some View {
        Button {
            if didLongPress {
                didLongPress = false
                return
            }
            onTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(edgeColor, lineWidth: cell.isRevealed ? 1 : 0)
                    )
                    .shadow(color: cell.isRevealed ? .clear : palette.tileCoveredEdge,
                            radius: 0, x: 0, y: cell.isRevealed ? 0 : 2)
                content
                    .padding(cellPadding)
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(highlight ? palette.accent : .clear, lineWidth: 3)
                    .padding(-2)
            )
            .scaleEffect(highlight && pulse ? 1.06 : 1.0)
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Rectangle())
        }
        .buttonStyle(CellPressStyle(isCovered: !cell.isRevealed))
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.33).onEnded { _ in
                didLongPress = true
                onLongPress()
            }
        )
        .onAppear {
            if highlight { startPulse() }
        }
        .onChange(of: highlight) { _, newValue in
            if newValue { startPulse() } else { pulse = false }
        }
    }

    private func startPulse() {
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }

    private var edgeColor: Color {
        cell.isRevealed ? palette.tileRevealedEdge : .clear
    }

    private var cellPadding: CGFloat {
        cols <= 9 ? 6 : (cols <= 12 ? 5 : 4)
    }

    @ViewBuilder
    private var content: some View {
        if cell.isRevealed {
            if cell.isMine {
                MushroomIcon()
                    .transition(.scale.combined(with: .opacity))
            } else if cell.neighborMines > 0 {
                Text("\(cell.neighborMines)")
                    .font(numberFont)
                    .foregroundStyle(palette.numberColors[cell.neighborMines])
                    .transition(.scale.combined(with: .opacity))
            } else {
                Color.clear
            }
        } else if cell.isFlagged {
            FlagIcon()
                .transition(.scale.combined(with: .opacity))
        } else {
            Color.clear
        }
    }
}

private struct CellPressStyle: ButtonStyle {
    let isCovered: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && isCovered ? 0.92 : 1)
            .brightness(configuration.isPressed && isCovered ? -0.03 : 0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

import ShroomKit
import SwiftUI

struct ResultBar: View {
    let won: Bool
    let savedConfirmation: Bool
    let timeText: String
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @Environment(\.palette) private var palette

    private var title: String {
        if savedConfirmation { return "Saved!" }
        return won ? "Basket full!" : "Poisonous!"
    }

    private var subtitle: String {
        if savedConfirmation { return "You're on the board." }
        return won ? "Cleared in \(timeText)" : "Better luck next time."
    }

    var body: some View {
        ResultCard(
            title: title,
            subtitle: subtitle,
            primaryLabel: won ? "Play again" : "Try again", onPrimary: onPlayAgain,
            secondaryLabel: "Menu", onSecondary: onMenu
        ) {
            MushroomIcon()
                .frame(width: 28, height: 28)
                .padding(9)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(palette.tierBg)
                )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

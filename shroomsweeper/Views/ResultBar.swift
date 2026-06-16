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
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MushroomIcon()
                    .frame(width: 28, height: 28)
                    .padding(9)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.tierBg)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(palette.text)
                    Text(subtitle)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(palette.sub)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 10) {
                Button(action: onMenu) {
                    Text("Menu")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(palette.text)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(palette.tierBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(palette.tierBorder, lineWidth: 1)
                                )
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: onPlayAgain) {
                    Text(won ? "Play again" : "Try again")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(palette.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(palette.accent)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.pill)
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

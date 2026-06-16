import ShroomKit
import SwiftUI

struct WelcomeView: View {
    let appearance: Appearance
    let onToggleAppearance: () -> Void
    let onStartTutorial: () -> Void
    let onSkipTutorial: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        WelcomeScaffold(
            title: "Welcome to Shroomsweeper",
            tagline: "A cozy minesweeper for mushroom foragers. Want a quick tour before you head out?",
            onPrimary: onStartTutorial,
            onSecondary: onSkipTutorial
        ) {
            MushroomIcon()
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onToggleAppearance) {
                Image(systemName: appearance == .forest ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.sub)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(palette.pill))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
}

import ShroomKit
import SwiftUI

struct WelcomeView: View {
    let themeMode: ThemeMode
    let onCycleTheme: () -> Void
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
            PillIconButton(systemName: themeMode.iconName, accessibilityLabel: "Theme", shape: .circle, action: onCycleTheme)
                .padding(.horizontal, 24)
                .padding(.top, 16)
        }
    }
}

import ShroomKit
import SwiftUI

struct HomeView: View {
    let selectedDifficulty: Difficulty
    let themeMode: ThemeMode
    let onCycleTheme: () -> Void
    let onPickDifficulty: () -> Void
    let onPlay: () -> Void
    let onOpenBestTimes: () -> Void
    let onOpenTutorial: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 38) {
            HStack {
                Spacer()
                Button(action: onCycleTheme) {
                    Image(systemName: themeIconName(for: themeMode))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.sub)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(palette.pill))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
            VStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(palette.pill)
                    .frame(width: 90, height: 90)
                    .overlay(MushroomIcon().frame(width: 52, height: 52))
                Text("Shroomsweeper")
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.text)
                Text("A cozy minesweeper for mushroom foragers.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }
            VStack(spacing: 11) {
                Button(action: onPickDifficulty) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            EyebrowLabel("Difficulty")
                            Text(selectedDifficulty.label)
                                .font(.system(.title3, design: .rounded).weight(.semibold))
                                .foregroundStyle(palette.text)
                            Text(selectedDifficulty.sizeDescription)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(palette.sub)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(palette.sub)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(palette.pill)
                    )
                }
                .buttonStyle(.plain)

                Button(action: onPlay) {
                    Text("Play")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.accentText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(palette.accent)
                        )
                }
                .buttonStyle(.plain)

                HStack(spacing: 6) {
                    Button(action: onOpenBestTimes) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                            Text("Best times")
                        }
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.sub)
                        .padding(.horizontal, 10)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button(action: onOpenTutorial) {
                        HStack(spacing: 8) {
                            Image(systemName: "questionmark.circle")
                            Text("How to play")
                        }
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.sub)
                        .padding(.horizontal, 10)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.appBg.ignoresSafeArea())
    }
}

/// Pick a glyph that represents the current theme mode in the quick toggle.
func themeIconName(for mode: ThemeMode) -> String {
    switch mode {
    case .system:   return "circle.lefthalf.filled"
    case .forest:   return "sun.max.fill"
    case .twilight: return "moon.fill"
    }
}

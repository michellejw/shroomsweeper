import SwiftUI

struct WelcomeView: View {
    let appearance: Appearance
    let onToggleAppearance: () -> Void
    let onStartTutorial: () -> Void
    let onSkipTutorial: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 38) {
            HStack {
                Spacer()
                Button(action: onToggleAppearance) {
                    Image(systemName: appearance == .forest ? "moon.fill" : "sun.max.fill")
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
                Text("Welcome to Shroomsweeper")
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.text)
                    .multilineTextAlignment(.center)
                Text("A cozy minesweeper for mushroom foragers. Want a quick tour before you head out?")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 290)
                    .lineSpacing(2)
            }
            VStack(spacing: 11) {
                Button(action: onStartTutorial) {
                    Text("Show me how to play")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(palette.accentText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(palette.accent)
                        )
                }
                .buttonStyle(.plain)

                Button(action: onSkipTutorial) {
                    Text("Jump right in")
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(palette.pill)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.appBg.ignoresSafeArea())
    }
}

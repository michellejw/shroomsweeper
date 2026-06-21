import ShroomKit
import SwiftUI

struct TutorialView: View {
    @Bindable var flow: TutorialFlow
    let onFinish: () -> Void
    let onSkip: () -> Void

    @Environment(\.palette) private var palette
    @State private var flagPulse: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            tutorialBanner
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 14)
            ZStack(alignment: .top) {
                BoardView(
                    game: flow.game,
                    highlightedCells: flow.highlightedCells,
                    onTap: { idx in
                        withAnimation(.easeOut(duration: 0.14)) {
                            flow.handleTap(at: idx)
                        }
                    },
                    onLongPress: { idx in
                        withAnimation(.easeOut(duration: 0.14)) {
                            flow.handleLongPress(at: idx)
                        }
                    }
                )
                if let msg = flow.nudgeMessage {
                    NudgeToast(msg)
                        .padding(.top, 8)
                        .padding(.horizontal, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .animation(.easeOut(duration: 0.2), value: flow.nudgeMessage)
            Spacer(minLength: 16)
            modeToggle
                .padding(.horizontal, 16)
            hint
                .padding(.top, 13)
            Spacer(minLength: 0)
        }
        .background(palette.appBg.ignoresSafeArea())
        .onChange(of: flow.highlightFlagButton) { _, newValue in
            if newValue { startFlagPulse() } else { flagPulse = false }
        }
        .onAppear {
            if flow.highlightFlagButton { startFlagPulse() }
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: flow.game.flagToggleTick)
        .sensoryFeedback(.success, trigger: flow.game.winTick)
    }

    private func startFlagPulse() {
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            flagPulse = true
        }
    }

    // MARK: - Banner

    private var tutorialBanner: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                EyebrowLabel(flow.stepLabel, tint: .accent)
                Spacer()
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.sub)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Text(flow.title)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(palette.text)
                .padding(.top, 2)
            Text(flow.body)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(palette.sub)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            if flow.showNextButton {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        flow.advance()
                    }
                } label: {
                    Text("Got it")
                }
                .buttonStyle(.shroomPrimary)
                .padding(.top, 10)
            }
            if flow.showDoneButton {
                Button("Start foraging", action: onFinish)
                    .buttonStyle(.shroomPrimary)
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.pill)
        )
    }

    // MARK: - Mode toggle

    private var modeToggle: some View {
        HStack(spacing: 10) {
            modeButton(
                title: "Forage",
                isActive: flow.game.mode == .forage,
                icon: nil,
                highlight: false,
                action: { flow.game.mode = .forage }
            )
            modeButton(
                title: "Flag",
                isActive: flow.game.mode == .flag,
                icon: { AnyView(FlagIcon().frame(width: 20, height: 20)) },
                highlight: flow.highlightFlagButton,
                action: { flow.game.mode = .flag }
            )
        }
    }

    private func modeButton(
        title: String,
        isActive: Bool,
        icon: (() -> AnyView)?,
        highlight: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon?()
                Text(title)
                    .font(.system(.headline, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .foregroundStyle(isActive ? palette.accentText : palette.sub)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isActive ? palette.accent : palette.pill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(highlight ? palette.accent : .clear, lineWidth: 3)
                    .padding(-3)
            )
            .scaleEffect(highlight && flagPulse ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var hint: some View {
        Text("Tap to forage · long-press to flag")
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(palette.sub)
    }
}

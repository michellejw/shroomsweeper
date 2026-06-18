import ShroomKit
import SwiftUI

struct GameView: View {
    @Bindable var game: Game
    let scoreStore: ScoreStore
    let onGoHome: () -> Void
    let onChangeDifficulty: () -> Void
    let onSave: () -> Void
    let onClearSave: () -> Void
    let themeMode: ThemeMode
    let onCycleTheme: () -> Void
    var screenshotAutoShowsWinEntry: Bool = false

    @Environment(\.palette) private var palette
    @Environment(\.scenePhase) private var scenePhase

    // Win flow state — local to a single playthrough.
    @State private var resultRevealed: Bool = false
    @State private var initials: String = ""
    @State private var scoreSaved: Bool = false
    @State private var entrySkipped: Bool = false
    @State private var showingWinEntry: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            titleRow
                .padding(.top, 6)
                .padding(.bottom, 12)
            statsRow
                .padding(.bottom, 14)
            BoardView(
                game: game,
                onTap: { idx in
                    withAnimation(.easeOut(duration: 0.14)) {
                        game.tap(at: idx)
                    }
                    onSave()
                },
                onLongPress: { idx in
                    withAnimation(.easeOut(duration: 0.14)) {
                        game.toggleFlag(at: idx)
                    }
                    onSave()
                }
            )
            Spacer(minLength: 16)
            modeArea
                .animation(.spring(response: 0.36, dampingFraction: 0.85), value: resultRevealed)
                .animation(.spring(response: 0.36, dampingFraction: 0.85), value: scoreSaved)
                .animation(.spring(response: 0.36, dampingFraction: 0.85), value: entrySkipped)
            hint
                .padding(.top, 13)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .background(palette.appBg.ignoresSafeArea())
        .task(id: ObjectIdentifier(game)) {
            guard !ScreenshotMode.isActive else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                game.tick()
            }
        }
        .onAppear {
            if screenshotAutoShowsWinEntry {
                resultRevealed = true
                showingWinEntry = true
            }
        }
        .onChange(of: game.status) { _, newStatus in
            guard newStatus.isFinished else {
                resultRevealed = false
                showingWinEntry = false
                return
            }
            onClearSave()
            Task {
                try? await Task.sleep(for: .milliseconds(750))
                resultRevealed = true
                if newStatus == .won,
                   let diff = game.difficulty,
                   scoreStore.qualifies(seconds: game.elapsedSeconds, for: diff) {
                    showingWinEntry = true
                }
            }
        }
        .onChange(of: game.winTick) { _, _ in
            // Reset entry state for the new win
            initials = ""
            scoreSaved = false
            entrySkipped = false
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: game.flagToggleTick)
        .sensoryFeedback(.success, trigger: game.winTick)
        .sensoryFeedback(.error, trigger: game.loseTick)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background || phase == .inactive {
                onSave()
            }
        }
        .sheet(isPresented: $showingWinEntry) {
            WinEntrySheet(
                timeText: game.elapsedSeconds.asTimerString,
                isRecord: bestTimeBefore.map { game.elapsedSeconds < $0 } ?? true,
                initials: $initials,
                onSave: saveScore,
                onSkip: skipEntry
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(false)
        }
    }

    private var titleRow: some View {
        HStack {
            Button(action: onChangeDifficulty) {
                HStack(spacing: 6) {
                    MushroomIcon().frame(width: 18, height: 18)
                    Text(game.difficulty?.label ?? "")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.text)
                    Text(game.difficulty?.shortSize ?? "")
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(palette.sub)
                    Image(systemName: "chevron.down")
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.sub)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(palette.pill)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onCycleTheme) {
                Image(systemName: themeIconName(for: themeMode))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.sub)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.pill)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onGoHome) {
                Image(systemName: "house.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.sub)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.pill)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var statsRow: some View {
        HStack {
            statPill(icon: { AnyView(MushroomIcon().frame(width: 20, height: 20)) },
                     text: "\(game.flagsRemaining)")
            Spacer()
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    game.reset()
                    resultRevealed = false
                    scoreSaved = false
                    entrySkipped = false
                    initials = ""
                }
                onClearSave()
            } label: {
                MushroomIcon()
                    .frame(width: 30, height: 30)
                    .padding(10)
                    .background(
                        Circle().fill(palette.pill)
                            .overlay(Circle().stroke(palette.tierBorder, lineWidth: 3))
                    )
            }
            .buttonStyle(.plain)
            Spacer()
            statPill(icon: {
                AnyView(
                    Image(systemName: "timer")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.sub)
                )
            }, text: game.elapsedSeconds.asTimerString)
        }
    }

    private func statPill(icon: () -> AnyView, text: String) -> some View {
        HStack(spacing: 7) {
            icon()
            Text(text)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(palette.text)
                .monospacedDigit()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 9)
        .frame(minWidth: 76)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.pill)
        )
    }

    // MARK: - Mode/Result area

    private var showResult: Bool {
        game.status.isFinished && resultRevealed
    }

    private var qualifiesForBoard: Bool {
        guard game.status == .won, let diff = game.difficulty else { return false }
        return scoreStore.qualifies(seconds: game.elapsedSeconds, for: diff)
    }

    @ViewBuilder
    private var modeArea: some View {
        if showResult {
            ResultBar(
                won: game.status == .won,
                savedConfirmation: scoreSaved,
                timeText: game.elapsedSeconds.asTimerString,
                onPlayAgain: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        game.reset()
                        resultRevealed = false
                        scoreSaved = false
                        entrySkipped = false
                        initials = ""
                    }
                },
                onMenu: onGoHome
            )
            .frame(minHeight: 54)
        } else {
            modeToggle
                .frame(minHeight: 54)
        }
    }

    private var bestTimeBefore: Int? {
        guard let diff = game.difficulty else { return nil }
        return scoreStore.best(for: diff).first?.seconds
    }

    private func saveScore() {
        guard let diff = game.difficulty else { return }
        scoreStore.save(initials: initials.isEmpty ? "YOU" : initials,
                        seconds: game.elapsedSeconds,
                        for: diff)
        scoreSaved = true
        showingWinEntry = false
    }

    private func skipEntry() {
        entrySkipped = true
        showingWinEntry = false
    }

    private var modeToggle: some View {
        HStack(spacing: 10) {
            modeButton(
                title: "Forage",
                isActive: game.mode == .forage,
                icon: nil,
                action: { game.mode = .forage }
            )
            modeButton(
                title: "Flag",
                isActive: game.mode == .flag,
                icon: { AnyView(FlagIcon().frame(width: 20, height: 20)) },
                action: { game.mode = .flag }
            )
        }
    }

    private func modeButton(
        title: String,
        isActive: Bool,
        icon: (() -> AnyView)?,
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
        }
        .buttonStyle(.plain)
    }

    private var hint: some View {
        Text("Tap to forage · long-press to flag")
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(palette.sub)
    }
}

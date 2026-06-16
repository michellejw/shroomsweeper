import SwiftUI

enum Screen {
    case launching
    case welcome
    case home
    case preparing
    case game
    case tutorial
}

@Observable
final class AppState {
    private static let tutorialSeenKey = "shroom_tutorial_seen_v1"

    var screen: Screen = .launching
    var appearance: Appearance = .forest
    var selectedDifficulty: Difficulty = .forager
    var activeGame: Game = Game(difficulty: .forager)
    var tutorialFlow: TutorialFlow? = nil
    let scoreStore: ScoreStore = ScoreStore()

    var isSheetPresented: Bool = false
    var sheetTab: SheetTab = .patch

    var preparingMessage: String = "Prepping the patch"

    var hasSeenTutorial: Bool {
        UserDefaults.standard.bool(forKey: Self.tutorialSeenKey)
    }

    func finishLaunch() {
        if hasSeenTutorial {
            screen = .home
        } else {
            screen = .welcome
        }
    }

    func skipWelcome() {
        UserDefaults.standard.set(true, forKey: Self.tutorialSeenKey)
        screen = .home
    }

    func startGame(difficulty: Difficulty) {
        selectedDifficulty = difficulty
        preparingMessage = "Prepping the patch"
        screen = .preparing
        Task { @MainActor in
            activeGame = Game(difficulty: difficulty)
            try? await Task.sleep(for: .milliseconds(1200))
            screen = .game
        }
    }

    func goHome() {
        screen = .home
    }

    func openSheet(tab: SheetTab) {
        sheetTab = tab
        isSheetPresented = true
    }

    func startTutorial() {
        preparingMessage = "Setting up your tour"
        screen = .preparing
        Task { @MainActor in
            tutorialFlow = TutorialFlow()
            try? await Task.sleep(for: .milliseconds(1200))
            screen = .tutorial
        }
    }

    func finishTutorial() {
        UserDefaults.standard.set(true, forKey: Self.tutorialSeenKey)
        tutorialFlow = nil
        screen = .home
    }
}

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        let palette = Palette.palette(for: appState.appearance)
        ZStack {
            palette.appBg.ignoresSafeArea()
            switch appState.screen {
            case .launching:
                LoadingView(message: "Loading")
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .milliseconds(700))
                        appState.finishLaunch()
                    }
            case .welcome:
                WelcomeView(
                    appearance: appState.appearance,
                    onToggleAppearance: toggleAppearance,
                    onStartTutorial: { appState.startTutorial() },
                    onSkipTutorial: { appState.skipWelcome() }
                )
                .transition(.opacity)
            case .home:
                HomeView(
                    selectedDifficulty: appState.selectedDifficulty,
                    appearance: appState.appearance,
                    onToggleAppearance: toggleAppearance,
                    onPickDifficulty: { appState.openSheet(tab: .patch) },
                    onPlay: { appState.startGame(difficulty: appState.selectedDifficulty) },
                    onOpenBestTimes: { appState.openSheet(tab: .scores) },
                    onOpenTutorial: { appState.startTutorial() }
                )
                .transition(.opacity)
            case .preparing:
                LoadingView(message: appState.preparingMessage)
                    .transition(.opacity)
            case .game:
                GameView(
                    game: appState.activeGame,
                    scoreStore: appState.scoreStore,
                    onGoHome: appState.goHome,
                    onChangeDifficulty: { appState.openSheet(tab: .patch) }
                )
                .transition(.opacity)
            case .tutorial:
                if let flow = appState.tutorialFlow {
                    TutorialView(
                        flow: flow,
                        onFinish: { appState.finishTutorial() },
                        onSkip: { appState.finishTutorial() }
                    )
                    .transition(.opacity)
                }
            }
        }
        .environment(\.palette, palette)
        .animation(.easeInOut(duration: 0.25), value: appState.screen)
        .animation(.easeInOut(duration: 0.2), value: appState.appearance)
        .sheet(isPresented: $appState.isSheetPresented) {
            OptionsSheet(
                tab: $appState.sheetTab,
                selectedDifficulty: $appState.selectedDifficulty,
                scoreStore: appState.scoreStore,
                isInGame: appState.screen == .game,
                onConfirm: {
                    appState.isSheetPresented = false
                    appState.startGame(difficulty: appState.selectedDifficulty)
                },
                onClose: {
                    appState.isSheetPresented = false
                }
            )
            .environment(\.palette, palette)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private func toggleAppearance() {
        appState.appearance = appState.appearance == .forest ? .twilight : .forest
    }
}

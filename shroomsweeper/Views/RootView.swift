import ShroomKit
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
    private static let themeModeKey = "shroom_theme_mode_v1"

    var screen: Screen = .launching
    var themeMode: ThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: Self.themeModeKey) }
    }
    var selectedDifficulty: Difficulty = .forager
    var activeGame: Game = Game(difficulty: .forager)
    var tutorialFlow: TutorialFlow? = nil
    let scoreStore: ScoreStore = ScoreStore()
    let gameStore: GameStore = GameStore()

    var isSheetPresented: Bool = false
    var sheetTab: SheetTab = .patch

    var preparingMessage: String = "Prepping the patch"

    var screenshotAutoShowsWinEntry: Bool = false

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.themeModeKey)
        self.themeMode = saved.flatMap(ThemeMode.init(rawValue:)) ?? .system
        if ScreenshotMode.isActive {
            applyScreenshotMode()
        }
    }

    private func applyScreenshotMode() {
        themeMode = ScreenshotMode.appearance == .twilight ? .twilight : .forest
        scoreStore.applyScreenshotSeed()
        UserDefaults.standard.set(true, forKey: Self.tutorialSeenKey)

        switch ScreenshotMode.target {
        case .home:
            screen = .home
        case .game:
            activeGame = Game.screenshotForageBoard()
            screen = .game
        case .tutorial:
            let flow = TutorialFlow()
            flow.applyScreenshotSeed()
            tutorialFlow = flow
            screen = .tutorial
        case .win:
            activeGame = Game.screenshotWonBoard()
            screenshotAutoShowsWinEntry = true
            screen = .game
        case .scores:
            screen = .home
            sheetTab = .scores
            isSheetPresented = true
        }
    }

    var hasSeenTutorial: Bool {
        UserDefaults.standard.bool(forKey: Self.tutorialSeenKey)
    }

    func finishLaunch() {
        // Resume an in-progress game if one was saved.
        if let snapshot = gameStore.load(),
           let restored = Game(restoring: snapshot) {
            activeGame = restored
            selectedDifficulty = snapshot.difficulty
            screen = .game
            return
        }
        if hasSeenTutorial {
            screen = .home
        } else {
            screen = .welcome
        }
    }

    func saveGame() {
        guard let snapshot = activeGame.snapshot() else { return }
        gameStore.save(snapshot)
    }

    func clearSavedGame() {
        gameStore.clear()
    }

    /// Quick toggle: a 2-state light/dark flip (Forest ↔ Twilight).
    func cycleThemeMode() {
        themeMode = (themeMode == .twilight) ? .forest : .twilight
    }

    func skipWelcome() {
        UserDefaults.standard.set(true, forKey: Self.tutorialSeenKey)
        screen = .home
    }

    func startGame(difficulty: Difficulty) {
        selectedDifficulty = difficulty
        preparingMessage = "Prepping the patch"
        clearSavedGame()
        screen = .preparing
        Task { @MainActor in
            activeGame = Game(difficulty: difficulty)
            try? await Task.sleep(for: .milliseconds(1200))
            screen = .game
        }
    }

    func goHome() {
        if activeGame.status.isFinished { clearSavedGame() }
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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = Palette.palette(for: colorScheme)
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
                    themeMode: appState.themeMode,
                    onCycleTheme: { appState.cycleThemeMode() },
                    onStartTutorial: { appState.startTutorial() },
                    onSkipTutorial: { appState.skipWelcome() }
                )
                .transition(.opacity)
            case .home:
                HomeView(
                    selectedDifficulty: appState.selectedDifficulty,
                    themeMode: appState.themeMode,
                    onCycleTheme: { appState.cycleThemeMode() },
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
                    onChangeDifficulty: { appState.openSheet(tab: .patch) },
                    onSave: { appState.saveGame() },
                    onClearSave: { appState.clearSavedGame() },
                    themeMode: appState.themeMode,
                    onCycleTheme: { appState.cycleThemeMode() },
                    screenshotAutoShowsWinEntry: appState.screenshotAutoShowsWinEntry
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
        .preferredColorScheme(appState.themeMode.preferredColorScheme)
        .animation(.easeInOut(duration: 0.25), value: appState.screen)
        .animation(.easeInOut(duration: 0.2), value: appState.themeMode)
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
}

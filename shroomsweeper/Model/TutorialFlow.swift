import Foundation

@Observable
final class TutorialFlow {
    enum Step: Int {
        case forage     // tap to forage
        case numbers    // mind the numbers
        case flag       // flag the mushroom
        case clear      // fill your basket
        case done       // basket full
    }

    static let rows = 6
    static let cols = 6
    static let mineIndices: Set<Int> = [5, 8, 14, 15, 22, 23]
    static let startTile = 0
    static let oneTile = 19
    static let flagTile = 14

    private(set) var step: Step = .forage
    private(set) var nudgeMessage: String? = nil
    let game: Game

    private var nudgeTask: Task<Void, Never>?

    init() {
        self.game = Game(
            rows: TutorialFlow.rows,
            cols: TutorialFlow.cols,
            mineCount: TutorialFlow.mineIndices.count,
            preplacedMines: TutorialFlow.mineIndices,
            isTutorial: true
        )
    }

    deinit {
        nudgeTask?.cancel()
    }

    // MARK: - Banner content

    var stepLabel: String {
        switch step {
        case .forage:   return "STEP 1 OF 4"
        case .numbers:  return "STEP 2 OF 4"
        case .flag:     return "STEP 3 OF 4"
        case .clear:    return "STEP 4 OF 4"
        case .done:     return "NICE WORK"
        }
    }

    var title: String {
        switch step {
        case .forage:  return "Tap to forage"
        case .numbers: return "Mind the numbers"
        case .flag:    return "Flag the mushroom"
        case .clear:   return "Fill your basket"
        case .done:    return "Basket full!"
        }
    }

    var body: String {
        switch step {
        case .forage:
            return "Tap the highlighted tile to uncover it — your very first dig is always safe."
        case .numbers:
            return "A number counts the poisonous mushrooms touching that tile — the highlighted 1 means exactly one is hiding beside it. Tap \"Got it\" to continue."
        case .flag:
            if game.mode != .flag {
                return "That 1 only touches one covered tile, so we know exactly what is there. First, tap Flag below to switch modes."
            } else {
                return "Now tap the highlighted tile to stake a caution marker right on it."
            }
        case .clear:
            return "Now forage the rest of the highlighted tiles to clear the patch — and leave that flagged mushroom be!"
        case .done:
            return "You cleared the whole patch — that's a win. You're ready to forage for real."
        }
    }

    var showNextButton: Bool { step == .numbers }
    var showDoneButton: Bool { step == .done }

    // MARK: - Highlight cues

    var highlightedCells: Set<Int> {
        switch step {
        case .forage:
            return [TutorialFlow.startTile]
        case .numbers:
            return [TutorialFlow.oneTile]
        case .flag:
            return game.mode == .flag ? [TutorialFlow.flagTile] : []
        case .clear:
            return Set(game.cells.compactMap { c in
                (!c.isRevealed && !c.isMine && !c.isFlagged) ? c.id : nil
            })
        case .done:
            return []
        }
    }

    var highlightFlagButton: Bool {
        step == .flag && game.mode != .flag
    }

    // MARK: - Tap routing

    func handleTap(at index: Int) {
        let cell = game.cells[index]
        switch step {
        case .forage:
            if index == TutorialFlow.startTile {
                game.reveal(at: index)
                step = .numbers
                clearNudge()
            } else {
                nudge("Let's begin with the highlighted tile up top.")
            }
        case .numbers:
            if !cell.isRevealed {
                nudge("Got the idea? Tap \"Got it\" to keep going.")
            }
        case .flag:
            if game.mode != .flag {
                nudge("First tap \"Flag\" below to switch modes.")
                return
            }
            if index == TutorialFlow.flagTile {
                game.toggleFlag(at: index)
                step = .clear
                game.mode = .forage
                clearNudge()
            } else {
                nudge("Tap the highlighted tile — that's where the mushroom hides.")
            }
        case .clear:
            handleClearTap(at: index, cell: cell)
        case .done:
            break
        }
    }

    func handleLongPress(at index: Int) {
        // In tutorial we don't allow free-form long-press flagging — flow controls it.
        // Only effective during clear, and only on mine cells.
        guard step == .clear else { return }
        let cell = game.cells[index]
        guard !cell.isRevealed else { return }
        if cell.isMine {
            game.toggleFlag(at: index)
        } else {
            nudge("That patch is safe — Forage it instead of flagging.")
        }
    }

    private func handleClearTap(at index: Int, cell: Cell) {
        if cell.isRevealed { return }
        if game.mode == .flag {
            if cell.isMine {
                game.toggleFlag(at: index)
            } else {
                nudge("That patch is safe — switch to Forage to dig it.")
            }
            return
        }
        if cell.isFlagged { return }
        if cell.isMine {
            nudge("Careful — that's a mushroom! Flag it instead of foraging.")
            return
        }
        game.reveal(at: index)
        if game.status == .won {
            step = .done
            clearNudge()
        }
    }

    func advance() {
        if step == .numbers {
            step = .flag
            clearNudge()
        }
    }

    // MARK: - Nudges

    private func nudge(_ msg: String) {
        nudgeTask?.cancel()
        nudgeMessage = msg
        nudgeTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(2800))
            if Task.isCancelled { return }
            if self?.nudgeMessage == msg {
                self?.nudgeMessage = nil
            }
        }
    }

    private func clearNudge() {
        nudgeTask?.cancel()
        nudgeMessage = nil
    }
}

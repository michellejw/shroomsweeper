import Foundation

struct Cell: Identifiable, Hashable {
    let id: Int
    var isMine: Bool = false
    var neighborMines: Int = 0
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var isExploded: Bool = false
}

enum GameStatus {
    case ready
    case playing
    case won
    case lost

    var isFinished: Bool { self == .won || self == .lost }
}

enum InteractionMode {
    case forage
    case flag
}

@Observable
final class Game {
    let rows: Int
    let cols: Int
    let mineCount: Int
    let isTutorial: Bool
    private(set) var difficulty: Difficulty?
    private(set) var cells: [Cell]
    private(set) var status: GameStatus = .ready
    var mode: InteractionMode = .forage
    private(set) var elapsedSeconds: Int = 0
    // Counters that drive .sensoryFeedback in the UI.
    private(set) var flagToggleTick: Int = 0
    private(set) var winTick: Int = 0
    private(set) var loseTick: Int = 0

    var totalCells: Int { rows * cols }

    var flagsRemaining: Int {
        mineCount - cells.lazy.filter(\.isFlagged).count
    }

    convenience init(difficulty: Difficulty) {
        self.init(rows: difficulty.rows, cols: difficulty.cols, mineCount: difficulty.mineCount, difficulty: difficulty)
    }

    init(
        rows: Int,
        cols: Int,
        mineCount: Int,
        preplacedMines: Set<Int>? = nil,
        isTutorial: Bool = false,
        difficulty: Difficulty? = nil
    ) {
        self.rows = rows
        self.cols = cols
        self.mineCount = mineCount
        self.isTutorial = isTutorial
        self.difficulty = difficulty
        var initialCells = (0..<rows * cols).map { Cell(id: $0) }
        if let mines = preplacedMines {
            for i in mines { initialCells[i].isMine = true }
            // Compute neighbor counts in-place since we can't use self.neighbors before init.
            for i in initialCells.indices where !initialCells[i].isMine {
                initialCells[i].neighborMines = Game.computeNeighborMineCount(
                    at: i, rows: rows, cols: cols, cells: initialCells
                )
            }
        }
        self.cells = initialCells
        if preplacedMines != nil {
            status = .playing
        }
    }

    func reset(to newDifficulty: Difficulty? = nil) {
        guard !isTutorial else { return }
        if let newDifficulty {
            difficulty = newDifficulty
        }
        let activeDifficulty = newDifficulty ?? difficulty
        if let activeDifficulty {
            // Use the canonical sizes from Difficulty.
            cells = (0..<activeDifficulty.rows * activeDifficulty.cols).map { Cell(id: $0) }
        } else {
            cells = (0..<rows * cols).map { Cell(id: $0) }
        }
        status = .ready
        elapsedSeconds = 0
        mode = .forage
    }

    func tap(at index: Int) {
        guard !status.isFinished else { return }
        if mode == .flag {
            toggleFlag(at: index)
        } else {
            reveal(at: index)
        }
    }

    func toggleFlag(at index: Int) {
        guard !status.isFinished else { return }
        guard !cells[index].isRevealed else { return }
        cells[index].isFlagged.toggle()
        flagToggleTick &+= 1
    }

    func reveal(at index: Int) {
        guard !status.isFinished else { return }
        if status == .ready {
            placeMines(avoiding: index)
            status = .playing
        }
        let cell = cells[index]
        guard !cell.isRevealed, !cell.isFlagged else { return }
        if cell.isMine {
            if isTutorial { return }
            cells[index].isExploded = true
            for i in cells.indices where cells[i].isMine {
                cells[i].isRevealed = true
            }
            status = .lost
            loseTick &+= 1
            return
        }
        floodReveal(from: index)
        if checkWin() {
            for i in cells.indices where cells[i].isMine {
                cells[i].isFlagged = true
            }
            status = .won
            winTick &+= 1
        }
    }

    func tick() {
        guard status == .playing else { return }
        elapsedSeconds += 1
    }

    private func neighbors(of index: Int) -> [Int] {
        Game.neighborIndices(of: index, rows: rows, cols: cols)
    }

    private static func neighborIndices(of index: Int, rows: Int, cols: Int) -> [Int] {
        let r = index / cols
        let c = index % cols
        var result: [Int] = []
        result.reserveCapacity(8)
        for dr in -1...1 {
            for dc in -1...1 where !(dr == 0 && dc == 0) {
                let nr = r + dr
                let nc = c + dc
                if nr >= 0, nr < rows, nc >= 0, nc < cols {
                    result.append(nr * cols + nc)
                }
            }
        }
        return result
    }

    private static func computeNeighborMineCount(at index: Int, rows: Int, cols: Int, cells: [Cell]) -> Int {
        var count = 0
        for n in Game.neighborIndices(of: index, rows: rows, cols: cols) where cells[n].isMine {
            count += 1
        }
        return count
    }

    private func placeMines(avoiding safeIndex: Int) {
        var safeSet = Set(neighbors(of: safeIndex))
        safeSet.insert(safeIndex)
        var placed = 0
        while placed < mineCount {
            let i = Int.random(in: 0..<totalCells)
            if safeSet.contains(i) || cells[i].isMine { continue }
            cells[i].isMine = true
            placed += 1
        }
        for i in cells.indices where !cells[i].isMine {
            cells[i].neighborMines = neighbors(of: i).reduce(0) { $0 + (cells[$1].isMine ? 1 : 0) }
        }
    }

    private func floodReveal(from start: Int) {
        var stack = [start]
        while let i = stack.popLast() {
            let cell = cells[i]
            if cell.isRevealed || cell.isFlagged || cell.isMine { continue }
            cells[i].isRevealed = true
            if cells[i].neighborMines == 0 {
                for n in neighbors(of: i) where !cells[n].isRevealed && !cells[n].isMine && !cells[n].isFlagged {
                    stack.append(n)
                }
            }
        }
    }

    private func checkWin() -> Bool {
        cells.allSatisfy { $0.isMine || $0.isRevealed }
    }
}

extension Int {
    var asTimerString: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%d:%02d", m, s)
    }
}

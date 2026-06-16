import SwiftUI

struct BoardView: View {
    @Bindable var game: Game
    var highlightedCells: Set<Int> = []
    var onTap: (Int) -> Void
    var onLongPress: (Int) -> Void

    @Environment(\.palette) private var palette

    private var spacing: CGFloat {
        game.cols <= 9 ? 5 : (game.cols <= 12 ? 4 : 3.5)
    }

    var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: spacing),
            count: game.cols
        )
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(game.cells) { cell in
                CellView(
                    cell: cell,
                    cols: game.cols,
                    highlight: highlightedCells.contains(cell.id),
                    onTap: { onTap(cell.id) },
                    onLongPress: { onLongPress(cell.id) }
                )
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.boardBg)
        )
    }
}

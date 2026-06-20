import ShroomKit
import SwiftUI

enum SheetTab: String, Identifiable {
    case patch
    case scores

    var id: String { rawValue }
    var label: String {
        switch self {
        case .patch:  return "Patch"
        case .scores: return "Best times"
        }
    }
}

struct OptionsSheet: View {
    @Binding var tab: SheetTab
    @Binding var selectedDifficulty: Difficulty
    let scoreStore: ScoreStore
    let isInGame: Bool
    let onConfirm: () -> Void
    let onClose: () -> Void

    @Environment(\.palette) private var palette
    @State private var scoresFocusedDifficulty: Difficulty = .forager

    var body: some View {
        VStack(spacing: 0) {
            tabBar
                .padding(.top, 8)
                .padding(.bottom, 18)
            content
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(palette.appBg.ignoresSafeArea())
        .onAppear {
            scoresFocusedDifficulty = selectedDifficulty
        }
    }

    // MARK: Tab bar

    private var tabBar: some View {
        HStack(spacing: 5) {
            tabButton(.patch)
            tabButton(.scores)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(palette.pill)
        )
    }

    private func tabButton(_ which: SheetTab) -> some View {
        Button {
            tab = which
        } label: {
            Text(which.label)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(tab == which ? palette.text : palette.sub)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tab == which ? palette.appBg : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Content switch

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .patch:  patchTab
        case .scores: scoresTab
        }
    }

    // MARK: Patch (difficulty)

    private var patchTab: some View {
        VStack(spacing: 10) {
            ForEach(Difficulty.allCases) { difficulty in
                difficultyRow(difficulty)
            }
            Button(isInGame ? "Start new game" : "Play", action: onConfirm)
                .buttonStyle(.shroomPrimary)
            .padding(.top, 6)
        }
    }

    private func difficultyRow(_ difficulty: Difficulty) -> some View {
        SelectionCard(title: difficulty.label, subtitle: difficulty.sizeDescription,
                      isSelected: selectedDifficulty == difficulty) {
            selectedDifficulty = difficulty
        }
    }

    // MARK: Scores

    private var scoresTab: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(Difficulty.allCases) { difficulty in
                    scoreTabButton(difficulty)
                }
            }
            scoresList
        }
    }

    private func scoreTabButton(_ difficulty: Difficulty) -> some View {
        let isFocused = scoresFocusedDifficulty == difficulty
        return Button {
            scoresFocusedDifficulty = difficulty
        } label: {
            Text(difficulty.label)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(isFocused ? palette.accentText : palette.sub)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isFocused ? palette.accent : palette.pill)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var scoresList: some View {
        let scores = scoreStore.best(for: scoresFocusedDifficulty)
        return VStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { idx in
                scoreRow(rank: idx + 1, entry: idx < scores.count ? scores[idx] : nil, alternate: idx % 2 == 0)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.pill)
        )
    }

    private func scoreRow(rank: Int, entry: ScoreEntry?, alternate: Bool) -> some View {
        HStack {
            Text("#\(rank)")
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(palette.sub)
                .frame(width: 32, alignment: .leading)
            Text(entry?.initials ?? "- - -")
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .tracking(2)
                .foregroundStyle(entry == nil ? palette.sub : palette.text)
            Spacer()
            Text(entry?.seconds.asTimerString ?? "--:--")
                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                .foregroundStyle(entry == nil ? palette.sub : palette.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(alternate ? palette.tierBg : Color.clear)
        )
        .opacity(entry == nil ? 0.45 : 1)
    }
}


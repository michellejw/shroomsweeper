import SwiftUI

struct WinEntrySheet: View {
    let timeText: String
    let isRecord: Bool
    @Binding var initials: String
    let onSave: () -> Void
    let onSkip: () -> Void

    @Environment(\.palette) private var palette
    @FocusState private var initialsFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    MushroomIcon()
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isRecord ? "New record!" : "Basket full!")
                            .font(.system(.title2, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.text)
                        Text("Cleared in \(timeText) — sign it!")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(palette.sub)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 4)

                TextField("AAA", text: $initials)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 26, weight: .bold, design: .monospaced))
                    .tracking(6)
                    .foregroundStyle(palette.text)
                    .padding(.vertical, 16)
                    .frame(width: 160)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.tierBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(initialsFocused ? palette.accent : palette.tierBorder, lineWidth: 2)
                            )
                    )
                    .focused($initialsFocused)
                    .submitLabel(.done)
                    .onSubmit(onSave)
                    .onChange(of: initials) { _, newValue in
                        let cleaned = sanitize(newValue)
                        if cleaned != newValue { initials = cleaned }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Skip", action: onSkip)
                                .tint(palette.sub)
                            Spacer()
                            Button("Save", action: onSave)
                                .tint(palette.accent)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)

                HStack(spacing: 10) {
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(palette.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(palette.tierBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(palette.tierBorder, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: onSave) {
                        Text("Save")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(palette.accentText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(palette.accent)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .background(palette.appBg.ignoresSafeArea())
        .onAppear {
            Task {
                try? await Task.sleep(for: .milliseconds(250))
                initialsFocused = true
            }
        }
    }

    private func sanitize(_ raw: String) -> String {
        let upper = raw.uppercased().unicodeScalars.filter { CharacterSet.uppercaseLetters.contains($0) }
        let str = String(String.UnicodeScalarView(upper))
        return String(str.prefix(3))
    }
}

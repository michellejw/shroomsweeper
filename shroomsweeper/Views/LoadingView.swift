import SwiftUI

struct LoadingView: View {
    let message: String

    @Environment(\.palette) private var palette
    @State private var bob: Bool = false
    @State private var dotPhase: Int = 0

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            MushroomIcon()
                .frame(width: 72, height: 72)
                .scaleEffect(bob ? 1.06 : 0.94)
                .offset(y: bob ? -4 : 4)
                .animation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true), value: bob)
            HStack(spacing: 0) {
                Text(message)
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.sub)
                Text(dotString)
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.sub)
                    .frame(width: 26, alignment: .leading)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.appBg.ignoresSafeArea())
        .onAppear { bob = true }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(380))
                if Task.isCancelled { return }
                dotPhase = (dotPhase + 1) % 4
            }
        }
    }

    private var dotString: String {
        String(repeating: ".", count: dotPhase)
    }
}

#Preview {
    LoadingView(message: "Loading")
        .environment(\.palette, .forest)
}

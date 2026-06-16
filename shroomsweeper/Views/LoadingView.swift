import ShroomKit
import SwiftUI

struct LoadingView: View {
    let message: String

    var body: some View {
        ShroomKit.LoadingView(message: message) {
            MushroomIcon()
        }
    }
}

#Preview {
    LoadingView(message: "Loading")
        .environment(\.palette, .forest)
}

import Foundation
import ShroomKit

/// Read-only access to launch-argument-driven screenshot configuration.
/// All flags are inert unless `--uiScreenshotMode` is passed at launch.
enum ScreenshotMode {
    enum Target: String {
        case home
        case game
        case tutorial
        case win
        case scores
    }

    static let modeFlag = "--uiScreenshotMode"
    static let targetFlag = "--uiScreenshotTarget"
    static let appearanceFlag = "--uiAppearance"

    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains(modeFlag)
    }

    static var target: Target {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: targetFlag),
           i + 1 < args.count,
           let value = Target(rawValue: args[i + 1]) {
            return value
        }
        return .home
    }

    static var appearance: Appearance {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: appearanceFlag),
           i + 1 < args.count,
           args[i + 1] == "twilight" {
            return .twilight
        }
        return .forest
    }
}

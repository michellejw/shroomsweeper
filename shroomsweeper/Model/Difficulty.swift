import Foundation

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case forager
    case woodlander
    case mycologist

    var id: String { rawValue }

    var label: String {
        switch self {
        case .forager:    return "Forager"
        case .woodlander: return "Woodlander"
        case .mycologist: return "Mycologist"
        }
    }

    var rows: Int {
        switch self {
        case .forager:    return 9
        case .woodlander: return 13
        case .mycologist: return 16
        }
    }

    var cols: Int {
        switch self {
        case .forager:    return 9
        case .woodlander: return 10
        case .mycologist: return 11
        }
    }

    var mineCount: Int {
        switch self {
        case .forager:    return 10
        case .woodlander: return 24
        case .mycologist: return 36
        }
    }

    var sizeDescription: String {
        "\(cols) × \(rows) · \(mineCount) mushrooms"
    }

    var shortSize: String {
        "\(cols)×\(rows)"
    }
}

import Foundation

enum AppDestination: String, CaseIterable, Identifiable, Equatable {
    case home
    case rashifal
    case patro
    case family
    case pandit

    var id: String { rawValue }

    var presentationStyle: AppPresentationStyle {
        switch self {
        case .patro:
            return .pushed
        case .pandit:
            return .modal
        case .home, .rashifal, .family:
            return .tab
        }
    }
}

enum AppPresentationStyle: Equatable {
    case tab
    case pushed
    case modal
}

enum AppTab: Int, CaseIterable, Identifiable, Equatable {
    case family
    case rashifal
    case home

    var id: Int { rawValue }

    var destination: AppDestination {
        switch self {
        case .home: return .home
        case .rashifal: return .rashifal
        case .family: return .family
        }
    }

    var legacyTabIndex: Int {
        switch self {
        case .home: return 0
        case .rashifal: return 1
        case .family: return 3
        }
    }

    static func fromLaunchIndex(_ index: Int) -> AppTab {
        switch index {
        case 1: return .rashifal
        case 2: return .home
        case 3: return .family // Legacy Parivar launch index.
        default: return .family
        }
    }
}

import SwiftUI

enum DesignSystem {

    enum Colors {
        static let accentYellow = Color(red: 1, green: 0.89, blue: 0.28)
        static let navyCard = Color(red: 0.10, green: 0.12, blue: 0.39)
        static let stationRowBg = Color(red: 0.28, green: 0.28, blue: 0.28)
        static let pageTitle = Color(red: 0.19, green: 0.19, blue: 0.19)
        static let backButtonTint = Color(red: 1, green: 0.93, blue: 0.51)
        static let tabInactive = Color(red: 0.19, green: 0.19, blue: 0.19)
        static let subtitleGray = Color(red: 0.49, green: 0.45, blue: 0.45)
        static let inputPlaceholder = Color(red: 0.85, green: 0.85, blue: 0.85)
        static let statCardBg = Color.white
        static let totalTimeBg = Color(red: 0.28, green: 0.28, blue: 0.28)
        static let clockRed = Color(red: 0.97, green: 0.24, blue: 0.24)
        static let halfWhite = Color.white.opacity(0.50)
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 20
        static let cardCornerRadius: CGFloat = 12
        static let sectionSpacing: CGFloat = 16
        static let tabBarHeight: CGFloat = 62
        static let tabBarItemSpacing: CGFloat = 83
        static let buttonHeight: CGFloat = 60
        static let buttonCornerRadius: CGFloat = 50
        static let navyCornerRadius: CGFloat = 18
        static let stationRowCornerRadius: CGFloat = 8
        static let statCardCornerRadius: CGFloat = 12
        static let statCardHeight: CGFloat = 127
        static let statCardWidth: CGFloat = 112
        static let routeCardHeight: CGFloat = 176
        static let inputHeight: CGFloat = 55
    }
}

private struct CompactScreenKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isCompactScreen: Bool {
        get { self[CompactScreenKey.self] }
        set { self[CompactScreenKey.self] = newValue }
    }
}

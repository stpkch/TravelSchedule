import SwiftUI

enum AppTheme {
    static let blue = Color("Blue Universal")
    static let red = Color("Red Universal")
    static let gray = Color("Gray Universal")
    static let lightGray = Color("Light Gray")

    static let whiteDay = Color("White [day]")
    static let whiteNight = Color("White [night]")

    static let blackDay = Color("Black [day]")
    static let blackNight = Color("Black [night]")

    static let whiteUniversal = Color("White Universal")
    static let blackUniversal = Color("Black Universal")

    static let screenHorizontalPadding: CGFloat = 16

    static let storyCardWidth: CGFloat = 92
    static let storyCardHeight: CGFloat = 140

    static let searchModuleWidth: CGFloat = 343
    static let searchModuleHeight: CGFloat = 204
    static let searchCardHeight: CGFloat = 128
    static let searchFieldHeight: CGFloat = 48
    static let searchFieldGroupWidth: CGFloat = 259
    static let searchFieldGroupHeight: CGFloat = 96
    static let routeSwapButtonSize: CGFloat = 36
    static let searchButtonWidth: CGFloat = 150
    static let searchButtonHeight: CGFloat = 60

    static let searchCardCornerRadius: CGFloat = 24
    static let searchFieldGroupCornerRadius: CGFloat = 20
    static let searchButtonCornerRadius: CGFloat = 16

    static let carrierCardWidth: CGFloat = 343
    static let carrierCardHeight: CGFloat = 104
    static let carrierCompactCardHeight: CGFloat = 90
    static let carrierCardCornerRadius: CGFloat = 24
    static let carrierBottomButtonHeight: CGFloat = 60

    static let settingsRowHeight: CGFloat = 60
    static let settingsToggleWidth: CGFloat = 51
    static let settingsToggleHeight: CGFloat = 31
}

extension ColorScheme {
    var appBackground: Color {
        self == .dark ? AppTheme.blackUniversal : AppTheme.whiteDay
    }

    var appPrimaryText: Color {
        self == .dark ? AppTheme.whiteUniversal : AppTheme.blackDay
    }

    var appSecondaryText: Color {
        AppTheme.gray
    }

    var appFieldBackground: Color {
        self == .dark ? AppTheme.whiteUniversal.opacity(0.08) : AppTheme.lightGray
    }

    var appCardBackground: Color {
        self == .dark ? AppTheme.whiteUniversal.opacity(0.08) : AppTheme.lightGray
    }

    var appDivider: Color {
        AppTheme.gray
    }
}

extension View {
    func appScreenBackground(_ colorScheme: ColorScheme) -> some View {
        background(colorScheme.appBackground.ignoresSafeArea())
    }
}

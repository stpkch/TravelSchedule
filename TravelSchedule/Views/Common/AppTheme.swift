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
        self == .dark
        ? AppTheme.whiteUniversal.opacity(0.08)
        : AppTheme.lightGray
    }

    var appCardBackground: Color {
        self == .dark
        ? AppTheme.whiteUniversal.opacity(0.08)
        : AppTheme.whiteUniversal
    }

    var appDivider: Color {
        AppTheme.gray.opacity(self == .dark ? 0.35 : 0.22)
    }
}

extension View {
    func appScreenBackground(_ colorScheme: ColorScheme) -> some View {
        background(colorScheme.appBackground.ignoresSafeArea())
    }
}

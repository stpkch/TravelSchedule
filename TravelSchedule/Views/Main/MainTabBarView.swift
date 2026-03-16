import SwiftUI
import UIKit

struct MainTabBarView: View {
    private enum Tab: Hashable {
        case main
        case settings
    }

    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab: Tab = .main
    @Environment(\.colorScheme) private var colorScheme

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 20)
        UITabBarItem.appearance().imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MainScreenView()
                .environmentObject(viewModel)
                .tag(Tab.main)
                .tabItem {
                    tabIcon(
                        systemName: "arrow.up.message.fill",
                        color: selectedTab == .main ? selectedIconColor : uiColor("Gray Universal")
                    )
                    Text("")
                }

            SettingsStubView()
                .tag(Tab.settings)
                .tabItem {
                    tabIcon(
                        systemName: "gearshape.fill",
                        color: selectedTab == .settings ? selectedIconColor : uiColor("Gray Universal")
                    )
                    Text("")
                }
        }
        .toolbarBackground(colorScheme.appBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    private var selectedIconColor: UIColor {
        colorScheme == .dark ? uiColor("White Universal") : uiColor("Black [day]")
    }

    private func tabIcon(systemName: String, color: UIColor) -> Image {
        let image = UIImage(systemName: systemName)?
            .withTintColor(color, renderingMode: .alwaysOriginal)

        return Image(uiImage: image ?? UIImage())
    }

    private func uiColor(_ name: String) -> UIColor {
        UIColor(named: name) ?? .label
    }
}

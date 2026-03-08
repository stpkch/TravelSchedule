import SwiftUI

struct MainTabBarView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        TabView {
            MainScreenView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "arrow.up.message.fill")
                    Text("Главная")
                }

            SettingsStubView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Настройки")
                }
        }
    }
}

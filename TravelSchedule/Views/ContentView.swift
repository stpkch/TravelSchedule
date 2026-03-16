import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @AppStorage("isDarkModeOverrideEnabled") private var isDarkModeOverrideEnabled = false

    var body: some View {
        ZStack {
            MainTabBarView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(isDarkModeOverrideEnabled ? .dark : .light)
        .task {
            guard showSplash else { return }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeOut(duration: 0.3)) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}

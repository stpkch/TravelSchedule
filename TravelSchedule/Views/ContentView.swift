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
        .preferredColorScheme(isDarkModeOverrideEnabled ? .dark : nil)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct SettingsStubView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Экран настроек")
                    .font(.title.weight(.bold))
                Spacer()
            }
            .navigationTitle("Настройки")
        }
    }
}

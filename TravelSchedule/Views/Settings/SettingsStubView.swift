import SwiftUI

struct SettingsStubView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkModeOverrideEnabled") private var isDarkModeOverrideEnabled = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Toggle("Темная тема", isOn: $isDarkModeOverrideEnabled)
                    .tint(AppTheme.blue)
                    .foregroundStyle(colorScheme.appPrimaryText)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                Divider()
                    .overlay(colorScheme.appDivider)

                NavigationLink {
                    AgreementView()
                } label: {
                    HStack(spacing: 12) {
                        Text("Пользовательское соглашение")
                            .foregroundStyle(colorScheme.appPrimaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(colorScheme.appPrimaryText)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 60)
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(spacing: 8) {
                    Text("Приложение использует API «Яндекс.Расписания»")
                    Text("Версия 1.0 (beta)")
                }
                .font(.footnote)
                .foregroundStyle(AppTheme.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
            }
            .appScreenBackground(colorScheme)
            .tint(colorScheme.appPrimaryText)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

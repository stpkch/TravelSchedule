import SwiftUI

struct SettingsStubView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkModeOverrideEnabled") private var isDarkModeOverrideEnabled = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 32)

                darkModeRow

                agreementRow

                Spacer()

                footer
                    .padding(.bottom, 24)
            }
            .appScreenBackground(colorScheme)
            .navigationBarHidden(true)
        }
    }

    private var darkModeRow: some View {
        HStack(spacing: 4) {
            Text("Темная тема")
                .font(.system(size: 17, weight: .regular))
                .tracking(-0.41)
                .foregroundStyle(colorScheme.appPrimaryText)

            Spacer()

            FigmaToggle(isOn: $isDarkModeOverrideEnabled)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
    }

    private var agreementRow: some View {
        NavigationLink {
            AgreementView()
        } label: {
            HStack(spacing: 4) {
                Text("Пользовательское соглашение")
                    .font(.system(size: 17, weight: .regular))
                    .tracking(-0.41)
                    .foregroundStyle(colorScheme.appPrimaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(colorScheme.appPrimaryText)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Text("Приложение использует API «Яндекс.Расписания»")
                .font(.system(size: 12, weight: .regular))
                .tracking(0.4)
                .foregroundStyle(colorScheme == .dark ? AppTheme.whiteUniversal : AppTheme.blackDay)

            Text("Версия 1.0 (beta)")
                .font(.system(size: 12, weight: .regular))
                .tracking(0.4)
                .foregroundStyle(colorScheme == .dark ? AppTheme.whiteUniversal : AppTheme.blackDay)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

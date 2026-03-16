import SwiftUI

struct SettingsStubView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = SettingsViewModel()

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

    private var darkModeBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isDarkModeEnabled },
            set: { viewModel.setDarkMode($0) }
        )
    }

    private var darkModeRow: some View {
        HStack(spacing: 4) {
            Text(viewModel.darkModeTitle)
                .font(.system(size: 17, weight: .regular))
                .tracking(-0.41)
                .foregroundStyle(colorScheme.appPrimaryText)

            Spacer()

            FigmaToggle(isOn: darkModeBinding)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
    }

    private var agreementRow: some View {
        NavigationLink {
            AgreementView()
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.agreementTitle)
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
            Text(viewModel.apiDescriptionText)
                .font(.system(size: 12, weight: .regular))
                .tracking(0.4)
                .foregroundStyle(colorScheme == .dark ? AppTheme.whiteUniversal : AppTheme.blackDay)

            Text(viewModel.versionText)
                .font(.system(size: 12, weight: .regular))
                .tracking(0.4)
                .foregroundStyle(colorScheme == .dark ? AppTheme.whiteUniversal : AppTheme.blackDay)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

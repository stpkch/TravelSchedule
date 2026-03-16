import SwiftUI
import UIKit

struct CarrierStubView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CarrierDetailsViewModel

    private let horizontalInset: CGFloat = 24
    private let logoCardCornerRadius: CGFloat = 24
    private let logoCardHeight: CGFloat = 104

    init(carrier: Carrier) {
        _viewModel = StateObject(wrappedValue: CarrierDetailsViewModel(carrier: carrier))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    carrierLogoCard
                        .padding(.top, 24)

                    Text(viewModel.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(colorScheme.appPrimaryText)
                        .padding(.top, 24)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 24)
                    }

                    infoBlock(title: "E-mail", value: viewModel.emailText)
                        .padding(.top, 24)

                    infoBlock(title: "Телефон", value: viewModel.phoneText)
                        .padding(.top, 24)

                    infoBlock(title: "Сайт", value: viewModel.websiteText)
                        .padding(.top, 24)

                    if let errorMessage = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(errorMessage)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(AppTheme.gray)

                            Button {
                                Task {
                                    appViewModel.selectedError = nil
                                    if let errorState = await viewModel.retryLoadDetails() {
                                        appViewModel.selectedError = errorState
                                    }
                                }
                            } label: {
                                Text("Повторить")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.whiteUniversal)
                                    .frame(height: 44)
                                    .frame(maxWidth: 180)
                                    .background(AppTheme.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 16)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, horizontalInset)
                .padding(.bottom, 24)
            }
        }
        .appScreenBackground(colorScheme)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task {
            appViewModel.selectedError = nil
            if let errorState = await viewModel.loadDetails() {
                appViewModel.selectedError = errorState
            }
        }
    }

    private var topBar: some View {
        ZStack {
            Text("Информация о перевозчике")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(colorScheme.appPrimaryText)
                .lineLimit(1)
                .padding(.horizontal, 44)

            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(colorScheme.appPrimaryText)
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, horizontalInset)
        .frame(height: 56)
    }

    private var carrierLogoCard: some View {
        RoundedRectangle(cornerRadius: logoCardCornerRadius, style: .continuous)
            .fill(Color.white)
            .frame(height: logoCardHeight)
            .overlay {
                carrierLogo
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
            }
    }

    private var carrierLogo: some View {
        Group {
            if let logoURL = viewModel.carrier.logoURL,
               let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        fallbackLogo
                    }
                }
            } else {
                fallbackLogo
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fallbackLogo: some View {
        Group {
            if let image = UIImage(named: viewModel.cardLogoAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(viewModel.cardLogoAssetName)
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    private func infoBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(colorScheme.appPrimaryText)

            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppTheme.gray)
        }
    }
}

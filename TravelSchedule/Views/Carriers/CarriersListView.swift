import SwiftUI

struct CarriersListView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var path: [AppRoute]

    @StateObject private var viewModel = CarriersListViewModel()

    private var reloadToken: String {
        [
            appViewModel.fromStation?.id ?? "",
            appViewModel.toStation?.id ?? "",
            String(appViewModel.showTransfers)
        ].joined(separator: "|")
    }

    private var localFilterToken: String {
        [
            String(appViewModel.isMorning),
            String(appViewModel.isDay),
            String(appViewModel.isEvening),
            String(appViewModel.isNight),
            String(appViewModel.showTransfers)
        ].joined(separator: "|")
    }

    var body: some View {
        VStack(spacing: 8) {
            topBar
            routeTitleBlock

            if viewModel.isLoading && viewModel.filteredCarriers.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if let errorMessage = viewModel.errorMessage, viewModel.filteredCarriers.isEmpty {
                Spacer()

                VStack(spacing: 16) {
                    Text(errorMessage)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(colorScheme.appPrimaryText)

                    Button {
                        Task {
                            appViewModel.selectedError = nil
                            if let errorState = await viewModel.retry(
                                from: appViewModel.fromStation,
                                to: appViewModel.toStation
                            ) {
                                appViewModel.selectedError = errorState
                            }
                        }
                    } label: {
                        Text("Повторить")
                            .font(.headline)
                            .foregroundStyle(AppTheme.whiteUniversal)
                            .frame(height: 48)
                            .frame(maxWidth: 220)
                            .background(AppTheme.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            } else if viewModel.filteredCarriers.isEmpty {
                Spacer()

                Text("Вариантов нет")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colorScheme.appPrimaryText)

                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredCarriers) { carrier in
                            Button {
                                path.append(.carrierStub(carrier))
                            } label: {
                                CarrierRowView(carrier: carrier)
                                    .frame(width: AppTheme.carrierCardWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, AppTheme.carrierBottomButtonHeight + 16)
                }
            }
        }
        .appScreenBackground(colorScheme)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            if !viewModel.filteredCarriers.isEmpty {
                Button {
                    path.append(.filters)
                } label: {
                    Text("Уточнить время")
                        .font(.system(size: 17, weight: .bold))
                        .tracking(0)
                        .foregroundStyle(AppTheme.whiteUniversal)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.carrierBottomButtonHeight)
                        .background(AppTheme.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(colorScheme.appBackground)
            }
        }
        .task(id: reloadToken) {
            appViewModel.selectedError = nil
            viewModel.updateFilters(
                isMorning: appViewModel.isMorning,
                isDay: appViewModel.isDay,
                isEvening: appViewModel.isEvening,
                isNight: appViewModel.isNight,
                showTransfers: appViewModel.showTransfers
            )

            if let errorState = await viewModel.loadCarriers(
                from: appViewModel.fromStation,
                to: appViewModel.toStation
            ) {
                appViewModel.selectedError = errorState
            }
        }
        .onChange(of: localFilterToken) { _ in
            viewModel.updateFilters(
                isMorning: appViewModel.isMorning,
                isDay: appViewModel.isDay,
                isEvening: appViewModel.isEvening,
                isNight: appViewModel.isNight,
                showTransfers: appViewModel.showTransfers
            )
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                if !path.isEmpty {
                    path.removeLast()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(colorScheme.appPrimaryText)
                    .frame(width: 17, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .frame(height: 42)
    }

    private var routeTitleBlock: some View {
        Text(appViewModel.routeTitle)
            .font(.system(size: 24, weight: .bold))
            .tracking(0)
            .foregroundStyle(colorScheme.appPrimaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 87, alignment: .topLeading)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
    }
}

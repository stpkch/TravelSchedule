import SwiftUI

struct StationSelectionView: View {
    let field: SelectionField

    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: StationSelectionViewModel

    init(city: City, field: SelectionField) {
        self.field = field
        _viewModel = StateObject(wrappedValue: StationSelectionViewModel(city: city))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if viewModel.isLoading && viewModel.stations.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if let errorMessage = viewModel.errorMessage, viewModel.stations.isEmpty {
                Spacer()

                VStack(spacing: 16) {
                    Text(errorMessage)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(colorScheme.appPrimaryText)

                    Button {
                        Task {
                            appViewModel.selectedError = nil
                            if let errorState = await viewModel.retry() {
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
            } else if viewModel.filteredStations.isEmpty {
                Spacer()
                Text("Станция не найдена")
                    .font(.title.weight(.bold))
                    .foregroundStyle(colorScheme.appPrimaryText)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredStations) { station in
                            Button {
                                appViewModel.selectStation(station, for: field)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(station.name)
                                        .foregroundStyle(colorScheme.appPrimaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(colorScheme.appPrimaryText)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 56)
                            }
                            .buttonStyle(.plain)

                            Rectangle()
                                .fill(colorScheme.appDivider)
                                .frame(height: 0.5)
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .appScreenBackground(colorScheme)
        .tint(colorScheme.appPrimaryText)
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .task {
            appViewModel.selectedError = nil
            if let errorState = await viewModel.loadStations() {
                appViewModel.selectedError = errorState
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.gray)

            TextField("Введите запрос", text: $viewModel.searchText)
                .foregroundStyle(colorScheme.appPrimaryText)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(colorScheme.appFieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}

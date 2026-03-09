import SwiftUI

struct MainScreenView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedField: SelectionField = .from
    @State private var showCitySelection = false
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                storiesSection

                routeSection

                if viewModel.canSearch {
                    Button {
                        path.append(.carriers)
                    } label: {
                        Text("Найти")
                            .font(.headline)
                            .foregroundStyle(AppTheme.whiteUniversal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(AppTheme.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)
                }

                Spacer()
            }
            .appScreenBackground(colorScheme)
            .tint(colorScheme.appPrimaryText)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .stationSelection(let field, let city):
                    StationSelectionView(city: city, field: field)
                        .environmentObject(viewModel)
                        .toolbar(.hidden, for: .tabBar)

                case .carriers:
                    CarriersListView(path: $path)
                        .environmentObject(viewModel)
                        .toolbar(.hidden, for: .tabBar)

                case .filters:
                    FilterView()
                        .environmentObject(viewModel)
                        .toolbar(.hidden, for: .tabBar)

                case .carrierStub(let carrier):
                    CarrierStubView(carrier: carrier)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .fullScreenCover(isPresented: $showCitySelection) {
                CitySelectionView(
                    field: selectedField,
                    onSelectCity: { city in
                        viewModel.selectCity(city, for: selectedField)
                        showCitySelection = false
                        path.append(.stationSelection(selectedField, city))
                    }
                )
            }
            .fullScreenCover(item: Binding(
                get: { viewModel.selectedError.map(ErrorWrapper.init) },
                set: { _ in viewModel.selectedError = nil }
            )) { wrapper in
                switch wrapper.state {
                case .noInternet:
                    NoInternetView {
                        viewModel.selectedError = nil
                    }
                case .serverError:
                    ServerErrorView {
                        viewModel.selectedError = nil
                    }
                }
            }
        }
    }

    private var storiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MockData.stories) { story in
                    StoryCardView(story: story)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    private var routeSection: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.blue)
                .frame(height: 140)

            VStack(spacing: 0) {
                routeButton(
                    title: viewModel.shortPointText(city: viewModel.fromCity, station: viewModel.fromStation),
                    placeholder: "Откуда"
                ) {
                    selectedField = .from
                    showCitySelection = true
                }

                Divider()

                routeButton(
                    title: viewModel.shortPointText(city: viewModel.toCity, station: viewModel.toStation),
                    placeholder: "Куда"
                ) {
                    selectedField = .to
                    showCitySelection = true
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 76)
            .padding(.vertical, 16)

            Button {
                viewModel.swapRoute()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title3)
                    .foregroundStyle(AppTheme.blue)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.whiteUniversal)
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private func routeButton(
        title: String,
        placeholder: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title.isEmpty ? placeholder : title)
                    .foregroundStyle(title.isEmpty ? AppTheme.gray : AppTheme.blackDay)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(AppTheme.whiteUniversal)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

private struct ErrorWrapper: Identifiable {
    let id = UUID()
    let state: AppErrorState

    init(_ state: AppErrorState) {
        self.state = state
    }
}

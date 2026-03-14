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

                searchModule
                    .padding(.top, 24)

                Spacer(minLength: 0)
            }
            .appScreenBackground(colorScheme)
            .tint(colorScheme.appPrimaryText)
            .navigationBarHidden(true)
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
            .padding(.horizontal, AppTheme.screenHorizontalPadding)
            .padding(.top, 16)
        }
    }

    private var searchModule: some View {
        VStack(spacing: 16) {
            routeSection

            if viewModel.canSearch {
                Button {
                    path.append(.carriers)
                } label: {
                    Text("Найти")
                        .font(.system(size: 17, weight: .bold))
                        .tracking(0)
                        .foregroundStyle(AppTheme.whiteUniversal)
                        .frame(width: AppTheme.searchButtonWidth, height: AppTheme.searchButtonHeight)
                        .background(AppTheme.blue)
                        .clipShape(
                            RoundedRectangle(cornerRadius: AppTheme.searchButtonCornerRadius)
                        )
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: AppTheme.searchButtonWidth, height: AppTheme.searchButtonHeight)
            }
        }
        .frame(width: AppTheme.searchModuleWidth, height: AppTheme.searchModuleHeight)
    }

    private var routeSection: some View {
        RoundedRectangle(cornerRadius: AppTheme.searchCardCornerRadius)
            .fill(AppTheme.blue)
            .frame(width: AppTheme.searchModuleWidth, height: AppTheme.searchCardHeight)
            .overlay {
                HStack(spacing: 16) {
                    routeFieldsGroup

                    Button {
                        viewModel.swapRoute()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppTheme.whiteUniversal)
                                .frame(width: 36, height: 36)

                            Image("changeButton")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 16)
            }
    }

    private var routeFieldsGroup: some View {
        RoundedRectangle(cornerRadius: AppTheme.searchFieldGroupCornerRadius)
            .fill(AppTheme.whiteUniversal)
            .frame(
                width: AppTheme.searchFieldGroupWidth,
                height: AppTheme.searchFieldGroupHeight
            )
            .overlay {
                VStack(spacing: 0) {
                    routeTextRow(
                        title: viewModel.shortPointText(
                            city: viewModel.fromCity,
                            station: viewModel.fromStation
                        ),
                        placeholder: "Откуда"
                    ) {
                        selectedField = .from
                        showCitySelection = true
                    }

                    routeTextRow(
                        title: viewModel.shortPointText(
                            city: viewModel.toCity,
                            station: viewModel.toStation
                        ),
                        placeholder: "Куда"
                    ) {
                        selectedField = .to
                        showCitySelection = true
                    }
                }
            }
    }

    private func routeTextRow(
        title: String,
        placeholder: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title.isEmpty ? placeholder : title)
                    .font(.system(size: 17, weight: .regular))
                    .tracking(-0.41)
                    .foregroundStyle(title.isEmpty ? AppTheme.gray : AppTheme.blackUniversal)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: AppTheme.searchFieldHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ErrorWrapper: Identifiable {
    let id = UUID()
    let state: AppErrorState

    init(_ state: AppErrorState) {
        self.state = state
    }
}

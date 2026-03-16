import SwiftUI

struct MainScreenView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = MainScreenViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
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
                        .environmentObject(appViewModel)
                        .toolbar(.hidden, for: .tabBar)

                case .carriers:
                    CarriersListView(path: $viewModel.path)
                        .environmentObject(appViewModel)
                        .toolbar(.hidden, for: .tabBar)

                case .filters:
                    FilterView()
                        .environmentObject(appViewModel)
                        .toolbar(.hidden, for: .tabBar)

                case .carrierStub(let carrier):
                    CarrierStubView(carrier: carrier)
                        .environmentObject(appViewModel)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showCitySelection) {
                CitySelectionView(
                    field: viewModel.selectedField,
                    onSelectCity: { city in
                        viewModel.handleSelectedCity(city, appViewModel: appViewModel)
                    }
                )
                .environmentObject(appViewModel)
            }
            .fullScreenCover(isPresented: $viewModel.isStoriesPresented) {
                StoriesScreenView(
                    stories: MockData.stories,
                    startIndex: viewModel.selectedStoryIndex
                ) { index in
                    viewModel.markStoryViewed(index)
                }
            }
            .fullScreenCover(item: Binding(
                get: { appViewModel.selectedError.map(ErrorWrapper.init) },
                set: { _ in appViewModel.selectedError = nil }
            )) { wrapper in
                switch wrapper.state {
                case .noInternet:
                    NoInternetView {
                        viewModel.closeError(appViewModel: appViewModel)
                    }
                case .serverError:
                    ServerErrorView {
                        viewModel.closeError(appViewModel: appViewModel)
                    }
                }
            }
        }
    }

    private var storiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.storiesPreviewOrder.enumerated()), id: \.offset) { _, storyIndex in
                    let story = MockData.stories[storyIndex]

                    Button {
                        viewModel.openStories(at: storyIndex)
                    } label: {
                        StoryCardView(
                            story: story,
                            isViewed: viewModel.viewedStoryIndices.contains(storyIndex)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.screenHorizontalPadding)
            .padding(.top, 16)
        }
    }

    private var searchModule: some View {
        VStack(spacing: 16) {
            routeSection

            if appViewModel.canSearch {
                Button {
                    viewModel.openCarriers()
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
                        appViewModel.swapRoute()
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
                        title: appViewModel.shortPointText(
                            city: appViewModel.fromCity,
                            station: appViewModel.fromStation
                        ),
                        placeholder: "Откуда"
                    ) {
                        viewModel.openCitySelection(for: .from)
                    }

                    routeTextRow(
                        title: appViewModel.shortPointText(
                            city: appViewModel.toCity,
                            station: appViewModel.toStation
                        ),
                        placeholder: "Куда"
                    ) {
                        viewModel.openCitySelection(for: .to)
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
